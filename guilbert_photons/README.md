# Guilbert Photons

## Русский

Guilbert Photons — локальная научная обсерватория документов. Она объединяет поиск FastAPI, фазовую визуализацию, мультиязычные запросы и экспорт результатов для работы с астрономией, астрофизикой, космологией, квантовой физикой и космической наукой.

### Запуск

```bash
make install
make run
```

Откройте <http://localhost:8000>. Команда `make run` перед запуском освобождает порт `PORT` (по умолчанию `8000`). Для ручного управления используйте `make stop PORT=8000` или `make kill-port PORT=8000`.

### Проверки и данные

`make check` проверяет синтаксис, наличие не более одного `return` в каждой Python-функции, отсутствие `exit()` и health/API smoke-check. `make build-corpus` обновляет корпус OpenAlex; размер задаётся через `CORPUS_TARGET`.

### Структура

- `app/` — FastAPI-приложение и backend-контракт.
- `static/` — HTML-интерфейс и CSS.
- `data/` — нормализованный корпус и метаданные.
- `scripts/` — сборка корпуса и статические проверки.
- `DESIGN.md` — пояснительная записка по визуальной системе.

Проект хранит библиографические данные, аннотации и ссылки, но не распространяет полные тексты статей.

## Français

Guilbert Photons est un observatoire local de documents scientifiques. Il réunit une recherche FastAPI, une visualisation de phase, des requêtes multilingues et l’export de résultats pour l’astronomie, l’astrophysique, la cosmologie, la physique quantique et les sciences spatiales.

### Lancement

```bash
make install
make run
```

Ouvrez <http://localhost:8000>. `make run` libère le port `PORT` avant le lancement (8000 par défaut). Utilisez `make stop PORT=8000` ou `make kill-port PORT=8000` pour le gérer manuellement.

### Vérifications et données

`make check` vérifie la syntaxe, limite chaque fonction Python à un seul `return`, interdit `exit()` et exécute un smoke-check de l’API. `make build-corpus` actualise le corpus OpenAlex; sa taille est contrôlée par `CORPUS_TARGET`.

Le projet conserve des métadonnées bibliographiques, des résumés et des liens, mais ne redistribue pas les textes intégraux.

Les documents de conception détaillés sont disponibles dans `DESIGN.md`.
