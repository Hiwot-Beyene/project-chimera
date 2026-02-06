# Contributing

## Spec-first and traceability

- Read **specs/** (_meta.md, functional.md, technical.md) before changing code. Do not add behavior that is not in the specs; align or propose a spec change first.
- When making a change, state which spec item or user story it satisfies. Keep commits traceable to specs.

## TDD

- Write tests first against spec contracts (see specs/testing_strategy.md). Implementation follows until tests pass.
- Run tests: `make test` (Docker). Scope: `tests/` and, where applicable, `skills/`.

## Git hygiene

- **Pre-commit:** Install with `pip install pre-commit && pre-commit install`. Hooks run on `tests/` and `skills/` (trailing whitespace, EOF newline, Black, Ruff).
- **Commits:** Prefer small, focused commits. Message should indicate area and intent (e.g. `skills: add get_required_resources per technical §2.2`).
- **Branches:** Use feature branches for work; open PRs against the main branch. CI runs lint, security, and tests on every push/PR.

## Agentic trajectory and growth

- **Agents and automation:** Follow AGENTS.md and `.cursor/rules/` (spec-first, MCP governance). New capabilities are specified first, then tests, then implementation.
- **Governance pipeline:** Lint (Ruff), security (Bandit, pip-audit), and tests run in Docker via Makefile and `.github/workflows/ci.yml`. Fix failures before merging.
- **Documentation:** Update README, ACCEPTANCE_CRITERIA, or specs when adding user-facing behavior or contracts.

## CI

- `make setup` — build image
- `make lint` — Ruff on tests/ and skills/
- `make security` — Bandit (high) + pip-audit
- `make test` — pytest
- `make spec-check` — placeholder spec presence check

All commands use the project Docker image; no host Python required for CI.
