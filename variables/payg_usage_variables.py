"""Variables for PAYG Data Usage E2E scenarios (SIM Plan, Pool Plan, Shared Plan)."""

import random, string, time

from _config_defaults import config_scalar
from _shared_seed import read_value


def _payg_rand(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def _cfg_or(key: str, fallback: str) -> str:
    """Return config value for ``key`` if non-empty, else ``fallback``.

    Lets users pin PAYG SIM range values in ``config/<env>.json`` for deterministic
    runs while keeping random generation as the default (empty config = random).
    """
    v = config_scalar(key, "").strip()
    return v if v else fallback


_PAYG_TS = str(int(time.time()))[-6:]

# Rerun later PAYG steps (e.g. only TC_PAYG_SIM_05) after TC_PAYG_SIM_01 wrote .run_seed.json
PAYG_SEED_EC_NAME = str(read_value("payg_ec_name", "") or "").strip()
PAYG_SEED_BU_NAME = str(read_value("payg_bu_name", "") or "").strip()

PAYG_TARIFF_PLAN = config_scalar(
    "PAYG_TARIFF_PLAN", "TP1-QRA-070425_UNLIMITEDPAYG_1-copy-1"
)
PAYG_SIM_PLAN_DP = config_scalar(
    "PAYG_DEVICE_PLAN_SIM", "SIMPLAN-QRA-070425_1-copy-1"
)
PAYG_POOL_PLAN_DP = config_scalar(
    "PAYG_DEVICE_PLAN_POOL", "POOLPLAN-QRA-070425_1-copy-1"
)
PAYG_SHARED_PLAN_DP = config_scalar(
    "PAYG_DEVICE_PLAN_SHARED", "SHAREDPLAN-QRA-070425_1-copy-1"
)

PAYG_MAX_USAGE_ITERATIONS = 50
PAYG_EXPECTED_QUOTA_TYPE = "payg"
PAYG_USAGE_COLUMN_KEYWORDS = ["payg", "data"]

# SIM Range: From == To so ICCID/IMSI/MSISDN row count = 1, matching Defined Pool Count (default 1).
# If From < To, range size is 2+ and the Add ICCID Range Submit stays disabled when pool count is 1.
# Multi-scenario runs: ``PAYG Create SIM Range`` calls ``libraries/PaygRangeIds.apply_fresh_payg_range_identifiers`` to avoid ICCID/IMSI/MSISDN/pool collisions across SIM / pool / shared.
# Config overrides (all optional — empty/missing = random): PAYG_POOL_NAME, PAYG_ICCID_FROM, PAYG_ICCID_TO, PAYG_IMSI_FROM, PAYG_IMSI_TO, PAYG_MSISDN_FROM, PAYG_MSISDN_TO, PAYG_MSISDN_POOL_NAME.
PAYG_POOL_NAME = _cfg_or("PAYG_POOL_NAME", f"payg_pool_{_payg_rand(6)}")
PAYG_SR_DESCRIPTION = _cfg_or("PAYG_SR_DESCRIPTION", "PAYG automation SIM range")
# Popup inputs maxLength 20 on QE — pad with trailing zeros (avoid leading zeros; backend may reject those).
_PAYG_ICCID_CORE = f"10000{_PAYG_TS}001"
_ICCID_PAD = max(0, 20 - len(_PAYG_ICCID_CORE))
PAYG_ICCID_FROM = _cfg_or("PAYG_ICCID_FROM", _PAYG_ICCID_CORE + ("0" * _ICCID_PAD))
PAYG_ICCID_TO = _cfg_or("PAYG_ICCID_TO", PAYG_ICCID_FROM)
_PAYG_IMSI_CORE = f"1000{_PAYG_TS}001"
_IMSI_PAD = max(0, 15 - len(_PAYG_IMSI_CORE))
PAYG_IMSI_FROM = _cfg_or("PAYG_IMSI_FROM", _PAYG_IMSI_CORE + ("0" * _IMSI_PAD))
PAYG_IMSI_TO = _cfg_or("PAYG_IMSI_TO", PAYG_IMSI_FROM)
PAYG_MSISDN_FROM = _cfg_or("PAYG_MSISDN_FROM", f"96660000{_PAYG_TS}01")
PAYG_MSISDN_TO = _cfg_or("PAYG_MSISDN_TO", PAYG_MSISDN_FROM)
PAYG_MSISDN_POOL_NAME = _cfg_or(
    "PAYG_MSISDN_POOL_NAME", f"payg-msisdn-{_payg_rand(6)}"
)
PAYG_MSISDN_DESCRIPTION = _cfg_or(
    "PAYG_MSISDN_DESCRIPTION", "PAYG automation MSISDN range"
)
PAYG_EXPECTED_POOL_COUNT = _cfg_or("PAYG_EXPECTED_POOL_COUNT", "1")

PAYG_ORDER_QUANTITY = "1"
PAYG_SIM_ACTIVATE_COUNT = 1
