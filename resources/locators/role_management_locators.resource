*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  ROLE MANAGEMENT LOCATORS — from role_create_delete.md
#  All identifiers taken line by line from the Locator Reference table
# ══════════════════════════════════════════════════════════════════════

# ── Navigation (MD: Locator Reference → Admin, Role & Access) ────────
# Admin menu item — Text: 'Admin'
${LOC_NAV_ADMIN}                   xpath=//span[text()='Admin'] | //a[normalize-space(text())='Admin']
# Role & Access sub-menu — Text: 'Role & Access'
${LOC_NAV_ROLE_ACCESS}             xpath=//span[text()='Role & Access'] | //a[normalize-space(text())='Role & Access'] | //a[@href='/ManageRole']

# ── Manage Role Page (MD: Step 1.2) ─────────────────────────────────
${LOC_ROLE_GRID}                   xpath=//div[contains(@class,'k-grid')]
${LOC_ROLE_GRID_COLUMN_HEADER}     xpath=//th[@role='columnheader']
${LOC_ROLE_GRID_PAGINATION}        xpath=//*[contains(@class,'k-pager-wrap')]

# ── Create Role Button (MD: Locator Reference → CSS .btn-custom-color, Text: Create Role) ──
${LOC_BTN_CREATE_ROLE}             xpath=//a[contains(text(),'Create Role')] | //a[contains(@class,'btn-custom-color') and contains(@href,'/CreateRole')]

# ── Breadcrumb (MD: Step 2.3 — "Role & Access > Create") ────────────
${LOC_BREADCRUMB_CREATE}           xpath=//*[contains(text(),'Create')] | //li[contains(@class,'breadcrumb') and contains(text(),'Create')]

# ── Create Role Form Fields (MD: Locator Reference table) ────────────

# Account — TreeView Dropdown (MD: Name: accountId / accountName)
${LOC_ROLE_ACCOUNT_DROPDOWN}       xpath=//input[@name='accountName'] | //input[@name='accountId'] | //div[contains(@class,'TreeViewDropdown')]//input
${LOC_ROLE_ACCOUNT_TREE}           xpath=//div[contains(@class,'k-treeview')] | //ul[contains(@class,'k-treeview')]
${LOC_ROLE_ACCOUNT_FIRST_NODE}     xpath=(//div[contains(@class,'k-treeview')]//span[contains(@class,'k-in')] | //ul[contains(@class,'k-treeview')]//li//span[contains(@class,'k-in')])[1]

# Role Name (MD: Name: roleName, max 250 chars)
${LOC_INPUT_ROLE_NAME}             xpath=//input[@name='roleName']

# Role Description (MD: Name: roleDescription, max 500 chars, optional)
${LOC_INPUT_ROLE_DESCRIPTION}      xpath=//input[@name='roleDescription'] | //textarea[@name='roleDescription']

# Data Masking checkbox (MD: Name: accountCheckbox)
${LOC_CHK_DATA_MASKING}            xpath=//input[@name='accountCheckbox']

# ── Permissions Table (MD: Step 4, Locator Reference) ────────────────

# View permission per screen (MD: CSS class: js-role-view)
${LOC_CHK_VIEW_PERMISSION}         xpath=//input[contains(@class,'js-role-view')]
# Edit permission per screen (MD: CSS class: js-role-edit)
${LOC_CHK_EDIT_PERMISSION}         xpath=//input[contains(@class,'js-role-edit')]
# View All header checkbox (MD: CSS class: js-role-viewheader)
${LOC_CHK_VIEW_ALL}                xpath=//input[contains(@class,'js-role-viewheader')]
# Edit All header checkbox (MD: CSS class: js-role-editheader)
${LOC_CHK_EDIT_ALL}                xpath=//input[contains(@class,'js-role-editheader')]

# Permissions table container
${LOC_PERMISSIONS_TABLE}           xpath=//table[contains(@class,'permission')] | //div[contains(@class,'permission')]//table | //table[.//input[contains(@class,'js-role-view')]]

# ── Permission Popup Modals (MD: Locator Reference → IDs) ───────────
# Permission popup (Tab)
${LOC_PERMISSION_POPUP}            xpath=//*[@id='openPermissionPopup']
# Ticketing popup
${LOC_TICKETING_POPUP}             xpath=//*[@id='openTicketingPopup']
# Notification popup
${LOC_NOTIFICATION_POPUP}          xpath=//*[@id='openNotificationPopup']
# Roles & Triggers popup
${LOC_ROLES_TRIGGERS_POPUP}        xpath=//*[@id='openRolesTriggersPopup']
# Save button inside any popup modal
${LOC_POPUP_SAVE_BTN}              xpath=//div[contains(@class,'modal') and contains(@class,'show')]//button[contains(text(),'Save')]

# ── Form Buttons (MD: Locator Reference → Submit/Update) ────────────
# Submit button (create mode) — Text: 'Submit'
${LOC_BTN_SUBMIT_ROLE}             xpath=//a[contains(text(),'Submit')] | //button[contains(text(),'Submit')]
# Close / Back button
${LOC_BTN_CLOSE_ROLE}              xpath=//a[contains(text(),'Close')] | //button[contains(text(),'Close')] | //a[contains(text(),'Back')]

# ── Search Input on List Page (MD: Locator Reference → Name: searchValue) ──
${LOC_ROLE_SEARCH_INPUT}           xpath=//input[@name='searchValue'] | //input[@placeholder='Enter Search Text']

# ── Delete Button in Grid Row (MD: Locator Reference → Text: Delete) ──
# Template: //tr[.//td[contains(text(),'ROLENAME')]]//button[contains(text(),'Delete')]
${LOC_DELETE_ROLE_TEMPLATE}        //tr[.//td[contains(text(),'PLACEHOLDER')]]//button[contains(text(),'Delete')] | //tr[.//td[contains(text(),'PLACEHOLDER')]]//a[contains(text(),'Delete')]

# ── Confirmation Dialog (MD: TC-ROLE-002 Step 4, Locator Reference → Yes/Confirm) ──
${LOC_DELETE_CONFIRM_DIALOG}       xpath=//div[contains(@class,'confirm-modal')] | //div[contains(@class,'modal') and contains(@class,'show')]
${LOC_DELETE_CONFIRM_BODY}         xpath=//div[contains(@class,'confirm-body')] | //div[contains(@class,'modal-body')]
${LOC_DELETE_CONFIRM_YES}          xpath=//button[contains(text(),'Yes')] | //button[contains(text(),'Confirm')]
${LOC_DELETE_CONFIRM_CANCEL}       xpath=//button[contains(text(),'Cancel')] | //button[contains(text(),'No')]

# ── Toast Notifications ─────────────────────────────────────────────
${LOC_ROLE_TOAST_SUCCESS}          xpath=//*[contains(@class,'toast-success')] | //*[contains(@class,'Toastify__toast--success')]
${LOC_ROLE_TOAST_ERROR}            xpath=//*[contains(@class,'toast-error')] | //*[contains(@class,'Toastify__toast--error')]
${LOC_ROLE_TOAST_MESSAGE}          xpath=//*[contains(@class,'toast-message')] | //*[contains(@class,'Toastify__toast-body')]

# ── Validation Errors ────────────────────────────────────────────────
${LOC_ROLE_VALIDATION_ERROR}       xpath=//*[contains(@class,'alert-danger')] | //*[contains(@class,'error-message')] | //*[contains(@class,'field-validation-error')]

# ── Grid Row for Role (for verification) ─────────────────────────────
${LOC_ROLE_GRID_ROW_TEMPLATE}      //td[contains(text(),'PLACEHOLDER')]
