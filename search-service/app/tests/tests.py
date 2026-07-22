import json
import pytest
from datetime import datetime
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch
from httpx import AsyncClient

from app.main import app
from app.models import Document, SearchRequest, SearchResponse
from app.config import Settings
from app.converters import row_to_document
from app.db import get_documents_by_ids, delete_document, insert_many, get_db
from app.es import search_documents, delete_document_from_index, bulk_index_documents
from app.load_data import _extract_id, _parse_rubrics, _build_document
from app.ui import render_page


@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


@pytest.fixture
def mock_db():
    db = AsyncMock()
    db.execute = AsyncMock()
    db.fetchall = AsyncMock()
    db.fetchone = AsyncMock()
    db.rowcount = 1
    db.__aenter__ = AsyncMock(return_value=db)
    db.__aexit__ = AsyncMock()
    return db


@pytest.fixture
def mock_es():
    es = AsyncMock()
    es.search = AsyncMock()
    es.delete = AsyncMock()
    es.indices = MagicMock()
    es.indices.exists = AsyncMock()
    es.indices.create = AsyncMock()
    es.close = AsyncMock()
    return es


@pytest.fixture(autouse=True)
def override_dependencies(mock_db, mock_es):
    app.dependency_overrides[get_db] = lambda: mock_db
    with patch("app.es.get_es_client", return_value=mock_es):
        yield


class TestModels:
    @pytest.mark.parametrize(
        "id_val, rubrics, text, date_str",
        [
            (1, ["a"], "text", "2023-01-01T10:00:00"),
            (2, [], "", "2023-12-31T23:59:59"),
            (3, ["x", "y"], "hello", "2020-01-01T00:00:00"),
            (4, ["one"], "test", "2022-06-15T12:30:45"),
            (5, ["a", "b", "c"], "long text", "2021-07-20T08:15:00"),
            (6, ["alpha", "beta"], "gamma", "2019-05-10T14:22:33"),
            (7, [], "empty", "2024-02-29T23:59:59"),
            (8, ["z"], "zzz", "2023-08-01T00:00:00"),
        ],
    )
    def test_document_validation(self, id_val, rubrics, text, date_str):
        doc = Document(
            id=id_val,
            rubrics=rubrics,
            text=text,
            created_date=datetime.fromisoformat(date_str),
        )
        assert doc.id == id_val
        assert doc.rubrics == rubrics
        assert doc.text == text

    def test_document_default(self):
        doc = Document(id=1, rubrics=[], text="", created_date=datetime.now())
        assert doc.id == 1

    @pytest.mark.parametrize(
        "query, limit, offset",
        [
            ("test", 10, 5),
            ("", 0, 0),
            ("hello", 30, 0),
            ("world", 1, 100),
            ("search", 50, 200),
            ("a", 1, 0),
            ("long query", 20, 10),
            ("политика", 15, 3),
            ("", 30, 0),
            ("x", 5, 5),
        ],
    )
    def test_search_request(self, query, limit, offset):
        req = SearchRequest(query=query, limit=limit, offset=offset)
        assert req.query == query
        assert req.limit == limit
        assert req.offset == offset

    def test_search_request_defaults(self):
        req = SearchRequest(query="test")
        assert req.limit == 30
        assert req.offset == 0

    @pytest.mark.parametrize("total", [0, 1, 5, 10, 20, 50, 100, 200])
    def test_search_response(self, total):
        docs = [
            Document(id=i, rubrics=[], text="", created_date=datetime.now())
            for i in range(total)
        ]
        resp = SearchResponse(results=docs, total=total)
        assert len(resp.results) == total
        assert resp.total == total


class TestConfig:
    def test_default_settings(self):
        settings = Settings()
        assert settings.es_host == "localhost:9200"
        assert settings.es_index == "documents"
        assert settings.es_chunk_size == 500
        assert settings.es_request_timeout == 30
        assert settings.search_size == 30
        assert settings.csv_path == Path("posts.csv")
        assert settings.log_level == "INFO"

    @pytest.mark.parametrize(
        "key, default",
        [
            ("es_host", "localhost:9200"),
            ("es_index", "documents"),
            ("es_chunk_size", 500),
            ("search_size", 30),
            ("log_level", "INFO"),
            ("es_request_timeout", 30),
        ],
    )
    def test_settings_fields_exist(self, key, default):
        settings = Settings()
        assert hasattr(settings, key)


class TestConverters:
    @pytest.mark.parametrize(
        "row, expected_id, expected_rubrics, expected_text, expected_date",
        [
            (
                {
                    "id": 1,
                    "rubrics": "a,b",
                    "text": "t1",
                    "created_date": "2023-01-01T10:00:00",
                },
                1,
                ["a", "b"],
                "t1",
                "2023-01-01T10:00:00",
            ),
            (
                {
                    "id": 2,
                    "rubrics": "",
                    "text": "t2",
                    "created_date": "2023-01-02T10:00:00",
                },
                2,
                [],
                "t2",
                "2023-01-02T10:00:00",
            ),
            (
                {
                    "id": 3,
                    "rubrics": "x",
                    "text": "t3",
                    "created_date": "2023-01-03T10:00:00",
                },
                3,
                ["x"],
                "t3",
                "2023-01-03T10:00:00",
            ),
            (
                {
                    "id": 4,
                    "rubrics": "one,two,three",
                    "text": "long",
                    "created_date": "2022-12-25T09:00:00",
                },
                4,
                ["one", "two", "three"],
                "long",
                "2022-12-25T09:00:00",
            ),
            (
                {
                    "id": 5,
                    "rubrics": "['a','b']",
                    "text": "json",
                    "created_date": "2021-11-11T11:11:11",
                },
                5,
                ["a", "b"],
                "json",
                "2021-11-11T11:11:11",
            ),
            (
                {
                    "id": 6,
                    "rubrics": "x,y,z",
                    "text": "abc",
                    "created_date": "2020-05-05T05:05:05",
                },
                6,
                ["x", "y", "z"],
                "abc",
                "2020-05-05T05:05:05",
            ),
            (
                {
                    "id": 7,
                    "rubrics": "['single']",
                    "text": "s",
                    "created_date": "2019-01-01T00:00:00",
                },
                7,
                ["single"],
                "s",
                "2019-01-01T00:00:00",
            ),
            (
                {
                    "id": 8,
                    "rubrics": "a,b,c,d,e",
                    "text": "many",
                    "created_date": "2023-12-31T23:59:59",
                },
                8,
                ["a", "b", "c", "d", "e"],
                "many",
                "2023-12-31T23:59:59",
            ),
        ],
    )
    def test_row_to_document(
        self, row, expected_id, expected_rubrics, expected_text, expected_date
    ):
        doc = row_to_document(row)
        assert doc.id == expected_id
        assert doc.rubrics == expected_rubrics
        assert doc.text == expected_text
        assert doc.created_date == datetime.fromisoformat(expected_date)

    def test_row_to_document_invalid_date(self):
        row = {"id": 1, "rubrics": "", "text": "", "created_date": "invalid"}
        with pytest.raises(ValueError):
            row_to_document(row)


class TestDB:
    @pytest.mark.parametrize(
        "ids, expected_result",
        [
            ([], []),
            (
                [1],
                [{"id": 1, "rubrics": "a", "text": "t", "created_date": "2023-01-01"}],
            ),
            (
                [1, 2],
                [
                    {
                        "id": 1,
                        "rubrics": "a",
                        "text": "t",
                        "created_date": "2023-01-01",
                    },
                    {
                        "id": 2,
                        "rubrics": "b",
                        "text": "t2",
                        "created_date": "2023-01-02",
                    },
                ],
            ),
            (
                [10, 20, 30],
                [{"id": 10, "rubrics": "x", "text": "y", "created_date": "2023-02-01"}],
            ),
            (
                [5, 6],
                [
                    {
                        "id": 5,
                        "rubrics": "r1",
                        "text": "txt1",
                        "created_date": "2023-03-01",
                    },
                    {
                        "id": 6,
                        "rubrics": "r2",
                        "text": "txt2",
                        "created_date": "2023-03-02",
                    },
                ],
            ),
            (
                [100, 200, 300, 400],
                [
                    {
                        "id": 100,
                        "rubrics": "z",
                        "text": "zz",
                        "created_date": "2023-04-01",
                    }
                ],
            ),
        ],
    )
    @pytest.mark.asyncio
    async def test_get_documents_by_ids(self, mock_db, ids, expected_result):
        mock_db.execute().fetchall = AsyncMock(return_value=expected_result)
        result = await get_documents_by_ids(mock_db, ids)
        if expected_result:
            assert result == expected_result
        else:
            assert result == []

    @pytest.mark.parametrize(
        "rowcount, expected", [(1, True), (0, False), (5, True), (3, True), (0, False)]
    )
    @pytest.mark.asyncio
    async def test_delete_document(self, mock_db, rowcount, expected):
        mock_db.execute().rowcount = rowcount
        result = await delete_document(mock_db, 1)
        assert result == expected

    @pytest.mark.parametrize(
        "docs",
        [
            [],
            [{"id": 1, "rubrics": "a", "text": "t", "created_date": "2023-01-01"}],
            [
                {"id": 1, "rubrics": "a", "text": "t", "created_date": "2023-01-01"},
                {"id": 2, "rubrics": "b", "text": "t2", "created_date": "2023-01-02"},
            ],
            [
                {"id": 10, "rubrics": "x", "text": "y", "created_date": "2023-02-01"},
                {"id": 20, "rubrics": "z", "text": "w", "created_date": "2023-02-02"},
                {"id": 30, "rubrics": "v", "text": "u", "created_date": "2023-02-03"},
            ],
        ],
    )
    @pytest.mark.asyncio
    async def test_insert_many(self, mock_db, docs):
        await insert_many(mock_db, docs)
        if docs:
            mock_db.executemany.assert_called_once()
            mock_db.commit.assert_called_once()
        else:
            mock_db.executemany.assert_not_called()


class TestES:
    @pytest.mark.parametrize(
        "query, size, offset, expected_ids, expected_total",
        [
            ("test", 10, 0, [1, 2], 2),
            ("", 5, 0, [], 0),
            ("none", 10, 0, [], 0),
            ("example", 20, 10, [5, 6, 7], 3),
            ("search", 1, 0, [1], 1),
            ("hello", 15, 5, [10, 11, 12, 13], 4),
            ("world", 3, 0, [100, 101], 2),
            ("python", 10, 20, [], 0),
            ("fastapi", 30, 0, [1, 2, 3, 4, 5], 5),
            ("test", 2, 0, [1, 2], 10),
        ],
    )
    @pytest.mark.asyncio
    async def test_search_documents(
        self, mock_es, query, size, offset, expected_ids, expected_total
    ):
        mock_es.search.return_value = {
            "hits": {
                "total": {"value": expected_total},
                "hits": [{"_source": {"id": i}} for i in expected_ids],
            }
        }
        ids, total = await search_documents(query, size, offset)
        assert ids == expected_ids
        assert total == expected_total

    @pytest.mark.parametrize(
        "doc_id, expected",
        [
            (1, True),
            (2, False),
            (3, True),
            (4, False),
            (5, True),
            (10, False),
            (100, True),
        ],
    )
    @pytest.mark.asyncio
    async def test_delete_document_from_index(self, mock_es, doc_id, expected):
        mock_es.delete.return_value = {"result": "deleted" if expected else "not_found"}
        result = await delete_document_from_index(doc_id)
        assert result == expected

    @pytest.mark.parametrize(
        "docs, refresh",
        [
            ([{"id": 1, "text": "a"}], True),
            ([], False),
            ([{"id": 1, "text": "a"}, {"id": 2, "text": "b"}], True),
            ([{"id": 5, "text": "x"}], False),
            ([{"id": 10, "text": "y"}, {"id": 20, "text": "z"}], True),
            ([], True),
        ],
    )
    @pytest.mark.asyncio
    async def test_bulk_index_documents(self, mock_es, docs, refresh):
        result = await bulk_index_documents(docs, refresh)
        if docs:
            assert result > 0
        else:
            assert result == 0


class TestLoadData:
    @pytest.mark.parametrize(
        "row_dict, idx, expected",
        [
            ({"id": "5"}, 1, 5),
            ({}, 1, 1),
            ({"id": "   "}, 2, 2),
            ({"id": "123"}, 10, 123),
            ({"id": "0"}, 5, 0),
            ({"id": "-1"}, 3, -1),
            ({"id": "999"}, 0, 999),
            ({"id": ""}, 4, 4),
        ],
    )
    def test_extract_id(self, row_dict, idx, expected):
        assert _extract_id(row_dict, idx) == expected

    @pytest.mark.parametrize(
        "rubrics_str, expected",
        [
            ("['a','b']", ["a", "b"]),
            ("[1,2]", [1, 2]),
            ("a,b,c", ["a", "b", "c"]),
            ("", []),
            ("[[]]", []),
            ("['x']", ["x"]),
            ("one,two", ["one", "two"]),
            ("[1,2,3]", [1, 2, 3]),
            ("['a','b','c','d']", ["a", "b", "c", "d"]),
            ("x,y,z,w", ["x", "y", "z", "w"]),
            ("[10,20,30,40,50]", [10, 20, 30, 40, 50]),
            ("", []),
        ],
    )
    def test_parse_rubrics(self, rubrics_str, expected):
        assert _parse_rubrics(rubrics_str) == expected

    @pytest.mark.parametrize(
        "row_dict, idx, expected_id, expected_rubrics",
        [
            (
                {
                    "id": "5",
                    "rubrics": "['a']",
                    "text": "t",
                    "created_date": "2023-01-01",
                },
                1,
                5,
                ["a"],
            ),
            ({}, 1, 1, []),
            (
                {
                    "id": "3",
                    "rubrics": "x,y",
                    "text": "txt",
                    "created_date": "2022-01-01",
                },
                1,
                3,
                ["x", "y"],
            ),
            ({"id": "", "rubrics": "[]", "text": "", "created_date": ""}, 2, 2, []),
            (
                {
                    "id": "10",
                    "rubrics": "['alpha','beta']",
                    "text": "greek",
                    "created_date": "2021-01-01",
                },
                1,
                10,
                ["alpha", "beta"],
            ),
            (
                {
                    "id": "7",
                    "rubrics": "a,b,c",
                    "text": "letters",
                    "created_date": "2020-02-02",
                },
                1,
                7,
                ["a", "b", "c"],
            ),
            (
                {
                    "id": "0",
                    "rubrics": "[]",
                    "text": "zero",
                    "created_date": "2019-03-03",
                },
                1,
                0,
                [],
            ),
            (
                {
                    "id": "99",
                    "rubrics": "['only']",
                    "text": "one",
                    "created_date": "2018-04-04",
                },
                1,
                99,
                ["only"],
            ),
        ],
    )
    def test_build_document(self, row_dict, idx, expected_id, expected_rubrics):
        doc = _build_document(row_dict, idx)
        if doc is None:
            assert False
        assert doc["id"] == expected_id
        assert (
            doc["rubrics"] == json.dumps(expected_rubrics) if expected_rubrics else "[]"
        )


class TestMain:
    @pytest.mark.parametrize(
        "query",
        [
            "",
            "test",
            "политика",
            "hello world",
            "none",
            "example",
            "long query with spaces",
            "single",
            "multiple words here",
            "special chars !@#",
            "12345",
            "русский язык",
            "   ",
            "query with numbers 123",
            "alpha beta gamma",
        ],
    )
    @pytest.mark.asyncio
    async def test_root(self, client, query):
        resp = await client.get(f"/?query={query}")
        assert resp.status_code == 200
        assert "text/html" in resp.headers["content-type"]

    @pytest.mark.asyncio
    async def test_health(self, client):
        resp = await client.get("/health")
        assert resp.status_code == 200
        assert resp.json() == {"status": "ok"}

    @pytest.mark.parametrize(
        "query, limit, offset",
        [
            ("test", 10, 0),
            ("", 5, 0),
            ("none", 30, 0),
            ("example", 20, 10),
            ("search", 15, 5),
            ("hello", 1, 0),
            ("world", 100, 0),
            ("", 0, 0),
            ("python", 25, 10),
            ("fastapi", 30, 20),
            ("elasticsearch", 10, 5),
            ("database", 50, 0),
            ("query", 3, 3),
            ("test", 30, 100),
            ("x", 1, 0),
            ("long", 20, 20),
        ],
    )
    @pytest.mark.asyncio
    async def test_search_endpoint(self, client, query, limit, offset):
        resp = await client.post(
            "/search", json={"query": query, "limit": limit, "offset": offset}
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "results" in data
        assert "total" in data

    @pytest.mark.parametrize(
        "doc_id", [1, 999, 1000, 0, -1, 12345, 999999, 2, 3, 4, 5, 10, 100, 200, 500]
    )
    @pytest.mark.asyncio
    async def test_delete_doc(self, client, doc_id):
        resp = await client.delete(f"/documents/{doc_id}")
        assert resp.status_code in (200, 404)

    @pytest.mark.parametrize("invalid_limit", [-1, -10, -100, -5, -2, -50])
    @pytest.mark.asyncio
    async def test_search_invalid_limit(self, client, invalid_limit):
        resp = await client.post(
            "/search", json={"query": "test", "limit": invalid_limit}
        )
        assert resp.status_code == 422


class TestUI:
    def test_render_page_no_template(self, tmp_path, monkeypatch):
        monkeypatch.setattr("app.ui.HTML_TEMPLATE_PATH", tmp_path / "nonexistent.html")
        resp = render_page()
        assert resp.status_code == 500
        assert "не найден" in resp.body.decode()

    def test_render_page_with_template(self, tmp_path, monkeypatch):
        template = tmp_path / "index.html"
        template.write_text("<html>Hello</html>")
        monkeypatch.setattr("app.ui.HTML_TEMPLATE_PATH", template)
        resp = render_page()
        assert resp.status_code == 200
        assert "Hello" in resp.body.decode()

    @pytest.mark.parametrize(
        "query, results, error",
        [
            ("test", [], ""),
            ("", None, "error"),
            ("example", [{"id": 1}], ""),
            ("hello", [{"id": 1, "text": "x"}], ""),
            ("world", [], "not found"),
            ("query", [{"id": 2, "text": "y"}], ""),
            ("", [], "some error"),
            ("none", None, ""),
        ],
    )
    def test_render_page_params(self, tmp_path, monkeypatch, query, results, error):
        template = tmp_path / "index.html"
        template.write_text("<html>Template</html>")
        monkeypatch.setattr("app.ui.HTML_TEMPLATE_PATH", template)
        resp = render_page(query, results, error)
        assert resp.status_code == 200
