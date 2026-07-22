import aiosqlite
import logging
from contextlib import asynccontextmanager
from pathlib import Path
from app.config import settings

logger = logging.getLogger(__name__)


def _get_db_path() -> Path:
    db_url = settings.database_url
    if db_url.startswith("sqlite:///"):
        path_str = db_url[10:]
    else:
        path_str = db_url
    return Path(path_str)


def _ensure_db_directory() -> None:
    db_path = _get_db_path()
    db_path.parent.mkdir(parents=True, exist_ok=True)
    logger.info("Database directory ensured: %s", db_path.parent)


async def _execute_create_tables(db):
    await db.execute(
        """
        CREATE TABLE IF NOT EXISTS documents (
            id INTEGER PRIMARY KEY,
            rubrics TEXT NOT NULL,
            text TEXT NOT NULL,
            created_date TEXT NOT NULL
        )
    """
    )
    await db.execute(
        "CREATE INDEX IF NOT EXISTS idx_created_date ON documents(created_date)"
    )


async def _setup_pragmas(db):
    await db.execute("PRAGMA journal_mode=WAL")
    await db.execute(f"PRAGMA synchronous={settings.sqlite_synchronous}")


async def init_db() -> None:
    _ensure_db_directory()
    db_path = _get_db_path()
    try:
        async with aiosqlite.connect(str(db_path)) as db:
            await _setup_pragmas(db)
            await _execute_create_tables(db)
            await db.commit()
            logger.info("DB initialized (synchronous=%s)", settings.sqlite_synchronous)
    except Exception as e:
        logger.error("DB init failed: %s", e)
        raise


@asynccontextmanager
async def get_db():
    db_path = _get_db_path()
    async with aiosqlite.connect(str(db_path)) as db:
        db.row_factory = aiosqlite.Row
        yield db


async def insert_many(db, docs: list[dict]) -> None:
    if docs:
        await db.executemany(
            "INSERT OR REPLACE INTO documents (id, rubrics, text, created_date) VALUES (?, ?, ?, ?)",
            [(d["id"], d["rubrics"], d["text"], d["created_date"]) for d in docs],
        )
        await db.commit()


async def get_documents_by_ids(db, ids: list[int]) -> list[dict]:
    result = []
    if ids:
        placeholders = ",".join("?" * len(ids))
        cursor = await db.execute(
            f"SELECT id, rubrics, text, created_date FROM documents WHERE id IN ({placeholders})",
            ids,
        )
        rows = await cursor.fetchall()
        result = list(map(dict, rows))
    return result


async def delete_document(db, doc_id: int) -> bool:
    cursor = await db.execute("DELETE FROM documents WHERE id = ?", (doc_id,))
    await db.commit()
    return cursor.rowcount > 0
