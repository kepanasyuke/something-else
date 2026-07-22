import json
from datetime import datetime
from pathlib import Path
from unittest.mock import AsyncMock, patch

import aiosqlite
import pytest
from elasticsearch import AsyncElasticsearch
from httpx import AsyncClient

from app.config import settings
from app.converters import parse_date, row_to_document
from app.db import delete_document, get_documents_by_ids, insert_many
from app.es import bulk_index_documents, delete_document_from_index, init_index, search_documents
from app.load_data import _build_document, _parse_rubrics
from app.main import app
from app.models import Document
from app.ui import render_page


@pytest.fixture
def mock_es():
    mock = AsyncMock()
    mock.indices = AsyncMock()
    mock.indices.exists = AsyncMock(return_value=False)
    mock.indices.create = AsyncMock(return_value={"acknowledged": True})
    mock.indices.refresh = AsyncMock(return_value={})
    mock.search = AsyncMock(return_value={
        "hits": {
            "total": {"value": 2},
            "hits": [
                {"_source": {"id": 1}},
                {"_source": {"id": 2}}
            ]
        }
    })
    mock.delete = AsyncMock(return_value={"result": "deleted"})
    return mock


# ============================================================
# CONFIG TESTS
# ============================================================

def test_settings_defaults():
    assert settings.database_url == "./data/documents.db"
    assert settings.es_host == "http://localhost:9200"
    assert settings.es_index == "documents"
    assert settings.search_size == 20
    assert settings.batch_size == 1000
    assert settings.log_level == "INFO"
    assert settings.sqlite_synchronous == "NORMAL"
    assert settings.es_request_timeout == 30
    assert settings.es_chunk_size == 500
    assert settings.csv_path == Path("data/posts.csv")


def test_csv_path_is_path():
    assert isinstance(settings.csv_path, Path)


# ============================================================
# PARSE DATE TESTS
# ============================================================

def test_parse_date_with_t():
    dt = parse_date("2023-01-01T10:00:00")
    assert dt == datetime(2023, 1, 1, 10, 0, 0)


def test_parse_date_invalid_raises():
    with pytest.raises(ValueError):
        parse_date("invalid")


# ============================================================
# ROW TO DOCUMENT TESTS
# ============================================================

def test_row_to_document():
    row = {
        "id": "123",
        "rubrics": '["science", "tech"]',
        "text": "Hello world",
        "created_date": "2023-05-05T14:30:00"
    }
    doc = row_to_document(row)
    assert doc.id == 123
    assert doc.rubrics == ["science", "tech"]
    assert doc.text == "Hello world"
    assert doc.created_date == datetime(2023, 5, 5, 14, 30, 0)


def test_row_to_document_invalid_json():
    row = {
        "id": "1",
        "rubrics": "not json",
        "text": "text",
        "created_date": "2023-01-01T00:00:00"
    }
    with pytest.raises(json.JSONDecodeError):
        row_to_document(row)


# ============================================================
# DB TESTS
# ============================================================

@pytest.mark.asyncio
async def test_insert_and_get():
    async with aiosqlite.connect(":memory:") as conn:
        conn.row_factory = aiosqlite.Row
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS documents (
                id INTEGER PRIMARY KEY,
                rubrics TEXT NOT NULL,
                text TEXT NOT NULL,
                created_date TEXT NOT NULL
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_created_date ON documents(created_date)")
        await conn.commit()

        docs = [
            {"id": 1, "rubrics": "[]", "text": "one", "created_date": "2023-01-01T00:00:00"},
            {"id": 2, "rubrics": '["a"]', "text": "two", "created_date": "2023-01-02T00:00:00"},
        ]
        await insert_many(conn, docs)

        result = await get_documents_by_ids(conn, [1, 2])
        assert len(result) == 2
        assert result[0]["id"] == 1
        assert result[1]["text"] == "two"

        docs[0]["text"] = "updated"
        await insert_many(conn, [docs[0]])
        result = await get_documents_by_ids(conn, [1])
        assert result[0]["text"] == "updated"


@pytest.mark.asyncio
async def test_delete():
    async with aiosqlite.connect(":memory:") as conn:
        conn.row_factory = aiosqlite.Row
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS documents (
                id INTEGER PRIMARY KEY,
                rubrics TEXT NOT NULL,
                text TEXT NOT NULL,
                created_date TEXT NOT NULL
            )
        """)
        await conn.commit()

        await insert_many(conn, [{"id": 1, "rubrics": "[]", "text": "delete me", "created_date": "2023-01-01T00:00:00"}])
        deleted = await delete_document(conn, 1)
        assert deleted is True
        result = await get_documents_by_ids(conn, [1])
        assert len(result) == 0

        deleted = await delete_document(conn, 999)
        assert deleted is False


# ============================================================
# ES TESTS
# ============================================================

@pytest.mark.asyncio
async def test_init_index(mock_es):
    with patch("app.es.es_client", mock_es):
        await init_index()
        mock_es.indices.exists.assert_awaited_once_with(index=settings.es_index)
        mock_es.indices.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_bulk_index(mock_es):
    with patch("app.es.es_client", mock_es):
        docs = [{"id": 1, "text": "hello"}, {"id": 2, "text": "world"}]
        with patch("app.es.async_bulk", new_callable=AsyncMock) as mock_bulk:
            mock_bulk.return_value = (2, [])
            count = await bulk_index_documents(docs)
            assert count == 2
            mock_bulk.assert_awaited_once()


@pytest.mark.asyncio
async def test_search(mock_es):
    with patch("app.es.es_client", mock_es):
        ids, total = await search_documents("test", 10)
        assert ids == [1, 2]
        assert total == 2


@pytest.mark.asyncio
async def test_delete_from_index(mock_es):
    with patch("app.es.es_client", mock_es):
        deleted = await delete_document_from_index(1)
        assert deleted is True
        mock_es.delete.assert_awaited_once_with(index=settings.es_index, id="1")


@pytest.mark.asyncio
async def test_search_es_error(mock_es):
    mock_es.search = AsyncMock(side_effect=Exception("ES error"))
    with patch("app.es.es_client", mock_es):
        ids, total = await search_documents("test", 10)
        assert ids == []
        assert total == 0


# ============================================================
# LOAD DATA HELPERS TESTS
# ============================================================

def test_parse_rubrics():
    assert _parse_rubrics("[]") == []
    assert _parse_rubrics('["a","b"]') == ["a", "b"]
    assert _parse_rubrics("a,b,c") == ["a", "b", "c"]
    assert _parse_rubrics("['single']") == ["single"]
    assert _parse_rubrics("") == []


def test_build_document():
    row = {
        "text": "Some text",
        "rubrics": "['tag1']",
        "created_date": "2023-01-01 12:00:00"
    }
    doc = _build_document(row, 1)
    assert doc["id"] == 1
    assert doc["rubrics"] == json.dumps(["tag1"])
    assert doc["text"] == "Some text"
    assert doc["created_date"] == "2023-01-01T12:00:00"


def test_build_document_missing_fields():
    row = {"text": "only text"}
    doc = _build_document(row, 42)
    assert doc["id"] == 42
    assert doc["rubrics"] == json.dumps([])
    assert doc["text"] == "only text"
    assert doc["created_date"] == ""


def test_build_document_invalid_rubrics():
    row = {"text": "text", "rubrics": "invalid", "created_date": "2023-01-01"}
    doc = _build_document(row, 1)
    assert doc["id"] == 1
    assert doc["rubrics"] == json.dumps(["invalid"])
    assert doc["text"] == "text"
    assert doc["created_date"] == "2023-01-01"


# ============================================================
# UI TESTS
# ============================================================

def test_render_page_returns_html():
    html = render_page()
    assert isinstance(html, str)
    assert html.startswith("<!DOCTYPE html>") or html.startswith("<")


def test_render_page_with_query():
    html = render_page(query="test query")
    assert isinstance(html, str)


def test_render_page_with_results():
    results = [
        Document(id=1, rubrics=["test"], text="result text", created_date=datetime.now())
    ]
    html = render_page(results=results)
    assert isinstance(html, str)


# ============================================================
# API TESTS
# ============================================================

@pytest.mark.asyncio
async def test_search_endpoint(monkeypatch):
    mock_search = AsyncMock(return_value=([1, 2], 2))
    mock_fetch = AsyncMock(return_value=[
        Document(id=1, rubrics=[], text="doc1", created_date=datetime.now()),
        Document(id=2, rubrics=[], text="doc2", created_date=datetime.now())
    ])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/search", json={"query": "test", "limit": 10, "offset": 0})
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 2
        assert len(data["results"]) == 2
        assert data["results"][0]["text"] == "doc1"


@pytest.mark.asyncio
async def test_search_no_results(monkeypatch):
    mock_search = AsyncMock(return_value=([], 0))
    mock_fetch = AsyncMock(return_value=[])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/search", json={"query": "nonexistent", "limit": 10, "offset": 0})
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 0
        assert len(data["results"]) == 0


@pytest.mark.asyncio
async def test_delete_doc(monkeypatch):
    mock_db_delete = AsyncMock(return_value=True)
    mock_es_delete = AsyncMock(return_value=True)
    monkeypatch.setattr("app.main._delete_document_from_db", mock_db_delete)
    monkeypatch.setattr("app.main.delete_document_from_index", mock_es_delete)

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.delete("/documents/123")
        assert response.status_code == 200
        assert response.json() == {"status": "deleted"}


@pytest.mark.asyncio
async def test_delete_doc_not_found(monkeypatch):
    mock_db_delete = AsyncMock(return_value=False)
    mock_es_delete = AsyncMock(return_value=False)
    monkeypatch.setattr("app.main._delete_document_from_db", mock_db_delete)
    monkeypatch.setattr("app.main.delete_document_from_index", mock_es_delete)

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.delete("/documents/999")
        assert response.status_code == 404
        assert response.json() == {"detail": "Документ не найден"}


@pytest.mark.asyncio
async def test_root_ui(monkeypatch):
    mock_search = AsyncMock(return_value=([1], 1))
    mock_fetch = AsyncMock(return_value=[Document(id=1, rubrics=[], text="result", created_date=datetime.now())])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]

        response = await client.get("/?query=hello")
        assert response.status_code == 200
        assert b"result" in response.content


@pytest.mark.asyncio
async def test_health_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}