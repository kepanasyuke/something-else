import pytest
from unittest.mock import AsyncMock, patch
from app.es import init_index, bulk_index_documents, search_documents, delete_document_from_index

@pytest.mark.asyncio
async def test_init_index():
    with patch("app.es.es_client") as mock_es:
        mock_es.indices.exists = AsyncMock(return_value=False)
        mock_es.indices.create = AsyncMock()
        await init_index()
        mock_es.indices.create.assert_called_once()

@pytest.mark.asyncio
async def test_bulk_index_documents():
    docs = [{"id": 1, "text": "hello"}, {"id": 2, "text": "world"}]
    with patch("app.es.async_bulk", new_callable=AsyncMock) as mock_bulk:
        mock_bulk.return_value = (2, [])
        success = await bulk_index_documents(docs)
        assert success == 2
        mock_bulk.assert_called_once()

@pytest.mark.asyncio
async def test_search_documents():
    with patch("app.es.es_client") as mock_es:
        mock_es.search = AsyncMock(return_value={
            "hits": {"hits": [{"_source": {"id": 1}}, {"_source": {"id": 2}}]}
        })
        ids = await search_documents("test", size=10)
        assert ids == [1, 2]

@pytest.mark.asyncio
async def test_search_documents_es_error():
    with patch("app.es.es_client") as mock_es:
        mock_es.search = AsyncMock(side_effect=Exception("Connection refused"))
        ids = await search_documents("test", size=10)
        assert ids == []

@pytest.mark.asyncio
async def test_delete_document_from_index():
    with patch("app.es.es_client") as mock_es:
        mock_es.delete = AsyncMock(return_value={"result": "deleted"})
        assert await delete_document_from_index(1) is True
        mock_es.delete = AsyncMock(return_value={"result": "not_found"})
        assert await delete_document_from_index(2) is False

@pytest.mark.asyncio
async def test_delete_document_from_index_es_error():
    with patch("app.es.es_client") as mock_es:
        mock_es.delete = AsyncMock(side_effect=Exception("Timeout"))
        assert await delete_document_from_index(1) is False