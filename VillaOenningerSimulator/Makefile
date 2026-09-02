# Makefile для управления симулятором Villa Oenninger в Codespaces

UNITY_PATH ?= $(shell command -v Unity 2>/dev/null || command -v unity 2>/dev/null || true)
UNITY_IMAGE ?= unityci/editor:ubuntu-2022.3.76f1-webgl-3.2.2
PORT ?= 8000
HOST ?= 0.0.0.0

.PHONY: all setup build-webgl build-webgl-docker serve play play-docker clean help

all: setup

setup:
	@command -v python3 >/dev/null || (echo "Ошибка: python3 не найден." && exit 1)
	@mkdir -p Builds/WebGL Assets/Scenes
	@if [ -z "$(UNITY_PATH)" ]; then \
		echo "Unity не найден. Укажите путь: make UNITY_PATH=/path/to/Unity play"; \
	else \
		echo "Unity: $(UNITY_PATH)"; \
	fi

help:
	@echo "Доступные команды:"
	@echo "  make build-webgl  - Собрать WebGL-версию игры (требует Unity)"
	@echo "  make build-webgl-docker - Собрать через публичный Docker-образ Unity"
	@echo "  make serve        - Запустить веб-сервер для готовой WebGL-сборки"
	@echo "  make play         - Собрать WebGL и сразу запустить сервер"
	@echo "  make play-docker  - Собрать через Docker и запустить сервер"
	@echo "  make clean        - Удалить временные файлы сборки"

build-webgl:
	@echo "🌐 Сборка WebGL-версии..."
	@if [ -z "$(UNITY_PATH)" ]; then \
		echo "Ошибка: Unity не найден. Укажите путь через UNITY_PATH."; \
	exit 1; \
	fi
	mkdir -p Builds/WebGL
	$(UNITY_PATH) -batchmode -quit -projectPath . -executeMethod WebGLBuilder.Build -logFile build.log
	@echo "✅ Сборка завершена. Логи: build.log"

build-webgl-docker:
	@command -v docker >/dev/null || (echo "Ошибка: docker не найден." && exit 1)
	@mkdir -p Builds/WebGL
	docker run --rm --name villa-unity-build -v "$(CURDIR):/project" $(UNITY_IMAGE) /opt/unity/Editor/Unity -batchmode -quit -nographics -projectPath /project -executeMethod WebGLBuilder.Build -logFile -

play-docker: build-webgl-docker serve

serve:
	@test -f Builds/WebGL/index.html || (echo "Ошибка: Builds/WebGL/index.html не найден. Сначала выполните make build-webgl в Unity." && exit 1)
	@echo "Запуск сервера на http://$(HOST):$(PORT)"
	cd Builds/WebGL && python3 -m http.server $(PORT) --bind $(HOST)

play: build-webgl serve

clean:
	@echo "🧹 Очистка директорий сборки..."
	rm -rf bin/ obj/ Builds/
	@echo "Готово."
