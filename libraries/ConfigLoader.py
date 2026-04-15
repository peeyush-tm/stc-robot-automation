"""
Robot Framework library: load environment variables directly from config/<env>.json
and set them as suite variables. Suites call Load Environment Config From Json    ${ENV}
at the start of Suite Setup. Also sets TESTDATA_PATH to data/<env> for data-driven tests.
"""
import json
import os
from robot.libraries.BuiltIn import BuiltIn

STC_AUTOMATION_ENV = "STC_AUTOMATION_ENV"


def _project_root():
    """Project root = parent of libraries/."""
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _normalize_config_data(data):
    """Merge legacy keys into canonical names (single source in JSON)."""
    d = dict(data)
    payg_apn = str(d.get("PAYG_CSR_MODAL_APN_NAME") or "").strip()
    if payg_apn and not str(d.get("DEFAULT_CSR_MODAL_APN_NAME") or "").strip():
        d["DEFAULT_CSR_MODAL_APN_NAME"] = payg_apn
    return d


def _alias_value(data, source_key):
    v = data.get(source_key)
    if v is None:
        return None
    s = str(v).strip()
    return s if s else None


# Legacy Robot / Python names ← canonical config keys (applied only if legacy absent from file).
_LEGACY_SUITE_ALIASES = (
    ("RM_EC_ACCOUNT_NAME", "DEFAULT_EC_ACCOUNT"),
    ("RM_BU_ACCOUNT_NAME", "DEFAULT_BU_ACCOUNT"),
    ("UM_EC_ACCOUNT_NAME", "DEFAULT_EC_ACCOUNT"),
    ("UM_BU_ACCOUNT_NAME", "DEFAULT_BU_ACCOUNT"),
    ("CC_EC_ACCOUNT_NAME", "DEFAULT_EC_ACCOUNT"),
    ("CC_PARENT_ACCOUNT_NAME", "DEFAULT_BU_ACCOUNT"),
    ("CSRJ_DEFAULT_TARIFF_PLAN", "DEFAULT_CSR_TARIFF_PLAN"),
    ("CSRJ_DEFAULT_APN_NAME", "DEFAULT_CSR_MODAL_APN_NAME"),
    ("CSRJ_DEFAULT_BUNDLE_PLAN", "DEFAULT_CSR_BUNDLE_PLAN"),
    ("CSRJ_DEFAULT_TARIFF_PLAN_2", "DEFAULT_CSR_TARIFF_PLAN_2"),
    ("CSRJ_DEFAULT_APN_TYPE_2", "DEFAULT_CSR_APN_TYPE_2"),
    ("CSRJ_DEFAULT_APN_NAME_2", "DEFAULT_CSR_APN_NAME_2"),
    ("CSRJ_DEFAULT_BUNDLE_PLAN_2", "DEFAULT_CSR_BUNDLE_PLAN_2"),
    ("PAYG_CSR_MODAL_APN_NAME", "DEFAULT_CSR_MODAL_APN_NAME"),
    ("PAYG_SIM_PLAN_DP", "PAYG_DEVICE_PLAN_SIM"),
    ("PAYG_POOL_PLAN_DP", "PAYG_DEVICE_PLAN_POOL"),
    ("PAYG_SHARED_PLAN_DP", "PAYG_DEVICE_PLAN_SHARED"),
)


def _apply_suite_aliases(builtin, raw_keys, data):
    for legacy, source in _LEGACY_SUITE_ALIASES:
        if legacy in raw_keys:
            continue
        val = _alias_value(data, source)
        if val:
            builtin.set_suite_variable("${%s}" % legacy, val)


def _xpath_literal_double(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def _set_csr_apn_modal_locators(builtin, apn: str):
    apn = str(apn or "").strip()
    if not apn:
        return
    q = _xpath_literal_double(apn)
    builtin.set_suite_variable(
        "${LOC_APN_MODAL_APN_SINGLE_VALUE}",
        f'xpath=//*[@id="apnSelectionModal"]//div[(contains(@class,"single-value") '
        f'or contains(@class,"singleValue")) and normalize-space(.)="{q}"]',
    )
    builtin.set_suite_variable(
        "${LOC_APN_MODAL_APN_OPTION}",
        f'xpath=//*[@id="apnSelectionModal"]//div[contains(@class,"select__option") '
        f'and normalize-space(.)="{q}"]',
    )


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
    os.environ[STC_AUTOMATION_ENV] = env
    root = _project_root()
    config_path = os.path.join(root, "config", f"{env}.json")
    if not os.path.isfile(config_path):
        env = "dev"
        config_path = os.path.join(root, "config", "dev.json")
    with open(config_path, encoding="utf-8") as f:
        file_data = json.load(f)
    raw_keys = set(file_data.keys())
    data = _normalize_config_data(file_data)
    builtin = BuiltIn()
    for k, v in data.items():
        builtin.set_suite_variable("${%s}" % k, str(v))
    # Apply --browser CLI override after JSON values so it wins (suite scope beats global).
    browser_override = builtin.get_variable_value("${BROWSER_OVERRIDE}")
    if browser_override:
        builtin.set_suite_variable("${BROWSER}", str(browser_override))
    _apply_suite_aliases(builtin, raw_keys, data)
    apn = str(builtin.get_variable_value("${CSRJ_DEFAULT_APN_NAME}") or "").strip()
    if not apn:
        apn = str(
            data.get("DEFAULT_CSR_MODAL_APN_NAME")
            or data.get("PAYG_CSR_MODAL_APN_NAME")
            or ""
        ).strip()
    _set_csr_apn_modal_locators(builtin, apn)
    testdata_path = os.path.join(root, "data", env)
    builtin.set_suite_variable("${TESTDATA_PATH}", testdata_path)
