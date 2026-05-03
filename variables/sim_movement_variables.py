"""SIM Movement test data.

Standalone runs (single suite / no E2E seed): set *_STANDALONE_* below, or export
``STC_SM_*`` env vars, or pass ``--variable SM_*:value`` to Robot. ICCID is preferred
for movement; if only ``SM_IMSI_TO_MOVE`` is set (seed/env/standalone), the suite
resolves ICCID from the grid after an IMSI search.
"""

import os

from _config_defaults import config_scalar
from _shared_seed import resolved

# ── Standalone defaults (used when env + .run_seed.json are empty) ─────
# Falls back to DEFAULT_EC_ACCOUNT / DEFAULT_BU_ACCOUNT from config/<env>.json.
_STANDALONE_EC = config_scalar("DEFAULT_EC_ACCOUNT", "")
_STANDALONE_SOURCE_BU = config_scalar("DEFAULT_BU_ACCOUNT", "")
_STANDALONE_ICCID = ""
_STANDALONE_IMSI = ""
_STANDALONE_DEVICE_PLAN = ""
_STANDALONE_TARGET_BU = config_scalar("SM_TARGET_BU_ACCOUNT", "")

# ── Account from E2E Flow With Usage seed / _STANDALONE_* / STC_SM_* ─
# Env: STC_SM_EC_ACCOUNT_NAME, STC_SM_SOURCE_BU_ACCOUNT
SM_EC_ACCOUNT_NAME = resolved("e2e_usage_ec_name", "STC_SM_EC_ACCOUNT_NAME", _STANDALONE_EC)
SM_SOURCE_BU_ACCOUNT = resolved("e2e_usage_bu_name", "STC_SM_SOURCE_BU_ACCOUNT", _STANDALONE_SOURCE_BU)

# ── E2E Flow With Usage activation capture / manual ──────────────────────
# Env: STC_SM_ICCID_TO_MOVE — preferred when set or present in seed.
SM_ICCID_TO_MOVE = resolved("e2e_usage_first_activated_iccid", "STC_SM_ICCID_TO_MOVE", _STANDALONE_ICCID)
# Env: STC_SM_IMSI_TO_MOVE — used when ICCID is empty; grid resolve selects by IMSI.
SM_IMSI_TO_MOVE = resolved("e2e_usage_first_activated_imsi", "STC_SM_IMSI_TO_MOVE", _STANDALONE_IMSI)
# Filled at runtime when TC_SM_005 runs
SM_IMSI_FOR_MOVE = ""
# GC Request Id from bell after TC_SM_005; for isolated TC_SM_009 use env or --variable
SM_BATCH_REQUEST_ID = (os.environ.get("STC_SM_BATCH_REQUEST_ID") or "").strip()

# ── Device Plan for Activated SIMs (CSR Journey / seed) ─────────────────
# Env: STC_SM_DEVICE_PLAN_NAME
SM_DEVICE_PLAN_NAME = resolved(
    "csrj_device_plan_alias", "STC_SM_DEVICE_PLAN_NAME", _STANDALONE_DEVICE_PLAN
)

# ── Target BU (move destination) ───────────────────────────────────────
# Resolution order: E2E seed target_bu_account → onboard_bu_name → env var → config SM_TARGET_BU_ACCOUNT
# Env: STC_SM_TARGET_BU_ACCOUNT
SM_TARGET_BU_ACCOUNT = (
    resolved("target_bu_account", "STC_SM_TARGET_BU_ACCOUNT", "")
    or resolved("onboard_bu_name", "", _STANDALONE_TARGET_BU)
)

# ── Action / Config ───────────────────────────────────────────────────
SM_ACTION_VALUE = "14"
SM_ACTION_LABEL = "SIM Movement"
SM_MANAGE_DEVICES_PATH = "ManageDevices"
SM_MANAGE_ACCOUNT_PATH = "ManageAccount"
SM_MANAGE_AUDIT_PATH = "ManageAudit"
SM_BATCH_JOB_PATH = "BatchJobLog"
SM_JOB_SET_OP_STATUS = "Set Operation Status"
SM_JOB_RESPONSE_HANDLER = "Response Handler"
SM_NOTE_SUCCESS_TEXT = "SIM Movement Successful"
SM_AUDIT_ACTION_TEXT = "SIM Movement"
SM_SEARCH_MODE_ICCID = "ICCID"

SM_SLOTS_TO_ADD = 5

SM_COMMENT_TEXT = "Automated SIM Movement test"
SM_BJL_DETAIL_SUBSTRING = "Sim Movement completed without DP change"
