
"""
Contract: specs/technical.md §2 (task_type trend_analysis), §5.1 (GlobalState current trends).
Assert: callable exists; return is list of JSON-serializable dicts. No impl yet → tests fail.
"""


def test_trend_fetcher_exists_and_is_callable():
    from trend_fetcher import fetch_trends
    assert callable(fetch_trends)


def test_trend_fetcher_returns_list():
    from trend_fetcher import fetch_trends
    result = fetch_trends()
    assert isinstance(result, list)


def test_trend_fetcher_return_matches_schema():
    from trend_fetcher import fetch_trends
    result = fetch_trends()
    assert isinstance(result, list)
    for item in result:
        assert isinstance(item, dict)
        for key, value in item.items():
            assert isinstance(key, str)
            assert value is None or isinstance(value, (str, int, float, bool, list, dict))


def test_trend_fetcher_return_usable_for_trend_analysis_task():
    from trend_fetcher import fetch_trends
    trends = fetch_trends()
    assert isinstance(trends, list)

