# Role Management — Create & Delete
**Module:** Admin → Role & Access  
**Framework:** Robot Framework  
**Routes:** `/ManageRole` | `/CreateRole`

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Test Data](#test-data)
4. [TC-ROLE-001 — Create a Role](#tc-role-001--create-a-role)
5. [TC-ROLE-002 — Delete the Created Role](#tc-role-002--delete-the-created-role)
6. [API Reference](#api-reference)
7. [Locator Reference](#locator-reference)

---

## Overview

This document describes the end-to-end steps to **create** a new Role and then **delete** the same Role through the application UI, under the **Admin** tab. These steps serve as the basis for Robot Framework test cases.

---

## Prerequisites

| # | Condition |
|---|-----------|
| 1 | User is logged in to the application |
| 2 | Logged-in user has **Read-Write (RW)** permission on the Role & Access screen |
| 3 | At least one **Account** exists in the system |
| 4 | The role to be deleted must **not** be the currently logged-in user's own role |

---

## Test Data

| Field | Example Value | Notes |
|-------|--------------|-------|
| Account | `Test Account` | Must exist in the system; selected via tree-view dropdown |
| Role Name | `AutoRole_001` | Max 250 characters; must be unique |
| Role Description | `Automation test role` | Max 500 characters; optional |
| Data Masking | `Unchecked` | Optional checkbox |

---

## TC-ROLE-001 — Create a Role

### Objective
Verify that a new role can be created successfully from the Admin → Role & Access page.

---

### Step 1 — Navigate to Admin Tab

| # | Action | Expected Result |
|---|--------|----------------|
| 1.1 | Click on the **Admin** menu item in the top/side navigation bar | Admin sub-menu options are displayed |
| 1.2 | Click **Role & Access** from the Admin sub-menu | Browser navigates to `/ManageRole`; the Role & Access list page is displayed |

---

### Step 2 — Open Create Role Form

| # | Action | Expected Result |
|---|--------|----------------|
| 2.1 | Verify the **Create Role** button is visible on the top-right of the page | Button is visible (only when user has RW permission) |
| 2.2 | Click the **Create Role** button | Browser navigates to `/CreateRole`; the Create Role form is displayed |
| 2.3 | Verify the breadcrumb reads **Role & Access > Create** | Breadcrumb is rendered correctly |

---

### Step 3 — Fill in Role Details

| # | Field | Action | Expected Result |
|---|-------|--------|----------------|
| 3.1 | **Account** | Click the Account tree-view dropdown | Dropdown opens showing available accounts |
| 3.2 | **Account** | Select `Test Account` from the dropdown | Selected account name appears in the field |
| 3.3 | **Role Name** | Click the Role Name input box and type `AutoRole_001` | Text is entered in the field (max 250 chars) |
| 3.4 | **Role Description** | Click the Role Description input box and type `Automation test role` | Text is entered in the field (max 500 chars) |
| 3.5 | **Data Masking** | Leave the Data Masking checkbox **unchecked** | Checkbox remains unchecked |

---

### Step 4 — (Optional) Configure Permissions

> Skip this step if default permissions are acceptable for the test.

| # | Action | Expected Result |
|---|--------|----------------|
| 4.1 | Locate the permissions table listing all screens/modules | Permissions grid is visible |
| 4.2 | Check **View** (`js-role-view`) and/or **Edit** (`js-role-edit`) checkboxes for required screens | Checkboxes are selected |
| 4.3 | To select all at once, click the **View All** or **Edit All** header checkbox (`js-role-viewheader` / `js-role-editheader`) | All screen permissions in that column are toggled |
| 4.4 | If a screen has a **Popup** icon, click it to open the permission modal | Modal opens (Tab, Ticketing, Notification, or Rule Engine Triggers) |
| 4.5 | Configure the modal permissions and click **Save** | Modal closes; selections are saved |

---

### Step 5 — Submit the Form

| # | Action | Expected Result |
|---|--------|----------------|
| 5.1 | Click the **Submit** button (top-right of the form) | Form is submitted |
| 5.2 | Verify a success toast/notification is displayed | Success message is shown |
| 5.3 | Verify the browser navigates back to `/ManageRole` | Role list page is displayed |
| 5.4 | Search for `AutoRole_001` in the search box | The newly created role appears in the grid |

---

## TC-ROLE-002 — Delete the Created Role

### Objective
Verify that the role created in TC-ROLE-001 (`AutoRole_001`) can be successfully deleted.

> **Dependency:** TC-ROLE-001 must have passed and `AutoRole_001` must exist.

---

### Step 1 — Navigate to Role & Access List

| # | Action | Expected Result |
|---|--------|----------------|
| 1.1 | Click **Admin** in the navigation bar | Admin sub-menu is displayed |
| 1.2 | Click **Role & Access** | Browser navigates to `/ManageRole`; the role list page is displayed |

---

### Step 2 — Search for the Role

| # | Action | Expected Result |
|---|--------|----------------|
| 2.1 | Click the **Search** input box (field name: `searchValue`) | Input box is focused |
| 2.2 | Type `AutoRole_001` | Search results are filtered in the grid |
| 2.3 | Verify `AutoRole_001` appears in the grid | Role row is visible |

---

### Step 3 — Initiate Delete

| # | Action | Expected Result |
|---|--------|----------------|
| 3.1 | Locate the row with **Role Name** = `AutoRole_001` | Row is visible in the grid |
| 3.2 | Click the **Delete** button (Action column) for that row | A confirmation dialog box is displayed |
| 3.3 | Verify the confirmation dialog contains the role name `AutoRole_001` | Dialog text references the role being deleted |

---

### Step 4 — Confirm Deletion

| # | Action | Expected Result |
|---|--------|----------------|
| 4.1 | Click **Confirm / Yes** on the confirmation dialog | Dialog closes; delete API is called |
| 4.2 | Verify a success toast/notification is displayed | Success message is shown |
| 4.3 | Verify `AutoRole_001` is no longer present in the grid (search again if needed) | Role row is absent from the grid |

---

### Step 5 — Negative Check (Guard Validation)

| # | Scenario | Expected Result |
|---|----------|----------------|
| 5.1 | Attempt to delete the role that matches the **currently logged-in user's own role** | Delete button action is blocked; an error toast is shown (`t_cantdelete`) |

---

## API Reference

> These endpoints are called by the UI internally. Useful for API-level assertions or mocking in tests.

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get roles list | `GET` | `api/role/access?offset=&limit=&sortColumn=&order=&searchValue=&condition=` |
| Get role by ID | `GET` | `api/roles/{id}` |
| Get screen list | `GET` | `api/get/screenList?roleId={id}` |
| Get tab list | `GET` | `api/get/tabList/?roleId={id}` |
| **Create role** | `POST` | `api/create/role` |
| Update role | `PUT` | `api/update/roles/{roleId}` |
| **Delete role** | `DELETE` | `api/delete/roles/{id}` |

**Create Role — POST Body:**

```json
{
  "groupId": "<group_id>",
  "accountId": "<account_id>",
  "roleName": "AutoRole_001",
  "roleDescription": "Automation test role",
  "dataMasking": false,
  "roleToScreenList": "<JSON string of screen permissions>",
  "roleToTabList": "<JSON string of tab permissions>"
}
```

---

## Locator Reference

> Element identifiers for Robot Framework locators (SeleniumLibrary / Browser Library).

| Element | Type | Identifier / Selector |
|---------|------|-----------------------|
| Admin menu item | Link / Nav item | Text: `Admin` |
| Role & Access sub-menu item | Link | Text: `Role & Access` |
| Create Role button | Link (`<a>`) | CSS: `.btn-custom-color` or Text: `Create Role` |
| Account dropdown | TreeView Dropdown | Name: `accountId` / `accountName` |
| Role Name input | Text input | Name: `roleName` |
| Role Description input | Text input | Name: `roleDescription` |
| Data Masking checkbox | Checkbox | Name: `accountCheckbox` |
| View permission checkbox (per screen) | Checkbox | `name` attribute: `js-role-view` → selector: `input[name="js-role-view"]` |
| Edit permission checkbox (per screen) | Checkbox | `name` attribute: `js-role-edit` → selector: `input[name="js-role-edit"]` |
| View All header checkbox | Checkbox | `name` attribute: `js-role-viewheader` → selector: `input[name="js-role-viewheader"]` |
| Edit All header checkbox | Checkbox | `name` attribute: `js-role-editheader` → selector: `input[name="js-role-editheader"]` |
| Submit / Update button | Button (`<a>`) | Text: `Submit` (create) / `Update` (edit) |
| Search input (list page) | Text input | Name: `searchValue` |
| Delete button (grid row) | Button (Kendo command) | Text: `Delete` (in Action column) |
| Confirm dialog — Yes button | Dialog button | Text: `Yes` / `Confirm` (ConfirmBox) |
| Permission popup Save button | Button | ID: `#openPermissionPopup` → Save |
| Ticketing popup Save button | Button | ID: `#openTicketingPopup` → Save |
| Notification popup Save button | Button | ID: `#openNotificationPopup` → Save |
| Roles & Triggers popup Save button | Button | ID: `#openRolesTriggersPopup` → Save |

---

## Notes

- The **Create Role** button is rendered only when `readWritePermission === "RW"`. Ensure the test user has RW access before running.
- A user **cannot delete their own role**. The application will display an error toast. Account for this in teardown steps by using a separate test user or a role that is not currently assigned to the logged-in user.
- After deletion, the grid refreshes automatically. No manual page reload is needed.
- The breadcrumb on the Create Role page displays **"Role & Access > Create"**. Use this as a page-load confirmation check in the Robot script.

---

## Current Project Implementation

This section documents the **actual implementation** in the project, mapping back to the Robot Framework files.

### Project Files

| Content | Location |
|---------|----------|
| Test cases (33 tests) | `tests/role_management_tests.robot` |
| Keywords | `resources/keywords/role_management_keywords.resource` |
| Locators | `resources/locators/role_management_locators.resource` |
| Variables / Test data | `variables/role_management_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |

### Run Command

```bash
robot --outputdir reports tests/role_management_tests.robot
```

### Test Case List (33 tests)

| ID | Name | Type |
|----|------|------|
| TC_ROLE_001 | Navigate To Manage Role Page | positive |
| TC_ROLE_002 | Verify Role Grid Loads With Data | positive |
| TC_ROLE_003 | Verify Role Grid Has Pagination | positive |
| TC_ROLE_004 | Verify Create Role Button Visible | positive |
| TC_ROLE_005 | Open Create Role Form | positive |
| TC_ROLE_006 | Verify Create Role Breadcrumb | positive |
| TC_ROLE_007 | Verify All Create Role Form Fields Present | positive |
| TC_ROLE_008 | Verify Submit Button Present On Create Form | positive |
| TC_ROLE_009 | Verify Permissions Table Visible On Create Form | positive |
| TC_ROLE_010 | Verify View All And Edit All Checkboxes Present | positive |
| TC_ROLE_011 | Create Role With All Fields | positive |
| TC_ROLE_012 | Create Role With Mandatory Fields Only | positive |
| TC_ROLE_013 | Create Role With Data Masking Checked | positive |
| TC_ROLE_014 | Create Role And Select View All Permissions | positive |
| TC_ROLE_015 | Create Role And Select Edit All Permissions | positive |
| TC_ROLE_016 | Search Role In Grid | positive |
| TC_ROLE_017 | Delete Role And Verify Removal | positive |
| TC_ROLE_018 | Close Create Role Form Without Saving | negative |
| TC_ROLE_019 | Close Form After Filling Fields Should Not Create Role | negative |
| TC_ROLE_020 | Submit Without Filling Any Field | negative |
| TC_ROLE_021 | Submit Without Selecting Account | negative |
| TC_ROLE_022 | Submit Without Role Name | negative |
| TC_ROLE_023 | Role Name More Than 250 Characters | negative |
| TC_ROLE_024 | Description More Than 500 Characters | negative |
| TC_ROLE_025 | Duplicate Role Name Should Show Error | negative |
| TC_ROLE_026 | Whitespace Only Role Name | negative |
| TC_ROLE_027 | Cannot Delete Own Role Shows Error | negative |
| TC_ROLE_028 | Cancel Delete Confirmation Should Keep Role | negative |
| TC_ROLE_029 | Role Name Exactly 250 Characters | edge |
| TC_ROLE_030 | Description Exactly 500 Characters | edge |
| TC_ROLE_031 | Special Characters In Role Name | edge |
| TC_ROLE_032 | Verify Delete Confirmation Dialog Elements | positive |
| TC_ROLE_033 | Verify Search Input On List Page | positive |

### Key Implementation Details

- **Navigation:** Uses dynamic URL from `BASE_URL` (`env_config.py`) — constructs `${BASE_URL}/ManageRole` with trailing-slash stripping. No hardcoded URLs.
- **Refresh Manage Role Page:** Skips re-navigation if already on `/ManageRole` (checks `Location Should Contain` first)
- **Account TreeView:** Hierarchical expansion KSA_OPCO → SANJ_1002 → billingAccountSANJ_1003 using JavaScript-based TreeView discovery and expansion (same pattern as Create User)
- **Permissions DOM:** The MD spec says `js-role-view`/`js-role-edit` are CSS classes, but in the actual DOM they are **`name` attributes**:
  - View per-row: `<input name="js-role-view" ...>` (selector: `input[name="js-role-view"]`)
  - Edit per-row: `<input name="js-role-edit" ...>` (selector: `input[name="js-role-edit"]`)
  - View All header: `<input name="js-role-viewheader" ...>` (selector: `input[name="js-role-viewheader"]`)
  - Edit All header: `<input name="js-role-editheader" ...>` (selector: `input[name="js-role-editheader"]`)
- **Permissions Table Container:** `<div class="gc-module-selector-wrapper role-access">` containing 14 `<table class="gc-module-selector-table">` elements (one per module: Devices, Dashboard, Rate Plan, etc.)
- **Checkbox Interaction:** All permission checkboxes use `Execute JavaScript` with `document.querySelector('input[name="..."]')` because they are not "visible" in Selenium's sense but can be clicked via JS
- **Permission Popups:** Handles Tab, Ticketing, Notification, and Rule Engine Triggers popup modals with Save buttons
- **Browser Session:** Suite-level login; test-level page refresh back to Manage Role
- **Delete Guard:** TC_ROLE_027 tests that a user cannot delete their own role
- **Page Load Waits:** Uses `Wait For App Loading To Complete` keyword after navigation
