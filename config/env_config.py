"""UI environment configuration (dev/staging/prod)."""

ENVIRONMENTS = {
    "dev": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "TARGET_URL": "https://192.168.1.26:7874/ManageDevices",
        "PRODUCT_TYPE_URL": "https://192.168.1.26:7874/ProductType",
        "CREATE_PT_URL": "https://192.168.1.26:7874/CreateProductType",
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "PAGE_RELOAD_WAIT": "15",
        "POST_CREDENTIALS_WAIT": "10",
    },
    "staging": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "TARGET_URL": "https://192.168.1.26:7874/ManageDevices",
        "PRODUCT_TYPE_URL": "https://192.168.1.26:7874/ProductType",
        "CREATE_PT_URL": "https://192.168.1.26:7874/CreateProductType",
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "PAGE_RELOAD_WAIT": "15",
        "POST_CREDENTIALS_WAIT": "10",
    },
    "prod": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "LOGIN_URL": "https://192.168.1.26:7874/",
        "TARGET_URL": "https://192.168.1.26:7874/ManageDevices",
        "PRODUCT_TYPE_URL": "https://192.168.1.26:7874/ProductType",
        "CREATE_PT_URL": "https://192.168.1.26:7874/CreateProductType",
        "VALID_USERNAME": "",
        "VALID_PASSWORD": "",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "PAGE_RELOAD_WAIT": "15",
        "POST_CREDENTIALS_WAIT": "10",
    },
}


def get_variables(ENV="dev"):
    env = ENVIRONMENTS.get(ENV, ENVIRONMENTS["dev"])
    return env
