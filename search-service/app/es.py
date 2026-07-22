from elasticsearch import AsyncElasticsearch
from elasticsearch.helpers import async_bulk
import logging
from app.config import settings

logger = logging.getLogger(__name__)

es_client = AsyncElasticsearch(
    [settings.es_host],
    retry_on_timeout=True,
    max_retries=3,
    request_timeout=settings.es_request_timeout,
)


async def init_index() -> None:
    try:
        if not await es_client.indices.exists(index=settings.es_index):
            await es_client.indices.create(
                index=settings.es_index,
                mappings={
                    "properties": {
                        "id": {"type": "integer"},
                        "text": {"type": "text", "analyzer": "russian"},
                    }
                },
            )
            logger.info("Index %s created", settings.es_index)
    except Exception as e:
        logger.error("ES init failed: %s", e)
        raise


async def bulk_index_documents(docs: list[dict], refresh: bool = True) -> int:
    success = 0
    if docs:
        actions = (
            {
                "_index": settings.es_index,
                "_id": d["id"],
                "_source": {"id": d["id"], "text": d["text"]},
            }
            for d in docs
        )
        success, _ = await async_bulk(
            es_client,
            actions,
            refresh="wait_for" if refresh else False,
            chunk_size=settings.es_chunk_size,
            request_timeout=settings.es_request_timeout,
        )
        logger.info("Indexed %s documents", success)
    elif refresh:
        await es_client.indices.refresh(index=settings.es_index)
    return success


async def search_documents(
    query: str, size: int, offset: int = 0
) -> tuple[list[int], int]:
    ids = []
    total = 0
    try:
        resp = await es_client.search(
            index=settings.es_index,
            body={
                "query": {"match": {"text": query}},
                "from": offset,
                "size": size,
                "_source": ["id"],
                "track_total_hits": True,
            },
        )
        hits = resp.get("hits", {})
        total = hits.get("total", {}).get("value", 0)
        ids = [int(h["_source"]["id"]) for h in hits.get("hits", [])]
        logger.info("ES search found %s IDs, total %s", len(ids), total)
    except Exception as e:
        logger.error("ES search failed: %s", e)
    return ids, total


async def delete_document_from_index(doc_id: int) -> bool:
    deleted = False
    try:
        resp = await es_client.delete(index=settings.es_index, id=doc_id, ignore=[404])
        deleted = resp.get("result") == "deleted"
        if deleted:
            logger.info("Document %s deleted from ES", doc_id)
    except Exception as e:
        logger.error("ES delete failed: %s", e)
    return deleted
