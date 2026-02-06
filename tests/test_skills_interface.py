"""
Contract: specs/technical.md §2.2 context.required_resources (array of MCP resource URI strings).
Assert: interface exists; return is list of strings (URIs). No impl yet → tests fail.
"""


def test_skills_interface_exists_and_is_callable():
    from skills.skills_interface import get_required_resources
    assert callable(get_required_resources)


def test_skills_interface_returns_list_of_strings():
    from skills.skills_interface import get_required_resources
    result = get_required_resources()
    assert isinstance(result, list)
    for uri in result:
        assert isinstance(uri, str)
