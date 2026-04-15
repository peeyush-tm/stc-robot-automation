import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


_TIMESTAMP = str(int(time.time()))[-6:]

# ── URLs (MANAGE_IP_POOL_URL, CREATE_IP_POOL_URL from config per ENV) ─
MANAGE_IP_POOL_PATH = "/manageIPPooling"
CREATE_IP_POOL_PATH = "/CreateIPPooling"

# ── APN Type Values ──────────────────────────────────────────────────
APN_TYPE_PUBLIC = "2"
APN_TYPE_PRIVATE = "1"

# ── Valid Form Data ──────────────────────────────────────────────────
VALID_NUMBER_OF_IPS = "1"
VALID_APN_INDEX = "1"

# ── Negative Test Data ───────────────────────────────────────────────
EMPTY_STRING = ""
ZERO_IPS = "0"
NEGATIVE_IPS = "-1"
NON_NUMERIC_IPS = "abc"
EXCEEDS_AVAILABLE_IPS = "99999"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_IP_POOL_CREATED = "IP Pool Created Successfully"
