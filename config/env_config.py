ENVIRONMENTS = {
    "dev": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",
    },
    "staging": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",
    },
    "prod": {
        "BASE_URL": "https://192.168.1.26:7874/",
        "VALID_USERNAME": "ksa_opco",
        "VALID_PASSWORD": "Admin@123",
        "BROWSER": "chrome",
        "IMPLICIT_WAIT": "10",
        "PAGE_LOAD_TIMEOUT": "30",
        "DB_HOST": "192.168.1.122",
        "DB_PORT": "3306",
        "DB_NAME": "stc_s5_p1",
        "DB_USER": "java_dev",
        "DB_PASS": "Java@123",
        "CAPTCHA_QUERY": "SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1",
    },
}


def get_variables(ENV="dev"):
    env = ENVIRONMENTS.get(ENV, ENVIRONMENTS["dev"])
    return env
