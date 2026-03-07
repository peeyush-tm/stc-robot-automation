"""Database configuration for CAPTCHA fetch (CMP login)."""

DB_HOST = "192.168.1.122"
DB_PORT = 3306
DB_NAME = "stc_s5_p1"
DB_USER = "java_dev"
DB_PASS = "Java@123"


def get_variables():
    return {
        "DB_HOST": DB_HOST,
        "DB_PORT": DB_PORT,
        "DB_NAME": DB_NAME,
        "DB_USER": DB_USER,
        "DB_PASS": DB_PASS,
    }
