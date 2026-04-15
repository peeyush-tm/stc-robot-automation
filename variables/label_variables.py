"""Label module — Admin > Manage Label / Create Label / Edit Label (TC_009 spec)."""
import random
import string
import time

_TIMESTAMP = str(int(time.time()))


def _rand(n=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=n))


# Paths (full URLs use ${BASE_URL} in Robot)
MANAGE_LABEL_PATH = "/ManageLabel"
CREATE_LABEL_PATH = "/CreateLabel"

# Timeouts / retries
LBL_TIMEOUT = "30s"
LBL_RETRY = "3x"
LBL_RETRY_INTERVAL = "5s"

# Default form data (aligned to TC_009_Create_Label_RF.md, adjusted to actual UI which shows OPCO)
LBL_LEVEL_KSA = "OPCO"
LBL_COLOR_HEX = "#FF5733"
LBL_COLOR_HEX_ALT = "#228B22"
LBL_DESCRIPTION_DEFAULT = "Label created via automation"
LBL_DESCRIPTION_UPDATED = "Label description updated via automation"
LBL_ACCOUNT_INDEX = 1

# Unique name per run (duplicate tests use fixed prefix + stable token where needed)
LBL_NAME = f"auto-lbl-{_rand(6)}-{_TIMESTAMP[-6:]}"
LBL_NAME_ALT = f"auto-lbl-alt-{_rand(6)}-{_TIMESTAMP[-6:]}"

# Duplicate negative: must match an existing label for same account after seed create
LBL_DUPLICATE_BASE = f"auto-lbl-dup-{_TIMESTAMP}"

# Long name (>100) for boundary negative
LBL_NAME_OVER_100 = "a" * 101

# Long description (>100) for optional field boundary (if app validates)
LBL_DESCRIPTION_OVER_100 = "d" * 101

# ── Label Assignment on Manage Devices (TC_021) ─────────────────────────────
LA_TAG_ASSIGNMENT_VALUE = "13"
LA_TAG_ACTION_ASSIGN = "assign"
LA_TAG_ACTION_UNASSIGN = "unassign"
