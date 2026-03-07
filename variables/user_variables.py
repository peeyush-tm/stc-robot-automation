"""User test variables."""
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

TEST_USERNAME = get_value("TEST_USERNAME", lambda: f"user_{_rand_str(6)}")
TEST_EMAIL = get_value("TEST_EMAIL", lambda: f"user_{_rand_str(6)}@test.com")
TEST_PASSWORD = get_value("TEST_PASSWORD", lambda: f"Pass_{_rand_str(8)}!")
EDIT_FIRSTNAME = get_value("EDIT_FIRSTNAME", lambda: f"Edit_{_rand_str(4)}")
EDIT_EMAIL = get_value("EDIT_EMAIL", lambda: f"edit_{_rand_str(6)}@test.com")
