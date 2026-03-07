"""Variables for Product Type module test cases (Workflow A + B)."""
import os
import sys
from datetime import datetime
_s = os.path.dirname(os.path.abspath(__file__))
if _s not in sys.path:
    sys.path.insert(0, _s)
from _shared_seed import get_value

_ts = datetime.now().strftime("%d%m%y%H%M%S")
PT_NAME = get_value("PT_NAME", lambda: f"Test SIM PT {_ts}")
PT_SERVICE_TYPE = "Postpaid"
PT_SUB_TYPE_2 = "physical"
PT_SUB_TYPE_3 = "SIM"
PT_SUB_TYPE_4 = "4FF"
PT_PROFILE_NAME = ""
PT_PACKAGING_SIZE = "100"
PT_COMMENT = "Automation test product type"
PT_DESC_EN = "Test product type created by automation"

PRODUCT_TYPE_URL = "https://192.168.1.26:7874/ProductType"
CREATE_PT_URL = "https://192.168.1.26:7874/CreateProductType"
