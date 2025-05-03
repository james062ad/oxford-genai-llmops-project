# Makefile

# include any .env in the root to pick up POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, POSTGRES_PORT
-include .env

# defaults
POSTGRES_USER ?= postgres
POSTGRES_PASSWORD ?= postgres
POSTGRES_DB ?= postgres
POSTGRES_PORT ?= 5432

.PHONY: build-db start-db stop-db db-status

# 1. Build the Postgres + pgvector image
build-db:
	@echo "🔧 Building PostgreSQL + pgvector image..."
	docker build \
	  --file pgvector2.Dockerfile \
	  --tag oxford-genai-db:latest \
	  .

# 2. Start it (detached)
start-db: build-db
	@echo "🚀 Starting database container..."
	docker run --rm -d \
	  --name oxford-genai-db \
	  -e POSTGRES_USER=$(POSTGRES_USER) \
	  -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	  -e POSTGRES_DB=$(POSTGRES_DB) \
	  -p $(POSTGRES_PORT):5432 \
	  oxford-genai-db:latest

# 3. Stop it
stop-db:
	@echo "🛑 Stopping database container..."
	docker stop oxford-genai-db || true

# 4. Check status
db-status:
	@docker ps --filter "name=oxford-genai-db"
