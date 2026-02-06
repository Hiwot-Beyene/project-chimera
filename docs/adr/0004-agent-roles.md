# ADR 0004: Planner–Worker–Judge agent roles

## Status

Accepted.

## Context

We need scalable, auditable execution: goal decomposition, single-task execution, and governance (approve/reject/escalate) without a single monolithic agent.

## Decision

- **Planner:** Reads GlobalState and goals; produces a DAG of tasks; enqueues to TaskQueue; does not execute tasks. Re-plans on rejection or OCC failure. Performs balance check before cost-incurring tasks (FR 5.1, P6).
- **Worker:** Pulls one task at a time; executes only via MCP Tools; returns one Result (artifact + confidence + sensitive_topics_detected) to ReviewQueue. Stateless, shared-nothing; no direct communication with other Workers.
- **Judge:** Consumes Results; Approve (commit if OCC passes), Reject (signal Planner), or Escalate (HITL). Routes by confidence and sensitive-topic rules. CFO Judge reviews all transaction requests and rejects/escales over limit or anomaly.

## Consequences

- Clear separation: planning, execution, and governance are distinct. No bypass of Judge; no single agent that both plans and commits.
- Enables scaling Workers independently and keeps Orchestrator stateless.

Reference: specs/_meta.md (Architectural invariants), specs/functional.md (P*, W*, J* stories), specs/technical.md (contracts §1–§5).
