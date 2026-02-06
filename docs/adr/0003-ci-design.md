# ADR 0003: CI design (Docker-based governance)

## Status

Accepted.

## Context

We need repeatable lint, security, and test runs that match production runtime and avoid “works on my machine” and dependency drift.

## Decision

- **Single Docker image** (Dockerfile) for build and all pipeline steps. No host Python in CI; no installing project deps on the runner.
- **Governance pipeline:** Lint (Ruff), security (Bandit + pip-audit), test (pytest) run inside the container via Makefile targets; CI workflow runs these on every push/PR.
- **Scope:** Lint and security target `tests/` and `skills/`; tests cover the same. Broader codebase included when backend/frontend implementations grow.

## Consequences

- Consistent environment; contributors and agents run the same commands locally (e.g. `make lint`, `make test`) as in CI.
- Slower first run due to image build; cached images reduce this.

Reference: specs/cicd.md, .github/workflows/ci.yml, Makefile.
