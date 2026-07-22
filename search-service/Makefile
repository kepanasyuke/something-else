.PHONY: help install install-dev run lint format type-check audit docker-build docker-up clean env kill-port

PORT := 8000

help:
	@echo "Доступные команды:"
	@echo "  install          - Установка основных зависимостей"
	@echo "  install-dev      - Установка зависимостей для разработки (flake8, black, mypy, pip-audit и др.)"
	@echo "  run              - Запуск сервиса локально (порт $(PORT))"
	@echo "  lint             - Проверка стиля кода (flake8 с лимитом 100 символов + black --check)"
	@echo "  format           - Автоформатирование кода (black)"
	@echo "  type-check       - Проверка типов (mypy, игнорируя отсутствие библиотечных стабов)"
	@echo "  audit            - Проверка уязвимостей зависимостей (pip-audit)"
	@echo "  docker-build     - Сборка Docker-образов"
	@echo "  docker-up        - Запуск контейнеров (создаёт папку data с правами 777)"
	@echo "  clean            - Очистка временных файлов"
	@echo "  env              - Создать .env из .env.example"
	@echo "  kill-port        - Принудительно завершить процесс, занимающий порт $(PORT)"

install:
	pip install -r requirements.txt

install-dev:
	pip install -r requirements-dev.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $(PORT)

lint:
	flake8 app/ --max-line-length=100
	black --check app/

format:
	black app/

type-check:
	mypy app/ --ignore-missing-imports

audit:
	pip-audit --requirement requirements.txt

docker-build:
	docker-compose build

docker-up:
	mkdir -p data && chmod 777 data
	docker-compose up -d

env:
	cp .env.example .env
	@echo "Создан .env файл. Отредактируйте при необходимости."

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .pytest_cache -exec rm -rf {} +
	rm -rf htmlcov coverage.xml .coverage
	rm -rf data/*.db

kill:
	@echo "Проверка порта $(PORT)..."
	@lsof -ti :$(PORT) > /dev/null 2>&1 || (echo "Порт $(PORT) свободен" && exit 0)
	@PID=$$(lsof -ti :$(PORT)); \
	echo "Завершение процесса с PID $$PID на порту $(PORT)"; \
	kill -9 $$PID 2>/dev/null || echo "Не удалось завершить процесс (возможно, уже завершён)"
	@echo "Порт $(PORT) освобождён."

