# Project Chimera — Makefile
# All commands use Docker; no host Python. Image must provide Python and project deps.
# Image name must be lowercase, no spaces (Docker tag requirement).

IMAGE := project-chimera

# setup: Build the Docker image. Run once (or after Dockerfile/code changes) before test or spec-check.
setup:
	docker build -t $(IMAGE) .

# test: Run the full test suite inside a container. Mounts current dir so latest code is used.
test:
	docker run --rm -v "$(PWD)":/app -w /app $(IMAGE) python -m pytest tests/ -v

# lint: Run Python linter (Ruff) in Docker. Scope: tests/ and skills/. Fails on lint errors. CI governance.
lint:
	docker run --rm -v "$(PWD)":/app -w /app $(IMAGE) ruff check tests/ skills/

# security: Run security checks in Docker. Bandit (code, high-severity only) + pip-audit (deps). CI governance.
security:
	docker run --rm -v "$(PWD)":/app -w /app $(IMAGE) sh -c 'bandit -r tests/ skills/ --severity-level high && pip-audit'

# spec-check: Verify code alignment with specs. Placeholder: ensures specs/ exists and _meta.md is present.
spec-check:
	docker run --rm -v "$(PWD)":/app -w /app $(IMAGE) sh -c 'test -d specs && test -f specs/_meta.md && echo "spec-check placeholder: OK"'
