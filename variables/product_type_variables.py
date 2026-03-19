import random
import string


def _random_string(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


# ── URLs ─────────────────────────────────────────────────────────────
MANAGE_USER_URL = "https://192.168.1.26:7874/ManageUser"
PRODUCT_TYPE_URL = "https://192.168.1.26:7874/ProductType"
CREATE_PT_URL = "https://192.168.1.26:7874/CreateProductType"

# ── Timeouts / Retries ──────────────────────────────────────────────
PT_TIMEOUT = "30s"
PT_RETRY_COUNT = "3x"
PT_RETRY_INTERVAL = "5s"

# ── Workflow A: Create Product Type — Valid Data ────────────────────
PT_NAME = f"Auto PT {_random_string(6)}"
PT_SERVICE_TYPE_POSTPAID = "Postpaid"
PT_SUB_TYPE_2 = "physical"
PT_SUB_TYPE_3_SIM = "SIM"
PT_SUB_TYPE_3_ESIM = "esim"
PT_SUB_TYPE_4 = "4FF"
PT_PACKAGING_SIZE = "100"
PT_COMMENT = "Automation test product type"
PT_DESC_EN = "Test product type created by automation"

# ── EC Account for Assign Customer ──────────────────────────────────
PT_EC_ACCOUNT_NAME = "SANJ_1002"

# ── Duplicate Test Data ─────────────────────────────────────────────
DUPLICATE_PT_NAME = "Test SIM Product Type"
