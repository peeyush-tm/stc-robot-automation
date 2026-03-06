import random
import string


def _random_string(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


# ── Credentials ──────────────────────────────────────────────────────
INVALID_USERNAME = f"WRONG_USER_{_random_string(4)}"
INVALID_PASSWORD = f"wrongpass_{_random_string(4)}"

# ── Injection / Boundary Inputs ──────────────────────────────────────
SQL_INJECTION_INPUT = "' OR '1'='1' --"
SPECIAL_CHARS_INPUT = "!@#$%^&*()_+{}|:<>?"
WHITESPACE_INPUT = "   "
LONG_INPUT = "a" * 256
EMPTY_STRING = ""
INCORRECT_CAPTCHA = "ZZZZZZ"

# ── URLs ─────────────────────────────────────────────────────────────
MANAGE_DEVICES_PATH = "/ManageDevices"
MANAGE_DEVICES_URL = "https://192.168.1.26:7874/ManageDevices"
