# Project Chimera

Autonomous Influencer Network: a swarm of Planner, Worker, and Judge agents that create and govern content and agentic commerce via MCP. Single source of truth: **specs/** and **docs/** (SRS).

## Stack

| Area | Choice |
|------|--------|
| Language | Python 3.12 |
| Runtime/CI | Docker |
| Linting/Tests | Ruff, pytest |
| Queues / short-term | Redis |
| Transactional state | PostgreSQL |
| Long-term memory | Weaviate |
| External connectivity | MCP only |

## Quick start

```bash
make setup    # build image
make test     # run tests
make lint     # Ruff on tests/ and skills/
make security # Bandit + pip-audit
```

All commands run inside Docker; no host Python required.

## Layout

- **specs/** — _meta, functional, technical, security, frontend_ux, testing, CI/CD, tooling. Specs override all other docs.
- **docs/** — SRS, ADRs (docs/adr/), MCP config doc.
- **config/** — Versioned MCP server config (config/mcp-servers.json).
- **skills/** — Runtime skills (contracts in skills/README.md; implementations under skills/).
- **tests/** — pytest; TDD per specs/testing_strategy.md.
- **.cursor/rules/** — Agent rules (spec-first, MCP governance).
- **.github/workflows/ci.yml** — Lint, security, test on push/PR.

## Architecture decisions

**docs/adr/** — ADRs for DB choice, MCP-only interaction, CI design, and Planner–Worker–Judge roles. See docs/adr/README.md.

## Acceptance criteria

User stories and traceability: **specs/functional.md**. Summary: **ACCEPTANCE_CRITERIA.md**.

## Security

See **SECURITY.md**. Keys never in code; Bandit + pip-audit in CI.

## Agent context

**AGENTS.md** — Centralized agent intent and policy for contributors and AI agents.

## Contributing and git hygiene

**CONTRIBUTING.md** — spec-first workflow, TDD, pre-commit, commit progression, and agentic trajectory. CI runs on every push/PR.

## License

See repository license file.
