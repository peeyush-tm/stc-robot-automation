import random
import string


def _random_string(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


# ── URLs ─────────────────────────────────────────────────────────────
CSR_JOURNEY_URL = "https://192.168.1.26:7874/CSRJourney"
CREATE_CSR_URL = "https://192.168.1.26:7874/CreateCSRJourney"
MANAGE_USER_URL = "https://192.168.1.26:7874/ManageUser"

# ── Timeouts / Retries ──────────────────────────────────────────────
CSRJ_TIMEOUT = "30s"
CSRJ_RETRY_COUNT = "3x"
CSRJ_RETRY_INTERVAL = "5s"

# ── Test Data: Standard Services ─────────────────────────────────────
# Tariff plan: div name="tariffplan" data-testid="tariffplan" class="option" -> select "DATA AND NBIOT IT tp"
CSRJ_DEFAULT_TARIFF_PLAN = "DATA AND NBIOT IT tp"
# APN type: select apnCategory -> Select Any (value="any", label "Any")
CSRJ_APN_TYPE_PRIVATE = "private"
CSRJ_APN_TYPE_PUBLIC = "public"
CSRJ_APN_TYPE_ANY = "Any"
# APN in modal: select "public_dynamic"
CSRJ_DEFAULT_APN_NAME = "public_dynamic"
# Bundle plan: select name="bundleName" -> "DATA AND NBIOT IT DP"
CSRJ_DEFAULT_BUNDLE_PLAN = "DATA AND NBIOT IT DP"
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

# ── Test Data: Customer & Business Unit (CSR Journey landing) ─────────
CSRJ_DEFAULT_CUSTOMER_NAME = "SANJ_1002"
CSRJ_DEFAULT_BU_NAME = "billingAccountSANJ_1003"

# ── Test Data: Discount ──────────────────────────────────────────────
CSRJ_DISCOUNT_CATEGORY_ACCOUNT = "accountLevel"
CSRJ_DISCOUNT_CATEGORY_DEVICE = "devicePlanLevel"
CSRJ_DISCOUNT_PRICE = "10"
CSRJ_DISCOUNT_START_DATE = "01/01/2027"
CSRJ_DISCOUNT_END_DATE = "12/31/2027"
