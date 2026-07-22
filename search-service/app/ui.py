from pathlib import Path
from typing import Optional

TEMPLATE_PATH = Path(__file__).parent / "templates" / "index.html"


def render_page(
    query: str = "", results: Optional[list] = None, error: str = ""
) -> str:
    """Возвращает содержимое index.html (статика)."""
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        content = f.read()
    return content
