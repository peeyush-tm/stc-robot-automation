# Login Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Login` |
| **Suite File** | `tests/login_tests.robot` |
| **Variables File** | `variables/login_variables.py` |
| **Type** | UI |
| **URL** | `<BASE_URL>/` (login page) → `<BASE_URL>/ManageDevices` (post-login) |
| **Total TCs** | 12 |
| **Tags** | `login`, `captcha`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite Login
python run_tests.py tests/login_tests.robot
python run_tests.py --suite Login --env staging
python run_tests.py --suite Login --browser headlesschrome
python run_tests.py --suite Login --include smoke
python run_tests.py --suite Login --test "TC_LOGIN_001*"
```

## Authentication Flow

The CMP login form requires **Username + Password + CAPTCHA**. The CAPTCHA value is fetched directly from MySQL during test execution. To avoid React re-render clearing credential fields, captcha is handled **before** entering username and password.

```
1. Open BASE_URL
2. Wait for captcha image src to become base64 data URI (confirms getCaptcha() API + setState complete)
3. Fetch captcha from DB: SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1
4. Enter captcha first (React state is stable after this)
5. Enter username
6. Enter password
7. Click Login
8. Wait for div#gridData (Manage Devices grid) to confirm success
```

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_LOGIN_001 | Valid Credentials Should Login Successfully | Positive | smoke, regression |
| TC_LOGIN_002 | Logout Should Redirect To Login Page | Positive | smoke, regression |
| TC_LOGIN_005 | Invalid Username Should Show Error | Negative | regression |
| TC_LOGIN_006 | Invalid Password Should Show Error | Negative | regression |
| TC_LOGIN_007 | Both Invalid Username And Password Should Show Error | Negative | regression |
| TC_LOGIN_008 | Empty Username Field Should Show Error | Negative | regression |
| TC_LOGIN_009 | Empty Password Field Should Show Error | Negative | regression |
| TC_LOGIN_010 | All Fields Empty Should Show Error | Negative | regression |
| TC_LOGIN_011 | Empty Captcha Should Show Error | Negative | regression, captcha |
| TC_LOGIN_012 | Incorrect Captcha Should Show Error | Negative | regression, captcha |
| TC_LOGIN_015 | Whitespace Only Username Should Show Error | Negative | regression |
| TC_LOGIN_016 | Direct Access To ManageDevices Without Login Should Redirect | Negative | regression, security, navigation |

## Test Case Categories

### Positive (2 TCs)
- **TC_LOGIN_001** — Full login flow with valid credentials; verifies redirect to Manage Devices and grid loads.
- **TC_LOGIN_002** — Logout flow; clicks logout button, verifies redirect back to login page.

### Negative — Invalid Credentials (8 TCs)
- **TC_LOGIN_005–007** — Various invalid username/password combinations; verifies error toast or inline message.
- **TC_LOGIN_008–010** — Empty field submissions; verifies required-field validation messages.
- **TC_LOGIN_011** — Submit with empty captcha field; expects captcha required error.
- **TC_LOGIN_012** — Submit with wrong captcha value; expects captcha mismatch error.

### Negative — Security (2 TCs)
- **TC_LOGIN_015** — Whitespace-only username; expects validation error (not treated as valid).
- **TC_LOGIN_016** — Directly navigate to `/ManageDevices` without logging in; must redirect to login page.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/login_tests.robot` | Test suite |
| `resources/keywords/login_keywords.resource` | Login, logout, captcha keywords |
| `resources/locators/login_locators.resource` | XPath locators for login form and Manage Devices |
| `variables/login_variables.py` | Test data: valid/invalid credentials, error messages |
| `config/<env>.json` | `VALID_USERNAME`, `VALID_PASSWORD`, `DB_*`, `CAPTCHA_QUERY` |

## Automation Notes

- **React re-render guard:** Captcha is entered **before** username/password. The `getCaptcha()` API triggers a `setState` that re-renders the form; entering credentials afterwards prevents them being cleared.
- **Captcha image check:** `Captcha Image Loaded` keyword polls the `<img id="image">` `src` attribute until it contains `data:image`, confirming the API call and React state update are complete.
- **CAPTCHA not available:** If the captcha DB table is empty (backend 500 error), the captcha step is skipped automatically via visibility check.
- **SSL bypass:** Chrome is opened with `--ignore-certificate-errors` for self-signed certs.
