"""Terms and Conditions test variables."""
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

TC_NAME = get_value("TC_NAME", lambda: f"TC_{_rand_str(6)}")
TC_TEXT = get_value("TC_TEXT", lambda: f"Terms content {_rand_str(12)}")
