"""Build a local physics and space mini-wiki from OpenAlex works.

OpenAlex provides bibliographic metadata and abstracts when available. The
result is intended for search and discovery, not as a substitute for the
published full text.
"""

import json
import os
import time
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

OUTPUT_PATH = Path(__file__).parents[1] / "knowledge_base.json"
META_PATH = Path(__file__).parents[1] / "knowledge_base.meta.json"
TARGET_SIZE = int(os.getenv("CORPUS_TARGET", "5000"))
PAGE_SIZE = 200
QUERIES = [
    "astrophysics",
    "cosmology",
    "quantum physics",
    "particle physics",
    "space science",
    "gravitational waves",
    "astronomy",
]
SELECT = ",".join(
    [
        "id",
        "title",
        "publication_date",
        "doi",
        "primary_location",
        "authorships",
        "abstract_inverted_index",
    ]
)


def fetch_page(query: str, page: int) -> dict:
    params = urlencode(
        {
            "filter": f"default.search:{query}",
            "per-page": PAGE_SIZE,
            "page": page,
            "select": SELECT,
        }
    )
    request = Request(
        f"https://api.openalex.org/works?{params}",
        headers={"User-Agent": "GuilbertPhotons/1.0 (local research browser)"},
    )
    with urlopen(request, timeout=45) as response:
        return json.load(response)


def restore_abstract(index: dict | None) -> str:
    words = []
    if index:
        for word, positions in index.items():
            words.extend((position, word) for position in positions)
    abstract = " ".join(word for _, word in sorted(words))
    return abstract


def classify(text: str) -> list[str]:
    terms = text.casefold()
    categories = []
    groups = {
        "астрофизика": ("astrophysics", "stellar", "supernova", "galaxy", "black hole"),
        "космология": ("cosmology", "dark matter", "dark energy", "universe", "inflation"),
        "квантовая физика": ("quantum", "photon", "entanglement", "wave function"),
        "частицы": ("particle", "boson", "neutrino", "hadron", "collider"),
        "гравитация": ("gravity", "gravitational", "relativity", "spacetime"),
        "космические наблюдения": ("telescope", "satellite", "orbit", "space mission", "astronomical"),
    }
    for label, keywords in groups.items():
        if any(keyword in terms for keyword in keywords):
            categories.append(label)
    return categories or ["физика"]


def normalize(work: dict, index: int) -> dict | None:
    title = (work.get("title") or "").strip()
    abstract = restore_abstract(work.get("abstract_inverted_index"))
    document = None
    if len(title) >= 8 and len(abstract) >= 120:
        location = work.get("primary_location") or {}
        source = location.get("source") or {}
        authors = [
            (author.get("author") or {}).get("display_name")
            for author in work.get("authorships", [])[:5]
        ]
        authors = [author for author in authors if author]
        text = f"{title}. {abstract}"
        document = {
            "id": 2000000 + index,
            "language": work.get("language") or "en",
            "title": title,
            "rubrics": classify(text),
            "text": text,
            "created_date": work.get("publication_date"),
            "journal": source.get("display_name"),
            "authors": authors,
            "doi": work.get("doi"),
            "source_url": location.get("landing_page_url"),
            "is_open_access": bool(location.get("is_oa")),
            "openalex_id": work.get("id"),
        }
    return document


def add_page_documents(page: dict, documents: list, seen: set) -> None:
    for work in page.get("results", []):
        unique_key = work.get("id") or work.get("doi") or work.get("title")
        if unique_key not in seen and len(documents) < TARGET_SIZE:
            document = normalize(work, len(documents))
            if document:
                seen.add(unique_key)
                documents.append(document)


def main() -> None:
    documents = []
    seen = set()
    page = 1
    query_index = 0
    while len(documents) < TARGET_SIZE and query_index < len(QUERIES):
        query = QUERIES[query_index]
        payload = fetch_page(query, page)
        add_page_documents(payload, documents, seen)
        if page * PAGE_SIZE >= payload.get("meta", {}).get("count", 0):
            page = 1
            query_index += 1
        else:
            page += 1
        time.sleep(0.15)

    if len(documents) < TARGET_SIZE:
        raise RuntimeError(f"Only collected {len(documents)} usable documents")

    OUTPUT_PATH.write_text(json.dumps(documents, ensure_ascii=False, indent=2), encoding="utf-8")
    META_PATH.write_text(
        json.dumps(
            {
                "provider": "OpenAlex",
                "provider_url": "https://openalex.org/",
                "api_url": "https://api.openalex.org/works",
                "license_note": "Bibliographic metadata and abstracts are collected from OpenAlex. Verify source license before redistributing full text.",
                "document_count": len(documents),
                "supported_search_languages": ["ru", "fr", "de"],
                "curated_annotation_count": 21,
                "queries": QUERIES,
                "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Wrote {len(documents)} documents to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
