# Search Service

Сервис полнотекстового поиска по документам с использованием **FastAPI**, **SQLite** и **Elasticsearch**.

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
- **87% покрытие** тестами (pytest + coverage).

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
├── tests/               # Модульные тесты (87% покрытие)
├── .env.example         # Пример переменных окружения
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

### 1. Клонируйте репозиторий

```bash
git clone <repository-url>
cd search-service
```

### 2. Создайте виртуальное окружение и установите зависимости

```bash
make install
```

Или вручную:

```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Настройте окружение

```bash
make env
```

Эта команда скопирует `.env.example` в `.env`. При необходимости отредактируйте параметры (см. раздел «Конфигурация»).

### 4. Запустите Elasticsearch

Локально через Docker:

```bash
docker run -d -p 9200:9200 -e "discovery.type=single-node" elasticsearch:8.11.0
```

Или используйте `docker-compose up -d` (если есть `docker-compose.yml`).

### 5. Загрузите данные

Автоматически при первом запуске, если есть `posts.csv` в папке `data/`.

### 6. Запустите сервер

```bash
make run
```

Сервис будет доступен по адресу: `http://localhost:8000`

## Использование

### Веб-интерфейс

Откройте `http://localhost:8000`, введите запрос в поле поиска.

### API

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| `POST` | `/search` | Полнотекстовый поиск с пагинацией (параметры: `query`, `limit`, `offset`) |
| `DELETE` | `/documents/{id}` | Удаление документа по ID |
| `GET` | `/health` | Проверка состояния сервиса |

### Документация API

Доступна по адресу `/docs` (Swagger UI).

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
| `make kill` | Принудительно завершить процесс, занимающий порт 8000 |
| `make kill-es` | Принудительно завершить процесс, занимающий порт 9200 |
| `make kill-all` | Завершить процессы на портах 8000 и 9200 |
| `make test` | Запуск тестов (pytest) |
| `make test-coverage` | Запуск тестов с отчётом о покрытии |
| `make test-watch` | Автоматический перезапуск тестов при изменениях |

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

## Тестирование и покрытие

Проект имеет **87% покрытие кода тестами**. Для запуска тестов с отчётом о покрытии выполните:

```bash
make test-coverage
```

Отчёт будет сгенерирован в папке `htmlcov/` и автоматически открыт в браузере (или доступен по адресу `http://localhost:8080`, если браузер недоступен).

## Лицензия

MIT

---

**Автор**: Кристина Панасюк  



