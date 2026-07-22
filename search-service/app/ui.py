from pathlib import Path

TEMPLATE_PATH = Path(__file__).parent / "templates" / "index.html"


def render_page() -> str:
    """Возвращает содержимое index.html (статика)."""
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        return f.read()
