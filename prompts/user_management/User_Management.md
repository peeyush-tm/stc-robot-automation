# User Management Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `User_Management` |
| **Suite File** | `tests/user_management_tests.robot` |
| **Variables File** | `variables/user_management_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageUser` (list), `<BASE_URL>/CreateUser` (create form) |
| **Total TCs** | 45 |
| **Tags** | `user-management`, `navigation`, `grid`, `pagination`, `columns`, `create-form`, `otp`, `search`, `delete`, `boundary`, `validation`, `duplicate`, `whitespace`, `special-chars`, `smoke`, `regression`, `edge-case` |

## Run Commands

```bash
python run_tests.py --suite User_Management
python run_tests.py tests/user_management_tests.robot
python run_tests.py --suite User_Management --include smoke
python run_tests.py --suite User_Management --include user-management
python run_tests.py --suite User_Management --include otp
python run_tests.py --suite User_Management --include delete
python run_tests.py --suite User_Management --test "TC_USER_009*"
```

## Module Description

The **User Management** module allows administrators to create, search, and delete portal users. Each user is configured with Account, Username, First/Last Name, Primary Phone, Email, Country, Time Zone, Role, and OTP Channel (SMS, Email, or Both). Created users appear in a paginated grid.

**Navigation:** Login → Admin sidebar → User Management → `/ManageUser`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_USER_001 | Navigate To Manage User Page Via Admin Sidebar | Positive | navigation, smoke |
| TC_USER_002 | Verify Manage User Grid Loads With Data | Positive | grid |
| TC_USER_003 | Verify Manage User Grid Columns | Positive | grid, columns |
| TC_USER_004 | Verify Manage User Grid Has Pagination | Positive | grid, pagination |
| TC_USER_005 | Verify Create User Button Is Visible | Positive | button |
| TC_USER_006 | Open Create User Form | Positive | create-form |
| TC_USER_007 | Verify All Create User Form Fields Present | Positive | create-form, fields |
| TC_USER_008 | Verify Submit And Close Buttons Present | Positive | create-form, buttons |
| TC_USER_009 | Create User With All Required Fields | Positive | create, e2e, smoke |
| TC_USER_010 | Create User With Email OTP Channel | Positive | create, otp |
| TC_USER_011 | Create User With Both SMS And Email OTP Channels | Positive | create, otp |
| TC_USER_012 | Search User In Grid By Username | Positive | search |
| TC_USER_013 | Delete User And Verify Removal | Positive | delete, e2e, smoke |
| TC_USER_014 | Close Create User Form Without Saving | Positive | close, form |
| TC_USER_015 | Close Form After Filling Fields Should Not Create User | Positive | close, form |
| TC_USER_016 | Submit Without Filling Any Field | Negative | validation, empty |
| TC_USER_017 | Submit Without Selecting Account | Negative | validation, account |
| TC_USER_018 | Submit Without Username | Negative | validation, username |
| TC_USER_019 | Submit Without First Name | Negative | validation, first-name |
| TC_USER_020 | Submit Without Last Name | Negative | validation, last-name |
| TC_USER_021 | Submit Without Primary Phone | Negative | validation, phone |
| TC_USER_022 | Submit Without Email Address | Negative | validation, email |
| TC_USER_023 | Submit Without Confirm Email Address | Negative | validation, confirm-email |
| TC_USER_024 | Submit Without Selecting Role | Negative | validation, role |
| TC_USER_025 | Submit Without Selecting Country | Negative | validation, country |
| TC_USER_026 | Submit Without Selecting Time Zone | Negative | validation, timezone |
| TC_USER_027 | Submit Without Selecting Any OTP Channel | Negative | validation, otp |
| TC_USER_028 | Username Less Than 5 Characters | Negative | validation, username, boundary |
| TC_USER_029 | Username More Than 50 Characters | Negative | validation, username, boundary |
| TC_USER_030 | Phone Less Than 5 Digits | Negative | validation, phone, boundary |
| TC_USER_031 | Phone More Than 16 Digits | Negative | validation, phone, boundary |
| TC_USER_032 | Phone With Non Numeric Characters | Negative | validation, phone |
| TC_USER_033 | Invalid Email Format | Negative | validation, email |
| TC_USER_034 | Mismatched Confirm Email | Negative | validation, confirm-email |
| TC_USER_035 | Duplicate Username Should Show Error | Negative | validation, duplicate |
| TC_USER_036 | Cancel Delete Confirmation Should Keep User | Negative | delete, cancel |
| TC_USER_037 | Username Exactly 5 Characters | Edge Case | boundary, username |
| TC_USER_038 | Username Exactly 50 Characters | Edge Case | boundary, username |
| TC_USER_039 | Phone Exactly 5 Digits | Edge Case | boundary, phone |
| TC_USER_040 | Phone Exactly 16 Digits | Edge Case | boundary, phone |
| TC_USER_041 | Whitespace Only Username | Edge Case | validation, username |
| TC_USER_042 | Whitespace Only First Name | Edge Case | validation, first-name |
| TC_USER_043 | Whitespace Only Last Name | Edge Case | validation, last-name |
| TC_USER_044 | Special Characters In Username | Edge Case | validation, username, special-chars |
| TC_USER_045 | Verify Delete Confirmation Dialog Elements | Edge Case | delete, dialog |

## Test Case Categories

### Positive — Landing Page & Navigation (4 TCs)
- **TC_USER_001** — Navigate to `/ManageUser`; page loads.
- **TC_USER_002** — Grid loads with user data.
- **TC_USER_003** — Grid shows expected columns (Username, Name, Email, Role, Account, etc.).
- **TC_USER_004** — Grid has pagination controls.
- **TC_USER_005** — Create User button is visible.

### Positive — Create Form UI Verification (3 TCs)
- **TC_USER_006** — Clicking Create User opens the create form.
- **TC_USER_007** — All form fields present (Account, Username, First Name, Last Name, Phone, Email, Confirm Email, Role, Country, Time Zone, OTP Channel).
- **TC_USER_008** — Submit and Close buttons are present on the form.

### Positive — Create User Happy Path (3 TCs)
- **TC_USER_009** — Create user with all required fields + SMS OTP. Verifies user appears in grid.
- **TC_USER_010** — Create user with Email OTP channel.
- **TC_USER_011** — Create user with both SMS and Email OTP channels.

### Positive — Search, Delete & Close (4 TCs)
- **TC_USER_012** — Search by Username in grid; matching row shown.
- **TC_USER_013** — Delete user: click delete icon, confirm, user removed from grid.
- **TC_USER_014** — Close form immediately → no user created.
- **TC_USER_015** — Fill form then close → no user created.

### Negative — All Mandatory Fields (12 TCs)
- **TC_USER_016** — Submit empty form → all required field errors.
- **TC_USER_017–027** — Each test omits one mandatory field and verifies its specific validation message:
  - Account, Username, First Name, Last Name, Primary Phone, Email, Confirm Email, Role, Country, Time Zone, OTP Channel.

### Negative — Format & Boundary Validation (8 TCs)
- **TC_USER_028** — Username < 5 chars → error.
- **TC_USER_029** — Username > 50 chars → error.
- **TC_USER_030** — Phone < 5 digits → error.
- **TC_USER_031** — Phone > 16 digits → error.
- **TC_USER_032** — Phone with non-numeric characters → error.
- **TC_USER_033** — Invalid email format → error.
- **TC_USER_034** — Confirm Email ≠ Email → mismatch error.
- **TC_USER_035** — Duplicate Username → conflict error.

### Negative — Delete (1 TC)
- **TC_USER_036** — Cancel delete confirmation → user remains in grid.

### Edge Cases (9 TCs)
- **TC_USER_037** — Username exactly 5 characters → accepted.
- **TC_USER_038** — Username exactly 50 characters → accepted.
- **TC_USER_039** — Phone exactly 5 digits → accepted.
- **TC_USER_040** — Phone exactly 16 digits → accepted.
- **TC_USER_041** — Whitespace-only Username → treated as empty, error.
- **TC_USER_042** — Whitespace-only First Name → error.
- **TC_USER_043** — Whitespace-only Last Name → error.
- **TC_USER_044** — Special characters in Username → validates behavior.
- **TC_USER_045** — Delete confirmation dialog shows correct text and buttons.

## Form Fields Reference

| Field | Mandatory | Notes |
|-------|-----------|-------|
| Account | ✅ | Dropdown |
| Username | ✅ | 5–50 chars, alphanumeric |
| First Name | ✅ | Text |
| Last Name | ✅ | Text |
| Primary Phone | ✅ | 5–16 digits |
| Email Address | ✅ | Valid email format |
| Confirm Email | ✅ | Must match Email |
| Role | ✅ | Dropdown (from Role Management) |
| Country | ✅ | Dropdown |
| Time Zone | ✅ | Dropdown |
| OTP Channel | ✅ | Checkbox (SMS and/or Email) |
| Description | ❌ | Optional, text |

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/user_management_tests.robot` | Test suite |
| `resources/keywords/user_management_keywords.resource` | User CRUD keywords |
| `resources/locators/user_management_locators.resource` | XPath locators (grid + form) |
| `variables/user_management_variables.py` | Usernames (random), names, phone numbers, emails |

## Automation Notes

- Usernames are randomly generated per run (timestamp suffix) to avoid duplicate conflicts.
- Email and Confirm Email fields must match exactly; keywords enter both from the same variable.
- OTP Channel uses checkboxes (not radio buttons); both SMS and Email can be selected simultaneously.
- Country and Time Zone dropdowns are Kendo dropdowns; keywords wait for options before selecting.
- Delete confirmation is a Kendo Dialog; keyword waits for it and clicks the appropriate action button.
- Boundary strings (5-char, 50-char, 5-digit, 16-digit) are pre-built in the variables file.
