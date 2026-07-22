import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse
from app.models import SearchRequest, SearchResponse
from app.db import get_db, get_documents_by_ids, delete_document, init_db
from app.es import search_documents, delete_document_from_index, es_client, init_index
from app.converters import row_to_document
from app.config import settings
from app.load_data import load_csv_from_file
from app.ui import render_page
import asyncio

logging.basicConfig(
    level=settings.log_level,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger(__name__)

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
    if not query:
        return render_page()
    try:
        ids, total = await search_documents(query, settings.search_size, offset=0)
        async with get_db() as db:
            rows = await get_documents_by_ids(db, ids)
            docs = [row_to_document(r) for r in rows]
            docs.sort(key=lambda d: d.created_date, reverse=True)
        return render_page(query=query, results=docs)
    except Exception as e:
        logger.error(f"Search UI error: {e}")
        return render_page(query=query, error="Ошибка выполнения поиска")

@app.get("/health", include_in_schema=False)
async def health_check():
    return {"status": "ok"}

@app.post("/search", response_model=SearchResponse)
async def search(request: SearchRequest):
    logger.info("Search query: %s (limit=%s, offset=%s)", request.query, request.limit, request.offset)
    ids, total = await search_documents(request.query, request.limit, request.offset)
    async with get_db() as db:
        rows = await get_documents_by_ids(db, ids)
        docs = [row_to_document(r) for r in rows]
        docs.sort(key=lambda d: d.created_date, reverse=True)
    logger.info(f"Returning {len(docs)} documents, total {total}")
    return SearchResponse(results=docs, total=total)

@app.delete("/documents/{doc_id}")
async def delete_doc(doc_id: int):
    logger.info("Deleting document %s", doc_id)
    async with get_db() as db:
        db_ok = await delete_document(db, doc_id)
        es_ok = await delete_document_from_index(doc_id)
    if not db_ok and not es_ok:
        raise HTTPException(status_code=404, detail="Документ не найден")
    return {"status": "deleted"}