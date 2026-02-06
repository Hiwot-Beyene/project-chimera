# CI/CD — Spec

**Purpose:** Define the basic build pipeline and the governance pipeline (Linting, Security Checks, and Testing) run automatically in Docker. Authority: `specs/_meta.md`, `specs/technical.md`.

---

## 1. Basic Build Pipeline

- **Trigger:** On every push and pull_request (`.github/workflows/ci.yml`).
- **Steps:** Checkout → Build Docker image (`make setup`) → run governance steps (lint, security, test) inside the container.
- **No host Python:** Build and all pipeline steps use the project Docker image; CI does not install Python or dependencies on the runner.
- **Image:** Built from `Dockerfile`; tag `project-chimera`. Contains Python 3.12, project deps (from `pyproject.toml` / `uv.lock`), plus pytest, Ruff, Bandit, and pip-audit for governance.

---

## 2. Governance Pipeline

All governance steps run **automatically in Docker** (same image, `make` targets that `docker run` against the image with the repo mounted).

| Step | Command | Purpose |
|------|---------|---------|
| **Linting** | `make lint` | Ruff on `tests/` and `skills/`. Fails on unused imports, undefined names, trailing whitespace. |
| **Security checks** | `make security` | Bandit (code: high-severity only on `tests/` and `skills/`) and pip-audit (dependencies for known vulnerabilities). Either failure fails the step. |
| **Testing** | `make test` | pytest on `tests/` inside the container. Strategy: `specs/testing_strategy.md`. |

Pipeline fails if any of these steps fails. No step runs host tooling; all use the containerized environment.

---

## 3. Cross-References

- **Workflow:** `.github/workflows/ci.yml`
- **Makefile:** `setup`, `lint`, `security`, `test`
- **Testing:** `specs/testing_strategy.md`
- **Stack:** `specs/technical.md` (Linting/tests row).
