"""
Environment configuration for the STC GControl IoT test automation suite.

Supports multiple environments via the ``env`` argument.
Robot Framework usage:
    Variables   ../config/env_config.py              # uses default (dev)
    Variables   ../config/env_config.py    ${ENV}     # uses value of ${ENV}

Command-line override:
    robot --variable ENV:staging tests/
"""

_ENVIRONMENTS = {
    "dev": {
        # ── Application URLs ─────────────────────────────────────────
        "BASE_URL": "https://192.168.1.26:7874",
        "LOGIN_URL": "https://192.168.1.26:7874",

        # ── Login Credentials ────────────────────────────────────────
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        # ── Browser Settings ─────────────────────────────────────────
        "BROWSER": "chrome",
        "HEADLESS": False,

        # ── Timeouts ─────────────────────────────────────────────────
        "DEFAULT_TIMEOUT": "30s",
        "PAGE_LOAD_TIMEOUT": "60s",
        "IMPLICIT_WAIT": "0s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        # ── API Configuration ────────────────────────────────────────
        "ONBOARD_API_BASE_URL": "https://10.121.77.94:8443",
        "API_VERIFY_SSL": False,

        # ── Account Hierarchy (TreeView selections) ──────────────────
        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },

    "staging": {
        "BASE_URL": "https://staging.gcontrol-iot.example.com",
        "LOGIN_URL": "https://staging.gcontrol-iot.example.com",

        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        "BROWSER": "chrome",
        "HEADLESS": False,

        "DEFAULT_TIMEOUT": "30s",
        "PAGE_LOAD_TIMEOUT": "60s",
        "IMPLICIT_WAIT": "0s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        "ONBOARD_API_BASE_URL": "https://staging-api.gcontrol-iot.example.com",
        "API_VERIFY_SSL": False,

        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },

    "prod": {
        "BASE_URL": "https://gcontrol-iot.example.com",
        "LOGIN_URL": "https://gcontrol-iot.example.com",

        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        "BROWSER": "chrome",
        "HEADLESS": True,

        "DEFAULT_TIMEOUT": "30s",
        "PAGE_LOAD_TIMEOUT": "60s",
        "IMPLICIT_WAIT": "0s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        "ONBOARD_API_BASE_URL": "https://api.gcontrol-iot.example.com",
        "API_VERIFY_SSL": True,

        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },
}

# Default environment when none is specified
_DEFAULT_ENV = "dev"


def get_variables(env=None):
    """Return environment-specific variables as a dictionary.

    Called by Robot Framework when the variable file is imported.
    - ``Variables  ../config/env_config.py``         → env defaults to "dev"
    - ``Variables  ../config/env_config.py  staging`` → env = "staging"
    - ``robot --variable ENV:staging tests/``         → env = "staging"
    """
    if env is None:
        env = _DEFAULT_ENV

    env = str(env).strip().lower()

    if env not in _ENVIRONMENTS:
        raise ValueError(
            f"Unknown environment '{env}'. "
            f"Valid options: {', '.join(_ENVIRONMENTS.keys())}"
        )

    config = dict(_ENVIRONMENTS[env])
    config["ENV"] = env

    return config
