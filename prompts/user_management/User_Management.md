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

---

## HTML Locators Reference

Use these locators directly in test automation or to generate new test cases for any framework.

### Navigation

| Element | HTML Attribute / XPath | Notes |
|---------|------------------------|-------|
| Admin sidebar icon | `xpath=//i[contains(@class,'admin-menu-icon')]` | Shared across admin modules |
| User sub-tab | `xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageUser')]` | Top nav tab to `/ManageUser` |

### Manage User Grid (List Page — `/ManageUser`)

| Element | HTML Attribute / XPath | Notes |
|---------|------------------------|-------|
| Page heading | `xpath=//*[contains(text(),'Users')]` | Page title verification |
| Grid container | `xpath=//div[contains(@class,'k-grid')]` | Kendo UI data grid |
| Pagination bar | `xpath=//*[contains(@class,'k-pager-wrap')]` | Kendo pager controls |
| Search input | `xpath=//input[@placeholder='Enter Search Text']` | Filters users in grid |
| Create User button | `xpath=//a[@href='/CreateUser']` | Navigates to `/CreateUser` |
| Grid row cell | `xpath=//td[contains(text(),'USERNAME')]` | Replace `USERNAME` to locate user row |
| Delete icon (row) | `xpath=//tr[.//td[contains(.,'USERNAME')]]//*[contains(@class,'k-grid-Delete')]` | Replace `USERNAME`; falls back to `@title='Delete User'` or `.fa-trash` |

### Create User Form (`/CreateUser`)

| Element | HTML Name / XPath | Type | Notes |
|---------|-------------------|------|-------|
| Account dropdown trigger | `xpath=//input[@name='parentAccount']` | TreeView input | Also `//div[contains(@class,'account-tree-dropdown')]` |
| Account tree container | `xpath=//div[contains(@id,'showTreeView')]` | Div | Appears after clicking account input |
| Account tree root expand | `xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-i-expand')])[1]` | Span | Expands root node |
| Account root node | `xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-in')])[1]` | Span | Click to select root account |
| Account tree search | `xpath=//div[contains(@id,'showTreeView')]//input[contains(@class,'search-textbox')]` | Input | Filter accounts inside tree |
| Username | `name="userName"` → `xpath=//input[@name='userName']` | Text input | 5–50 chars |
| First Name | `name="firstName"` → `xpath=//input[@name='firstName']` | Text input | Required |
| Last Name | `name="lastName"` → `xpath=//input[@name='lastName']` | Text input | Required |
| Primary Phone | `name="telephoneNumber"` → `xpath=//input[@name='telephoneNumber']` | Text input | 5–16 digits, numeric only |
| Email Address | `name="emailId"` → `xpath=//input[@name='emailId']` | Email input | Valid email format required |
| Confirm Email | `name="confirmEmailId"` → `xpath=//input[@name='confirmEmailId']` | Email input | Must match Email Address |
| User Category | `name="userAccountType"` → `xpath=//select[@name='userAccountType']` | Native select | Optional category dropdown |
| Role dropdown | `xpath=//div[@data-testid='roleSelectedValueuet']//div[contains(@class,'selectBtn')]` | Custom dropdown | Click to open; then select option |
| Country dropdown | `xpath=//div[@data-testid='countrySelectedValueuet']//div[contains(@class,'selectBtn')]` | Custom dropdown | Click to open; then select option |
| Time Zone dropdown | `xpath=//div[@data-testid='timeZoneSelectedValueuet']//div[contains(@class,'selectBtn')]` | Custom dropdown | Click to open; then select option |
| OTP – SMS checkbox | `name="sms"` → `xpath=//input[@name='sms']` | Checkbox | SMS delivery channel |
| OTP – Email checkbox | `name="email"` → `xpath=//input[@name='email']` | Checkbox | Email delivery channel |
| Submit button | `xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit']` | Anchor/button | Submits create form |
| Close button | `xpath=//input[@type='button' and contains(@class,'btn-cancel-color') and @value='Close']` | Input button | Cancels; also `//a[contains(@href,'ManageUser')]` |

### Delete Confirmation Dialog

| Element | XPath | Notes |
|---------|-------|-------|
| Dialog container | `xpath=//div[contains(@class,'confirm-modal')]` | Also `//div[contains(@class,'modal') and contains(@class,'show')]` |
| Dialog heading | `xpath=//div[contains(@class,'confirm-heading')]` | Title of delete dialog |
| Dialog body | `xpath=//div[contains(@class,'confirm-body')]` | Confirmation message text |
| OK / Confirm button | `xpath=//button[contains(text(),'OK')]` | Confirms deletion |
| Cancel button | `xpath=//button[contains(text(),'Cancel')]` | Keeps user in grid |

### Toast Notifications & Validation Errors

| Element | XPath | Notes |
|---------|-------|-------|
| Success toast | `xpath=//*[contains(@class,'toast-success')]` | Also `Toastify__toast--success` |
| Error toast | `xpath=//*[contains(@class,'toast-error')]` | Also `Toastify__toast--error` |
| Toast message body | `xpath=//*[contains(@class,'toast-message')]` | Text of any toast |
| Validation error | `xpath=//*[contains(@class,'alert-danger')]` | Also `.error-message`, `.field-validation-error` |

### Raw HTML Element Summary (for framework-agnostic use)

```html
<!-- Navigation -->
<i class="admin-menu-icon">                         <!-- Admin sidebar icon -->
<ul id="pageHeading"><a href="/ManageUser">User</a> <!-- Top nav tab -->

<!-- List Page Grid -->
<div class="k-grid">                                <!-- User grid container -->
<input placeholder="Enter Search Text">             <!-- Grid search filter -->
<a href="/CreateUser" class="btn btn-custom-color">Create User</a>

<!-- Create Form — Text Inputs -->
<input name="parentAccount">                        <!-- Account TreeView trigger -->
<input name="userName">                             <!-- Username (5–50 chars) -->
<input name="firstName">                            <!-- First Name -->
<input name="lastName">                             <!-- Last Name -->
<input name="telephoneNumber">                      <!-- Primary Phone (5–16 digits) -->
<input name="emailId">                              <!-- Email Address -->
<input name="confirmEmailId">                       <!-- Confirm Email -->
<select name="userAccountType">                     <!-- User Category (optional) -->

<!-- Create Form — Custom Dropdowns (data-testid pattern) -->
<div data-testid="roleSelectedValueuet">            <!-- Role dropdown container -->
  <div class="selectBtn">...</div>                  <!-- Click to open -->
</div>
<div data-testid="countrySelectedValueuet">         <!-- Country dropdown container -->
  <div class="selectBtn">...</div>
</div>
<div data-testid="timeZoneSelectedValueuet">        <!-- Time Zone dropdown container -->
  <div class="selectBtn">...</div>
</div>

<!-- OTP Channels (checkboxes — multiple can be selected) -->
<input type="checkbox" name="sms">                  <!-- SMS OTP channel -->
<input type="checkbox" name="email">                <!-- Email OTP channel -->

<!-- Buttons -->
<a class="btn btn-custom-color cursor-pointer">Submit</a>
<input type="button" class="btn-cancel-color" value="Close">

<!-- Delete -->
<a class="k-grid-Delete">                           <!-- Delete icon in grid row -->
<div class="confirm-modal">                         <!-- Confirmation dialog -->
<button>OK</button>                                 <!-- Confirm delete -->
<button>Cancel</button>                             <!-- Cancel delete -->
```

### Dropdown Option XPath Pattern

For **Role**, **Country**, and **Time Zone** custom dropdowns, after clicking the trigger (`selectBtn`), options appear as:

```xpath
//div[@data-testid='roleSelectedValueuet']//div[contains(@class,'selectDropdown')]//div[contains(@class,'option') and normalize-space()='OPTION_TEXT']
```

Replace `roleSelectedValueuet` with `countrySelectedValueuet` or `timeZoneSelectedValueuet` as needed.
