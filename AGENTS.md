# AGENTS.md — Agent intent and policy

Centralized context for AI agents and contributors. Authority: **specs/_meta.md**, **specs/functional.md**, **specs/technical.md**.

## Intent

- **Project Chimera** is an autonomous influencer system: Planner–Worker–Judge swarm, MCP-only external interaction, agentic commerce (e.g. Coinbase AgentKit).
- **Goal:** Consistent, auditable agent behavior; no direct APIs from core; HITL and confidence-based routing; honesty and disclosure.

## Rules for agents

1. **Spec-first.** Never generate or change code without checking **specs/** (e.g. _meta.md, functional.md, technical.md). If a feature is not in the specs, do not invent it—align or flag the gap.
2. **Traceability.** Before coding, state which spec item or user story the change satisfies; then implement.
3. **Spec supremacy.** If SRS, docs, or code conflict with specs/, specs/ wins. Update code and docs to match specs.
4. **MCP and Git.** For edits and runs, follow MCP governance (e.g. tenxfeedbackanalytics first; use GitHub MCP for GitHub operations, Git for local operations) as defined in `.cursor/rules/mcp-governance.mdc`.

## Where to look

- **Behavior and contracts:** specs/functional.md, specs/technical.md
- **Hard constraints and invariants:** specs/_meta.md
- **Security (AuthN/AuthZ, rate limit, moderation):** specs/security.md
- **Frontend (screens, APIs):** specs/frontend_ux.md
- **MCP runtime config:** config/mcp-servers.json, docs/mcp-config.md
- **Testing (TDD):** specs/testing_strategy.md, tests/
- **Skills and MCP:** specs/tooling_and_skills.md, skills/README.md
- **CI/CD:** specs/cicd.md, .github/workflows/ci.yml, Makefile
- **Architecture decisions:** docs/adr/
