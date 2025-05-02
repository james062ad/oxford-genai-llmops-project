# Makefile for Oxford GenAI LLMOps Project

# Install all dependencies (including dev dependencies)
install:
	poetry install

# Run unit tests only
.PHONY: test-unit
test-unit:
	poetry install --no-root
	poetry run pytest -q

# Run the FastAPI application with auto-reload
.PHONY: run-app
run-app:
	poetry install --no-root
	poetry run uvicorn oxford_genai_llmops_project.main:app --reload
