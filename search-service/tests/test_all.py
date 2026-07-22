import warnings
import json
from datetime import datetime
from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock

import aiosqlite
import pytest
from fastapi.testclient import TestClient

from app.config import settings
from app.converters import parse_date, row_to_document
from app.db import init_db, get_db, insert_many, get_documents_by_ids, delete_document
from app.es import init_index, bulk_index_documents, search_documents, delete_document_from_index
from app.load_data import (
    _parse_rubrics,
    _build_document,
    _extract_id,
    _batch_generator,
    _process_batch,
    _process_rows,
    _read_csv_rows,
    load_csv_from_file,
    load_from_url,
)
from app.main import app
from app.models import Document
from app.ui import render_page

# Подавляем все предупреждения, чтобы тесты были чистыми
warnings.filterwarnings("ignore")
# Подавляем конкретные предупреждения
warnings.filterwarnings("ignore", category=DeprecationWarning, module="starlette.testclient")
warnings.filterwarnings("ignore", category=RuntimeWarning, module="unittest.mock")


@pytest.fixture(autouse=True)
def mock_es_env(monkeypatch):
    monkeypatch.setenv("ES_HOST", "http://localhost:9200")
    monkeypatch.setenv("ES_INDEX", "documents")


@pytest.fixture
def mock_es_client():
    mock = AsyncMock()
    mock.indices = AsyncMock()
    mock.indices.exists = AsyncMock(return_value=False)
    mock.indices.create = AsyncMock(return_value={"acknowledged": True})
    mock.indices.refresh = AsyncMock(return_value={})
    mock.search = AsyncMock(return_value={
        "hits": {
            "total": {"value": 2},
            "hits": [{"_source": {"id": 1}}, {"_source": {"id": 2}}]
        }
    })
    mock.delete = AsyncMock(return_value={"result": "deleted"})
    mock.index = AsyncMock(return_value={"result": "created"})
    return mock


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


def test_parse_date_with_t():
    dt = parse_date("2023-01-01T10:00:00")
    assert dt == datetime(2023, 1, 1, 10, 0, 0)


def test_parse_date_with_space():
    with pytest.raises(ValueError):
        parse_date("2023-01-01 10:00:00")


def test_parse_date_without_time():
    with pytest.raises(ValueError):
        parse_date("2023-01-01")


def test_parse_date_invalid_fallback():
    with pytest.raises(ValueError):
        parse_date("invalid")


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


@pytest.mark.asyncio
async def test_init_db_creates_tables(tmp_path):
    db_path = tmp_path / "test.db"
    settings.database_url = str(db_path)
    await init_db()
    async with aiosqlite.connect(db_path) as conn:
        cursor = await conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='documents'")
        row = await cursor.fetchone()
        assert row is not None


@pytest.mark.asyncio
async def test_get_db_context_manager():
    async with get_db() as db:
        assert db is not None
        result = await db.execute("SELECT 1")
        row = await result.fetchone()
        assert row[0] == 1


@pytest.mark.asyncio
async def test_insert_and_get():
    async with aiosqlite.connect(":memory:") as conn:
        conn.row_factory = aiosqlite.Row
        await conn.execute("""
            CREATE TABLE documents (
                id INTEGER PRIMARY KEY,
                rubrics TEXT NOT NULL,
                text TEXT NOT NULL,
                created_date TEXT NOT NULL
            )
        """)
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
            CREATE TABLE documents (
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


@pytest.mark.asyncio
async def test_init_index(mock_es_client):
    with patch("app.es.es_client", mock_es_client):
        await init_index()
        mock_es_client.indices.exists.assert_awaited_once_with(index=settings.es_index)
        mock_es_client.indices.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_bulk_index(mock_es_client):
    with patch("app.es.es_client", mock_es_client):
        docs = [{"id": 1, "text": "hello"}, {"id": 2, "text": "world"}]
        with patch("app.es.async_bulk", new_callable=AsyncMock) as mock_bulk:
            mock_bulk.return_value = (2, [])
            count = await bulk_index_documents(docs)
            assert count == 2
            mock_bulk.assert_awaited_once()


@pytest.mark.asyncio
async def test_search(mock_es_client):
    with patch("app.es.es_client", mock_es_client):
        ids, total = await search_documents("test", 10)
        assert ids == [1, 2]
        assert total == 2


@pytest.mark.asyncio
async def test_delete_from_index(mock_es_client):
    with patch("app.es.es_client", mock_es_client):
        deleted = await delete_document_from_index(1)
        assert deleted is True
        mock_es_client.delete.assert_awaited_once_with(index=settings.es_index, id="1")


@pytest.mark.asyncio
async def test_search_es_error(mock_es_client):
    mock_es_client.search = AsyncMock(side_effect=Exception("ES error"))
    with patch("app.es.es_client", mock_es_client):
        ids, total = await search_documents("test", 10)
        assert ids == []
        assert total == 0


def test_extract_id():
    assert _extract_id({"id": "42"}, 0) == 42
    assert _extract_id({}, 5) == 5
    assert _extract_id({"id": "  10  "}, 0) == 10
    assert _extract_id({"id": "99"}, 0) == 99


def test_parse_rubrics():
    assert _parse_rubrics("[]") == []
    assert _parse_rubrics('["a","b"]') == ["a", "b"]
    assert _parse_rubrics("a,b,c") == ["a", "b", "c"]
    assert _parse_rubrics("['single']") == ["single"]
    assert _parse_rubrics("") == []
    with pytest.raises(ValueError):
        _parse_rubrics("[invalid]")


def test_build_document():
    row = {"text": "Some text", "rubrics": "['tag1']", "created_date": "2023-01-01 12:00:00"}
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
    assert doc["rubrics"] == json.dumps(["invalid"])


def test_batch_generator():
    rows = [
        {"id": "1", "text": "one", "rubrics": "[]", "created_date": "2023-01-01"},
        {"id": "2", "text": "two", "rubrics": "['a']", "created_date": "2023-01-02"}
    ]
    batches = list(_batch_generator(rows, 3))
    assert len(batches) == 1
    assert len(batches[0]) == 2


@pytest.mark.asyncio
async def test_process_batch_success():
    mock_db = AsyncMock()
    batch = [{"id": 1, "text": "test"}]
    with patch("app.load_data.insert_many", new_callable=AsyncMock) as mock_insert, \
         patch("app.load_data.bulk_index_documents", new_callable=AsyncMock) as mock_bulk:
        mock_insert.return_value = None
        mock_bulk.return_value = 1
        await _process_batch(mock_db, batch)
        mock_insert.assert_awaited_once()
        mock_bulk.assert_awaited_once()


@pytest.mark.asyncio
async def test_process_batch_with_errors():
    mock_db = AsyncMock()
    batch = [{"id": 1, "text": "test"}]
    with patch("app.load_data.insert_many", side_effect=Exception("DB error")):
        await _process_batch(mock_db, batch)


@pytest.mark.asyncio
async def test_read_csv_rows(tmp_path):
    csv_path = tmp_path / "data.csv"
    csv_path.write_text("id,text\n1,hello\n2,world")
    rows, has_rows = await _read_csv_rows(csv_path)
    assert has_rows is True
    assert len(rows) == 2
    assert rows[0]["id"] == "1"
    assert rows[0]["text"] == "hello"


@pytest.mark.asyncio
async def test_read_csv_rows_empty(tmp_path):
    csv_path = tmp_path / "empty.csv"
    csv_path.write_text("id,text\n")
    rows, has_rows = await _read_csv_rows(csv_path)
    assert has_rows is False
    assert len(rows) == 0


@pytest.mark.asyncio
async def test_process_rows(mock_es_client):
    rows = [{"id": "1", "text": "one"}, {"id": "2", "text": "two"}]
    mock_db = AsyncMock()
    with patch("app.load_data._process_batch", new_callable=AsyncMock) as mock_batch:
        await _process_rows(rows, mock_db)
        assert mock_batch.call_count == 1


@pytest.mark.asyncio
async def test_load_csv_from_file(tmp_path, monkeypatch):
    csv_path = tmp_path / "data.csv"
    csv_path.write_text("id,text,rubrics,created_date\n1,hello,\"['a']\",2023-01-01T00:00:00")

    with patch("app.load_data.init_db", new_callable=AsyncMock) as mock_init_db, \
         patch("app.load_data.init_index", new_callable=AsyncMock) as mock_init_idx, \
         patch("app.load_data.get_db") as mock_get_db, \
         patch("app.load_data._process_rows", new_callable=AsyncMock) as mock_process, \
         patch("app.load_data.es_client.indices.refresh", new_callable=AsyncMock) as mock_refresh:
        mock_db = AsyncMock()
        mock_get_db.return_value.__aenter__.return_value = mock_db
        mock_process.return_value = (1, 0)

        await load_csv_from_file(csv_path)

        mock_init_db.assert_awaited_once()
        mock_init_idx.assert_awaited_once()
        assert mock_get_db.call_count == 1
        mock_process.assert_awaited_once()
        mock_refresh.assert_awaited_once()


@pytest.mark.asyncio
async def test_load_from_url(tmp_path, monkeypatch):
    url = "http://example.com/data.csv"
    target_path = tmp_path / "downloaded.csv"
    mock_response = AsyncMock()
    mock_response.raise_for_status = MagicMock()
    mock_response.content = b"id,text\n1,hello"

    with patch("httpx.AsyncClient.get", return_value=mock_response) as mock_get, \
         patch("app.load_data.load_csv_from_file", new_callable=AsyncMock) as mock_load:
        await load_from_url(url, target_path)
        mock_get.assert_awaited_once_with(url)
        mock_load.assert_awaited_once_with(target_path)


def test_render_page_returns_html():
    html = render_page()
    assert isinstance(html, str)
    assert html.startswith("<!DOCTYPE html>") or html.startswith("<")


def test_render_page_with_query():
    html = render_page(query="test")
    assert isinstance(html, str)


def test_render_page_with_results():
    results = [Document(id=1, rubrics=["test"], text="result", created_date=datetime.now())]
    html = render_page(results=results)
    assert isinstance(html, str)


# ============================================================
# API TESTS (синхронные с TestClient)
# ============================================================

@pytest.fixture
def client():
    return TestClient(app)


def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_search_endpoint(client, monkeypatch):
    mock_search = AsyncMock(return_value=([1, 2], 2))
    mock_fetch = AsyncMock(return_value=[
        Document(id=1, rubrics=[], text="doc1", created_date=datetime.now()),
        Document(id=2, rubrics=[], text="doc2", created_date=datetime.now())
    ])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    response = client.post("/search", json={"query": "test", "limit": 10, "offset": 0})
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 2
    assert len(data["results"]) == 2
    assert data["results"][0]["text"] == "doc1"


def test_search_endpoint_no_results(client, monkeypatch):
    mock_search = AsyncMock(return_value=([], 0))
    mock_fetch = AsyncMock(return_value=[])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    response = client.post("/search", json={"query": "nonexistent", "limit": 10, "offset": 0})
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 0
    assert len(data["results"]) == 0


def test_search_endpoint_valid_limit(client):
    response = client.post("/search", json={"query": "test", "limit": 1, "offset": 0})
    assert response.status_code == 200


def test_search_endpoint_missing_query(client):
    response = client.post("/search", json={})
    assert response.status_code == 422


def test_delete_doc(client, monkeypatch):
    mock_db_delete = AsyncMock(return_value=True)
    mock_es_delete = AsyncMock(return_value=True)
    monkeypatch.setattr("app.main._delete_document_from_db", mock_db_delete)
    monkeypatch.setattr("app.main.delete_document_from_index", mock_es_delete)

    response = client.delete("/documents/123")
    assert response.status_code == 200
    assert response.json() == {"status": "deleted"}


def test_delete_doc_partial(client, monkeypatch):
    mock_db_delete = AsyncMock(return_value=True)
    mock_es_delete = AsyncMock(return_value=False)
    monkeypatch.setattr("app.main._delete_document_from_db", mock_db_delete)
    monkeypatch.setattr("app.main.delete_document_from_index", mock_es_delete)

    response = client.delete("/documents/123")
    assert response.status_code == 200
    assert response.json()["status"] == "partially_deleted"


def test_delete_doc_not_found(client, monkeypatch):
    mock_db_delete = AsyncMock(return_value=False)
    mock_es_delete = AsyncMock(return_value=False)
    monkeypatch.setattr("app.main._delete_document_from_db", mock_db_delete)
    monkeypatch.setattr("app.main.delete_document_from_index", mock_es_delete)

    response = client.delete("/documents/999")
    assert response.status_code == 404
    assert response.json() == {"detail": "Документ не найден"}


def test_root_ui(client, monkeypatch):
    mock_search = AsyncMock(return_value=([1], 1))
    mock_fetch = AsyncMock(return_value=[Document(id=1, rubrics=[], text="result", created_date=datetime.now())])
    monkeypatch.setattr("app.main.search_documents", mock_search)
    monkeypatch.setattr("app.main._fetch_documents_by_ids", mock_fetch)

    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

    response = client.get("/?query=hello")
    assert response.status_code == 200
    assert b"result" in response.content


def test_root_ui_error(client, monkeypatch):
    mock_search = AsyncMock(side_effect=Exception("Search error"))
    monkeypatch.setattr("app.main.search_documents", mock_search)

    response = client.get("/?query=error")
    assert response.status_code == 200
    assert "Ошибка" in response.text or "error" in response.text.lower()
