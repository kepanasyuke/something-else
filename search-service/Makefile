.PHONY: help install install-dev run lint format type-check audit docker-build docker-up clean env kill kill-all test test-coverage test-watch

PORT := 8000
ES_PORT := 9200

help:
	@echo "Доступные команды:"
	@echo "  install          - Установка зависимостей"
	@echo "  run              - Запуск сервиса локально (порт $(PORT))"
	@echo "  lint             - Проверка стиля кода (flake8 с лимитом 100 символов + black --check)"
	@echo "  format           - Автоформатирование кода (black)"
	@echo "  audit            - Проверка уязвимостей зависимостей (pip-audit)"
	@echo "  docker-build     - Сборка Docker-образов"
	@echo "  docker-up        - Запуск контейнеров (создаёт папку data с правами 777)"
	@echo "  kill             - Принудительно завершить процесс на порту $(PORT) (приложение)"
	@echo "  kill-es          - Принудительно завершить процесс на порту $(ES_PORT) (Elasticsearch)"
	@echo "  kill-all         - Завершить процессы на портах $(PORT) и $(ES_PORT)"
	@echo "  test             - Запуск тестов (pytest)"
	@echo "  test-coverage    - Запуск тестов с отчётом о покрытии"
	@echo "  test-watch       - Автоматический перезапуск тестов при изменениях"
	@echo "  clean            - Очистка временных файлов"

install:
	pip install -r requirements.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $(PORT)

lint:
	flake8 app/ --max-line-length=101
	black --check app/

format:
	black app/

audit:
	pip-audit --requirement requirements.txt

docker-build:
	docker-compose build

docker-up:
	mkdir -p data && chmod 777 data
	docker-compose up -d

kill:
	@echo "Проверка порта $(PORT)..."
	@lsof -ti :$(PORT) > /dev/null 2>&1 || (echo "Порт $(PORT) свободен" && exit 0)
	@PID=$$(lsof -ti :$(PORT)); \
	echo "Завершение процесса с PID $$PID на порту $(PORT)"; \
	kill -9 $$PID 2>/dev/null || echo "Не удалось завершить процесс (возможно, уже завершён)"
	@echo "Порт $(PORT) освобождён."

kill-es:
	@echo "Проверка порта $(ES_PORT)..."
	@lsof -ti :$(ES_PORT) > /dev/null 2>&1 || (echo "Порт $(ES_PORT) свободен" && exit 0)
	@PID=$$(lsof -ti :$(ES_PORT)); \
	echo "Завершение процесса с PID $$PID на порту $(ES_PORT)"; \
	kill -9 $$PID 2>/dev/null || echo "Не удалось завершить процесс (возможно, уже завершён)"
	@echo "Порт $(ES_PORT) освобождён."

kill-all: kill kill-es

PYTHONPATH := .

test:
	PYTHONPATH=$(PYTHONPATH) pytest tests/ -v 

test-coverage:
	PYTHONPATH=$(PYTHONPATH) pytest tests/ --cov=app --cov-report=term-missing --cov-report=html
	
	@echo "Opening coverage report..."
	@(open htmlcov/index.html 2>/dev/null || xdg-open htmlcov/index.html 2>/dev/null || echo "No browser found; open htmlcov/index.html manually")
    
	@python -c "import webbrowser; webbrowser.open('htmlcov/index.html')" 2>/dev/null || echo "Browser not available, open htmlcov/index.html manually"

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .pytest_cache -exec rm -rf {} +
	rm -rf htmlcov coverage.xml .coverage
	rm -rf data/*.db