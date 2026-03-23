import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


_TIMESTAMP = str(int(time.time()))[-6:]

# ── URLs (SIM_RANGE_URL, CREATE_SIM_RANGE_URL etc. from config per ENV) ─
SIM_RANGE_PATH = "/SIMRange"
CREATE_SIM_RANGE_PATH = "/CreateSIMRange"

# ── Valid Form Data ──────────────────────────────────────────────────
VALID_POOL_NAME = f"auto_pool_{_random_string(6)}"
VALID_SR_DESCRIPTION = "Automation test SIM range"

# ── ICCID Range (max 14 digits — prefix is auto-filled by the app) ──
VALID_ICCID_FROM = f"10000{_TIMESTAMP}001"
VALID_ICCID_TO = str(int(VALID_ICCID_FROM) + 9)
EXPECTED_POOL_COUNT = "10"

# ── IMSI Range (max 13 digits — prefix is auto-filled by the app) ──
VALID_IMSI_FROM = f"1000{_TIMESTAMP}001"
VALID_IMSI_TO = str(int(VALID_IMSI_FROM) + 9)

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

OVERLAPPING_ICCID_FROM = f"10000{_TIMESTAMP}005"
OVERLAPPING_ICCID_TO = f"10000{_TIMESTAMP}015"
OVERLAPPING_IMSI_FROM = f"1000{_TIMESTAMP}005"
OVERLAPPING_IMSI_TO = f"1000{_TIMESTAMP}015"

MISMATCHED_IMSI_FROM = f"1000{_TIMESTAMP}001"
MISMATCHED_IMSI_TO = f"1000{_TIMESTAMP}005"

SQL_INJECTION_POOL_NAME = "' OR '1'='1' --"
SPECIAL_CHARS_POOL_NAME = "!@#$%^&*()_+{}|:<>?"

# ── MSISDN URLs (from config per ENV) ─────────────────────────────────

# ── MSISDN Range (10-15 digits, pool count 10: from .. from+9) ───────
VALID_MSISDN_FROM = f"96650000{_TIMESTAMP}01"
VALID_MSISDN_TO = str(int(VALID_MSISDN_FROM) + 9)
MSISDN_POOL_NAME = f"auto-msisdn-pool-{_random_string(6)}"
MSISDN_DESCRIPTION = "Automation test MSISDN SIM range"
EXPECTED_MSISDN_POOL_COUNT = "10"
SIM_CATEGORY_VALUE = "1"

# ── MSISDN Negative Test Data ───────────────────────────────────────
MSISDN_TOO_SHORT = "123456789"
MSISDN_FROM_GREATER_THAN_TO_FROM = "966500000010"
MSISDN_FROM_GREATER_THAN_TO_TO = "966500000001"
OVERLAPPING_MSISDN_FROM = f"96650000{_TIMESTAMP}05"
OVERLAPPING_MSISDN_TO = f"96650000{_TIMESTAMP}15"
MSISDN_EXCEEDS_MAX_LENGTH = "1234567890123456"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_SIM_RANGE_CREATED = "SIM Range Created Successfully"
