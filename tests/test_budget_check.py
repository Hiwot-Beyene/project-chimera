"""
Contract: specs/technical.md §5.1, specs/functional.md P6 (budget_check skill).
Assert: callable exists; until implemented, raises NotImplementedError with spec reference.
"""

import pytest


def test_budget_check_exists_and_is_callable():
    from skills.budget_check import budget_check
    assert callable(budget_check)


def test_budget_check_raises_not_implemented():
    from skills.budget_check import budget_check
    with pytest.raises(NotImplementedError) as exc_info:
        budget_check(
            tenant_id="t1",
            agent_id="a1",
            amount_required="100",
            currency_or_asset="USDC",
        )
    assert "specs/technical.md" in str(exc_info.value) or "P6" in str(exc_info.value)
