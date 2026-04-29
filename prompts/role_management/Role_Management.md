# Role Management Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Role_Management` |
| **Suite File** | `tests/role_management_tests.robot` |
| **Variables File** | `variables/role_management_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageRole` (list), `<BASE_URL>/CreateRole` (create form) |
| **Total TCs** | 33 |
| **Tags** | `role-management`, `navigation`, `grid`, `pagination`, `button`, `create-form`, `permissions`, `data-masking`, `search`, `delete`, `boundary`, `duplicate`, `whitespace`, `special-chars`, `smoke`, `regression`, `edge-case` |

## Run Commands

```bash
python run_tests.py --suite Role_Management
python run_tests.py tests/role_management_tests.robot
python run_tests.py --suite Role_Management --include smoke
python run_tests.py --suite Role_Management --include role-management
python run_tests.py --suite Role_Management --include delete
python run_tests.py --suite Role_Management --test "TC_ROLE_011*"
```

## Module Description

The **Role Management** module allows administrators to create, view, search, and delete roles. Each role defines a Name, Account, optional Description, Data Masking flag, and a permissions matrix (View/Edit per module). Created roles appear in a paginated grid and can be searched and deleted.

**Navigation:** Login → Admin sidebar → Role Management → `/ManageRole`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_ROLE_001 | Navigate To Manage Role Page | Positive | navigation, smoke |
| TC_ROLE_002 | Verify Role Grid Loads With Data | Positive | grid |
| TC_ROLE_003 | Verify Role Grid Has Pagination | Positive | grid, pagination |
| TC_ROLE_004 | Verify Create Role Button Visible | Positive | button, permission |
| TC_ROLE_005 | Open Create Role Form | Positive | create-form |
| TC_ROLE_006 | Verify Create Role Breadcrumb | Positive | create-form, breadcrumb |
| TC_ROLE_007 | Verify All Create Role Form Fields Present | Positive | create-form, fields |
| TC_ROLE_008 | Verify Submit Button Present On Create Form | Positive | create-form, button |
| TC_ROLE_009 | Verify Permissions Table Visible On Create Form | Positive | create-form, permissions |
| TC_ROLE_010 | Verify View All And Edit All Checkboxes Present | Positive | create-form, permissions |
| TC_ROLE_011 | Create Role With All Fields | Positive | create, e2e, smoke |
| TC_ROLE_012 | Create Role With Mandatory Fields Only | Positive | create, mandatory |
| TC_ROLE_013 | Create Role With Data Masking Checked | Positive | create, data-masking |
| TC_ROLE_014 | Create Role And Select View All Permissions | Positive | create, permissions |
| TC_ROLE_015 | Create Role And Select Edit All Permissions | Positive | create, permissions |
| TC_ROLE_016 | Search Role In Grid | Positive | search |
| TC_ROLE_017 | Delete Role And Verify Removal | Positive | delete, e2e, smoke |
| TC_ROLE_018 | Close Create Role Form Without Saving | Positive | close, form |
| TC_ROLE_019 | Close Form After Filling Fields Should Not Create Role | Positive | close, form |
| TC_ROLE_020 | Submit Without Filling Any Field | Negative | validation, empty |
| TC_ROLE_021 | Submit Without Selecting Account | Negative | validation, account |
| TC_ROLE_022 | Submit Without Role Name | Negative | validation, role-name |
| TC_ROLE_023 | Role Name More Than 250 Characters | Negative | validation, boundary, role-name |
| TC_ROLE_024 | Description More Than 500 Characters | Negative | validation, boundary, description |
| TC_ROLE_025 | Duplicate Role Name Should Show Error | Negative | validation, duplicate |
| TC_ROLE_026 | Whitespace Only Role Name | Negative | validation, role-name, whitespace |
| TC_ROLE_027 | Cannot Delete Own Role Shows Error | Negative | delete, guard, own-role |
| TC_ROLE_028 | Cancel Delete Confirmation Should Keep Role | Negative | delete, cancel |
| TC_ROLE_029 | Role Name Exactly 250 Characters | Edge Case | boundary, role-name |
| TC_ROLE_030 | Description Exactly 500 Characters | Edge Case | boundary, description |
| TC_ROLE_031 | Special Characters In Role Name | Edge Case | validation, role-name, special-chars |
| TC_ROLE_032 | Verify Delete Confirmation Dialog Elements | Edge Case | delete, dialog |
| TC_ROLE_033 | Verify Search Input On List Page | Edge Case | search, ui |

## Test Case Categories

### Positive — Landing Page & Navigation (4 TCs)
- **TC_ROLE_001** — Navigate to `/ManageRole`; page loads.
- **TC_ROLE_002** — Grid loads with role data (columns: Role Name, Account, etc.).
- **TC_ROLE_003** — Grid has pagination controls.
- **TC_ROLE_004** — Create Role button is visible (confirms RW permission).

### Positive — Create Form UI Verification (6 TCs)
- **TC_ROLE_005** — Clicking Create Role opens the create form.
- **TC_ROLE_006** — Breadcrumb shows `Manage Role > Create Role`.
- **TC_ROLE_007** — Form shows Account, Role Name, Description, Data Masking fields.
- **TC_ROLE_008** — Submit button is present on the form.
- **TC_ROLE_009** — Permissions table (module × view/edit matrix) is visible.
- **TC_ROLE_010** — View All and Edit All checkboxes are present at the top of the permissions table.

### Positive — Create Role Happy Path (5 TCs)
- **TC_ROLE_011** — Create with Account, Role Name, Description, Data Masking, selected permissions. Verifies success and grid entry.
- **TC_ROLE_012** — Create with only Account and Role Name (mandatory fields only).
- **TC_ROLE_013** — Create with Data Masking checkbox checked. Verifies masking is applied.
- **TC_ROLE_014** — Check View All → all View checkboxes are selected in permissions table.
- **TC_ROLE_015** — Check Edit All → all Edit checkboxes are selected.

### Positive — Search, Delete & Close (4 TCs)
- **TC_ROLE_016** — Search by Role Name in grid; matching row is shown.
- **TC_ROLE_017** — Delete a role: click delete icon, confirm dialog, role removed from grid.
- **TC_ROLE_018** — Close form immediately → no role created.
- **TC_ROLE_019** — Fill fields then close → no role created.

### Negative — Mandatory Validation (3 TCs)
- **TC_ROLE_020** — Submit empty form → all required field errors.
- **TC_ROLE_021** — Account not selected → error.
- **TC_ROLE_022** — Role Name blank → error.

### Negative — Boundary (2 TCs)
- **TC_ROLE_023** — Role Name > 250 characters → validation error.
- **TC_ROLE_024** — Description > 500 characters → validation error.

### Negative — Business Rules (4 TCs)
- **TC_ROLE_025** — Duplicate Role Name → error.
- **TC_ROLE_026** — Whitespace-only Role Name → treated as empty, error.
- **TC_ROLE_027** — Attempting to delete one's own role → error/guard message.
- **TC_ROLE_028** — Cancel delete confirmation dialog → role remains in grid.

### Edge Cases (5 TCs)
- **TC_ROLE_029** — Role Name exactly 250 characters → accepted (boundary pass).
- **TC_ROLE_030** — Description exactly 500 characters → accepted.
- **TC_ROLE_031** — Special characters in Role Name → validates behavior (reject or sanitize).
- **TC_ROLE_032** — Delete confirmation dialog shows expected text, Confirm and Cancel buttons.
- **TC_ROLE_033** — Search input on list page is visible and interactive.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/role_management_tests.robot` | Test suite |
| `resources/keywords/role_management_keywords.resource` | Role CRUD and permissions keywords |
| `resources/locators/role_management_locators.resource` | XPath locators (grid + form + permissions table) |
| `variables/role_management_variables.py` | Role names (random), descriptions, boundary strings |

## Automation Notes

- Role Names are randomly generated per run to prevent duplicate conflicts.
- Permissions table is a complex grid (module rows × View/Edit columns); keywords iterate rows or use header-level "View All / Edit All" checkboxes.
- Delete confirmation is a Kendo Dialog; keyword waits for it and clicks the correct button.
- The "own role" guard (TC_ROLE_027) depends on the logged-in user's role matching the role being deleted — test data must set this up correctly.
- Boundary strings for 250 and 500 characters are pre-built in the variables file.

---

## HTML Locators Reference

Use these locators directly in test automation or to generate new test cases for any framework.

### Navigation

| Element | HTML Attribute / XPath | Notes |
|---------|------------------------|-------|
| Admin sidebar icon | `xpath=//i[contains(@class,'admin-menu-icon')]` | Same icon used across all admin modules |
| Role & Access tab | `xpath=//a[@href='/ManageRole']` | Top nav link; navigates to `/ManageRole` |

### Manage Role Grid (List Page — `/ManageRole`)

| Element | HTML Attribute / XPath | Notes |
|---------|------------------------|-------|
| Grid container | `xpath=//div[contains(@class,'k-grid')]` | Kendo UI grid |
| Column headers | `xpath=//th[@role='columnheader']` | All column header cells |
| Pagination bar | `xpath=//*[contains(@class,'k-pager-wrap')]` | Kendo pager |
| Search input | `xpath=//input[@name='searchValue']` | Filter roles by name; also `//input[@placeholder='Enter Search Text']` |
| Create Role button | `xpath=//a[contains(@href,'/CreateRole')]` | Navigates to `/CreateRole` |
| Grid row cell | `xpath=//td[contains(text(),'ROLE_NAME')]` | Replace `ROLE_NAME` with actual role name to locate row |
| Delete icon (row) | `xpath=//tr[.//td[contains(.,'ROLE_NAME')]]//*[contains(@class,'k-grid-Delete')]` | Replace `ROLE_NAME`; falls back to `@title='Delete'` or `.fa-trash` |

### Create Role Form (`/CreateRole`)

| Element | HTML Name / XPath | Type | Notes |
|---------|-------------------|------|-------|
| Account dropdown trigger | `xpath=//input[@name='accountName']` | TreeView input | Also `//div[contains(@class,'TreeViewDropdown')]//input` |
| Account tree container | `xpath=//div[contains(@id,'showTreeView')]` | Div | Appears after clicking account input |
| Tree root expand icon | `xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-i-expand')])[1]` | Span | Expands root node |
| Tree root node | `xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-in')])[1]` | Span | Click to select root account |
| Role Name | `name="roleName"` → `xpath=//input[@name='roleName']` | Text input | Max 250 chars |
| Description | `name="roleDescription"` → `xpath=//input[@name='roleDescription']` | Text input | Optional; max 500 chars |
| Data Masking checkbox | `name="accountCheckbox"` → `xpath=//input[@name='accountCheckbox']` | Checkbox | Applies data masking to role |
| Submit button | `xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit']` | Anchor/button | Submits create form |
| Close button | `xpath=//input[@type='button' and contains(@class,'btn-cancel-color') and @value='Close']` | Input button | Cancels without saving; also `//a[contains(@href,'ManageRole')]` |

### Permissions Table

| Element | HTML Name / XPath | Notes |
|---------|-------------------|-------|
| Permissions wrapper | `xpath=//div[contains(@class,'gc-module-selector-wrapper')]` | Contains all module permission rows |
| Module permission tables | `xpath=//table[contains(@class,'gc-module-selector-table')]` | One per module group |
| View permission checkbox (per row) | `name="js-role-view"` → `xpath=//input[@name='js-role-view']` | One per module row |
| Edit permission checkbox (per row) | `name="js-role-edit"` → `xpath=//input[@name='js-role-edit']` | One per module row |
| View All header checkbox | `name="js-role-viewheader"` → `xpath=//input[@name='js-role-viewheader']` | Selects all View checkboxes |
| Edit All header checkbox | `name="js-role-editheader"` → `xpath=//input[@name='js-role-editheader']` | Selects all Edit checkboxes |
| Permission popup (Tab) | `xpath=//*[@id='openPermissionPopup']` | Opens permission detail popup |
| Ticketing popup | `xpath=//*[@id='openTicketingPopup']` | Ticketing-specific permissions |
| Notification popup | `xpath=//*[@id='openNotificationPopup']` | Notification permissions |
| Roles & Triggers popup | `xpath=//*[@id='openRolesTriggersPopup']` | Role trigger settings |
| Popup Save button | `xpath=//div[contains(@class,'modal') and contains(@class,'show')]//button[contains(text(),'Save')]` | Inside any permission popup |

### Delete Confirmation Dialog

| Element | XPath | Notes |
|---------|-------|-------|
| Dialog container | `xpath=//div[contains(@class,'confirm-modal')]` | Also `//div[contains(@class,'modal') and contains(@class,'show')]` |
| Dialog body | `xpath=//div[contains(@class,'confirm-body')]` | Confirmation message text |
| Confirm / OK button | `xpath=//button[normalize-space()='OK']` | Also `//button[contains(text(),'Yes')]` |
| Cancel button | `xpath=//button[contains(text(),'Cancel')]` | Keeps role in grid |

### Toast Notifications & Validation Errors

| Element | XPath | Notes |
|---------|-------|-------|
| Success toast | `xpath=//*[contains(@class,'toast-success')]` | Also `Toastify__toast--success` |
| Error toast | `xpath=//*[contains(@class,'toast-error')]` | Also `Toastify__toast--error` |
| Toast message body | `xpath=//*[contains(@class,'toast-message')]` | Text content of any toast |
| Validation error | `xpath=//*[contains(@class,'alert-danger')]` | Also `.error-message`, `.field-validation-error` |

### Raw HTML Element Summary (for framework-agnostic use)

```html
<!-- Navigation -->
<i class="admin-menu-icon">                    <!-- Admin sidebar icon -->
<a href="/ManageRole">Role &amp; Access</a>    <!-- Top nav tab -->

<!-- List Page Grid -->
<div class="k-grid">                           <!-- Role grid container -->
<input name="searchValue" placeholder="Enter Search Text">   <!-- Search -->
<a href="/CreateRole" class="btn btn-custom-color">Create Role</a>

<!-- Create Form -->
<input name="accountName">                     <!-- Account TreeView trigger -->
<input name="roleName">                        <!-- Role Name (max 250) -->
<input name="roleDescription">                 <!-- Description (max 500, optional) -->
<input type="checkbox" name="accountCheckbox"> <!-- Data Masking -->

<!-- Permissions Table -->
<div class="gc-module-selector-wrapper">       <!-- Permissions container -->
<input name="js-role-view">                    <!-- View permission per row -->
<input name="js-role-edit">                    <!-- Edit permission per row -->
<input name="js-role-viewheader">              <!-- View All header toggle -->
<input name="js-role-editheader">              <!-- Edit All header toggle -->

<!-- Buttons -->
<a class="btn btn-custom-color cursor-pointer">Submit</a>
<input type="button" class="btn-cancel-color" value="Close">

<!-- Delete -->
<a class="k-grid-Delete">                      <!-- Delete icon in grid row -->
<div class="confirm-modal">                    <!-- Confirmation dialog -->
<button>OK</button>                            <!-- Confirm delete -->
<button>Cancel</button>                        <!-- Cancel delete -->
```
