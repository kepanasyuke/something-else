import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from app.models import SearchRequest, SearchResponse
from app.db import get_db, get_documents_by_ids, delete_document, init_db
from app.es import search_documents, delete_document_from_index, es_client, init_index
from app.converters import row_to_document
from app.config import settings
from app.load_data import load_csv_from_file
from app.ui import render_page

logging.basicConfig(
    level=settings.log_level,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


async def _fetch_documents_by_ids(ids: list[int]) -> list:
    docs = []
    if ids:
        async with get_db() as db:
            rows = await get_documents_by_ids(db, ids)
            docs = [row_to_document(r) for r in rows]
            docs.sort(key=lambda d: d.created_date, reverse=True)
    return docs


async def _delete_document_from_db(doc_id: int) -> bool:
    async with get_db() as db:
        return await delete_document(db, doc_id)


def _build_delete_response(db_ok: bool, es_ok: bool) -> tuple[int, dict]:
    if db_ok and es_ok:
        status_code = 200
        content = {"status": "deleted"}
    elif db_ok or es_ok:
        status_code = 200
        content = {"status": "partially_deleted", "detail": "Документ удалён частично"}
    else:
        status_code = 404
        content = {"detail": "Документ не найден"}
    return status_code, content


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    await init_index()
    async with get_db() as db:
        cur = await db.execute("SELECT COUNT(*) FROM documents")
        count = (await cur.fetchone())[0]
    if count == 0 and settings.csv_path.exists():
        logger.info("Auto-loading data from %s", settings.csv_path)
        await load_csv_from_file(settings.csv_path)
    else:
        logger.info("Database contains %s documents, skip auto-load", count)
    yield
    await es_client.close()
    logger.info("ES client closed")


app = FastAPI(title="Search Service", version="1.0", lifespan=lifespan)


@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    query = request.query_params.get("query", "").strip()
    result = render_page()
    if query:
        try:
            ids, _ = await search_documents(query, settings.search_size, offset=0)
            docs = await _fetch_documents_by_ids(ids)
            result = render_page(query=query, results=docs)
        except Exception as e:
            logger.error(f"Search UI error: {e}")
            result = render_page(query=query, error="Ошибка выполнения поиска")
    return result


@app.get("/health", include_in_schema=False)
async def health_check():
    return {"status": "ok"}


@app.post("/search", response_model=SearchResponse)
async def search_endpoint(request: SearchRequest):
    logger.info(
        "Search query: %s (limit=%s, offset=%s)",
        request.query,
        request.limit,
        request.offset,
    )
    ids, total = await search_documents(request.query, request.limit, request.offset)
    docs = await _fetch_documents_by_ids(ids)
    logger.info(f"Returning {len(docs)} documents, total {total}")
    return SearchResponse(results=docs, total=total)


@app.delete("/documents/{doc_id}")
async def delete_doc(doc_id: int):
    logger.info("Deleting document %s", doc_id)
    db_ok = await _delete_document_from_db(doc_id)
    es_ok = await delete_document_from_index(doc_id)
    status_code, content = _build_delete_response(db_ok, es_ok)
    return JSONResponse(status_code=status_code, content=content)
