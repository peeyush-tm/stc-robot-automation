import random
import string
from datetime import datetime


def _random_digits(length=4):
    return "".join(random.choices(string.digits, k=length))


def _timestamp_seconds():
    """Current timestamp up to seconds only, digits only: YYYYMMDDHHMMSS (14 chars)."""
    return datetime.now().strftime("%Y%m%d%H%M%S")


def unique_id():
    """Generates a fresh unique suffix each time it is called (timestamp to seconds)."""
    return _timestamp_seconds()


# ── API endpoint and headers (from config/<env>/config.json per ENV) ───
# ONBOARD_API_URL, ONBOARD_AUTH_HEADER, ONBOARD_SOAP_ACTION loaded from config.

# ── Unique values: timestamp to seconds (YYYYMMDDHHMMSS), appended with no separators ───
_TS = _timestamp_seconds()

# ══════════════════════════════════════════════════════════════════════
#  7 FIELDS THAT MUST BE UNIQUE IN EVERY RUN
# ══════════════════════════════════════════════════════════════════════
ORDER_NUMBER = f"S5{_TS}"
TASK_ID = f"ID{_TS}"
BUSINESS_UNIT_NAME = f"S5P1auto{_TS}"
CUSTOMER_REFERENCE_NUMBER = f"95{_TS}"
COMPANY_NAME = f"AQ_AUTO_EC{_TS}"
BILLING_ACCOUNT_NAME = f"AQ_AUTO_BU{_TS}"
BILLING_ACCOUNT_NUMBER = f"42{_TS}"

# ── Customer Fields (matching latest SOAP payload) ──────────────────
UNIFIED_ID = "10"
CUSTOMER_SEGMENT_CODE = "NG"
CUSTOMER_TYPE = "regular"
BILL_HIERARCHY_FLAG = "Y"
FIRST_NAME = "aaaryaanshhh"
LAST_NAME = "upadhhyyeeeeee"
ALTERNATE_NAME = "Digital"
IDENTIFICATION_TYPE_CODE = "esim"
IDENTITY_NUMBER = "56"
PRIMARY_PHONE_NUMBER = "9604581171"
LANGUAGE_CODE = "ar"

# ── Customer Address ─────────────────────────────────────────────────
CUSTOMER_COUNTRY = "SA"
CUSTOMER_ZIP_CODE = "342008"
CUSTOMER_ADDRESS_TYPE = "Permanent"
CUSTOMER_ADDRESS_LINE1 = "HIG 12 RK Enclave"
CUSTOMER_ADDRESS_LINE2 = "baner"
CUSTOMER_ADDRESS_LINE3 = "Sprint Anatayaa road"
CUSTOMER_ADDRESS_LINE4 = "Pune"
CUSTOMER_ADDRESS_LINE5 = "Maharashtra"

# ── Customer Additional Fields ───────────────────────────────────────
CUSTOMER_GENRE = "unmanaged"
CUSTOMER_CATEGORY = "commercial"
MAX_NUMBER_IMSIS = "0"
TECH_CONTACT_PERSON_MOBILE = "09403464075"
TECH_CONTACT_PERSON_EMAIL = "akshit.shukla@airlinq.com"
LEAD_PERSON_OR_ACC_MANAGER_ID = "4432"
LOCAL_DATA = "true"
DATA_WITH_INTERNET = "true"
VOICE_WITH_INTERNET = "true"
PREFERRED_LANGUAGE = "en"

# ── Billing Account Fields ───────────────────────────────────────────
BILLING_ACCOUNT_STATUS = "Live"
BILL_CYCLE = "75"
MAX_SIM_NUMBER = "0"
FINGERPRINT_STATUS = "y"
BU_TECH_CONTACT_PERSON_MOBILE = "9146741159"
BU_TECH_CONTACT_PERSON_EMAIL = "akshit.shukla@airlinq.com"

# ── Billing Address ──────────────────────────────────────────────────
BILLING_COUNTRY = "SA"
BILLING_ZIP_CODE = "2435235"
BILLING_ADDRESS_TYPE = "Permanent"
BILLING_ADDRESS_LINE1 = "ornate pg"
BILLING_ADDRESS_LINE2 = "Baghmugalia"
BILLING_ADDRESS_LINE3 = "Amar tech road"
BILLING_ADDRESS_LINE4 = "pune"
BILLING_ADDRESS_LINE5 = "Mr"
