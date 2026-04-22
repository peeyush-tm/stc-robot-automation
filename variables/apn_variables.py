import random
import string
import time

from _shared_seed import env_default


def _random_string(length=6):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


_TIMESTAMP = str(int(time.time()))[-6:]

# ── URLs (MANAGE_APN_URL, CREATE_APN_URL from config/<env>/config.json) ─
MANAGE_APN_PATH = "/ManageAPN"
CREATE_APN_PATH = "/CreateAPN"

# ── APN Type Values ──────────────────────────────────────────────────
APN_TYPE_PRIVATE = "1"
APN_TYPE_PUBLIC = "2"

# ── Account & BU (env STC_APN_ACCOUNT_NAME / STC_APN_BU_NAME) ───────
ACCOUNT_NAME = env_default("STC_APN_ACCOUNT_NAME", "SANJU")
BU_NAME = env_default("STC_APN_BU_NAME", "billingAccountSANJU")

# ── Valid Primary Details — Private APN ──────────────────────────────
VALID_APN_ID = f"10{_TIMESTAMP}"
VALID_APN_NAME = f"auto-apn-{_random_string(6)}"
VALID_DESCRIPTION = "APN created via automation"
VALID_EQOS_ID = "100"
VALID_CONTEXT_ID = "1"
VALID_APN_SERVICE_TYPE = "1"
VALID_IP_ADDR_TYPE_IPV4 = "1"
VALID_IP_ADDR_TYPE_IPV6 = "0"
VALID_IP_ADDR_TYPE_BOTH = "2"
VALID_IP_ALLOC_STATIC = "static"
VALID_IP_ALLOC_DYNAMIC = "dynamic"

# ── Valid Primary Details — Public APN ───────────────────────────────
PUBLIC_APN_ID = f"20{_TIMESTAMP}"
PUBLIC_APN_NAME = f"auto-pub-apn-{_random_string(6)}"
PUBLIC_DESCRIPTION = "Public APN created via automation"

# ── Valid Subnet Mask Details ────────────────────────────────────────
VALID_SUBNET_IP = "10.0.0.0"
VALID_SUBNET_CIDR = "/24"
VALID_SUBNET_IPV6 = "2001:db8::"
VALID_FIRST_USABLE_IP = ""

# ── Valid Secondary Details ──────────────────────────────────────────
VALID_HLR_APN_ID = "5001"
VALID_MCC = "420"
VALID_MNC = "01"
VALID_PROFILE_ID = "100"

# ── Valid QoS Details ────────────────────────────────────────────────
VALID_QOS_PROFILE_2G3G = f"qos2g3g-{_random_string(4)}"
VALID_QOS_BW_UPLINK_2G3G = "512"
VALID_QOS_BW_DOWNLINK_2G3G = "1024"
VALID_QOS_PROFILE_LTE = f"qosLTE-{_random_string(4)}"
VALID_QOS_BW_UPLINK_LTE = "2048"
VALID_QOS_BW_DOWNLINK_LTE = "4096"
QOS_UNIT_KBPS = "1"
QOS_UNIT_MBPS = "2"

# ── Valid Radius Configuration ───────────────────────────────────────
RADIUS_AUTH = "Authentication"
RADIUS_FORWARDING = "Forwarding"
RADIUS_AUTH_TYPE_NONE = "None"
RADIUS_AUTH_TYPE_PAP_CHAP = "PAP/CHAP"
VALID_RADIUS_PASSWORD = "RadPass@123"

# ── Negative Test Data ───────────────────────────────────────────────
EMPTY_STRING = ""
APN_ID_EXCEEDS_MAX = "12345678901234567890"
APN_NAME_EXCEEDS_MAX = "a" * 51
DESCRIPTION_EXCEEDS_MAX = "d" * 501
HLR_APN_ID_EXCEEDS_MAX = "12345678901234567890"
SQL_INJECTION_APN_NAME = "' OR '1'='1' --"
SPECIAL_CHARS_APN_NAME = "!@#$%^&*()_+{}|:<>?"
DUPLICATE_APN_NAME = "test-apn-automation"

# ── Public APN E2E (Static Dual-Stack) ──────────────────────────────
E2E_PUBLIC_APN_ID = f"34{_TIMESTAMP}"
E2E_PUBLIC_APN_NAME = f"auto-e2e-pub-{_random_string(6)}"
E2E_PUBLIC_DESCRIPTION = "E2E Public APN with Static IPV4 and IPV6"
E2E_PUBLIC_EQOS_ID = "3456789"
E2E_PUBLIC_CONTEXT_ID = "23456789"
PUBLIC_ACCOUNT_NAME = "KSA_OPCO"

# ── APN ID Validation ────────────────────────────────────────────────
ALPHA_APN_ID = "abc123xyz"
SPECIAL_CHAR_APN_ID = "12#45@678"

# ── Search / Grid Test Data ─────────────────────────────────────────
APN_SEARCH_TERM = "auto-apn"

# ── Expected Column Headers ─────────────────────────────────────────
EXPECTED_APN_COLUMNS = [
    "APN NAME", "APN ID", "ACCOUNT", "APN TYPE", "SHARED",
    "STATUS", "EQOSID", "IPV4 ALLOCATION TYPE", "IPV6 ALLOCATION TYPE",
    "HSS PROFILE ID", "DESCRIPTION", "CREATION DATE",
]

# ── Subnet IPV4 Test Data ────────────────────────────────────────────
SUBNET_IPV4_VALID = "10.45.223.45"
SUBNET_IPV4_PREFIX_30 = "/30"
SUBNET_IPV4_INVALID = "999.999.999.999"
SUBNET_IPV4_SECOND = "172.16.0.0"
SUBNET_IPV4_SECOND_PREFIX = "/30"
SUBNET_IPV4_EDGE_IP = "192.168.1.0"
SUBNET_IPV4_PREFIX_32 = "/32"
SUBNET_IPV4_PREFIX_24 = "/24"
SUBNET_IPV4_PREFIX_29 = "/29"

# ── Subnet IPV6 Test Data ────────────────────────────────────────────
SUBNET_IPV6_VALID = "fd8c:42b7:1000:0000:0"
SUBNET_IPV6_PREFIX_63 = "/63"
SUBNET_IPV6_INVALID = "invalid::address::xyz"
SUBNET_IPV6_SECOND = "2001:db8:1000::"
SUBNET_IPV6_SECOND_PREFIX = "/64"

# ── Expected Messages ────────────────────────────────────────────────
TOAST_APN_CREATED = "APN Created Successfully"
