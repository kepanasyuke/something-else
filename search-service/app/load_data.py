import csv
import json
import asyncio
import logging
from pathlib import Path
import aiofiles
import httpx
import ast
from app.db import init_db, insert_many, get_db
from app.es import init_index, bulk_index_documents, es_client
from app.config import settings

logger = logging.getLogger(__name__)

def _parse_row(row_dict: dict, idx: int) -> dict | None:
    """Преобразует словарь строки CSV в документ.
       idx – порядковый номер строки, используется как ID.
    """
    try:
        if 'id' in row_dict and row_dict['id'].strip():
            doc_id = int(row_dict['id'])
        else:
            doc_id = idx

        rubrics_str = row_dict.get('rubrics', '[]').strip()
        if rubrics_str.startswith('[') and rubrics_str.endswith(']'):
            rubrics = ast.literal_eval(rubrics_str)
            if not isinstance(rubrics, list):
                rubrics = [str(rubrics)]
        else:
            rubrics = [r.strip() for r in rubrics_str.split(',') if r.strip()]

        # Приводим дату к ISO (заменяем пробел на 'T')
        created_date = row_dict.get('created_date', '').replace(' ', 'T')

        return {
            "id": doc_id,
            "rubrics": json.dumps(rubrics),
            "text": row_dict.get('text', ''),
            "created_date": created_date
        }
    except (KeyError, ValueError, SyntaxError, Exception) as e:
        logger.warning("Ошибка парсинга строки %s: %s", row_dict, e)
        return None

async def _process_batch(db, batch: list[dict]) -> None:
    if not batch:
        return
    results = await asyncio.gather(
        insert_many(db, batch),
        bulk_index_documents(batch, refresh=False),
        return_exceptions=True
    )
    for i, res in enumerate(results):
        if isinstance(res, Exception):
            logger.error("Batch step %s failed: %s", i, res)
    logger.info("Processed batch of %s documents", len(batch))

async def load_csv_from_file(csv_path: Path) -> None:
    """Загружает данные из CSV-файла (читает весь файл в память)."""
    await init_db()
    await init_index()
    
    # Читаем весь CSV как текст
    async with aiofiles.open(csv_path, "r", encoding="utf-8") as f:
        content = await f.read()
    
    # Парсим через csv.DictReader (поддерживает многострочные поля)
    reader = csv.DictReader(content.splitlines())
    columns = reader.fieldnames
    if not columns:
        logger.error("CSV is empty or has no header")
        return
    
    logger.info("CSV columns: %s", columns)
    
    batch = []
    error_count = 0
    idx = 1
    
    async with get_db() as db:
        for row_dict in reader:
            doc = _parse_row(row_dict, idx)
            if doc is None:
                error_count += 1
                continue
            batch.append(doc)
            idx += 1
            if len(batch) >= settings.batch_size:
                await _process_batch(db, batch)
                batch = []
        if batch:
            await _process_batch(db, batch)
    
    await es_client.indices.refresh(index=settings.es_index)
    logger.info("Data loading completed with %s errors", error_count)

async def load_from_url(url: str, target_path: Path) -> None:
    target_path.parent.mkdir(parents=True, exist_ok=True)
    logger.info("Downloading %s ...", url)
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        async with aiofiles.open(target_path, "wb") as f:
            await f.write(resp.content)
    await load_csv_from_file(target_path)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Загрузка данных из CSV")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--csv", type=Path, help="Путь к локальному CSV")
    group.add_argument("--url", help="URL для скачивания CSV")
    args = parser.parse_args()
    if args.csv:
        asyncio.run(load_csv_from_file(args.csv))
    elif args.url:
        asyncio.run(load_from_url(args.url, settings.csv_path))
    else:
        print("Укажите --csv или --url")