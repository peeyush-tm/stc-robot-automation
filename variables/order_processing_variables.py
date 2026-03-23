# Placeholder in OrderId field that gets replaced with actual orderId at runtime
TEMPLATE_ORDER_ID = "REPLACE_ORDER_ID"

# ── URLs (ORDER_HISTORY_URL from config per ENV) ──────────────────────
ORDER_HISTORY_PATH = "/OrderHistory"

# ── DB Query Template ─────────────────────────────────────────────────
ACCOUNT_ID_QUERY = "SELECT id FROM accounts WHERE name = '{}'"

# ── Expected Order Statuses ──────────────────────────────────────────
STATUS_NEW = "New"
STATUS_IN_PROGRESS = "In Progress"
STATUS_COMPLETED = "Completed"

# ── Response File Extensions ─────────────────────────────────────────
RESPONSE_FILE_EXTENSIONS = ["dsprsp", "ordrsp", "pcsrsp"]

# ── Template File Contents ───────────────────────────────────────────
# Source: 120326_076.dsprsp — replace "120326" with actual orderId
TEMPLATE_DSPRSP = """\
[OOF]
NoId = "GCT"
OofFileType = "DspRsp"
OrdReqInfo = "a"
OrderDate = "230226"
OrderId = "REPLACE_ORDER_ID"
OrderCustomerId = "120326_096"
OrderBatchCount = 1
ServiceType = "POSTPAID"
ServiceSubType.1 = "GCT"
ServiceSubType.2 = "BUSINESS M2M NP"
ServiceSubType.3 = "NORMAL"
ServiceSubType.4 = "EBU VIRTUAL TEST"
AlgorithmType = "3G Milenage"
[OOF.1]
OrderBatchCardCount = 1
[OOF.1.1]
GsmIccid = 899660110010024513
GsmImsi = 420011010024513
GsmEncCHV1 = 0000
GsmEncCHV2 = 6366
GsmEncUCHV1 = 07229045
GsmEncUCHV2 = 70451703
[OOF.END]"""

# Source: 120326_076.ordrsp — replace "120326" with actual orderId
TEMPLATE_ORDRSP = """\
[OOF]
OofFileType = "OrdRsp"
OrdReqInfo = "a"
NoId = "GCT"
OrderDate = "230226"
OrderId = "REPLACE_ORDER_ID"
OrderCustomerId = "120326_096"
OrderBatchCount = 1
ServiceType = "POSTPAID"
ServiceSubType.1 = "GCT"
ServiceSubType.2 = "BUSINESS M2M NP"
AlgorithmType = "3G Milenage"
[OOF.1]
OrderBatchCardCount = 1
[OOF.1.1]
GsmImsi = "420011010024513"
GsmIccid = "899660110010024513"
[OOF.END]"""

# Source: 120326_076.pcsrsp — replace "120326" with actual orderId
TEMPLATE_PCSRSP = """\
[OOF]
OofFileType = "OrdRsp"
OrdReqInfo = "a"
NoId = "GCT"
OrderDate = "230226"
OrderId = "REPLACE_ORDER_ID"
OrderCustomerId = "120326_076"
OrderBatchCount = 1
ServiceType = "POSTPAID"
ServiceSubType.1 = "GCT"
ServiceSubType.2 = "BUSINESS M2M NP"
AlgorithmType = "3G Milenage"
[OOF.1]
OrderBatchCardCount = 1
[OOF.1.1]
GsmImsi = "420011010024513"
GsmIccid = "899660110010024513"
[OOF.END]"""

# Map extension to template content for easy iteration
TEMPLATE_MAP = {
    "dsprsp": TEMPLATE_DSPRSP,
    "ordrsp": TEMPLATE_ORDRSP,
    "pcsrsp": TEMPLATE_PCSRSP,
}

# ── SOAP: Update Order Status ─────────────────────────────────────────
UPDATE_ORDER_STATUS_BODY = """\
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sim="http://simorder.fingerprint.webservice.stc.comarch.com/">
<soapenv:Header/>
<soapenv:Body>
<sim:updateOrderStatus>
<orderID>REPLACE_ORDER_ID</orderID>
<status>Approved</status>
</sim:updateOrderStatus>
</soapenv:Body>
</soapenv:Envelope>"""

# ── Manage Devices (MANAGE_DEVICES_URL_E2E from config per ENV) ────────
EXPECTED_WARM_STATE = "Warm"
EXPECTED_INACTIVE_STATE = "InActive"
EXPECTED_ACTIVATED_STATE = "Activated"
SIM_ACTIVATE_COUNT = 5

# ── Billing / Invoice ────────────────────────────────────────────────
BILLING_LOCAL_DIR = "billing"
