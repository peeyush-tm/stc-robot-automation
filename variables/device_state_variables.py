import random
import string

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
MSISDN_COLUMN_HEADER = "MSISDN"

# Account used for all DSC tests — narrows grid to known devices
DSC_ACCOUNT_NAME = "billingAccountDONTUSE_005"

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
