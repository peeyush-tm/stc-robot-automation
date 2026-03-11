import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def _unique_suffix():
    return str(int(time.time()))[-6:]


_SUFFIX = _unique_suffix()

# ── Timeouts ──────────────────────────────────────────────────────────
UM_TIMEOUT = "30s"

# ── Navigation URLs ──────────────────────────────────────────────────
MANAGE_USER_PATH = "/ManageUser"
CREATE_USER_PATH = "/CreateUser"

# ── Account TreeView selection ──────────────────────────────────────
UM_EC_ACCOUNT_NAME = "SANJ_1002"
UM_BU_ACCOUNT_NAME = "billingAccountSANJ_1003"

# ── Dropdown selections ───────────────────────────────────────────
UM_USER_CATEGORY = "NormalUser"
UM_ROLE_NAME = "BillingAccount_Admin"
UM_TIMEZONE_TEXT = "(GMT+03:00) Kuwait, Riyadh"
UM_COUNTRY_TEXT = "India"

# ── Test User Data (from MD: Step 7–16) ──────────────────────────────
# Username: min 5 chars, max 50 chars, must be unique
TEST_USERNAME = f"autouser{_SUFFIX}"
TEST_FIRST_NAME = "Test"
TEST_LAST_NAME = "User"
# Primary Phone: min 5 digits, max 16 digits, numeric only
TEST_PRIMARY_PHONE = "9876543210"
# Email: valid email format
TEST_EMAIL = f"autouser{_SUFFIX}@mailinator.com"

# ── Boundary Values (from MD: Form Field Reference) ─────────────────
# Username boundaries
USERNAME_MIN_LENGTH = 5
USERNAME_MAX_LENGTH = 50
USERNAME_EXACTLY_5 = "usr" + _random_string(2)
USERNAME_EXACTLY_50 = "u" * 50
USERNAME_LESS_THAN_5 = "usr"
USERNAME_MORE_THAN_50 = "u" * 51

# Phone boundaries
PHONE_MIN_DIGITS = 5
PHONE_MAX_DIGITS = 16
PHONE_EXACTLY_5 = "98765"
PHONE_EXACTLY_16 = "9876543210123456"
PHONE_LESS_THAN_5 = "9876"
PHONE_MORE_THAN_16 = "98765432101234567"
PHONE_NON_NUMERIC = "abcde12345"

# Invalid email
INVALID_EMAIL = "not-an-email"
MISMATCHED_EMAIL = "different@mailinator.com"

# Whitespace / special chars
WHITESPACE_INPUT = "   "
SPECIAL_CHARS_USERNAME = "user!@#$%"

# Delete dialog expected text (from MD: Confirmation Dialog Reference)
DELETE_DIALOG_HEADING = "Delete User"
DELETE_SUCCESS_MSG = "User Deleted Successfully"
