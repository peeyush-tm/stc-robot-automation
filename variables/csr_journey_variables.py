import os
import random
import string

from _config_defaults import config_scalar
from _shared_seed import read_value


def _random_string(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


# ── URLs (CSR_JOURNEY_URL, CREATE_CSR_URL, MANAGE_USER_URL from config per ENV) ─

# ── Timeouts / Retries ──────────────────────────────────────────────
CSRJ_TIMEOUT = "30s"
# SPA route changes (ManageUser / CSRJourney / CreateCSRJourney): poll often — 5s gaps added ~5–10s latency per hop.
CSRJ_RETRY_COUNT = "40x"
CSRJ_RETRY_INTERVAL = "0.5s"

# Standard Services — Add APN(s) primary button (Python so import order cannot revive a stale locator)
CSRJ_LOC_ADD_APNS_BTN = (
    "xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'cursor-pointer') "
    "and contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', "
    "'abcdefghijklmnopqrstuvwxyz'), 'add apn')]"
)

# ── Test Data: Standard Services ─────────────────────────────────────
# Tariff / APN / bundle defaults: config/<env>.json (DEFAULT_CSR_*); suite load may override.
CSRJ_DEFAULT_TARIFF_PLAN = config_scalar(
    "DEFAULT_CSR_TARIFF_PLAN", "DATA AND NBIOT IT tp"
)
# APN type: select apnCategory -> Select Any (value="any", label "Any")
# Labels must match <select> option text (Select From List By Label); lowercase breaks Public/Private.
CSRJ_APN_TYPE_PRIVATE = "Private"
CSRJ_APN_TYPE_PUBLIC = "Public"
CSRJ_APN_TYPE_ANY = "Any"
CSRJ_DEFAULT_APN_NAME = config_scalar(
    "DEFAULT_CSR_MODAL_APN_NAME", "public_dynamic"
)
CSRJ_DEFAULT_BUNDLE_PLAN = config_scalar(
    "DEFAULT_CSR_BUNDLE_PLAN", "DATA AND NBIOT IT DP"
)
CSRJ_DEFAULT_TARIFF_PLAN_2 = config_scalar(
    "DEFAULT_CSR_TARIFF_PLAN_2", ""
)
CSRJ_DEFAULT_APN_TYPE_2 = config_scalar(
    "DEFAULT_CSR_APN_TYPE_2", "Public"
)
CSRJ_DEFAULT_APN_NAME_2 = config_scalar(
    "DEFAULT_CSR_APN_NAME_2", ""
)
CSRJ_DEFAULT_BUNDLE_PLAN_2 = config_scalar(
    "DEFAULT_CSR_BUNDLE_PLAN_2", "SimReplacementDpRC"
)
# Random device plan alias for dpAliasName input (Create CSR - TC_CSRJ_004)
CSRJ_DEVICE_PLAN_ALIAS = f"DP_{_random_string(6)}"
# Device plan alias for Modify CSR (TC_CSRJ_052) — independent from create
CSRJ_DEVICE_PLAN_ALIAS_MODIFY = f"DPM_{_random_string(6)}"
# Device plan alias for second row additions
CSRJ_DEVICE_PLAN_ALIAS_2 = f"DP2_{_random_string(6)}"

# ── Test Data: Service Plan ──────────────────────────────────────────
CSRJ_SERVICE_PLAN_NAME = f"Auto SP {_random_string(6)}"

# ── Test Data: End Date (future date) ────────────────────────────────
CSRJ_END_DATE = "12/31/2027"

# ── Test Data: VAS Charges ───────────────────────────────────────────
CSRJ_VAS_AMOUNT = "100"

# ── Customer & BU from Customer Onboard tests seed (paired resolution) ─
def _csrj_default_ec_bu_pair():
    file_ec = config_scalar("DEFAULT_EC_ACCOUNT", "SANJ_1002")
    file_bu = config_scalar("DEFAULT_BU_ACCOUNT", "billingAccountSANJ_1003")
    ec_env = os.environ.get("STC_CSRJ_DEFAULT_CUSTOMER_NAME", "").strip()
    bu_env = os.environ.get("STC_CSRJ_DEFAULT_BU_NAME", "").strip()
    if ec_env or bu_env:
        return (ec_env or file_ec), (bu_env or file_bu)
    sec = str(read_value("onboard_ec_name", "") or "").strip()
    sbu = str(read_value("onboard_bu_name", "") or "").strip()
    if sec and sbu:
        return sec, sbu
    return file_ec, file_bu


CSRJ_DEFAULT_CUSTOMER_NAME, CSRJ_DEFAULT_BU_NAME = _csrj_default_ec_bu_pair()

# ── Test Data: Discount ──────────────────────────────────────────────
CSRJ_DISCOUNT_CATEGORY_ACCOUNT = "accountLevel"
CSRJ_DISCOUNT_CATEGORY_DEVICE = "devicePlanLevel"
CSRJ_DISCOUNT_PRICE = "10"
CSRJ_DISCOUNT_START_DATE = "01/01/2027"
CSRJ_DISCOUNT_END_DATE = "12/31/2027"
