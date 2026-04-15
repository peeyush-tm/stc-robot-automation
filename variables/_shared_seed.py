"""Shared seed file + resolution helpers for test data.

Resolution order for ``resolved()``:

1. Environment variable *env_var* (e.g. ``STC_SM_EC_ACCOUNT_NAME``) — CI or local shell.
2. ``.run_seed.json`` key *seed_key* — written by E2E / prior suite steps.
3. *file_default* — literals in ``variables/<suite>_variables.py`` (standalone when no seed).

**Standalone (no seed):** If ``.run_seed.json`` is missing or empty, or the key is absent,
``read_value`` returns the fallback (usually ``""``) and ``resolved()`` uses *file_default*.
You do **not** need a seed file to run suites locally — configure defaults in
``config/<env>.json`` (see ``variables/_config_defaults.py``), the variables Python module,
or override with ``STC_*`` / ``--variable`` in Robot.

``run_tests.py`` sets ``STC_AUTOMATION_ENV`` to match ``--env``. If you invoke ``robot``
directly, set ``STC_AUTOMATION_ENV`` to the same value as ``-v ENV:`` so Python defaults
match the loaded JSON.

Robot Framework ``--variable NAME:value`` still overrides the final value at the
framework layer after this module is imported.

Use ``resolved_any()`` in suite variables when multiple seed keys are valid
(e.g. ``onboard_ec_name`` or ``payg_ec_name`` for Role / User Management).

**Typical pipeline keys** (written by E2E / activation / onboard steps; consumed by later suites):

*E2E Flow (without usage) — ``e2e_flow.robot``:*
- ``e2e_ec_name`` / ``e2e_bu_name`` — EC/BU from E2E flow without usage (consumed by Device State).
- ``e2e_first_activated_imsi`` / ``e2e_second_activated_imsi`` — activated IMSIs from E2E flow.

*E2E Flow With Usage — ``e2e_flow_with_usage.robot``:*
- ``e2e_usage_ec_name`` / ``e2e_usage_bu_name`` — EC/BU from E2E flow with usage (consumed by Rule Engine, SIM Movement, Device Plan, SIM Replacement).
- ``e2e_usage_first_activated_imsi`` / ``e2e_usage_second_activated_imsi`` — activated IMSIs from E2E usage flow.

*Customer Onboard Tests — ``onboard_customer_api_tests.robot``:*
- ``onboard_ec_name`` / ``onboard_bu_name`` — EC/BU from standalone onboard (consumed by Role Mgmt, User Mgmt, Cost Center, CSR Journey).

*Shared / legacy (still written by e2e_keywords.resource):*
- ``first_activated_imsi`` / ``first_activated_iccid`` — generic; prefer flow-specific keys above.
- ``second_activated_imsi`` / ``second_activated_iccid`` — generic; prefer flow-specific keys above.
- ``csrj_device_plan_alias`` — optional; CSR journey can seed for SIM movement device plan.
- ``target_bu_account`` — optional destination BU for SIM movement (env ``STC_SM_*`` if not seeded).

For modules that do not use the seed file, use ``env_default()``:
environment variable, then *file_default*.
"""

import json
import os

SEED_FILE = os.path.join(os.path.dirname(__file__), ".run_seed.json")


def _load_seed():
    if os.path.exists(SEED_FILE):
        with open(SEED_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def _save_seed(data):
    with open(SEED_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)


def get_value(key, generator_fn):
    """Return cached value for *key*, or call *generator_fn* to create one."""
    data = _load_seed()
    if key in data:
        return data[key]
    value = generator_fn()
    data[key] = value
    _save_seed(data)
    return value


def save_value(key, value):
    """Write (or overwrite) *key* → *value* in the seed file immediately."""
    data = _load_seed()
    data[key] = value
    _save_seed(data)


def read_value(key, fallback=""):
    """Return value for *key* from the seed file, or *fallback* if absent."""
    return _load_seed().get(key, fallback)


def _strip_env(val):
    if val is None:
        return ""
    return str(val).strip()


def env_default(env_var: str, file_default: str = "") -> str:
    """Prefer ``os.environ[env_var]`` when non-empty; else *file_default*."""
    v = _strip_env(os.environ.get(env_var))
    return v if v else file_default


def resolved(seed_key: str, env_var: str, file_default: str = "") -> str:
    """Env → seed file → *file_default* (see module docstring)."""
    v = _strip_env(os.environ.get(env_var))
    if v:
        return v
    s = _strip_env(read_value(seed_key, ""))
    if s:
        return s
    return file_default


def resolved_any(seed_keys: tuple, env_var: str, file_default: str = "") -> str:
    """Like ``resolved`` but tries multiple seed keys in order before *file_default*."""
    v = _strip_env(os.environ.get(env_var))
    if v:
        return v
    for key in seed_keys:
        s = _strip_env(read_value(key, ""))
        if s:
            return s
    return file_default
