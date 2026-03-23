import random
import string

# ── SIM States eligible for Change Device Plan ───────────────────────
DP_STATE_ACTIVATED = "Activated"
DP_STATE_TEST_ACTIVE = "TestActive"
DP_STATE_SUSPENDED = "Suspended"

# Filter labels for the Kendo filter panel
DP_FILTER_ACTIVATED = "Activated"
DP_FILTER_TEST_ACTIVE = "TestActive"
DP_FILTER_SUSPENDED = "Suspended"

# ── Grid Column Headers ──────────────────────────────────────────────
DP_STATE_COLUMN = "SIM State"
DP_IMSI_COLUMN = "IMSI"
DP_DEVICE_PLAN_COLUMN = "Device Plan"

# ── Account for all Device Plan tests ────────────────────────────────
DP_ACCOUNT_NAME = "billingAccountDONTUSE_005"

# ── Action dropdown label ────────────────────────────────────────────
DP_ACTION_LABEL = "Device Plan"

# ── URLs (DP_MANAGE_DEVICES_URL from config per ENV) ───────────────────
DP_MANAGE_DEVICES_PATH = "/ManageDevices"

# ── Negative / Edge-Case Data ────────────────────────────────────────
DP_COMMENT_TEXT = "Automated device plan change test"
DP_EMPTY_STRING = ""
