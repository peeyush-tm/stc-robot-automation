import os
import random
import string

from _config_defaults import config_scalar
from _shared_seed import resolved


def _env_truthy(name: str) -> bool:
    return str(os.environ.get(name, "") or "").strip().lower() in ("1", "true", "yes")


def _env_falsy(name: str) -> bool:
    return str(os.environ.get(name, "") or "").strip().lower() in ("0", "false", "no")


# Manage Devices account filter: **False = legacy** (Sleep + global overlay — stable for Device State, Order Proc, SIM Movement).
# **True = OOM-safe** (popup-first, no global overlay mid-filter — SIM Replacement default via ``sim_replacement_variables``).
# Force: ``STC_DSC_ACCOUNT_FILTER_OOM_SAFE=1`` or ``=0``.
if _env_truthy("STC_DSC_ACCOUNT_FILTER_OOM_SAFE"):
    DSC_ACCOUNT_FILTER_OOM_SAFE = True
elif _env_falsy("STC_DSC_ACCOUNT_FILTER_OOM_SAFE"):
    DSC_ACCOUNT_FILTER_OOM_SAFE = False
else:
    DSC_ACCOUNT_FILTER_OOM_SAFE = False

# ── SIM State Values ─────────────────────────────────────────────────
STATE_ACTIVATED = "Activated"
STATE_SUSPENDED = "Suspended"
STATE_TERMINATE = "Terminate"
STATE_TEST_READY = "TestReady"
STATE_TEST_ACTIVE = "TestActive"
STATE_DEACTIVATED = "Deactivated"
STATE_WARM = "Warm"
STATE_INACTIVE = "InActive"
STATE_RETIRED = "Retired"

# Filter option visible text → data-id mapping
# Warm → Warm, Activated → Activated, Suspended → Suspended,Deactivated
# TestActive → TestActive, InActive → TestReady, Terminate → Terminate, Retired → Retired
FILTER_LABEL_ACTIVATED = "Activated"
FILTER_LABEL_SUSPENDED = "Suspended"
FILTER_LABEL_TEST_ACTIVE = "TestActive"
FILTER_LABEL_INACTIVE = "InActive"
FILTER_LABEL_TERMINATE = "Terminate"
FILTER_LABEL_WARM = "Warm"
FILTER_LABEL_RETIRED = "Retired"

# Grid column header text
STATE_COLUMN_HEADER = "SIM State"
ICCID_COLUMN_HEADER = "ICCID"
IMSI_COLUMN_HEADER = "IMSI"
# Manage Devices grid — account / BU column (header match uses substring)
ACCOUNT_COLUMN_HEADER = "Account"
BUSINESS_UNIT_NAME_COLUMN_HEADER = "Business Unit Name"
MSISDN_COLUMN_HEADER = "MSISDN"

# Account from E2E Flow (without usage) seed — env STC_DSC_ACCOUNT_NAME or edit default
DSC_ACCOUNT_NAME = resolved("e2e_bu_name", "STC_DSC_ACCOUNT_NAME",
                            config_scalar("DEFAULT_BU_ACCOUNT", "billingAccountSANJ_1003"))

# ── Transitions that require Service Plan + Device Plan ──────────────
# All other transitions only require Reason.
TRANSITIONS_NEEDING_PLANS = [
    ("TestReady", "Activated"),
    ("TestReady", "TestActive"),
    ("TestActive", "Activated"),
]

# ── URLs (MANAGE_DEVICES_URL from config per ENV) ─────────────────────
MANAGE_DEVICES_PATH = "/ManageDevices"

# ── Negative / Edge-Case Data ────────────────────────────────────────
EMPTY_STRING = ""
COMMENT_LONG = "a" * 501
COMMENT_SQL_INJECTION = "' OR '1'='1' --"
