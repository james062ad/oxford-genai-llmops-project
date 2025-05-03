# Makefile for Oxford GenAI LLMOps Project

# -----------------------------------------------------------------------------
# 1. Install all dependencies (including dev dependencies)
# -----------------------------------------------------------------------------
install:
	poetry install

# -----------------------------------------------------------------------------
# 2. Run unit tests only
# -----------------------------------------------------------------------------
.PHONY: test-unit
test-unit:
	poetry install --no-root
	poetry run pytest -q

# -----------------------------------------------------------------------------
# 3. Launch the FastAPI application with auto-reload
# -----------------------------------------------------------------------------
.PHONY: run-app
run-app:
	poetry install --no-root
	poetry run uvicorn oxford_genai_llmops_project.main:app \
		--reload --host 0.0.0.0 --port 8000

# -----------------------------------------------------------------------------
# 4. Build & start the Postgres + pgvector container
# -----------------------------------------------------------------------------
.PHONY: build-db
build-db:
	docker-compose --env-file .env \
		-f rag-app/deploy/docker/postgres/docker-compose.yaml \
		up --build

# -----------------------------------------------------------------------------
# 5. Spin up Ollama (local LLM) container
# -----------------------------------------------------------------------------
.PHONY: run-ollama
run-ollama:
	docker-compose --env-file .env \
		-f rag-app/deploy/docker/ollama/docker-compose.yaml \
		up --build

# -----------------------------------------------------------------------------
# 6. Tear down all infra (DB + Ollama)
# -----------------------------------------------------------------------------
.PHONY: down
down:
	docker-compose -f rag-app/deploy/docker/postgres/docker-compose.yaml down || true
	docker-compose -f rag-app/deploy/docker/ollama/docker-compose.yaml down  || true
