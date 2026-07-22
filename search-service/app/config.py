from pydantic_settings import BaseSettings
from pathlib import Path


class Settings(BaseSettings):
    """Настройки приложения, загружаемые из .env."""

    database_url: str = "./data/documents.db"
    es_host: str = "http://localhost:9200"
    es_index: str = "documents"
    search_size: int = 20
    batch_size: int = 1000
    log_level: str = "INFO"
    sqlite_synchronous: str = "NORMAL"
    es_request_timeout: int = 30
    es_chunk_size: int = 500
    csv_path: Path = Path("data/posts.csv")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
