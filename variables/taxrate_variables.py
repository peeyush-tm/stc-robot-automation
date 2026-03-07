"""Tax rate test variables."""
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

TAX_IDENTIFIER = get_value("TAX_IDENTIFIER", lambda: f"TAX_{_rand_str(6)}")
TAX_RATE_VALUE = get_value("TAX_RATE_VALUE", lambda: str(round(random.uniform(1, 15), 2)))
