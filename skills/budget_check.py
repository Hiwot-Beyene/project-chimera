"""
Budget check before cost-incurring workflows. Contract: specs/technical.md §5.1 (Planner balance check);
specs/functional.md P6; FR 5.1.

Input: tenant_id (required), agent_id (required), amount_required (required), currency_or_asset (required).
Output: { "allowed": bool, "current_balance": str|number, "required": str|number, "reason": str | null }.
  allowed=true iff current_balance >= amount_required; reason set on failure.
Error: raise SkillError or return structured error per skills/README.md § I/O.
TODO: Implement per specs/technical.md §5.1; read balance via MCP wallet_commerce only (config/mcp-servers.json).
"""


def budget_check(
    tenant_id: str,
    agent_id: str,
    amount_required: str | float,
    currency_or_asset: str,
) -> dict:
    raise NotImplementedError(
        "budget_check: implement per specs/technical.md §5.1, specs/functional.md P6; "
        "read balance via MCP wallet_commerce only."
    )
