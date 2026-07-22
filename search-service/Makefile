.PHONY: help install run test coverage coverage-html coverage-xml coverage-fail lint type-check audit docker-build docker-up clean env

help:
	@echo "Доступные команды:"
	@echo "  install          - Установка зависимостей"
	@echo "  run              - Запуск сервиса локально"
	@echo "  test             - Запуск тестов с покрытием"
	@echo "  coverage         - Генерация HTML-отчёта о покрытии"
	@echo "  coverage-xml     - Генерация XML-отчёта для CI"
	@echo "  coverage-fail    - Проверка покрытия с порогом 80%"
	@echo "  lint             - Проверка стиля кода (ruff)"
	@echo "  type-check       - Проверка типов (mypy)"
	@echo "  audit            - Проверка уязвимостей зависимостей"
	@echo "  docker-build     - Сборка Docker-образов"
	@echo "  docker-up        - Запуск контейнеров"
	@echo "  clean            - Очистка временных файлов"
	@echo "  env              - Создать .env из .env.example"

install:
	pip install -r requirements.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

test:
	pytest -v app/tests/ --cov=app --cov-report=term-missing

coverage:
	pytest --cov=app --cov-report=html
	@echo "HTML-отчёт создан в htmlcov/index.html"

coverage-xml:
	pytest --cov=app --cov-report=xml
	@echo "XML-отчёт создан в coverage.xml"

coverage-fail:
	pytest --cov=app --cov-report=term-missing --cov-fail-under=80

lint:
	ruff check app/
	black --check app/ --diff

type-check:
	mypy app/ --ignore-missing-imports

audit:
	pip-audit --requirement requirements.txt

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

env:
	cp .env.example .env
	@echo "Создан .env файл. Отредактируйте при необходимости."

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .pytest_cache -exec rm -rf {} +
	rm -rf htmlcov coverage.xml .coverage
	rm -rf data/*.db