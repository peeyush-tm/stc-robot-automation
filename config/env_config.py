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
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "MANAGE_DEVICES_URL": "https://192.168.1.26:7874/ManageDevices",

        # ── Login Credentials ────────────────────────────────────────
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        # ── Browser Settings ─────────────────────────────────────────
        "BROWSER": "chrome",
        "HEADLESS": False,
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",

        # ── Timeouts ─────────────────────────────────────────────────
        "DEFAULT_TIMEOUT": "30s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        # ── Captcha Database ─────────────────────────────────────────
        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",

        # ── API Configuration ────────────────────────────────────────
        "ONBOARD_API_BASE_URL": "https://10.121.77.94:8443",
        "API_VERIFY_SSL": False,

        # ── Account Hierarchy (TreeView selections) ──────────────────
        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },

    "staging": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "MANAGE_DEVICES_URL": "https://192.168.1.26:7874/ManageDevices",

        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        "BROWSER": "chrome",
        "HEADLESS": False,
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",

        "DEFAULT_TIMEOUT": "30s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",

        "ONBOARD_API_BASE_URL": "https://10.121.77.94:8443",
        "API_VERIFY_SSL": False,

        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },

    "prod": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "MANAGE_DEVICES_URL": "https://192.168.1.26:7874/ManageDevices",

        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",

        "BROWSER": "chrome",
        "HEADLESS": True,
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",

        "DEFAULT_TIMEOUT": "30s",
        "RETRY_COUNT": "3x",
        "RETRY_INTERVAL": "5s",

        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",

        "ONBOARD_API_BASE_URL": "https://10.121.77.94:8443",
        "API_VERIFY_SSL": True,

        "ROOT_ACCOUNT_NAME": "KSA_OPCO",
        "EC_ACCOUNT_NAME": "SANJ_1002",
        "BU_ACCOUNT_NAME": "billingAccountSANJ_1003",
    },
}

_DEFAULT_ENV = "dev"


def get_variables(ENV="dev"):
    env = _ENVIRONMENTS.get(ENV, _ENVIRONMENTS["dev"])
    return env
