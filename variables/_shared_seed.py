"""Shared random seed: cache generated values in .run_seed.json for cross-suite consistency."""
import json
import os

SEED_FILE = os.path.join(os.path.dirname(__file__), ".run_seed.json")


def _load_seed():
    if os.path.exists(SEED_FILE):
        with open(SEED_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def _save_seed(data):
    with open(SEED_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)


def get_value(key, generator_fn):
    data = _load_seed()
    if key in data:
        return data[key]
    value = generator_fn()
    data[key] = value
    _save_seed(data)
    return value
