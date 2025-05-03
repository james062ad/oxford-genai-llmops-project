# Makefile for Oxford GenAI LLMOps Project

# Load .env from project root if present
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ──────────────────────────────────────────────────────────────
# 1. Install all Python dependencies (including dev)
# ──────────────────────────────────────────────────────────────
install:
	poetry install --no-interaction

# ──────────────────────────────────────────────────────────────
# 2. Build & launch Postgres + pgvector
# ──────────────────────────────────────────────────────────────
run-postgres:
	docker-compose --env-file .env \
		-f rag-app/deploy/docker/postgres/docker-compose.yaml \
		up --build -d

# ──────────────────────────────────────────────────────────────
# 3. Download sample papers JSONs (80 total)
# ──────────────────────────────────────────────────────────────
download-data:
	cd rag-app && poetry run python ./server/src/ingestion/arxiv_client.py

# ──────────────────────────────────────────────────────────────
# 4. Ingest downloaded JSON → Postgres papers table
# ──────────────────────────────────────────────────────────────
run-ingestion:
	cd rag-app && poetry run python ./server/src/ingestion/pipeline.py

# ──────────────────────────────────────────────────────────────
# 5. Verify ingestion in containerized Postgres
# ──────────────────────────────────────────────────────────────
verify-ingestion:
	@echo "Counting rows in papers table:"
	docker exec -it postgres-postgres-1 \
	  psql -U $$POSTGRES_USER -d $$POSTGRES_DB -c "SELECT COUNT(*) FROM papers;"

# ──────────────────────────────────────────────────────────────
# 6. (Optional) Tear down Postgres
# ──────────────────────────────────────────────────────────────
down-postgres:
	docker-compose --env-file .env \
		-f rag-app/deploy/docker/postgres/docker-compose.yaml down

.PHONY: install run-postgres download-data run-ingestion verify-ingestion down-postgres
