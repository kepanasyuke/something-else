import pytest
import json
from app.db import init_db, insert_many, get_documents_by_ids, delete_document, get_db

@pytest.mark.asyncio
async def test_init_db():
    await init_db()
    async with get_db() as db:
        cur = await db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='documents'")
        assert await cur.fetchone() is not None

@pytest.mark.asyncio
async def test_insert_many(sample_docs):
    await init_db()
    async with get_db() as db:
        await insert_many(db, sample_docs)
        cur = await db.execute("SELECT COUNT(*) FROM documents")
        assert (await cur.fetchone())[0] == 2

@pytest.mark.asyncio
async def test_get_documents_by_ids(sample_docs):
    await init_db()
    async with get_db() as db:
        await insert_many(db, sample_docs)
        docs = await get_documents_by_ids(db, [1, 2])
        assert len(docs) == 2
        assert docs[0]["id"] == 1
        assert json.loads(docs[0]["rubrics"]) == ["политика", "экономика"]

@pytest.mark.asyncio
async def test_delete_document(sample_docs):
    await init_db()
    async with get_db() as db:
        await insert_many(db, sample_docs)
        assert await delete_document(db, 1) is True
        cur = await db.execute("SELECT COUNT(*) FROM documents")
        assert (await cur.fetchone())[0] == 1
        assert await delete_document(db, 1) is False

@pytest.mark.asyncio
async def test_insert_many_empty():
    await init_db()
    async with get_db() as db:
        await insert_many(db, [])
        cur = await db.execute("SELECT COUNT(*) FROM documents")
        assert (await cur.fetchone())[0] == 0

@pytest.mark.asyncio
async def test_get_documents_by_ids_empty():
    await init_db()
    async with get_db() as db:
        docs = await get_documents_by_ids(db, [])
        assert docs == []