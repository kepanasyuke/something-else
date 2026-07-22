# Search Service

Сервис поиска по текстам документов с использованием FastAPI, SQLite и Elasticsearch.

## Требования
- Docker & Docker Compose (рекомендуется)
- Python 3.11+ (для локального запуска)

## Быстрый старт
1. Скопируйте `.env.example` в `.env` и настройте под свои нужды.
2. Поместите CSV-файл с данными в `data/posts.csv` (или укажите другой путь в `.env`).
3. Запустите через Docker:
   ```bash
   make docker-build
   make docker-up
   ```
4. Сервис доступен на `http://localhost:8000`. Документация API – `/docs`.

## Локальный запуск
```bash
make install
make run
```

## Команды Make
- `make install` – установка зависимостей
- `make run` – локальный запуск с автоперезагрузкой
- `make test` – запуск тестов с покрытием
- `make coverage` – HTML-отчёт о покрытии
- `make coverage-fail` – проверка покрытия (порог 80%)
- `make lint` – проверка стиля кода (ruff + black)
- `make type-check` – проверка типов (mypy)
- `make audit` – проверка уязвимостей зависимостей
- `make docker-build` / `make docker-up` – сборка и запуск контейнеров
- `make clean` – очистка временных файлов
- `make env` – создать `.env` из примера

## Примеры использования

### Поиск документов
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "политика"}'
```

### Удаление документа
```bash
curl -X DELETE http://localhost:8000/documents/1
```

### Проверка работоспособности
```bash
curl http://localhost:8000/health
```

### Получение OpenAPI-спецификации
```bash
curl http://localhost:8000/openapi.json > docs.json
```

## Конфигурация
Все настройки задаются через переменные окружения в `.env` (см. `.env.example`). Ключевые параметры:
- `DATABASE_URL` – путь к SQLite
- `ES_HOST` – адрес Elasticsearch
- `SEARCH_SIZE` – количество результатов поиска
- `BATCH_SIZE` – размер пачки при загрузке данных
- `LOG_LEVEL` – уровень логирования
- `SQLITE_SYNCHRONOUS` – режим синхронности SQLite (для продакшена рекомендуется `NORMAL`)
- `CSV_PATH` – путь к CSV-файлу с данными

## Структура CSV
Ожидаются колонки: `id` (целое, опционально), `rubrics` (список через запятую или Python-список в виде строки), `text` (текст), `created_date` (ISO-формат или с пробелом).

## Тестирование и анализ
```bash
make test          # запуск тестов
make coverage      # отчёт о покрытии
make lint          # проверка стиля
make type-check    # проверка типов
make audit         # аудит безопасности
```

## Лицензия
MIT
```

