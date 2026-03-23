import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


_TIMESTAMP = str(int(time.time()))[-6:]

# ── URLs (LIVE_ORDER_URL, CREATE_SIM_ORDER_URL from config per ENV) ───
LIVE_ORDER_PATH = "/LiveOrder"
CREATE_SIM_ORDER_PATH = "/CreateSIMOrder"

# ── Valid Form Data — Step 1 (Order Details) ─────────────────────────
VALID_ACCOUNT_NAME = "KSA_OPCO"
VALID_SIM_TYPE_VALUE = "6"
VALID_QUANTITY = "5"
VALID_ACTIVATION_TYPE = "autoActivation"
VALID_SIM_STATE_VALUE = "1"

# ── Valid Form Data — Step 2 (Shipping Details) ──────────────────────
VALID_ADDRESS_LINE1 = "123 Test Street"
VALID_ADDRESS_LINE2 = "Suite 100"
VALID_AREA = "Riyadh Region"
VALID_CITY = "Riyadh"
VALID_POSTAL_CODE = "12345"
VALID_BILLING_NAME = "Test Billing Contact"
VALID_EMAIL = "test@example.com"
VALID_PRIMARY_PHONE = "1234567890"
VALID_SECONDARY_PHONE = "9876543210"

# ── Cancel Order Data ────────────────────────────────────────────────
VALID_CANCEL_REASON = "Automated test cancel"
VALID_CANCEL_REMARKS = f"Cancel remarks from automation run {_TIMESTAMP}"

# ── Search Data ──────────────────────────────────────────────────────
SEARCH_VALID_ORDER_NUMBER = "1"
SEARCH_NONEXISTENT = "ZZZZZZNOTEXIST999999"

# ── Negative Test Data — Quantity ────────────────────────────────────
QUANTITY_ZERO = "0"
QUANTITY_NEGATIVE = "-1"
QUANTITY_NON_NUMERIC = "abc"
QUANTITY_EXCEEDS_MAX = "999999999"

# ── Negative Test Data — Shipping ────────────────────────────────────
INVALID_POSTAL_CODE = "ABCDE"
SPECIAL_CHARS_ADDRESS = "!@#$%^&*()_+{}|:<>?"

# ── Security Test Data ───────────────────────────────────────────────
SQL_INJECTION_QUANTITY = "5; DROP TABLE orders;--"
SQL_INJECTION_ADDRESS = "' OR '1'='1' --"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_ORDER_CREATED = "Order submitted successfully"
TOAST_ORDER_CANCELLED = "cancelled"
