"""Read scalar defaults from config/<env>.json for Python variable modules.

``STC_AUTOMATION_ENV`` selects the file (e.g. ``dev``, ``qe``). It is set by
``run_tests.py`` before spawning Robot and by ``Load Environment Config From Json``
at suite setup. If unset, ``dev`` is used (e.g. static analysis or ``robot`` without
the runner — set ``STC_AUTOMATION_ENV`` to match ``-v ENV:`` when running Robot
directly).
"""

import json
import os

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def active_env() -> str:
    v = (
        os.environ.get("STC_AUTOMATION_ENV")
        or os.environ.get("STC_CONFIG_ENV")
        or "dev"
    )
    s = str(v).strip().lower()
    return s if s else "dev"


def config_scalar(key: str, default: str = "") -> str:
    path = os.path.join(_ROOT, "config", f"{active_env()}.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        if "PAYG_CSR_MODAL_APN_NAME" in data and not str(
            data.get("DEFAULT_CSR_MODAL_APN_NAME") or ""
        ).strip():
            data = dict(data)
            data["DEFAULT_CSR_MODAL_APN_NAME"] = data["PAYG_CSR_MODAL_APN_NAME"]
        v = data.get(key)
        if v is None:
            return default
        s = str(v).strip()
        return s if s else default
    except (OSError, json.JSONDecodeError, TypeError):
        return default
