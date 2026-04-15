import random
import string

from _config_defaults import config_scalar
from _shared_seed import resolved


def _random_string(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


# ── URLs (MANAGE_ACCOUNT_URL, CREATE_COST_CENTER_URL from config per ENV) ─

# ── Timeouts ─────────────────────────────────────────────────────────
CC_TIMEOUT = "30s"

# ── Test Data: Create Cost Center Form ───────────────────────────────
CC_ACCOUNT_NAME = f"AutoCC_{_random_string(8)}"
CC_COMMENT = "Automation test cost center"
CC_PARENT_ACCOUNT_NAME = resolved(
    "onboard_bu_name",
    "STC_CC_PARENT_ACCOUNT_NAME",
    config_scalar("DEFAULT_BU_ACCOUNT", "billingAccountSANJ_1003"),
)
CC_EC_ACCOUNT_NAME = resolved(
    "onboard_ec_name",
    "STC_CC_EC_ACCOUNT_NAME",
    config_scalar("DEFAULT_EC_ACCOUNT", "SANJ_1002"),
)

# ── Boundary / Negative Test Data ────────────────────────────────────
CC_LONG_ACCOUNT_NAME = "A" * 101
CC_MAX_ACCOUNT_NAME = "B" * 100
CC_LONG_COMMENT = "C" * 51
CC_MAX_COMMENT = "D" * 50
CC_SPECIAL_CHARS_NAME = "Test@#$%^&*()Name"
CC_SEMICOLON_NAME = "Test;CostCenter;Name"
CC_DUPLICATE_NAME = "Test Cost Center Automation"
