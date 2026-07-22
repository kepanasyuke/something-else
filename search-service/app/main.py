import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException
from app.models import SearchRequest, SearchResponse
from app.db import get_db, get_documents_by_ids, delete_document, init_db
from app.es import search_documents, delete_document_from_index, es_client, init_index
from app.converters import row_to_document
from app.config import settings
from app.load_data import load_csv_from_file
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

@app.get("/health", include_in_schema=False)
async def health_check():
    return {"status": "ok"}

@app.post("/search", response_model=SearchResponse)
async def search(request: SearchRequest, db=Depends(get_db)):
    logger.info("Search query: %s", request.query)
    ids = await search_documents(request.query, settings.search_size)
    rows = await get_documents_by_ids(db, ids)
    docs = [row_to_document(r) for r in rows]
    docs.sort(key=lambda d: d.created_date, reverse=True)
    logger.info("Returning %s documents", len(docs))
    return SearchResponse(results=docs)

@app.delete("/documents/{doc_id}")
async def delete_doc(doc_id: int, db=Depends(get_db)):
    logger.info("Deleting document %s", doc_id)
    db_ok, es_ok = await asyncio.gather(
        delete_document(db, doc_id),
        delete_document_from_index(doc_id)
    )
    if not db_ok and not es_ok:
        raise HTTPException(status_code=404, detail="Документ не найден")
    logger.info("Document %s deleted", doc_id)
    return {"status": "deleted"}