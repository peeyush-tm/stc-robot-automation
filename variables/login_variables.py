"""Login test variables (invalid inputs, etc.)."""
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

INVALID_USERNAME = get_value("INVALID_USERNAME", lambda: f"invalid_{_rand_str(6)}")
INVALID_PASSWORD = get_value("INVALID_PASSWORD", lambda: f"Wrong_{_rand_str(6)}")
SQL_INJECTION_INPUT = get_value("SQL_INJECTION_INPUT", lambda: "admin' OR '1'='1")
SPECIAL_CHARS_INPUT = get_value("SPECIAL_CHARS_INPUT", lambda: "user<>\"&@")
WHITESPACE_INPUT = get_value("WHITESPACE_INPUT", lambda: "   ")
