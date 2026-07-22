# Поисковый сервис документов

Сервис для полнотекстового поиска по документам с использованием FastAPI, SQLite и Elasticsearch.  
Поддерживает загрузку данных из CSV, индексацию в Elasticsearch, пагинацию, удаление документов и выгрузку результатов в Excel через веб-интерфейс.

## Возможности

- **Загрузка данных** из CSV (локально или по URL).
- **Индексация** в Elasticsearch с поддержкой русского языка.
- **Полнотекстовый поиск** с пагинацией (постраничная загрузка).
- **Веб-интерфейс**: поиск, просмотр, удаление документов, экспорт в XLSX.
- **Подсветка** найденных ключевых слов.
- **REST API** с документацией OpenAPI (`/docs`).
- **Асинхронная работа** с SQLite и Elasticsearch.
- **Код**: принцип «один выход на функцию», нет `break/continue`, функции разбиты на короткие (до 30–50 строк).

## Структура проекта

```
search-service/
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI приложение
│   ├── models.py        # Pydantic-модели
│   ├── config.py        # Настройки (pydantic-settings)
│   ├── db.py            # Работа с SQLite (aiosqlite)
│   ├── es.py            # Работа с Elasticsearch
│   ├── load_data.py     # Загрузка данных из CSV
│   ├── converters.py    # Преобразование данных (row → Document)
│   └── ui.py            # Рендеринг HTML-страницы
├── data/                # Данные (CSV-файлы)
├── static/              # Статические файлы (HTML, CSS, JS)
├── .env.example
├── .gitignore
├── Dockerfile
├── Makefile
├── README.md
├── docker-compose.yml
├── requirements.txt     # Основные зависимости
└── requirements-dev.txt # Зависимости для разработки
```

## Требования

- Python 3.9+
- Elasticsearch (локально или через Docker)
- Установленные зависимости (см. `requirements.txt`)

## Быстрый старт

1. **Клонируйте репозиторий** и перейдите в папку `search-service`.
2. **Создайте виртуальное окружение** и установите зависимости:
   ```bash
   make install
   ```
   Или вручную:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. **Настройте окружение**:
   ```bash
   make env
   ```
   (скопирует `.env.example` в `.env` — при необходимости отредактируйте параметры).
4. **Запустите Elasticsearch** (локально или через Docker):
   ```bash
   docker run -d -p 9200:9200 -e "discovery.type=single-node" elasticsearch:8.11.0
   ```
   Или используйте `docker-compose up -d` (если есть `docker-compose.yml`).
5. **Загрузите данные** (автоматически при первом запуске, если есть `posts.csv` в папке `data/`).
6. **Запустите сервер**:
   ```bash
   make run
   ```
   Сервис будет доступен на `http://localhost:8000`.

## Использование

- **Веб-интерфейс**: откройте `http://localhost:8000`, введите запрос в поле поиска.
- **API**:
  - `POST /search` — полнотекстовый поиск с пагинацией (параметры: `query`, `limit`, `offset`).
  - `DELETE /documents/{id}` — удаление документа по ID.
  - `GET /health` — проверка состояния сервиса.
- **Документация API**: доступна по адресу `/docs` (Swagger UI).

## Команды Makefile

| Команда | Описание |
|---------|----------|
| `make install` | Установка основных зависимостей |
| `make install-dev` | Установка зависимостей для разработки (flake8, black, mypy и др.) |
| `make run` | Запуск сервера (порт 8000) с автоперезагрузкой |
| `make lint` | Проверка стиля кода (flake8 + black --check) |
| `make format` | Автоматическое форматирование кода (black) |
| `make type-check` | Проверка типов (mypy) |
| `make audit` | Проверка уязвимостей зависимостей (pip-audit) |
| `make docker-build` | Сборка Docker-образов |
| `make docker-up` | Запуск контейнеров |
| `make clean` | Очистка временных файлов |
| `make env` | Создать `.env` из `.env.example` |
| `make kill-port` | Принудительно завершить процесс, занимающий порт 8000 |

## Конфигурация (.env)

| Параметр | Описание |
|----------|----------|
| `DATABASE_URL` | Путь к SQLite (по умолчанию `sqlite:///data/documents.db`) |
| `ES_HOST` | Адрес Elasticsearch (по умолчанию `localhost:9200`) |
| `SEARCH_SIZE` | Количество результатов поиска (по умолчанию 30) |
| `BATCH_SIZE` | Размер пачки при загрузке данных (по умолчанию 500) |
| `LOG_LEVEL` | Уровень логирования (`INFO`, `DEBUG` и т.д.) |
| `SQLITE_SYNCHRONOUS` | Режим синхронности SQLite (для продакшена рекомендуется `NORMAL`) |
| `CSV_PATH` | Путь к CSV-файлу с данными (по умолчанию `data/posts.csv`) |

## Лицензия

MIT



