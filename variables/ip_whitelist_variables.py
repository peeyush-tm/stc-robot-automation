import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


_TIMESTAMP = str(int(time.time()))[-6:]

# ── URLs (MANAGE_IP_WHITELIST_URL, CREATE_IP_WHITELIST_URL from config per ENV) ─
MANAGE_IP_WHITELIST_PATH = "/IPWhitelisting"
CREATE_IP_WHITELIST_PATH = "/CreateIPWhitelisting"

# ── Valid Rule Data ──────────────────────────────────────────────────
VALID_SOURCE_IP = "10.10.10.1"
VALID_DESTINATION_ADDR = "192.168.0.1"
VALID_PORT = "any"
VALID_PORT_ENTER = "EnterPort"
VALID_PORT_VALUE = "8080"
VALID_PROTOCOL_TCP = "TCP"
VALID_PROTOCOL_UDP = "UDP"
VALID_PROTOCOL_ANY = "any"

# ── Negative Test Data ───────────────────────────────────────────────
EMPTY_STRING = ""
INVALID_SOURCE_IP = "abc123"
INVALID_DESTINATION_ADDR = "999.999.999.999"
PORT_VALUE_EXCEEDS_MAX = "99999"
MULTIPLE_DESTINATIONS = "192.168.0.1,10.0.0.1,172.16.0.1"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_WL_POLICY_CREATED = "Policy Added Successfully"
