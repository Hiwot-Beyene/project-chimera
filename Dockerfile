# Project Chimera — dev/CI image. No application logic; runs test suite only.
# Python version from pyproject.toml requires-python ">=3.12"
FROM python:3.12-slim

WORKDIR /app

# Deterministic install from lock file; no dev deps
COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir uv \
    && uv sync --frozen --no-dev

# pytest for CMD/default python (not in project deps); use system pip so `python -m pytest` works
RUN pip install --no-cache-dir pytest

# Default: run test suite (expect failures until implementation exists)
CMD ["python", "-m", "pytest", "tests/", "-v"]
