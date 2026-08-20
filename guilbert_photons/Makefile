PYTHON ?= python3
PIP ?= pip3
UVICORN ?= uvicorn
HOST ?= 0.0.0.0
PORT ?= 8000
CORPUS_TARGET ?= 5000

.PHONY: help install build-corpus run clean check

help:
	@printf '%s\n' \
		'make install       Install Python dependencies' \
		'make build-corpus  Refresh the OpenAlex corpus' \
		'                   use CORPUS_TARGET=3000,5000,8000' \
		'make run           Start the FastAPI observatory' \
		'make check         Run syntax and API smoke checks' \
		'make clean         Remove generated local files'

install:
	$(PIP) install -r requirements.txt

build-corpus:
	CORPUS_TARGET=$(CORPUS_TARGET) $(PYTHON) scripts/build_corpus.py

run:
	$(UVICORN) main:app --host $(HOST) --port $(PORT) --reload

check:
	$(PYTHON) -m py_compile main.py
	$(PYTHON) -c "from fastapi.testclient import TestClient; from main import app; c = TestClient(app); assert c.get('/health').json() == {'status': 'ok'}; print('health: ok')"

clean:
	rm -rf __pycache__ .pytest_cache scripts/__pycache__
	rm -f *.pptx *.xlsx *.png
