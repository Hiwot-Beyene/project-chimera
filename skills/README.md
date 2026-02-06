# Skills — Project Chimera

This directory holds **Skills**: reusable, documented capabilities that agents (or developers) invoke to perform a well-scoped task in the Chimera ecosystem. This README defines what a Skill is, the rules Skills must follow, input/output expectations, and MCP usage. No implementation is specified here.

**Spec:** Runtime Skills are defined here; separation from Developer MCPs and interface index: `specs/tooling_and_skills.md`.

---

## What a Skill Is

- **Skill:** A named, single-responsibility capability. It has a clear purpose, a defined input/output contract, and a set of rules it must obey. It is invoked by an agent or a developer to achieve one kind of outcome (e.g. “fetch trends,” “validate content,” “check budget”).
- **Scope:** A Skill does one thing. It does not orchestrate the full Planner–Worker–Judge loop; it supports one step or one concern within the system. Skills may be used by Planner, Worker, Judge, or tooling, depending on the Skill’s definition.
- **Reusability:** The same Skill can be invoked in multiple contexts (e.g. different agents, different queues) as long as the contract and rules are satisfied. Skills are not tied to a single service implementation.
- **Documentation:** Each Skill is described in a way that allows an invoker to know when to use it, what to pass in, what to expect out, and what constraints apply. The description is the source of truth for the Skill’s behavior.

---

## Rules Skills Must Follow

1. **Spec alignment.** A Skill’s behavior and contracts must align with Project Chimera specs (`specs/_meta.md`, `specs/functional.md`, `specs/technical.md`). It must not violate hard constraints, architectural invariants, or “what must NEVER be done.”
2. **Single responsibility.** A Skill implements one capability. It does not combine unrelated concerns (e.g. “fetch trends and post to Twitter” is two Skills or a workflow, not one Skill).
3. **No bypass of governance.** A Skill must not bypass the Judge, HITL, or CFO checks. It may prepare data or call MCP Tools, but it must not commit results to GlobalState, approve content, or execute transactions without going through the defined governance path.
4. **MCP-only for external world.** Any interaction with the outside world (social, news, blockchain, vector DBs) must go through MCP (Resources/Tools). A Skill must not introduce direct API calls from agent logic.
5. **Tenant isolation.** A Skill must not expose or combine data across tenants. Inputs and outputs must be tenant-scoped when they touch agent or user data.
6. **No secrets in Skill definition.** A Skill must not require or document embedding of wallet keys, API keys, or seeds in code or config. Secrets are provided at runtime (e.g. via environment or MCP/secrets manager); the Skill describes only the shape of inputs/outputs and any non-secret configuration.
7. **Traceability.** A Skill’s documentation must state which spec items or user stories it supports (e.g. functional story IDs, technical contract names). This allows changes to be traced from spec to Skill.

---

## Input/Output Contract Expectations

- **Input contract.** Each Skill declares:
  - **Required inputs:** Names, types, and meaning. The invoker must supply these for the Skill to run correctly.
  - **Optional inputs:** Names, types, defaults, and meaning.
  - **Context assumptions:** Any assumed context (e.g. “caller is a Worker,” “MCP Host is connected,” “tenant_id is set”). The Skill does not define how that context is established; it states what it assumes.
- **Output contract.** Each Skill declares:
  - **Success outputs:** Shape and meaning of what is returned (e.g. a list of trend objects, a validation result). Types or schema references should be stated so that downstream logic (e.g. Judge, Planner) can rely on them.
  - **Failure/error:** How the Skill signals failure (e.g. error code, exception type, or structured error payload). The invoker must be able to distinguish success from failure and handle both.
  - **Side effects:** Any observable side effects (e.g. “calls MCP Resource X,” “writes to queue Y”). The Skill does not hide side effects; they are part of the contract.
- **Idempotency and ordering.** If the Skill’s behavior depends on idempotency or ordering, that must be stated. Otherwise, callers must not assume idempotency or a specific call order.
- **No implementation.** The README and Skill docs describe contracts and rules only. Actual types, function signatures, or code live in implementation artifacts (e.g. codebase, OpenAPI, or MCP tool definitions), not in this Skills README.

---

## MCP Usage Requirements

- **External data and actions.** When a Skill needs to read external data (e.g. trends, mentions, market data) or perform external actions (e.g. post, transfer), it must do so via MCP Resources or MCP Tools. The Skill description must name the MCP primitives it uses (e.g. resource URIs, tool names) and the expected request/response shape, not the underlying third-party API.
- **Discovery.** A Skill that uses MCP must state which MCP Server(s) it depends on and what capabilities it uses (Resources, Tools, or Prompts). This allows the runtime to ensure those servers are available and connected before the Skill is invoked.
- **No direct API.** A Skill must not document or require direct calls to social, news, blockchain, or vector-DB APIs from the agent core. All such access is through MCP. Developer-only tooling (e.g. for testing) may call APIs directly but must not be part of the agent-facing Skill contract.
- **Secrets and credentials.** If an MCP Server or Tool requires credentials, the Skill describes that dependency (e.g. “requires MCP server X to be configured with credentials Y”) without specifying how secrets are stored or injected. Secret handling follows the project’s tooling strategy (secrets manager, env at startup, no keys in repo).
