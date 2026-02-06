# Testing Strategy — Spec

**Purpose:** Define basic unit-test approach and true TDD: failing tests exist before implementation and define the agent’s goal posts. Authority: `specs/_meta.md`, `specs/technical.md`.

---

## 1. Basic Unit Tests

- **Runner:** pytest. Executed via `make test` (Docker); CI runs `make test` on push/PR.
- **Scope:** `tests/` and, where applicable, code under `skills/`. Linting (Ruff) covers `tests/` and `skills/` per `specs/technical.md`.
- **What is tested:** Contract compliance (interfaces, return shapes, spec-derived schemas). Unit tests are the primary automated check that code meets the contracts defined in the specs.

---

## 2. True TDD: Failing Tests Before Implementation

- **Order of work:** Tests are written **first**, against the spec contracts. Implementation is added **after** so that tests pass. No “implementation first, then tests.”
- **Failing tests as goal posts:** A test that fails because the implementation is missing or incomplete is the desired state until the implementation satisfies the contract. Tests define the agent’s (and the system’s) goal posts: they encode what “done” means for a given capability.
- **Traceability:** Each test file (or test) should document which spec item it enforces (e.g. `specs/technical.md` §2.2, task_type `trend_analysis`). Test docstrings and naming make the goal post explicit.
- **No impl yet → tests fail:** It is acceptable and intended for tests to fail (e.g. ImportError or assertion failure) when the corresponding module or function does not yet exist. Passing tests after implementation confirm the goal post is met.

---

## 3. Current Test Contracts (Goal Posts)

| Test file | Spec / contract | Goal post (what tests define) |
|-----------|-----------------|-------------------------------|
| `tests/test_skills_interface.py` | `technical.md` §2.2 `context.required_resources` | `get_required_resources` exists, is callable, returns a list of strings (MCP resource URIs). |
| `tests/test_trend_fetcher.py` | `technical.md` §2 (task_type `trend_analysis`), §5.1 (GlobalState current trends) | `fetch_trends` exists, is callable, returns a list of JSON-serializable dicts suitable for trend analysis. |

New capabilities should add tests first that encode the spec contract; implementation follows until those tests pass.

---

## 4. Cross-References

- **Specs:** `_meta.md`, `technical.md`, `functional.md`.
- **Execution:** `make test`, `.github/workflows/ci.yml`.
