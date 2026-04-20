import random
import string
import time

from variables._config_defaults import config_scalar


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def _cfg_or(key: str, fallback: str) -> str:
    """Return config value for ``key`` if non-empty, else ``fallback``.

    Lets users pin SIM range values in ``config/<env>.json`` for deterministic runs
    while keeping random generation as the default (empty config = random).
    """
    v = config_scalar(key, "").strip()
    return v if v else fallback


def _range_to(from_val: str, to_cfg_key: str, count_fallback: int = 10) -> str:
    """Resolve a range's TO value: config override wins, else FROM + (count-1)."""
    cfg_to = config_scalar(to_cfg_key, "").strip()
    if cfg_to:
        return cfg_to
    return str(int(from_val) + (count_fallback - 1))


_MS8 = str(int(time.time() * 1000))[-8:]
_MS7 = str(int(time.time() * 1000))[-7:]
_TS6 = str(int(time.time() * 1000))[-6:]
_R3 = f"{random.randint(0, 999):03d}"

# ── URLs (SIM_RANGE_URL, CREATE_SIM_RANGE_URL etc. from config per ENV) ─
SIM_RANGE_PATH = "/SIMRange"
CREATE_SIM_RANGE_PATH = "/CreateSIMRange"

# ── Pool count (override via SIM_RANGE_POOL_COUNT, default 10) ────────
EXPECTED_POOL_COUNT = _cfg_or("SIM_RANGE_POOL_COUNT", "10")
_POOL_COUNT_INT = int(EXPECTED_POOL_COUNT) if EXPECTED_POOL_COUNT.isdigit() else 10

# ── Valid Form Data (override via SIM_RANGE_POOL_NAME / *_DESCRIPTION) ─
VALID_POOL_NAME = _cfg_or("SIM_RANGE_POOL_NAME", f"auto_pool_{_random_string(6)}")
VALID_SR_DESCRIPTION = _cfg_or("SIM_RANGE_DESCRIPTION", "Automation test SIM range")

# ── ICCID / IMSI — prefix and digit count come from config/<env>.json ──
# FROM/TO values: if SIM_RANGE_ICCID_FROM/TO (or IMSI equivalent) is set in config,
# use it directly; otherwise generate from prefix + timestamp + random suffix.
_ICCID_PREFIX = config_scalar("SIM_RANGE_ICCID_PREFIX", "100")
_ICCID_DIGITS = int(config_scalar("SIM_RANGE_ICCID_DIGITS", "14"))
_IMSI_PREFIX = config_scalar("SIM_RANGE_IMSI_PREFIX", "1000")
_IMSI_DIGITS = int(config_scalar("SIM_RANGE_IMSI_DIGITS", "13"))

VALID_ICCID_FROM = _cfg_or(
    "SIM_RANGE_ICCID_FROM", f"{_ICCID_PREFIX}{_MS8}{_R3}"[:_ICCID_DIGITS]
)
VALID_IMSI_FROM = _cfg_or(
    "SIM_RANGE_IMSI_FROM", f"{_IMSI_PREFIX}{_MS7}{_R3[:2]}"[:_IMSI_DIGITS]
)

VALID_ICCID_TO = _range_to(VALID_ICCID_FROM, "SIM_RANGE_ICCID_TO", _POOL_COUNT_INT)
VALID_IMSI_TO = _range_to(VALID_IMSI_FROM, "SIM_RANGE_IMSI_TO", _POOL_COUNT_INT)

# ── Negative Test Data ───────────────────────────────────────────────
EMPTY_STRING = ""
POOL_NAME_EXCEEDS_MAX = "a" * 51
DESCRIPTION_EXCEEDS_MAX = "d" * 501

ICCID_TOO_SHORT = "10001"
ICCID_FROM_GREATER_THAN_TO_FROM = "10000000000020"
ICCID_FROM_GREATER_THAN_TO_TO = "10000000000010"
ICCID_INVALID_FORMAT = "abc12345678901"

IMSI_TOO_SHORT = "10001"
IMSI_FROM_GREATER_THAN_TO_FROM = "1000000000020"
IMSI_FROM_GREATER_THAN_TO_TO = "1000000000010"

OVERLAPPING_ICCID_FROM = f"10000{_TS6}005"
OVERLAPPING_ICCID_TO = f"10000{_TS6}015"
OVERLAPPING_IMSI_FROM = f"1000{_TS6}005"
OVERLAPPING_IMSI_TO = f"1000{_TS6}015"

MISMATCHED_IMSI_FROM = f"1000{_TS6}001"
MISMATCHED_IMSI_TO = f"1000{_TS6}005"

SQL_INJECTION_POOL_NAME = "' OR '1'='1' --"
SPECIAL_CHARS_POOL_NAME = "!@#$%^&*()_+{}|:<>?"

# ── MSISDN — prefix and digit count come from config/<env>.json ──────
# FROM/TO values: override via SIM_RANGE_MSISDN_FROM / SIM_RANGE_MSISDN_TO in config.
_MSISDN_PREFIX = config_scalar("SIM_RANGE_MSISDN_PREFIX", "96650000")
_MSISDN_DIGITS = int(config_scalar("SIM_RANGE_MSISDN_DIGITS", "15"))

EXPECTED_MSISDN_POOL_COUNT = _cfg_or("SIM_RANGE_MSISDN_POOL_COUNT", "10")
_MSISDN_POOL_COUNT_INT = (
    int(EXPECTED_MSISDN_POOL_COUNT) if EXPECTED_MSISDN_POOL_COUNT.isdigit() else 10
)

VALID_MSISDN_FROM = _cfg_or(
    "SIM_RANGE_MSISDN_FROM", f"{_MSISDN_PREFIX}{_TS6}{_R3}"[:_MSISDN_DIGITS]
)
VALID_MSISDN_TO = _range_to(
    VALID_MSISDN_FROM, "SIM_RANGE_MSISDN_TO", _MSISDN_POOL_COUNT_INT
)
MSISDN_POOL_NAME = _cfg_or(
    "SIM_RANGE_MSISDN_POOL_NAME", f"auto-msisdn-pool-{_random_string(6)}"
)
MSISDN_DESCRIPTION = _cfg_or(
    "SIM_RANGE_MSISDN_DESCRIPTION", "Automation test MSISDN SIM range"
)
SIM_CATEGORY_VALUE = "1"

# ── MSISDN Negative Test Data ───────────────────────────────────────
MSISDN_TOO_SHORT = "123456789"
MSISDN_FROM_GREATER_THAN_TO_FROM = "966500000010"
MSISDN_FROM_GREATER_THAN_TO_TO = "966500000001"
OVERLAPPING_MSISDN_FROM = f"{_MSISDN_PREFIX}{_TS6}05"[:_MSISDN_DIGITS]
OVERLAPPING_MSISDN_TO = f"{_MSISDN_PREFIX}{_TS6}15"[:_MSISDN_DIGITS]
MSISDN_EXCEEDS_MAX_LENGTH = "1234567890123456"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_SIM_RANGE_CREATED = "SIM Range Created Successfully"
