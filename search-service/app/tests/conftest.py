import os
import pytest
from fastapi.testclient import TestClient
from app.main import app

os.environ["DATABASE_URL"] = "sqlite:///:memory:"
os.environ["CSV_PATH"] = "non_existent.csv"

@pytest.fixture(autouse=True)
def mock_csv(monkeypatch):
    monkeypatch.setenv("CSV_PATH", "non_existent.csv")

@pytest.fixture
def client():
    with TestClient(app) as client:
        yield client

@pytest.fixture
def sample_docs():
    return [
        {
            "id": 1,
            "rubrics": '["политика", "экономика"]',
            "text": "Первый документ о политике",
            "created_date": "2023-01-01T10:00:00"
        },
        {
            "id": 2,
            "rubrics": '["спорт"]',
            "text": "Второй документ о спорте",
            "created_date": "2023-01-02T12:00:00"
        }
    ]