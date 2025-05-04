# rag-app/Makefile

install:
	poetry install

run-app:
	poetry run uvicorn server.src.main:app --reload --host 0.0.0.0 --port 8000

test:
	poetry run pytest -q

build-db:
	docker-compose -f deploy/docker/postgres/docker-compose.yaml --env-file .env up -d --build

remove-db:
	docker-compose -f deploy/docker/postgres/docker-compose.yaml --env-file .env down

build-ollama:
	docker-compose -f deploy/docker/llm-server/docker-compose.yml build

run-ollama:
	docker-compose -f deploy/docker/llm-server/docker-compose.yml up -d

remove-ollama:
	docker-compose -f deploy/docker/llm-server/docker-compose.yml down

download-data:
	poetry run python ./rag-app/server/src/ingestion/arxiv_client.py

run-ingestion:
	poetry run python ./rag-app/server/src/ingestion/pipeline.py

test-unit:
	poetry run pytest -q Tests/

aws-list-models:
	aws bedrock list-foundation-models --region us-east-1

aws-invoke-test:
	aws bedrock invoke-model \
	--model-id amazon.titan-text-express-v1 \
	--region us-east-1 \
	--body '{"inputText": "What is perovskite?"}' \
	--content-type application/json \
	--accept application/json
