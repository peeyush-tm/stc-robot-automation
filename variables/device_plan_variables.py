from _config_defaults import config_scalar
from _shared_seed import resolved

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

# ── Account for all Device Plan tests ─────────────────────────────────
# Account from E2E Flow With Usage seed → env STC_DP_ACCOUNT_NAME → file default.
DP_ACCOUNT_NAME = resolved("e2e_usage_bu_name", "STC_DP_ACCOUNT_NAME",
                           config_scalar("DEFAULT_BU_ACCOUNT", "billingAccountSANJ_1003"))
# Second activated IMSI from E2E Flow With Usage for TC_CDP_002 when set.
DP_PINNED_IMSI_ACTIVATED = resolved(
    "e2e_usage_second_activated_imsi", "STC_DP_PINNED_IMSI", ""
)

# ── Action dropdown label ────────────────────────────────────────────
DP_ACTION_LABEL = "Device Plan"

# ── URLs (DP_MANAGE_DEVICES_URL from config per ENV) ───────────────────
DP_MANAGE_DEVICES_PATH = "/ManageDevices"

# ── Negative / Edge-Case Data ────────────────────────────────────────
DP_COMMENT_TEXT = "Automated device plan change test"
DP_EMPTY_STRING = ""
