"""Zone test variables."""
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

ZONE_NAME = get_value("ZONE_NAME", lambda: f"Zone_{_rand_str(6)}")
ZONE_CODE = get_value("ZONE_CODE", lambda: f"Z{_rand_str(6)}")
