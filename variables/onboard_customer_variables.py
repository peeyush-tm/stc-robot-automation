import random
import string
import time


def _random_digits(length=4):
    return "".join(random.choices(string.digits, k=length))


def _unique_suffix():
    return str(int(time.time()))[-6:]


def unique_id():
    """Generates a fresh unique suffix each time it is called."""
    return str(int(time.time() * 1000))[-8:]


# ── API Endpoint ──────────────────────────────────────────────────────
ONBOARD_API_URL = "https://10.121.77.94:8443/STCCMPSoapInterfaceS5P1/services/CustomerOnboardOperationsImplService"

# ── Headers ───────────────────────────────────────────────────────────
ONBOARD_AUTH_HEADER = "Basic c3RjX2FkbWluOmdsb2JldG91Y2g="
ONBOARD_SOAP_ACTION = "http://webservices.stc.comarch.com/CRMIntegrationsAPI/createOnboardCustomerRequest"

# ── Dynamic suffix for unique test data per run ───────────────────────
_SUFFIX = _unique_suffix()

# ══════════════════════════════════════════════════════════════════════
#  7 FIELDS THAT MUST BE UNIQUE IN EVERY RUN
# ══════════════════════════════════════════════════════════════════════
ORDER_NUMBER = f"S5P1_{_SUFFIX}"
TASK_ID = f"S5P1_auto_{_SUFFIX}"
BUSINESS_UNIT_NAME = f"S5P1_auto_{_SUFFIX}"
CUSTOMER_REFERENCE_NUMBER = f"9595{_random_digits(8)}"[:12]
COMPANY_NAME = f"AQ_AUTO_EC_{_SUFFIX}"
BILLING_ACCOUNT_NAME = f"AQ_AUTO_BU_{_SUFFIX}"
BILLING_ACCOUNT_NUMBER = f"4423{_random_digits(13)}"[:17]

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
MAX_NUMBER_IMSIS = "5"
TECH_CONTACT_PERSON_MOBILE = "09403464075"
TECH_CONTACT_PERSON_EMAIL = "akshay.upadhye@airlinq.com"
LEAD_PERSON_OR_ACC_MANAGER_ID = "4432"
LOCAL_DATA = "true"
DATA_WITH_INTERNET = "true"
VOICE_WITH_INTERNET = "true"
PREFERRED_LANGUAGE = "en"

# ── Billing Account Fields ───────────────────────────────────────────
BILLING_ACCOUNT_STATUS = "Live"
BILL_CYCLE = "75"
MAX_SIM_NUMBER = "5"
FINGERPRINT_STATUS = "y"
BU_TECH_CONTACT_PERSON_MOBILE = "9146741159"
BU_TECH_CONTACT_PERSON_EMAIL = "akshay.upadhye@qtsolv.com"

# ── Billing Address ──────────────────────────────────────────────────
BILLING_COUNTRY = "SA"
BILLING_ZIP_CODE = "2435235"
BILLING_ADDRESS_TYPE = "Permanent"
BILLING_ADDRESS_LINE1 = "ornate pg"
BILLING_ADDRESS_LINE2 = "Baghmugalia"
BILLING_ADDRESS_LINE3 = "Amar tech road"
BILLING_ADDRESS_LINE4 = "pune"
BILLING_ADDRESS_LINE5 = "Mr"
