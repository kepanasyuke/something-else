# Guilbert Photons

Guilbert Photons est un observatoire local de documents scientifiques. Il réunit une recherche FastAPI, une visualisation de phase, une navigation multilingue et des exports pour explorer l'astronomie, l'astrophysique, la cosmologie, la physique quantique et les sciences spatiales.

## Fonctionnalités

- Recherche dans 1 521 notices bibliographiques.
- Recherche en russe, français et allemand.
- Animation de la trace de phase avec prise en charge de la réduction des mouvements.
- Export JPEG, GIF, XLSX et PPTX.
- Métadonnées OpenAlex, liens vers les sources et indication d'accès ouvert.

## Lancement local

```bash
make install
make run
```

Ouvrez `http://localhost:8000`. `make check` vérifie la syntaxe et le endpoint de santé. `make build-corpus` actualise la partie OpenAlex du corpus.

## Données et langues

Les notices OpenAlex sont des données bibliographiques de découverte. Le projet conserve les titres, résumés, auteurs, identifiants et liens, sans redistribuer les articles en texte intégral. Les entrées russes, françaises et allemandes sont de courtes notices de navigation qui renvoient vers des sources scientifiques publiques.

Les choix visuels et les interactions sont décrits dans `DESIGN.md`.