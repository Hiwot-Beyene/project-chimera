# Security — AuthN/AuthZ, Rate Limiting, Content Moderation

**Purpose:** Concrete model so an agent can implement end-to-end security without human clarification. **Authority:** specs/_meta.md, SRS FR 5.0, NFR 1.x, tenant isolation; SECURITY.md.

---

## 1. Authentication and Authorization (AuthN/AuthZ)

### 1.1 Model

- **AuthN:** JWT (RS256 or HS256). Issuer and audience are configured per environment. Access and optional refresh tokens; refresh rotation recommended.
- **AuthZ:** Role-based. Roles are carried in the JWT (e.g. `roles: string[]` or `role: string`). Tenant scope: `tenant_id` (or equivalent) in token or from API path so one tenant’s data is never returned to another.

### 1.2 Roles

| Role | Allowed actions |
|------|------------------|
| **super_orchestrator** | All Dashboard and API actions; fleet-wide view; HITL decisions; campaign CRUD; agent list (all tenants if multi-tenant). |
| **hitl_reviewer** | View and decide HITL queue items (Approve/Reject/Edit) for tenants they are assigned; no campaign or agent creation. |
| **operator** | Read fleet status, read campaigns and agents (tenant-scoped); no HITL decide, no campaign/agent create or delete. |
| **viewer** | Read-only fleet status and own-tenant campaigns/agents; no HITL, no edits. |

### 1.3 Endpoint → Role Matrix

| Endpoint (conceptual) | super_orchestrator | hitl_reviewer | operator | viewer |
|------------------------|--------------------|---------------|----------|--------|
| POST /auth/login | ✓ | ✓ | ✓ | ✓ |
| GET /api/fleet/status | ✓ | ✓ | ✓ | ✓ |
| GET/POST/PATCH /api/campaigns | ✓ | — | R only (tenant) | R only (tenant) |
| GET /api/hitl/queue | ✓ | ✓ (assigned) | — | — |
| POST /api/hitl/queue/:id/decision | ✓ | ✓ (assigned) | — | — |
| GET /api/agents | ✓ | R (tenant) | R (tenant) | R (tenant) |
| GET /api/tasks/:id, /api/results/:id | ✓ | ✓ (tenant) | R (tenant) | R (tenant) |

R = read. Tenant scoping: filter by `tenant_id` from token or path; never return another tenant’s data.

### 1.4 Token Shape (minimal)

- `sub` (subject): user or service id.
- `tenant_id` (optional): tenant for scoping (required for multi-tenant).
- `roles`: array of role strings from §1.2.
- `exp`, `iat`, `iss`, `aud`: standard JWT claims.

Validation: verify signature, `exp`, `iss`, `aud`; then check `roles` and `tenant_id` for the requested resource.

---

## 2. Endpoint-Level Rate Limiting

### 2.1 Strategy

- **Per identity:** Limit by `sub` (and optionally `tenant_id`) after AuthN. Anonymous endpoints (e.g. login) limit by IP or client id.
- **Per endpoint group:** Different limits for read vs write and for sensitive endpoints (HITL decision, campaign create).

### 2.2 Limits (example; tune per env)

| Group | Limit | Window |
|-------|--------|--------|
| Login | 10 requests | 1 minute per IP/client_id |
| Read (GET) fleet/campaigns/agents/tasks/results | 300 requests | 1 minute per sub |
| Write (POST/PATCH) campaigns | 30 requests | 1 minute per sub |
| HITL queue GET | 120 requests | 1 minute per sub |
| HITL decision POST | 60 requests | 1 minute per sub |

Response when exceeded: **429 Too Many Requests** with `Retry-After` (seconds). No body required; optional JSON `{ "error": "rate_limit_exceeded", "retry_after": N }`.

### 2.3 Implementation Notes

- Use a store (e.g. Redis) keyed by (identity, endpoint_group) or (identity, "login") with sliding or fixed window. Middleware or API gateway applies the check after AuthN where applicable.

---

## 3. Content Moderation Pipeline (Stepwise + Escalation)

Content moderation applies to Worker outputs (e.g. text, captions, reply drafts) before they are committed or published. Judge and HITL use this pipeline; sensitive-topic content always reaches HITL (specs/_meta.md, NFR 1.2).

### 3.1 Steps (in order)

1. **Automated policy check**  
   - Input: artifact (text or reference to image/video), artifact_type, confidence_score, sensitive_topics_detected (from Worker).  
   - Rules: blocklist (banned words/phrases), character/format rules (e.g. max length, no raw URLs if policy says so).  
   - Output: pass | fail (reason code).  
   - If **fail** → route to **Reject** (no HITL); signal Planner per specs/technical.md §1.3.

2. **Sensitive-topic gate**  
   - Input: sensitive_topics_detected.  
   - Rule: if non-empty (politics, health_advice, financial_advice, legal_claims) → **must** go to HITL; no auto-approve.  
   - Output: route to HITL (queue for human).

3. **Confidence gate**  
   - Input: confidence_score, sensitive_topics_detected.  
   - Rules:  
     - If sensitive_topics_detected non-empty → already routed to HITL (step 2).  
     - Else if confidence_score > high_threshold (e.g. 0.90) → **Auto-approve** (subject to step 1 and OCC).  
     - Else if confidence_score in [medium_low, medium_high] (e.g. 0.70–0.90) → **Async HITL** (queue for human).  
     - Else (below 0.70) → **Reject** (signal Planner; no HITL unless step 2 already sent to HITL).

4. **HITL review**  
   - Human reviews queued item: Approve, Reject, or Edit-then-Approve.  
   - Approve → Judge commits (if OCC passes); Reject → Judge sends reject signal to Planner §1.3.

5. **Post-approval check (optional)**  
   - Before final publish: optional second automated check (e.g. platform policy, AI disclosure flag). Failure → do not publish; escalate back to HITL or Reject.

### 3.2 Escalation Rules

| Condition | Action |
|-----------|--------|
| Policy check fail | Reject; signal Planner; do not put in HITL. |
| Sensitive topic detected | Always HITL; never auto-approve. |
| Confidence &lt; low_threshold | Reject; signal Planner. |
| Confidence in medium band | HITL queue; human decides. |
| Confidence ≥ high_threshold, no sensitive topic, policy pass | Auto-approve (Judge commits if OCC OK). |
| OCC conflict at commit | Reject commit; signal Planner with reason rejected_occ_conflict. |
| HITL Reject (or Edit-then-Reject) | Signal Planner with reason rejected_by_hitl. |
| Transaction rejection (CFO Judge) | Flag for human review; payload per specs/technical.md §1.5. |

### 3.3 Thresholds (configurable)

- **high_confidence_threshold:** 0.90 (auto-approve if no sensitive topic and policy pass).  
- **medium_confidence_low:** 0.70 (below = reject; above = HITL or auto per band).  
- Sensitive topic list: politics, health_advice, financial_advice, legal_claims (fixed set; extend only via spec change).

---

## 4. Cross-References

- **Judge routing:** specs/technical.md §3.2, §5.4; specs/functional.md J2, J4, J5.  
- **Reject signal:** specs/technical.md §1.3.  
- **CFO→HITL:** specs/technical.md §1.5.  
- **SECURITY.md:** no keys in code; tenant isolation; governance.
