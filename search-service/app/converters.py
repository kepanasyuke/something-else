import json
from datetime import datetime
from app.models import Document

def parse_date(date_str: str) -> datetime:
    """Преобразует строку даты в datetime, поддерживая форматы ISO и с пробелом."""
    try:
        return datetime.fromisoformat(date_str)
    except ValueError:
        return datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')

def row_to_document(row: dict) -> Document:
    """Преобразует строку из БД (словарь) в модель Document."""
    return Document(
        id=row['id'],
        rubrics=json.loads(row['rubrics']),
        text=row['text'],
        created_date=parse_date(row['created_date'])
    )