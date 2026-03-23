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

# ── Expected Error Messages ──────────────────────────────────────────
ERROR_INVALID_CAPTCHA = "Invalid Captcha"
ERROR_AUTH_FAILURE = "Authorization Failure"
ERROR_PLEASE_ENTER_CAPTCHA = "Please Enter Captcha"
ERROR_USERNAME_REQUIRED = "Username is required"
ERROR_PASSWORD_REQUIRED = "Password Required"

# ── URLs (MANAGE_DEVICES_URL from config/<env>/config.json per ENV) ───
MANAGE_DEVICES_PATH = "/ManageDevices"
