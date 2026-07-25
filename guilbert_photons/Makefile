# ===== КОНФИГУРАЦИЯ И ПЕРЕМЕННЫЕ =====
PYTHON = python3
PIP = pip3
UVICORN = uvicorn
APP_MODULE = main:app
HOST = 0.0.0.0
PORT = 8000

# Переменные Docker
IMAGE_NAME = search-service-hub
CONTAINER_NAME = quantum-search-container

# Цвета для красивого вывода в терминал
CYAN = \033[0.5;36m
GREEN = \033[0.5;32m
NC = \033[0m

.PHONY: help install run build-container run-container stop-container clean kill 

# ===== КОМАНДЫ СПРАВКИ И ИНИЦИАЛИЗАЦИИ =====

help:
	@echo "$(CYAN)Доступные команды локального Makefile:$(NC)"
	@echo "  make install        - Установить все необходимые Python-библиотеки"
	@echo "  make run            - Запустить локальный сервер FastAPI в режиме разработки"
	@echo "  make clean          - Удалить кэш Python и сгенерированные файлы презентаций"
	@echo "$(CYAN)Доступные команды для Docker:$(NC)"
	@echo "  make build-container - Собрать Docker-образ поискового хаба"
	@echo "  make run-container   - Запустить Docker-контейнер на порту $(PORT)"
	@echo "  make stop-container  - Остановить и удалить активный Docker-контейнер"

install:
	@echo "$(GREEN)>>>> Установка необходимых B2B-компонентов...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install fastapi uvicorn matplotlib python-pptx pydantic

# ===== КОМАНДЫ ЗАПУСКА И РАЗРАБОТКИ =====

run:
	@echo "$(GREEN)>>>> Запуск FastAPI REST Engine на http://$(HOST):$(PORT)...$(NC)"
	$(UVICORN) $(APP_MODULE) --host $(HOST) --port $(PORT) --reload

# ===== УПРАВЛЕНИЕ КОНТЕЙНЕРИЗАЦИЕЙ (DOCKER) =====

build-container:
	@echo "$(GREEN)>>>> Сборка Docker-образа [$(IMAGE_NAME)]...$(NC)"
	docker build -t $(IMAGE_NAME) .

run-container:
	@echo "$(GREEN)>>>> Запуск контейнера [$(CONTAINER_NAME)] на порту $(PORT)...$(NC)"
	docker run -d -p $(PORT):$(PORT) --name $(CONTAINER_NAME) $(IMAGE_NAME)
	@echo "$(GREEN)>>>> Контейнер запущен успешно. Проверка здоровья: http://localhost:$(PORT)/health$(NC)"

stop-container:
	@echo "$(GREEN)>>>> Остановка и зачистка Docker-контейнера...$(NC)"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

# ===== СИСТЕМНАЯ ЗАЧИСТКА =====

clean:
	@echo "$(GREEN)>>>> Очистка временных файлов и кэша компиляции...$(NC)"
	rm -rf __pycache__ .pytest_cache
	rm -rf app/__pycache__
	rm -f *.pptx *.xlsx *.png *.csv
	@echo "$(GREEN)>>>> Очистка завершена успешно.$(NC)"

# Мгновенно находит PID процесса main.py и уничтожает его сигналом -9
kill:
	@echo "\033[0.5;31m⚠️  Запуск принудительного завершения процессов (KILL)...\033[0m"
	-pkill -9 -f "main.py" || true
	-pkill -9 -f "uvicorn" || true
	@echo "\033[0.5;32m✅ Все фоновые процессы Python успешно уничтожены.\033[0m"

# Экстренное освобождение порта, если Uvicorn завис в состоянии TIME_WAIT
kill-port:
	@echo "\033[0.5;31m🧹 Сканирование и принудительная очистка порта $(PORT)...\033[0m"
	-lsof -t -i:$(PORT) | xargs kill -9 2>/dev/null || true
	@echo "\033[0.5;32m✅ Порт $(PORT) полностью свободен и готов к запуску.\033[0m"
