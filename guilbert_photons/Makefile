PYTHON ?= python3
PIP ?= pip3
UVICORN ?= uvicorn
HOST ?= 0.0.0.0
PORT ?= 8000
CORPUS_TARGET ?= 5000

.PHONY: help install build-corpus run stop kill-port clean check

help:
	@printf '%s\n' \
		'Команды Guilbert Photons:' \
		'  make install       установить зависимости Python' \
		'  make build-corpus  обновить корпус OpenAlex' \
		'                    пример: CORPUS_TARGET=3000 make build-corpus' \
		'  make run           освободить порт и запустить FastAPI' \
		'  make stop          остановить процесс на PORT (по умолчанию 8000)' \
		'  make kill-port     принудительно освободить PORT' \
		'  make check         проверить синтаксис, return/exit и API' \
		'  make clean         удалить локальные артефакты'

install:
	$(PIP) install -r requirements.txt

build-corpus:
	CORPUS_TARGET=$(CORPUS_TARGET) $(PYTHON) scripts/build_corpus.py

run: kill-port
	$(UVICORN) app.main:app --host $(HOST) --port $(PORT) --reload

stop: kill-port

kill-port:
	@pids="$$(lsof -tiTCP:$(PORT) -sTCP:LISTEN 2>/dev/null)"; \
	if [ -n "$$pids" ]; then \
		kill $$pids; \
		printf 'Порт %s освобождён (PID: %s)\n' '$(PORT)' "$$pids"; \
	else \
		printf 'Порт %s свободен\n' '$(PORT)'; \
	fi

check:
	$(PYTHON) -m py_compile app/*.py scripts/*.py
	$(PYTHON) scripts/check_returns.py app scripts
	$(PYTHON) -c "from fastapi.testclient import TestClient; from app.main import app; c = TestClient(app); assert c.get('/health').json() == {'status': 'ok'}; assert c.get('/').status_code == 200; print('health: ok')"

clean:
	rm -rf __pycache__ app/__pycache__ scripts/__pycache__ .pytest_cache
	rm -f *.pptx *.xlsx *.png app/*.pptx app/*.xlsx app/*.png
