"""Fresh ICCID/IMSI/MSISDN and pool names for PAYG SIM range steps.

``payg_usage_variables.py`` defines defaults at import time; when SIM, Pool, and Shared
scenarios run in one suite, each ``PAYG Create SIM Range`` call should refresh identifiers
so ranges do not collide.

Config override: if ``PAYG_ICCID_FROM``/``PAYG_IMSI_FROM``/``PAYG_MSISDN_FROM`` (or the
matching pool name keys) are set in ``config/<env>.json``, those exact values are honored
for every scenario — user assumes responsibility for multi-scenario collision avoidance.
Empty/missing config = random regeneration per scenario (default behavior).
"""

import os
import json
import random
import string
import time

from robot.libraries.BuiltIn import BuiltIn


_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _active_env() -> str:
    v = (
        os.environ.get("STC_AUTOMATION_ENV")
        or os.environ.get("STC_CONFIG_ENV")
        or "dev"
    )
    return (str(v).strip().lower() or "dev")


def _cfg(key: str) -> str:
    """Return non-empty config value for ``key``, else empty string."""
    path = os.path.join(_ROOT, "config", f"{_active_env()}.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        v = data.get(key)
        return str(v).strip() if v is not None else ""
    except (OSError, json.JSONDecodeError, TypeError):
        return ""


def _rand_alnum(n: int = 6) -> str:
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=n))


def _safe_tag(tag: str) -> str:
    s = "".join(c for c in (tag or "payg").lower() if c.isalnum() or c in "_-")
    return (s[:24] or "payg").replace("-", "_")


def apply_fresh_payg_range_identifiers(tag: str = "sim") -> None:
    """Regenerate suite variables used by ``PAYG Create SIM Range`` (same padding rules as variables file).

    Config override: if a given PAYG_* key is set in ``config/<env>.json``, use that value
    instead of generating a fresh random one. Mix-and-match is supported (e.g. pin ICCID,
    randomize MSISDN).
    """
    st = _safe_tag(tag)
    ts = str(int(time.time()))[-6:]
    core_iccid = f"10000{ts}001"
    iccid_pad = max(0, 20 - len(core_iccid))
    iccid = core_iccid + ("0" * iccid_pad)
    core_imsi = f"1000{ts}001"
    imsi_pad = max(0, 15 - len(core_imsi))
    imsi = core_imsi + ("0" * imsi_pad)
    msisdn = f"96660000{ts}01"

    cfg_pool = _cfg("PAYG_POOL_NAME")
    cfg_mpool = _cfg("PAYG_MSISDN_POOL_NAME")
    cfg_iccid_f = _cfg("PAYG_ICCID_FROM")
    cfg_iccid_t = _cfg("PAYG_ICCID_TO")
    cfg_imsi_f = _cfg("PAYG_IMSI_FROM")
    cfg_imsi_t = _cfg("PAYG_IMSI_TO")
    cfg_msisdn_f = _cfg("PAYG_MSISDN_FROM")
    cfg_msisdn_t = _cfg("PAYG_MSISDN_TO")

    bu = BuiltIn()
    bu.set_suite_variable(
        "${PAYG_POOL_NAME}", cfg_pool or f"payg_rng_{st}_{_rand_alnum(6)}"
    )
    bu.set_suite_variable(
        "${PAYG_MSISDN_POOL_NAME}",
        cfg_mpool or f"payg-msisdn-{st}-{_rand_alnum(6)}",
    )
    bu.set_suite_variable("${PAYG_ICCID_FROM}", cfg_iccid_f or iccid)
    bu.set_suite_variable("${PAYG_ICCID_TO}", cfg_iccid_t or cfg_iccid_f or iccid)
    bu.set_suite_variable("${PAYG_IMSI_FROM}", cfg_imsi_f or imsi)
    bu.set_suite_variable("${PAYG_IMSI_TO}", cfg_imsi_t or cfg_imsi_f or imsi)
    bu.set_suite_variable("${PAYG_MSISDN_FROM}", cfg_msisdn_f or msisdn)
    bu.set_suite_variable(
        "${PAYG_MSISDN_TO}", cfg_msisdn_t or cfg_msisdn_f or msisdn
    )
