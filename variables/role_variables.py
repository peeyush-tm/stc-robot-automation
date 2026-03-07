"""Role test variables."""
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

ROLE_NAME = get_value("ROLE_NAME", lambda: f"Role_{_rand_str(6)}")
EDIT_ROLE_NAME = get_value("EDIT_ROLE_NAME", lambda: f"Role_Edit_{_rand_str(6)}")
DELETE_ROLE_NAME = get_value("DELETE_ROLE_NAME", lambda: f"Role_Del_{_rand_str(6)}")
SPECIAL_CHARS_ROLE_NAME = get_value("SPECIAL_CHARS_ROLE_NAME", lambda: "Role<>\"&")
LONG_ROLE_NAME = get_value("LONG_ROLE_NAME", lambda: "A" * 256)
