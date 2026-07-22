from pathlib import Path
from typing import List, Optional
from app.models import Document

TEMPLATE_PATH = Path(__file__).parent / "templates" / "index.html"

def _load_svg(name: str) -> str:
    icon_path = Path(__file__).parent / "static" / "icons" / f"{name}.svg"
    if icon_path.exists():
        with open(icon_path, "r", encoding="utf-8") as f:
            return f.read()
    return ""

def render_page(query: str = "", results: Optional[List[Document]] = None, error: Optional[str] = None) -> str:
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        template = f.read()

    results_html = ""
    if results is not None:
        if results:
            rows = []
            for doc in results:
                text_preview = doc.text[:280] + "…" if len(doc.text) > 280 else doc.text
                date_str = doc.created_date.strftime("%d %b %Y, %H:%M")
                rubrics_html = " ".join(f'<span class="rubric">{r}</span>' for r in doc.rubrics)
                rows.append(f"""
                <div class="result-card">
                    <div class="card-header">
                        <span class="doc-id">{_load_svg("file")} #{doc.id}</span>
                        <span class="doc-date">{date_str}</span>
                    </div>
                    <div class="card-body">
                        <p class="doc-text">{text_preview}</p>
                        <div class="doc-rubrics">{rubrics_html}</div>
                    </div>
                    <div class="card-footer">
                        <a href="#" class="detail-link">Подробнее {_load_svg("arrow-right")}</a>
                        <button class="delete-btn" data-id="{doc.id}">{_load_svg("trash")}</button>
                    </div>
                </div>
                """)
            results_html = f"""
            <div class="results-section">
                <div class="results-header">
                    <h2>Результаты поиска</h2>
                    <span class="result-count">{len(results)} документов</span>
                </div>
                <div class="results-grid">
                    {''.join(rows)}
                </div>
            </div>
            """
        else:
            results_html = f"""
            <div class="empty-state">
                <div class="empty-icon">🔍</div>
                <h3>Ничего не найдено</h3>
                <p>По запросу «{query}» документов не найдено. Попробуйте изменить запрос.</p>
            </div>
            """
    if error:
        results_html = f"""
        <div class="error-state">
            <span class="error-icon">⚠️</span>
            <span class="error-text">{error}</span>
        </div>
        """

    return template.replace("{{ search_icon }}", _load_svg("search")) \
                   .replace("{{ speaker_icon }}", _load_svg("speaker")) \
                   .replace("{{ mute_icon }}", _load_svg("mute")) \
                   .replace("{{ query }}", query) \
                   .replace("{{ results_html }}", results_html)