# Install dependencies (including dev deps)
install:
	poetry install

# Run unit tests only
.PHONY: test-unit
test-unit:
	poetry install --no-root
	poetry run pytest -q
