"""Product test variables."""
import os
import random
import string
import sys
_s = os.path.dirname(os.path.abspath(__file__))
if _s not in sys.path:
    sys.path.insert(0, _s)
from _shared_seed import get_value

def _rand_str(n=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=n))

PRODUCT_NAME = get_value("PRODUCT_NAME", lambda: f"Product_{_rand_str(6)}")
PRODUCT_SKU = get_value("PRODUCT_SKU", lambda: f"SKU-{_rand_str(8)}")
PRODUCT_PRICE = get_value("PRODUCT_PRICE", lambda: str(round(random.uniform(10, 100), 2)))
EXTERNAL_PACKAGE_ID = get_value("EXTERNAL_PACKAGE_ID", lambda: f"EXT-{_rand_str(6)}")
