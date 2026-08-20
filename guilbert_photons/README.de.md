# Guilbert Photons

Guilbert Photons ist ein lokales Observatorium für wissenschaftliche Dokumente. Es verbindet eine FastAPI-Suche, eine Phasenvisualisierung, mehrsprachige Navigation und Exporte für Astronomie, Astrophysik, Kosmologie, Quantenphysik und Weltraumforschung.

## Funktionen

- Suche in 5.021 lokalen Datensätzen.
- Suche auf Russisch, Französisch und Deutsch.
- Phasen-Trace-Animation mit Unterstützung für reduzierte Bewegung.
- Export als JPEG, GIF, XLSX und PPTX.
- OpenAlex-Metadaten, Quelllinks und Kennzeichnung des offenen Zugangs.

## Lokaler Start

```bash
make install
make run
```

Öffnen Sie `http://localhost:8000`. `make check` prüft Syntax und Health-Endpunkt. Mit `make build-corpus` wird der OpenAlex-Teil des Korpus aktualisiert.

## Daten und Sprachen

OpenAlex-Einträge sind bibliografische Suchdaten. Das Projekt speichert Titel, Zusammenfassungen, Autoren, Kennungen und Links, verteilt aber keine kopierten Volltexte. Die russischen, französischen und deutschen Einträge sind kurze Navigationszusammenfassungen mit Verweisen auf öffentliche wissenschaftliche Quellen.

Die visuelle Sprache und Interaktionen sind in `DESIGN.md` beschrieben.