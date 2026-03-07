"""Plan test variables."""
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

PLAN_NAME_DEFAULT = get_value("PLAN_NAME_DEFAULT", lambda: f"Plan_{_rand_str(6)}")
PLAN_NUM_PAYMENTS = get_value("PLAN_NUM_PAYMENTS", lambda: str(random.randint(1, 24)))
EDIT_PLAN_NAME = get_value("EDIT_PLAN_NAME", lambda: f"Plan_Edit_{_rand_str(6)}")
