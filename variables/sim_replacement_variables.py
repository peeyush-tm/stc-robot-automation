"""SIM Replacement suite data (no ``config/*.json`` — configure here, env, or seed only).

**Standalone (no ``.run_seed.json``):** use the constants in *this* module. Resolution: env ``STC_*`` first, then
seed keys if the file exists, then file defaults — ``_DEFAULT_EC_UNSEEDED``, ``_STANDALONE_EC`` / ``_STANDALONE_BU``,
and ``_STANDALONE_MSISDN`` (often empty until the suite sets MSISDN from the grid).

**Account model (CMP):** billing units (**BU**) sit **under** an enterprise customer (**EC**). On Manage Devices /
Blank SIM, filtering by **EC** is enough to see devices (MSISDNs) for that EC **including** those under its BUs —
you do not have to set a BU for that. **Create SIM Order** (blank SIM replacement wizard) must use the **EC** in the
account tree; ``SIMR_EC_ACCOUNT_NAME`` is what the suite passes there.

**Set the EC** via ``STC_SIMR_EC_ACCOUNT_NAME``, seed ``e2e_usage_ec_name``, or
``STC_SIMR_DEFAULT_EC_NAME``. If all are empty, the module falls back to the same unseeded dev EC as Rule Engine /
Role Management (override with env or seed for your tenant).

**BU is optional:** ``SIMR_BU_ACCOUNT_NAME`` only if you want to **narrow** the grid to one BU under the EC, or Live
Order’s Account column needs a BU fallback.

- ``SIMR_MSISDN`` — env / seed; else read from Manage Devices after EC (± BU) filter.
- Stale seed values in ``.run_seed.json`` can break filters — update seed or override with env.
- ``SIMR_ONBOARD_UI_SETTLE_SECONDS`` — only for ``SR Onboard EC And Set Sim Replacement Suite Variables``.
- Optional ``STC_SIMR_STANDALONE_BLANK_ICCID`` / seed ``simr_blank_iccid``.
- ``STC_SIMR_FORCE_ACCOUNT_FILTER_MODAL=1`` — do not use toolbar Account search; always open the Filters modal (matches older runs visually / debugging).
- ``STC_SIMR_PROPAGATION_WAIT_MINUTES`` — wait after SIM Replacement submit (default ``5``).
"""

import os

from _config_defaults import config_scalar
from _shared_seed import env_default, read_value, resolved

_STANDALONE_MSISDN = "898988888888880"
_STANDALONE_BLANK_ICCID = ""
# Same default customer pair from config/<env>.json when seed + env are empty.
_DEFAULT_EC_UNSEEDED = config_scalar("DEFAULT_EC_ACCOUNT", "SANJ_1002")
# EC for order creation + EC-level Manage Devices/Blank SIM filter (shows devices under child BUs).
_STANDALONE_EC = env_default("STC_SIMR_DEFAULT_EC_NAME", _DEFAULT_EC_UNSEEDED)
# Optional BU to narrow grid to one billing unit under the EC; "" = EC-only filter.
_STANDALONE_BU = env_default("STC_SIMR_DEFAULT_BU_NAME",
                             config_scalar("DEFAULT_BU_ACCOUNT", "billingAccountSANJ_1003"))


def _strip(val):
    if val is None:
        return ""
    return str(val).strip()


def _simr_ec_resolve():
    v = _strip(os.environ.get("STC_SIMR_EC_ACCOUNT_NAME"))
    if v:
        return v
    s = _strip(read_value("e2e_usage_ec_name", ""))
    if s:
        return s
    return _STANDALONE_EC


def _simr_bu_resolve():
    v = _strip(os.environ.get("STC_SIMR_BU_ACCOUNT_NAME"))
    if v:
        return v
    s = _strip(read_value("e2e_usage_bu_name", ""))
    if s:
        return s
    return _STANDALONE_BU


SIMR_MSISDN = resolved("simr_msisdn", "STC_SIMR_MSISDN", _STANDALONE_MSISDN)
SIMR_STANDALONE_BLANK_ICCID = resolved(
    "simr_blank_iccid", "STC_SIMR_STANDALONE_BLANK_ICCID", _STANDALONE_BLANK_ICCID
)
SIMR_EC_ACCOUNT_NAME = _simr_ec_resolve()
SIMR_BU_ACCOUNT_NAME = _simr_bu_resolve()

SIMR_ONBOARD_UI_SETTLE_SECONDS = env_default("STC_SIMR_ONBOARD_UI_SETTLE_SECONDS", "120")
# After SIM Replacement submit, TC_SIMRPL_01 waits this many minutes (env override for faster runs / less idle RAM growth).
SIMR_PROPAGATION_WAIT_MINUTES = env_default("STC_SIMR_PROPAGATION_WAIT_MINUTES", "5")


def _env_truthy(name: str) -> bool:
    return _strip(os.environ.get(name, "")).lower() in ("1", "true", "yes")


# ``STC_SIMR_FORCE_ACCOUNT_FILTER_MODAL=1`` — skip Manage Devices toolbar search; always open Filters popup (old behavior).
SIMR_FORCE_ACCOUNT_FILTER_MODAL = _env_truthy("STC_SIMR_FORCE_ACCOUNT_FILTER_MODAL")

# Populated during suite (TC_SIMRPL_01 / keywords).
# Each also accepts an env / seed override so TC_SIMRPL_03 can run standalone
# (without TC_SIMRPL_01 in the same session).
#
#   seed key              env var                  description
#   ──────────────────    ─────────────────────    ──────────────────────────────────────────
#   simr_old_iccid        STC_SIMR_OLD_ICCID       ICCID on device before replacement
#   simr_old_imsi         STC_SIMR_OLD_IMSI        IMSI on device before replacement
#   simr_new_iccid        STC_SIMR_NEW_ICCID       ICCID of blank SIM assigned at replacement
#   simr_new_imsi         STC_SIMR_NEW_IMSI        IMSI of blank SIM assigned at replacement
#   simr_order_id         STC_SIMR_ORDER_ID        SIM order ID created in TC_SIMRPL_01
SIMR_OLD_ICCID = resolved("simr_old_iccid", "STC_SIMR_OLD_ICCID", "11111144444444494508")
SIMR_OLD_IMSI = resolved("simr_old_imsi", "STC_SIMR_OLD_IMSI", "224444444494508")
SIMR_NEW_ICCID = resolved("simr_new_iccid", "STC_SIMR_NEW_ICCID", "11111110000960958001")
SIMR_NEW_IMSI = resolved("simr_new_imsi", "STC_SIMR_NEW_IMSI", "221000960958001")
# Blank SIM ICCID == new ICCID — the blank SIM created by the order IS the ICCID
# assigned to the device after replacement.  Always keep them in sync.
SIMR_CREATED_BLANK_ICCID = SIMR_NEW_ICCID
SIMR_SIM_ORDER_ID = resolved("simr_order_id", "STC_SIMR_ORDER_ID", "")
