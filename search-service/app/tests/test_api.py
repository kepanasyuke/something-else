import pytest
from httpx import AsyncClient
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.mark.asyncio
async def test_health(client: AsyncClient):
    resp = await client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}

@pytest.mark.asyncio
async def test_search_empty(client: AsyncClient):
    resp = await client.post("/search", json={"query": ""})
    assert resp.status_code == 200
    data = resp.json()
    assert data["results"] == []
    assert data["total"] == 0

@pytest.mark.asyncio
async def test_search_with_query(client: AsyncClient):
    resp = await client.post("/search", json={"query": "политика", "limit": 2, "offset": 0})
    assert resp.status_code == 200
    data = resp.json()
    assert "results" in data
    assert "total" in data
    assert len(data["results"]) <= 2

@pytest.mark.asyncio
async def test_delete_not_found(client: AsyncClient):
    resp = await client.delete("/documents/999999")
    assert resp.status_code == 404

@pytest.mark.asyncio
async def test_root_page(client: AsyncClient):
    resp = await client.get("/")
    assert resp.status_code == 200
    assert "text/html" in resp.headers["content-type"]