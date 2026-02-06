# OpenClaw Integration — Specification

**Purpose:** Describe how Project Chimera will publish its availability, status, and capabilities to the OpenClaw network in a future implementation phase. This is an architectural plan only; no implementation, transport, or API details are specified.

**Authority:** SRS, `specs/_meta.md`, `specs/functional.md`, `specs/technical.md`.

---

## 1. Overview

### What OpenClaw Is in Relation to Chimera

OpenClaw acts as a **capability discovery** and **agent registry** layer. From Chimera’s perspective, OpenClaw is the external system where the Chimera fleet (or individual agent swarms) can be registered so that other participants in the OpenClaw network can discover that Chimera exists, what it can do, and whether it is currently available to participate in orchestration or delegation. Chimera does not depend on OpenClaw for internal operation; integration is for **discoverability** and **interoperability** with the broader network.

### Why Chimera Integrates with OpenClaw

- **Discoverability:** Chimera (or its agents) becomes visible to orchestrators and other agents that use OpenClaw to find capable participants. Without registration, Chimera would be invisible to the network.
- **Orchestration:** External orchestration or task-routing systems that rely on OpenClaw can select Chimera when its advertised capabilities and status match their needs. Integration enables Chimera to be part of a larger multi-agent ecosystem rather than a closed system.

---

## 2. Integration Philosophy

- **Push vs pull:** Chimera **pushes** its metadata to OpenClaw (or to a Chimera-owned facade that then updates OpenClaw). Chimera is the source of truth for its own identity, capabilities, and status. OpenClaw (or its consumers) **pull** or **read** that published view. Chimera does not wait for OpenClaw to poll Chimera’s internals; Chimera initiates updates when its state or posture changes.
- **Declarative capability advertisement:** What Chimera publishes is **declarative**: “this is who I am, what I can do, and how I am doing.” No imperative commands or secrets are exposed. Capabilities are described in terms of roles (e.g. Planner, Worker, Judge), task types (from specs), and skills (mapped to the `skills/` directory concepts), not low-level implementation.
- **Eventual consistency:** The published view is **eventually consistent** with Chimera’s real state. The system does not guarantee real-time coupling. There may be a delay between an internal event (e.g. swarm busy, CI failed) and the corresponding update in OpenClaw. This avoids tight coupling and allows Chimera to batch or throttle updates for stability and simplicity.

---

## 3. Published Metadata (Conceptual Contract)

The following are **conceptual** fields Chimera would publish. No wire format or schema is defined here.

- **Agent identity**
  - Name (e.g. Chimera fleet name or agent identifier).
  - Version (e.g. application or spec version) so consumers can reason about compatibility.
  - Role(s): e.g. Planner, Worker, Judge, or a composite “Chimera swarm” that exposes multiple roles. Aligned with `specs/technical.md` and the swarm architecture.

- **Available skills**
  - A set of named capabilities, mapped to the **skills/** directory concepts (e.g. trend fetching, content validation, budget checks). Each advertised skill should correspond to a documented, spec-aligned capability in the Chimera skills model, without exposing implementation or MCP internals.

- **Current status**
  - Operational state: e.g. **idle**, **busy**, **degraded**. Idle = available for new work; busy = actively processing; degraded = operational but with reduced capability or known issues (e.g. a dependency unavailable). No requirement for fine-grained real-time state; coarse, stable states are sufficient.

- **Governance signals**
  - **Spec version** (or spec identifier) so consumers know which Chimera spec set the behavior is aligned to.
  - **Test compliance:** whether the current codebase passes the project’s test suite (as defined by `make test` / specs). Can be a boolean or a simple enum (e.g. passing, failing, unknown).
  - **CI status:** whether the last CI run (e.g. GitHub Actions) succeeded. Used as a trust signal that the deployed or advertised instance matches a verified build.

---

## 4. Availability Lifecycle

- **When Chimera registers with OpenClaw:** Registration occurs when Chimera (or its orchestration layer) decides to join the OpenClaw network—e.g. at startup after health checks, or when an operator enables the integration. Registration includes the initial published metadata (identity, skills, status, governance signals). No specific trigger event is mandated; the exact moment is an implementation concern.

- **When status updates occur:** Updates are pushed when Chimera’s advertised state changes in a way that should be visible to the network. Examples: transition from idle to busy (or vice versa), transition to or from degraded, a change in advertised skills, or a change in governance signals (e.g. test or CI result). Frequency and batching are not specified; the design accepts eventual consistency.

- **When Chimera withdraws or is marked unavailable:** Chimera withdraws (or marks itself unavailable) when it is shutting down, undergoing maintenance, or deliberately leaving the network. It may also mark itself unavailable without fully unregistering (e.g. “temporarily not accepting work”). The exact semantics (unregister vs. status=unavailable) are left to the implementation; the spec only requires that Chimera can signal that it should not be considered available for new work.

---

## 5. Security & Governance Considerations

- **No secrets published:** Published metadata must **never** include secrets: no API keys, wallet keys, seeds, tokens, or credentials. Only non-sensitive, read-safe identity, capability, and status information is exposed.

- **Read-only external visibility:** External parties (including OpenClaw and its consumers) have **read-only** visibility into what Chimera publishes. They do not get write or control access to Chimera’s internals, queues, or state through this integration.

- **Spec and test alignment as trust signals:** Advertised **spec version** and **test/CI compliance** act as trust signals. They indicate that the instance claims to behave according to a known spec set and to have passed the project’s tests and CI. Misalignment (e.g. failing tests or failed CI) can be reflected in status or governance fields so that consumers can treat Chimera as degraded or untrusted until corrected.

---

## 6. Relationship to Specs & Tests

- **Dependence on specs/ as authoritative:** The integration assumes that **specs/** (`_meta.md`, `functional.md`, `technical.md`, and related specs) are the single source of truth for Chimera’s behavior and contracts. Published capabilities and roles must align with these specs. New capabilities or roles should not be advertised unless they are reflected in the specs (or in the skills/ directory as spec-aligned concepts). This keeps the OpenClaw view consistent with what Chimera is designed to do.

- **Effect of failing tests or CI on advertised status:** When the test suite fails or CI fails, the advertised **governance signals** (test compliance, CI status) should reflect that. Optionally, Chimera may also set its operational status to **degraded** or **unavailable** so that the network does not treat it as fully trustworthy until tests and CI pass again. The exact policy (e.g. always mark degraded vs. only after a grace period) is an implementation choice; the spec requires that test and CI outcomes can influence the advertised status.

---

## 7. Out-of-Scope (Explicit)

The following are **explicitly out of scope** for this specification:

- **Transport details:** How metadata is sent to OpenClaw (HTTP, message bus, SDK, etc.) is not defined. Only the conceptual contract and lifecycle are specified.
- **Authentication mechanism:** How Chimera authenticates to OpenClaw, or how OpenClaw verifies the publisher, is not defined. No tokens, credentials, or auth flows are specified here.
- **Concrete API calls:** No concrete endpoints, request/response formats, or API signatures are specified. This document describes *what* Chimera would publish and *when*, not the exact shape of the integration API.

Implementation of the OpenClaw integration will be addressed in a later phase, in line with the above constraints and the project’s spec-first discipline.
