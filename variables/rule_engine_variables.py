import random
import string
import time


def _random_suffix():
    """6-char suffix from epoch + random chars for uniqueness."""
    ts = str(int(time.time()))[-4:]
    rand = "".join(random.choices(string.ascii_lowercase + string.digits, k=4))
    return f"{ts}{rand}"


_SUFFIX = _random_suffix()
# Exposed for Robot Framework (Python names starting with _ are not imported)
RE_SUFFIX = _SUFFIX

# ── URLs (RE_RULE_ENGINE_URL, RE_CREATE_RULE_URL from config per ENV) ─
RE_RULE_ENGINE_PATH = "/RuleEngine"
RE_CREATE_RULE_PATH = "/CreateRuleEngine"

# ── Tab 1 — Primary Details Valid Data ───────────────────────────────
RE_RULE_NAME = f"AutoRule_{_SUFFIX}"
RE_CATEGORY = "SIMLifecycle"
RE_CATEGORY_FRAUD = "FraudPrevention"
RE_CATEGORY_COST = "CostControl"
RE_CATEGORY_OTHER = "others"
RE_DESCRIPTION = "Rule created via automation"
RE_APP_LEVEL_EC = "EC"
RE_APP_LEVEL_BU = "BU"
RE_APP_LEVEL_CC = "CC"
RE_APP_LEVEL_SIM = "SIM"

# ── Tab 1 — Customer / BU Search Text (onboarded accounts) ──────────
RE_CUSTOMER_SEARCH_TEXT = "SANJ_1002"
RE_BU_SEARCH_TEXT = "billingAccountSANJ_1003"

# ── Tab 4 — Action Valid Data ────────────────────────────────────────
RE_ALERT_EMAIL = "test@automation.com"
RE_ALERT_DESC = "Alert from automation test"
RE_ACTION_RAISE_ALERT = "Raise Alert in Web GUI"

# ── Negative Test Data ───────────────────────────────────────────────
RE_EMPTY_STRING = ""
RE_INVALID_EMAIL = "not-an-email"
RE_LONG_RULE_NAME = "A" * 51  # 51 characters — exceeds max 50

# ── Expected Messages ────────────────────────────────────────────────
RE_SUCCESS_TOAST_TEXT = "Rule Added Successfully"

# ── Misc ─────────────────────────────────────────────────────────────
RE_RULE_NAME_MAX_LENGTH = 50
