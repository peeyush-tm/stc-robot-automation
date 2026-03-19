# Test Case: Create User and Delete User
**Module:** Admin > User Management  
**Automation Framework:** Robot Framework  
**Page Under Test:** Manage User (`/ManageUser`)

---

## Overview

This document outlines the step-by-step test cases for:
1. **TC_001** – Create a new platform user
2. **TC_002** – Delete the same platform user created in TC_001

---

## Prerequisites

- Valid credentials with Admin-level access
- User must have **Read/Write** permission on the **User** module
- At least one **Account**, **Role**, **Group**, **Country**, and **Time Zone** must be available in the system

---

## Navigation Path

```
Login → Sidebar → Admin → User
```

> The **User** menu item is under the **Admin** tab in the left sidebar navigation panel.  
> Route: `/ManageUser`

---

## TC_001 – Create User

### Objective
Verify that an Admin user can successfully create a new platform user from the Manage User page.

---

### Test Steps

| Step | Action | Input / Expected Result |
|------|--------|------------------------|
| 1 | Log in to the application | Login with Admin credentials |
| 2 | Click on **Admin** in the left sidebar | Admin section expands |
| 3 | Click on **User** under Admin | Navigates to the **Manage User** page (`/ManageUser`) |
| 4 | Verify the page heading | Page title shows **"Users"** |
| 5 | Click the **"Create User"** button (top-right area of the page) | Create User form / page opens (`/CreateUser`) |
| 6 | Fill in the **Account** field | Select a valid account from the TreeView dropdown (Required) |
| 7 | Fill in the **Username** field | Enter a unique username (min 5 chars, max 50 chars) e.g. `testuser01` |
| 8 | Fill in the **First Name** field | Enter first name e.g. `Test` (Required) |
| 9 | Fill in the **Last Name** field | Enter last name e.g. `User` (Required) |
| 10 | Fill in the **Primary Phone** field | Enter a valid phone number (min 5 digits, max 16 digits) e.g. `9876543210` (Required) |
| 11 | Fill in the **Email Address** field | Enter a valid email e.g. `testuser01@example.com` (Required) |
| 12 | Fill in the **Confirm Email Address** field | Re-enter the same email e.g. `testuser01@example.com` (Required, must match Email Address) |
| 13 | Select a **Role** from the dropdown | Select a valid role (Required) |
| 14 | Select a **Country** from the dropdown | Select a valid country (Required) |
| 15 | Select a **Time Zone** from the dropdown | Select a valid time zone (Required) |
| 16 | Select at least one **OTP Delivery Channel** checkbox | Check **SMS** and/or **Email** (at least one is Required) |
| 17 | Click the **"Submit"** button | User is created successfully |
| 18 | Verify success | Toast notification appears confirming user creation; user is redirected or form closes |
| 19 | Navigate back to **Manage User** page | The newly created user `testuser01` appears in the grid |

---

### Form Field Reference

| Field Label | Type | Validation | Notes |
|---|---|---|---|
| Account | TreeView Dropdown | Required | Must select a valid account |
| Username | Text Input | Required, min 5 chars, max 50 chars | Must be unique in the system |
| First Name | Text Input | Required, non-empty | Trimmed whitespace |
| Last Name | Text Input | Required, non-empty | Trimmed whitespace |
| Primary Phone | Number Input | Required, min 5 digits, max 16 digits | Numeric only |
| Email Address | Text Input | Required, valid email format | |
| Confirm Email Address | Text Input | Required, must match Email Address | Only shown on Create, not Edit |
| Role | Dropdown | Required | Must select a valid role |
| Country | Dropdown | Required | |
| Time Zone | Dropdown | Required | Not required if Local Time = Yes |
| OTP Delivery Channel | Checkbox (SMS / Email) | At least one required | Default: SMS checked |
| Secondary Phone | Number Input | Optional (feature-flagged) | min 5, max 16 digits |
| Local Time | Radio (Yes / No) | Optional (feature-flagged) | Yes = local system time |
| User Type | Dropdown | Optional (shown if OIAM enabled) | OIAM-specific feature |
| User Category | Dropdown | Optional (feature-flagged) | Values: Normal User, Lead Person, Account Manager, BR, BRS, Retention User, Catalogue User |

---

### Buttons on Create User Form

| Button Label | Action |
|---|---|
| Submit | Saves the new user |
| Close | Cancels and closes the form without saving |

---

### Grid Columns on Manage User Page (for Verification)

| Column | Field |
|---|---|
| Action | Row-level action icons |
| User Name | `userName` |
| User Type | `userType` |
| User Category | `userAccountType` |
| Account | `account.name` |
| Lock Status | `locked` |
| Lock/Unlock Reason | `reason` |
| Group | `group.name` |
| Role & Access | `role.roleName` |
| First Name | `contactInfo.firstName` |
| Last Name | `contactInfo.lastName` |
| Primary Phone | `contactInfo.primaryPhone` |
| Email Address | `contactInfo.email` |

---

### Expected Result – TC_001

- User `testuser01` is successfully created.
- A success toast notification is displayed.
- The user appears in the **Manage User** grid with correct details.

---

## TC_002 – Delete User

### Objective
Verify that the Admin user can successfully delete the user (`testuser01`) created in TC_001.

> **Dependency:** TC_001 must pass before executing TC_002.

---

### Test Steps

| Step | Action | Input / Expected Result |
|------|--------|------------------------|
| 1 | Navigate to **Admin → User** | Manage User page (`/ManageUser`) opens |
| 2 | Locate the user `testuser01` in the grid | User row is visible in the grid (use search if needed) |
| 3 | In the **Action** column of the row for `testuser01`, click the **"Delete User"** icon/button | A confirmation dialog box appears |
| 4 | Verify the confirmation dialog **heading** | Heading reads: **"Delete User"** |
| 5 | Verify the confirmation dialog **body text** | Body reads: **"Do you want to delete the user - testuser01?"** |
| 6 | Click the **"OK"** button in the confirmation dialog | Deletion request is submitted |
| 7 | Verify the success notification | Toast message: **"User Deleted Successfully"** |
| 8 | Verify the user is removed | The user `testuser01` no longer appears in the Manage User grid |

---

### Confirmation Dialog Reference

| Element | Text |
|---|---|
| Dialog Heading | `Delete User` |
| Dialog Body | `Do you want to delete the user - {{username}}?` |
| Confirm Button | `OK` |
| Cancel Button | `Cancel` |

---

### Expected Result – TC_002

- Confirmation dialog appears with correct heading and body text.
- Clicking **OK** deletes the user.
- Success toast notification is displayed: **"User Deleted Successfully"**.
- The user `testuser01` is no longer listed in the Manage User grid.

---

## Robot Framework Test Case Outline

```robot
*** Settings ***
Library    SeleniumLibrary
Library    BuiltIn

*** Variables ***
${BASE_URL}         https://<application-url>
${ADMIN_USER}       <admin-username>
${ADMIN_PASS}       <admin-password>
${TEST_USERNAME}    testuser01
${TEST_EMAIL}       testuser01@example.com
${TEST_FNAME}       Test
${TEST_LNAME}       User
${TEST_PHONE}       9876543210

*** Test Cases ***

TC_001 Create Platform User
    [Documentation]    Creates a new platform user from Admin > User > Create User
    [Tags]    Admin    User    Create
    Open Browser    ${BASE_URL}    chrome
    Login To Application    ${ADMIN_USER}    ${ADMIN_PASS}
    Navigate To Manage User Page
    Click Create User Button
    Fill User Creation Form
    Submit User Form
    Verify User Created Successfully    ${TEST_USERNAME}
    [Teardown]    Close Browser

TC_002 Delete Platform User
    [Documentation]    Deletes the platform user testuser01 from Admin > User
    [Tags]    Admin    User    Delete
    [Setup]    TC_001 Create Platform User
    Open Browser    ${BASE_URL}    chrome
    Login To Application    ${ADMIN_USER}    ${ADMIN_PASS}
    Navigate To Manage User Page
    Search And Select User In Grid    ${TEST_USERNAME}
    Click Delete User Action Icon    ${TEST_USERNAME}
    Verify Delete Confirmation Dialog    ${TEST_USERNAME}
    Confirm Delete User
    Verify User Deleted Successfully    ${TEST_USERNAME}
    [Teardown]    Close Browser

*** Keywords ***

Login To Application
    [Arguments]    ${username}    ${password}
    Input Text        id=username    ${username}
    Input Text        id=password    ${password}
    Click Button      xpath=//button[@type='submit']
    Wait Until Page Contains Element    xpath=//div[contains(@class,'sidebar')]

Navigate To Manage User Page
    Click Element     xpath=//span[text()='Admin']
    Click Element     xpath=//span[text()='User']
    Wait Until Page Contains    Users
    Location Should Contain    /ManageUser

Click Create User Button
    Click Element     xpath=//button[contains(text(),'Create User')]
    Wait Until Page Contains    Create User

Fill User Creation Form
    # Account - TreeView Dropdown
    Click Element     xpath=//div[contains(@class,'account-tree-dropdown')]
    Select TreeView Account    <Account Name>

    # Username
    Input Text        xpath=//input[@name='userName']    ${TEST_USERNAME}

    # First Name
    Input Text        xpath=//input[@name='firstName']    ${TEST_FNAME}

    # Last Name
    Input Text        xpath=//input[@name='lastName']    ${TEST_LNAME}

    # Primary Phone
    Input Text        xpath=//input[@name='telephoneNumber']    ${TEST_PHONE}

    # Email Address
    Input Text        xpath=//input[@name='emailId']    ${TEST_EMAIL}

    # Confirm Email Address
    Input Text        xpath=//input[@name='confirmEmailId']    ${TEST_EMAIL}

    # Role - Dropdown
    Select Role Dropdown    <Role Name>

    # Country - Dropdown
    Select Country Dropdown    <Country Name>

    # Time Zone - Dropdown
    Select Time Zone Dropdown    <Time Zone>

    # OTP Delivery Channel - SMS checkbox (default checked)
    # Verify or select SMS checkbox
    Select Checkbox    xpath=//input[@name='sms']

Submit User Form
    Click Element     xpath=//button[contains(text(),'Submit')]
    Wait Until Page Contains    Users

Verify User Created Successfully
    [Arguments]    ${username}
    Wait Until Page Contains Element    xpath=//td[contains(text(),'${username}')]
    Page Should Contain    ${username}

Search And Select User In Grid
    [Arguments]    ${username}
    Input Text        xpath=//input[@placeholder='Enter Search Text']    ${username}
    Press Keys        xpath=//input[@placeholder='Enter Search Text']    RETURN
    Wait Until Page Contains Element    xpath=//td[contains(text(),'${username}')]

Click Delete User Action Icon
    [Arguments]    ${username}
    Click Element    xpath=//tr[td[contains(text(),'${username}')]]//span[@title='Delete User']
    Wait Until Page Contains    Delete User

Verify Delete Confirmation Dialog
    [Arguments]    ${username}
    Element Text Should Be    xpath=//div[contains(@class,'confirm-heading')]    Delete User
    Page Should Contain    Do you want to delete the user - ${username}?

Confirm Delete User
    Click Element    xpath=//button[contains(text(),'OK')]
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'confirm-modal')]

Verify User Deleted Successfully
    [Arguments]    ${username}
    Page Should Contain    User Deleted Successfully
    Wait Until Page Does Not Contain Element    xpath=//td[contains(text(),'${username}')]
```

---

## Notes for Automation Engineer

1. **XPath Locators** – The XPaths above are indicative. Verify and update them against actual rendered HTML using browser DevTools.
2. **Account / Role / Country / Time Zone** – Replace placeholder values (`<Account Name>`, `<Role Name>`, `<Country Name>`, `<Time Zone>`) with actual test data values available in the environment.
3. **Feature Flags** – Fields like **User Category**, **Secondary Phone**, **Local Time**, and **User Type** are conditionally rendered based on server-side feature flags. Handle their presence/absence using `Run Keyword If Element Is Visible`.
4. **Search in Grid** – The Manage User page uses a Kendo Grid. If pagination is active, ensure the search returns the target user before interacting with row-level actions.
5. **Test Data Cleanup** – TC_002 serves as the teardown for TC_001. If TC_002 is skipped or fails, manually delete the test user to keep the environment clean.
6. **OTP Channel** – By default, SMS is checked. Adjust if environment requires Email OTP.
7. **Confirmation Dialog** – The delete confirmation uses a custom `ConfirmBox` component. Confirm the dialog is fully rendered before clicking OK.

---

## Current Project Implementation

This section documents the **actual implementation** in the project, mapping back to the Robot Framework files.

### Project Files

| Content | Location |
|---------|----------|
| Test cases (45 tests) | `tests/user_management_tests.robot` |
| Keywords | `resources/keywords/user_management_keywords.resource` |
| Locators | `resources/locators/user_management_locators.resource` |
| Variables / Test data | `variables/user_management_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |

### Run Command

```bash
robot --outputdir reports tests/user_management_tests.robot
```

### Test Case List (45 tests)

| ID | Name | Type |
|----|------|------|
| TC_USER_001 | Navigate To Manage User Page Via Admin Sidebar | positive |
| TC_USER_002 | Verify Manage User Grid Loads With Data | positive |
| TC_USER_003 | Verify Manage User Grid Columns | positive |
| TC_USER_004 | Verify Manage User Grid Has Pagination | positive |
| TC_USER_005 | Verify Create User Button Is Visible | positive |
| TC_USER_006 | Open Create User Form | positive |
| TC_USER_007 | Verify All Create User Form Fields Present | positive |
| TC_USER_008 | Verify Submit And Close Buttons Present | positive |
| TC_USER_009 | Create User With All Required Fields | positive |
| TC_USER_010 | Create User With Email OTP Channel | positive |
| TC_USER_011 | Create User With Both SMS And Email OTP Channels | positive |
| TC_USER_012 | Search User In Grid By Username | positive |
| TC_USER_013 | Delete User And Verify Removal | positive |
| TC_USER_014 | Close Create User Form Without Saving | negative |
| TC_USER_015 | Close Form After Filling Fields Should Not Create User | negative |
| TC_USER_016 | Submit Without Filling Any Field | negative |
| TC_USER_017 | Submit Without Selecting Account | negative |
| TC_USER_018 | Submit Without Username | negative |
| TC_USER_019 | Submit Without First Name | negative |
| TC_USER_020 | Submit Without Last Name | negative |
| TC_USER_021 | Submit Without Primary Phone | negative |
| TC_USER_022 | Submit Without Email Address | negative |
| TC_USER_023 | Submit Without Confirm Email Address | negative |
| TC_USER_024 | Submit Without Selecting Role | negative |
| TC_USER_025 | Submit Without Selecting Country | negative |
| TC_USER_026 | Submit Without Selecting Time Zone | negative |
| TC_USER_027 | Submit Without Selecting Any OTP Channel | negative |
| TC_USER_028 | Username Less Than 5 Characters | negative |
| TC_USER_029 | Username More Than 50 Characters | negative |
| TC_USER_030 | Phone Less Than 5 Digits | negative |
| TC_USER_031 | Phone More Than 16 Digits | negative |
| TC_USER_032 | Phone With Non Numeric Characters | negative |
| TC_USER_033 | Invalid Email Format | negative |
| TC_USER_034 | Mismatched Confirm Email | negative |
| TC_USER_035 | Duplicate Username Should Show Error | negative |
| TC_USER_036 | Cancel Delete Confirmation Should Keep User | negative |
| TC_USER_037 | Username Exactly 5 Characters | edge |
| TC_USER_038 | Username Exactly 50 Characters | edge |
| TC_USER_039 | Phone Exactly 5 Digits | edge |
| TC_USER_040 | Phone Exactly 16 Digits | edge |
| TC_USER_041 | Whitespace Only Username | edge |
| TC_USER_042 | Whitespace Only First Name | edge |
| TC_USER_043 | Whitespace Only Last Name | edge |
| TC_USER_044 | Special Characters In Username | edge |
| TC_USER_045 | Verify Delete Confirmation Dialog Elements | positive |

### Key Implementation Details

- **Navigation:** Uses sidebar Admin icon (`//i[contains(@class,'admin-menu-icon')]`) → clicks User sub-tab (`//ul[@id='pageHeading']//a[contains(@href,'/ManageUser')]`)
- **User Category:** Selects "Normal User" from native `<select>` dropdown (`<select name="userAccountType">`)
- **Account TreeView:** Hierarchical expansion KSA_OPCO → SANJ_1002 → billingAccountSANJ_1003 (same pattern as Cost Center)
- **Role:** Custom div-based dropdown — selects "BillingAccount_Admin"
- **Timezone:** Custom div-based dropdown — selects "(GMT+03:00) Kuwait, Riyadh"
- **Country:** Custom div-based dropdown with search — types "India" and selects from filtered options
- **Browser Session:** Suite-level login; test-level navigation back to Manage User via sidebar
- **Page Load Waits:** Uses `Wait For App Loading To Complete` keyword after navigation
