import json
from datetime import datetime
from app.models import Document

def parse_date(date_str: str) -> datetime:
    return next(
        (dt for fmt in ("%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d")
         for dt in [datetime.strptime(date_str, fmt)] if dt),
        datetime.now()
    )

def row_to_document(row: dict) -> Document:
    return Document(
        id=row['id'],
        rubrics=json.loads(row['rubrics']),
        text=row['text'],
        created_date=parse_date(row['created_date'])
    )