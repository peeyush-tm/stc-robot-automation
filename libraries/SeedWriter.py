"""
SeedWriter — Robot Framework library for persisting runtime values to .run_seed.json.

Usage in .resource / .robot files:
    Library    ../../libraries/SeedWriter.py

    Write Seed Value    ec_name    ${E2E_EC_NAME}
    Write Seed Value    first_activated_iccid    ${iccid}
"""

import json
import os

_SEED_FILE = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "variables", ".run_seed.json")
)


def write_seed_value(key, value):
    """Write (or overwrite) *key* → *value* in the shared .run_seed.json file.

    Creates the file if it does not exist.  Safe to call from multiple Robot
    suites within the same ``run_tests.py`` session.
    """
    if os.path.exists(_SEED_FILE):
        with open(_SEED_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    else:
        data = {}
    data[key] = value
    with open(_SEED_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
