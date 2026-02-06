# Project Chimera — dev/CI image. No application logic; runs test suite only.
# Python version from pyproject.toml requires-python ">=3.12"
FROM python:3.12-slim

WORKDIR /app

# Deterministic install from lock file; no dev deps
COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir uv \
    && uv sync --frozen --no-dev

# pytest and ruff for CI (not in project deps)
RUN pip install --no-cache-dir pytest ruff

# Default: run test suite (expect failures until implementation exists)
CMD ["python", "-m", "pytest", "tests/", "-v"]
