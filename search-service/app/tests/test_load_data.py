import pytest
from unittest.mock import AsyncMock
from pathlib import Path
import json
from app.load_data import load_csv_from_file, load_from_url
from app.db import get_db, get_documents_by_ids
import httpx

@pytest.fixture
def temp_csv(tmp_path):
    content = """id,rubrics,text,created_date
1,политика,экономика,Первый текст,2023-01-01T10:00:00
2,спорт,Второй текст,2023-01-02T12:00:00
"""
    file_path = tmp_path / "test.csv"
    file_path.write_text(content, encoding="utf-8")
    return file_path

@pytest.mark.asyncio
async def test_load_csv_from_file(temp_csv):
    await load_csv_from_file(temp_csv)
    async with get_db() as db:
        docs = await get_documents_by_ids(db, [1, 2])
        assert len(docs) == 2
        assert docs[0]["text"] == "Первый текст"
        assert json.loads(docs[0]["rubrics"]) == ["политика", "экономика"]

@pytest.mark.asyncio
async def test_load_csv_malformed(tmp_path):
    content = """id,rubrics,text,created_date
1,test,text1,2023-01-01
invalid
2,test,text2,2023-01-02
"""
    csv_path = tmp_path / "bad.csv"
    csv_path.write_text(content, encoding="utf-8")
    await load_csv_from_file(csv_path)
    async with get_db() as db:
        cur = await db.execute("SELECT COUNT(*) FROM documents")
        assert (await cur.fetchone())[0] == 2

@pytest.mark.asyncio
async def test_load_from_url(mocker, tmp_path):
    mock_client = mocker.AsyncMock()
    mock_response = mocker.AsyncMock()
    mock_response.content = b"id,rubrics,text,created_date\n1,test,Hello,2023-01-01"
    mock_response.raise_for_status = mocker.Mock()
    mock_client.get = mocker.AsyncMock(return_value=mock_response)
    mocker.patch("httpx.AsyncClient", return_value=mock_client)
    mock_load = mocker.patch("app.load_data.load_csv_from_file", new_callable=AsyncMock)
    await load_from_url("http://example.com/data.csv", Path(tmp_path / "data.csv"))
    mock_load.assert_called_once()

@pytest.mark.asyncio
async def test_load_from_url_http_error(mocker, tmp_path):
    mock_client = mocker.AsyncMock()
    mock_response = mocker.AsyncMock()
    mock_response.raise_for_status = mocker.Mock(side_effect=httpx.HTTPStatusError("404", request=None, response=None))
    mock_client.get = mocker.AsyncMock(return_value=mock_response)
    mocker.patch("httpx.AsyncClient", return_value=mock_client)
    with pytest.raises(httpx.HTTPStatusError):
        await load_from_url("http://example.com/missing.csv", Path(tmp_path / "data.csv"))

@pytest.mark.asyncio
async def test_load_csv_with_real_format(tmp_path):
    content = """text,created_date,rubrics
"Пример текста",2019-07-25 12:42:13,"['VK-123', 'VK-456']"
"""
    csv_path = tmp_path / "real.csv"
    csv_path.write_text(content, encoding='utf-8')
    await load_csv_from_file(csv_path)
    async with get_db() as db:
        docs = await get_documents_by_ids(db, [1])
        assert len(docs) == 1
        assert docs[0]['id'] == 1
        assert json.loads(docs[0]['rubrics']) == ['VK-123', 'VK-456']
        assert docs[0]['created_date'] == '2019-07-25T12:42:13'