# 1. Base image
FROM python:3.12-slim

# 2. Set working directory
WORKDIR /app

# 3. Copy project manifest files
COPY pyproject.toml poetry.lock ./

# 4. Copy your source code so Poetry can install your package
COPY src ./src

# 5. Install Poetry and then all dependencies + your package itself
RUN pip install --no-cache-dir poetry \
  && poetry config virtualenvs.create false \
  && poetry install --no-interaction

# 6. Expose FastAPI’s default port
EXPOSE 8000

# 7. Launch via Uvicorn
CMD ["uvicorn", "oxford_genai_llmops_project.main:app", "--host", "0.0.0.0"]
