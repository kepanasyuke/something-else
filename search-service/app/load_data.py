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


def _extract_id(row_dict: dict, idx: int) -> int:
    return int(row_dict["id"]) if "id" in row_dict and row_dict["id"].strip() else idx


def _parse_rubrics(rubrics_str: str) -> list[str]:
    rubrics_str = rubrics_str.strip()
    result = []
    if rubrics_str.startswith("[") and rubrics_str.endswith("]"):
        rubrics = ast.literal_eval(rubrics_str)
        if isinstance(rubrics, list):
            result = rubrics
        else:
            result = [str(rubrics)]
    else:
        result = [r.strip() for r in rubrics_str.split(",") if r.strip()]
    return result


def _build_document(row_dict: dict, idx: int) -> dict | None:
    result = None
    try:
        doc_id = _extract_id(row_dict, idx)
        rubrics = _parse_rubrics(row_dict.get("rubrics", "[]"))
        created_date = row_dict.get("created_date", "").replace(" ", "T")
        result = {
            "id": doc_id,
            "rubrics": json.dumps(rubrics),
            "text": row_dict.get("text", ""),
            "created_date": created_date,
        }
    except (KeyError, ValueError, SyntaxError, Exception) as e:
        logger.warning("Ошибка парсинга строки %s: %s", row_dict, e)
    return result


async def _process_batch(db, batch: list[dict]) -> None:
    if batch:
        results = await asyncio.gather(
            insert_many(db, batch),
            bulk_index_documents(batch, refresh=False),
            return_exceptions=True,
        )
        for i, res in enumerate(results):
            if isinstance(res, Exception):
                logger.error("Batch step %s failed: %s", i, res)
        logger.info("Processed batch of %s documents", len(batch))


def _batch_generator(rows: list[dict], batch_size: int):
    batch = []
    idx = 1
    for row in rows:
        doc = _build_document(row, idx)
        if doc is not None:
            batch.append(doc)
            idx += 1
            if len(batch) >= batch_size:
                yield batch
                batch = []
    if batch:
        yield batch


async def _process_rows(rows: list[dict], db) -> tuple[int, int]:
    total = 0
    errors = 0
    for batch in _batch_generator(rows, settings.batch_size):
        total += len(batch)
        await _process_batch(db, batch)
    return total, errors


async def _read_csv_rows(csv_path: Path) -> tuple[list[dict], bool]:
    content = ""
    async with aiofiles.open(csv_path, "r", encoding="utf-8") as f:
        content = await f.read()
    reader = csv.DictReader(content.splitlines())
    rows = list(reader)
    return rows, bool(rows)


async def load_csv_from_file(csv_path: Path) -> None:
    await init_db()
    await init_index()

    rows, has_rows = await _read_csv_rows(csv_path)
    if not has_rows:
        logger.error("CSV is empty or has no header")
        return

    logger.info("CSV columns: %s", rows[0].keys() if has_rows else [])

    async with get_db() as db:
        total, errors = await _process_rows(rows, db)

    await es_client.indices.refresh(index=settings.es_index)
    logger.info("Data loading completed: %s documents, %s errors", total, errors)


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
