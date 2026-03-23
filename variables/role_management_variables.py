import random
import string
import time


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def _unique_suffix():
    return str(int(time.time()))[-6:]


_SUFFIX = _unique_suffix()
SUFFIX = _SUFFIX   # exposed so Robot Framework can use ${SUFFIX}

# ── Timeouts ──────────────────────────────────────────────────────────
RM_TIMEOUT = "30s"

# ── Navigation (MD: Routes) ──────────────────────────────────────────
MANAGE_ROLE_PATH = "/ManageRole"
CREATE_ROLE_PATH = "/CreateRole"

# ── Account TreeView hierarchy (same as Create User) ─────────────────
RM_EC_ACCOUNT_NAME = "AQ_AUTO_EC_20260319165618"
RM_BU_ACCOUNT_NAME = "AQ_AUTO_BU_20260319165618"

# ── Test Data (MD: Test Data table) ──────────────────────────────────
# Role Name: max 250 chars, must be unique
ROLE_NAME = f"AutoRole_{_SUFFIX}"
# Role Description: max 500 chars, optional
ROLE_DESCRIPTION = "Automation test role"

# ── Boundary Values (MD: Test Data → max 250 / max 500) ──────────────
ROLE_NAME_MAX = 250
ROLE_DESC_MAX = 500
ROLE_NAME_EXACTLY_250 = "R" * 250
ROLE_NAME_MORE_THAN_250 = "R" * 251
ROLE_DESC_EXACTLY_500 = "D" * 500
ROLE_DESC_MORE_THAN_500 = "D" * 501

# ── Invalid / Edge Case Data ─────────────────────────────────────────
WHITESPACE_ROLE_NAME = "   "
SPECIAL_CHARS_ROLE_NAME = "Role!@#$%^&*()"

# ── Breadcrumb (MD: Step 2.3, Notes) ─────────────────────────────────
CREATE_ROLE_BREADCRUMB = "Create"

# ── Delete Dialog (MD: TC-ROLE-002, Step 4) ──────────────────────────
# Guard validation error key (MD: Step 5.1)
CANT_DELETE_OWN_ROLE_KEY = "t_cantdelete"

# ── API Endpoints (MD: API Reference) ────────────────────────────────
API_ROLES_LIST = "api/role/access"
API_CREATE_ROLE = "api/create/role"
API_DELETE_ROLE = "api/delete/roles"
API_GET_ROLE = "api/roles"
API_SCREEN_LIST = "api/get/screenList"
API_TAB_LIST = "api/get/tabList"
API_UPDATE_ROLE = "api/update/roles"
