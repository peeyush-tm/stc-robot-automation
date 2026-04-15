"""Fresh ICCID/IMSI/MSISDN and pool names for PAYG SIM range steps.

``payg_usage_variables.py`` defines defaults at import time; when SIM, Pool, and Shared
scenarios run in one suite, each ``PAYG Create SIM Range`` call should refresh identifiers
so ranges do not collide."""

import random
import string
import time

from robot.libraries.BuiltIn import BuiltIn


def _rand_alnum(n: int = 6) -> str:
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=n))


def _safe_tag(tag: str) -> str:
    s = "".join(c for c in (tag or "payg").lower() if c.isalnum() or c in "_-")
    return (s[:24] or "payg").replace("-", "_")


def apply_fresh_payg_range_identifiers(tag: str = "sim") -> None:
    """Regenerate suite variables used by ``PAYG Create SIM Range`` (same padding rules as variables file)."""
    st = _safe_tag(tag)
    ts = str(int(time.time()))[-6:]
    core_iccid = f"10000{ts}001"
    iccid_pad = max(0, 20 - len(core_iccid))
    iccid = core_iccid + ("0" * iccid_pad)
    core_imsi = f"1000{ts}001"
    imsi_pad = max(0, 15 - len(core_imsi))
    imsi = core_imsi + ("0" * imsi_pad)
    msisdn = f"96660000{ts}01"
    bu = BuiltIn()
    bu.set_suite_variable("${PAYG_POOL_NAME}", f"payg_rng_{st}_{_rand_alnum(6)}")
    bu.set_suite_variable("${PAYG_MSISDN_POOL_NAME}", f"payg-msisdn-{st}-{_rand_alnum(6)}")
    bu.set_suite_variable("${PAYG_ICCID_FROM}", iccid)
    bu.set_suite_variable("${PAYG_ICCID_TO}", iccid)
    bu.set_suite_variable("${PAYG_IMSI_FROM}", imsi)
    bu.set_suite_variable("${PAYG_IMSI_TO}", imsi)
    bu.set_suite_variable("${PAYG_MSISDN_FROM}", msisdn)
    bu.set_suite_variable("${PAYG_MSISDN_TO}", msisdn)
