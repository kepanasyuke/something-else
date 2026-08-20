# Guilbert Photons

Guilbert Photons is a local scientific document observatory. It combines a FastAPI search service, a phase-field visualization, multilingual navigation, and export actions for researchers exploring astronomy, astrophysics, cosmology, quantum physics, and space science.

## Features

- Local search across 1,521 bibliographic records.
- Russian, French, and German query aliases and curated annotations.
- Phase trace animation with reduced-motion support.
- JPEG, GIF, XLSX, and PPTX export actions.
- OpenAlex metadata with source links and Open Access flags.

## Run locally

```bash
make install
make run
```

Open `http://localhost:8000`. Use `make check` for a syntax and health smoke check. Use `make build-corpus` to refresh the OpenAlex portion of the corpus.

## Data and language policy

OpenAlex records are bibliographic discovery data. The project stores titles, abstracts, authors, identifiers, and source links; it does not redistribute copied full-text articles. Curated multilingual entries are short navigation annotations that point to public research sources. Supported search languages are Russian (`ru`), Français (`fr`), and Deutsch (`de`).

## Structure

- `main.py` — FastAPI application and search contract.
- `guilbert.html` / `guilbert.css` — observatory interface and animation.
- `knowledge_base.json` — normalized OpenAlex corpus.
- `multilingual_documents.json` — curated Russian, French, and German annotations.
- `scripts/build_corpus.py` — OpenAlex corpus builder.

Further design notes live in `DESIGN.md`.