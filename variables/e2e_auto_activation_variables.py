"""E2E Auto Activation flow test data.

Two flows:
  e2e_aa_activated  — Auto Activation + Activated SIM state (skip UI activation steps)
  e2e_aa_testactive — Auto Activation + TestActive SIM state (activate via UI from TestActive)

Set E2E_AA_* keys in config/<env>.json before running on a new env.
"""

from _config_defaults import config_scalar

# ── SIM State dropdown values for the SIM Order form ──────────────────
# Value "1" = Activated (default in sim_order_variables.py)
# Value "2" = TestActive — confirm against live DOM if dropdown option not found
E2E_AA_SIM_STATE_ACTIVATED   = config_scalar("E2E_AA_SIM_STATE_ACTIVATED", "1")
E2E_AA_SIM_STATE_TESTACTIVE  = config_scalar("E2E_AA_SIM_STATE_TESTACTIVE", "2")

# ── Device Plan name to select during SIM order creation ──────────────
E2E_AA_DEVICE_PLAN = config_scalar("E2E_AA_DEVICE_PLAN", "")

# ── CSR Journey plan config for auto-activation orders ────────────────
# These specific plan values produce a device plan visible in the SIM Order
# dropdown immediately (unlike default plans which need 24h backend processing).
E2E_AA_TARIFF_PLAN  = config_scalar("E2E_AA_TARIFF_PLAN", "")
E2E_AA_APN_TYPE     = config_scalar("E2E_AA_APN_TYPE", "Public")
E2E_AA_APN_NAME     = config_scalar("E2E_AA_APN_NAME", "")
E2E_AA_BUNDLE_PLAN  = config_scalar("E2E_AA_BUNDLE_PLAN", "")

# ── Runtime — populated by TC_E2E_AA_*_001 (onboard API) ──────────────
E2E_AA_EC_NAME  = ""
E2E_AA_BU_NAME  = ""
E2E_AA_ORDER_ID = ""
E2E_AA_EC_ID    = ""
E2E_AA_BU_ID    = ""
