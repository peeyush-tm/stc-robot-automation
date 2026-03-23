"""
Robot Framework library: load environment variables directly from config/<env>.json
and set them as suite variables. Suites call Load Environment Config From Json    ${ENV}
at the start of Suite Setup. Also sets TESTDATA_PATH to data/<env> for data-driven tests.
"""
import json
import os
from robot.libraries.BuiltIn import BuiltIn


def _project_root():
    """Project root = parent of libraries/."""
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_environment_config_from_json(env):
    """Load config/<env>.json and set each key as a Robot suite variable.
    Call with ${ENV} (e.g. dev, staging, prod, qe) at the start of Suite Setup.
    If the env file is missing, falls back to config/dev.json.
    Also sets TESTDATA_PATH to the absolute path of data/<env>.

    Browser priority (highest to lowest):
      1. BROWSER_OVERRIDE variable  — set by run_tests.py when --browser is passed
      2. BROWSER in config/<env>.json — environment default
    """
    env = (env or "dev").strip().lower()
    root = _project_root()
    config_path = os.path.join(root, "config", f"{env}.json")
    if not os.path.isfile(config_path):
        env = "dev"
        config_path = os.path.join(root, "config", "dev.json")
    with open(config_path, encoding="utf-8") as f:
        data = json.load(f)
    builtin = BuiltIn()
    for k, v in data.items():
        builtin.set_suite_variable("${%s}" % k, str(v))
    # Apply --browser CLI override after JSON values so it wins (suite scope beats global).
    browser_override = builtin.get_variable_value("${BROWSER_OVERRIDE}")
    if browser_override:
        builtin.set_suite_variable("${BROWSER}", str(browser_override))
    testdata_path = os.path.join(root, "data", env)
    builtin.set_suite_variable("${TESTDATA_PATH}", testdata_path)
