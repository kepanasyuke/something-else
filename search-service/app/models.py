from __future__ import annotations
from datetime import datetime
from pydantic import BaseModel


class Document(BaseModel):
    id: int
    rubrics: list[str]
    text: str
    created_date: datetime
    model_config = {
        "json_schema_extra": {
            "example": {
                "id": 1,
                "rubrics": ["политика", "экономика"],
                "text": "Текст документа",
                "created_date": "2023-01-01T10:00:00",
            }
        }
    }


class SearchRequest(BaseModel):
    query: str
    limit: int = 30
    offset: int = 0


class SearchResponse(BaseModel):
    results: list[Document]
    total: int
