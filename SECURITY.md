# Security

Aligned with **specs/_meta.md** and SRS (FR 5.0, NFR 1.x, tenant isolation).

## Key rules

- **No keys in code or config.** Wallet private keys and seeds live only in a secrets manager; injected at runtime. Never log or embed in repo.
- **Tenant isolation.** One agent’s memories and financial assets are not visible or usable by another tenant.
- **MCP-only external interaction.** No direct API calls from agent core; all perception and action via MCP.
- **Governance.** No bypass of Judge/HITL/CFO; no auto-approve of sensitive-topic content; OCC enforced on commit.

## CI security checks

- **Bandit** — high-severity issues on `tests/` and `skills/` (`make security`).
- **pip-audit** — known vulnerabilities in dependencies.

Both run in Docker on every push/PR (`.github/workflows/ci.yml`).

## Reporting

Report vulnerabilities via the repository’s preferred channel (e.g. security advisory or maintainer contact). Do not open public issues for sensitive findings.
