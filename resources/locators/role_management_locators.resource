*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  ROLE MANAGEMENT LOCATORS — from role_create_delete.md
#  All identifiers taken line by line from the Locator Reference table
# ══════════════════════════════════════════════════════════════════════

# ── Navigation (MD: Locator Reference → Admin, Role & Access) ────────
# Admin sidebar icon (same as User Management — <i class="admin-menu-icon">)
${LOC_RM_SIDEBAR_ADMIN}            xpath=//i[contains(@class,'admin-menu-icon')]
# Role & Access sub-tab: <a href="/ManageRole">Role &amp; Access</a>
${LOC_RM_ROLE_ACCESS_TAB}          xpath=//a[@href='/ManageRole'] | //a[contains(@href,'/ManageRole')]

# ── Manage Role Page (MD: Step 1.2) ─────────────────────────────────
${LOC_ROLE_GRID}                   xpath=//div[contains(@class,'k-grid')]
${LOC_ROLE_GRID_COLUMN_HEADER}     xpath=//th[@role='columnheader']
${LOC_ROLE_GRID_PAGINATION}        xpath=//*[contains(@class,'k-pager-wrap')]

# ── Create Role Button (MD: Locator Reference → CSS .btn-custom-color, Text: Create Role) ──
${LOC_BTN_CREATE_ROLE}             xpath=//a[contains(@href,'/CreateRole')] | //a[contains(text(),'Create Role')] | //a[contains(@class,'btn-custom-color') and contains(text(),'Create')]

# ── Breadcrumb (MD: Step 2.3 — "Role & Access > Create") ────────────
${LOC_BREADCRUMB_CREATE}           xpath=//*[contains(text(),'Create')] | //li[contains(@class,'breadcrumb') and contains(text(),'Create')]

# ── Create Role Form Fields (MD: Locator Reference table) ────────────

# Account — TreeView Dropdown (MD: Name: accountId / accountName)
${LOC_ROLE_ACCOUNT_DROPDOWN}       xpath=//input[@name='accountName'] | //input[@name='accountId'] | //div[contains(@class,'TreeViewDropdown')]//input
${LOC_ROLE_ACCOUNT_TREE}           xpath=//div[contains(@id,'showTreeView')] | //div[contains(@class,'k-treeview')] | //ul[contains(@class,'k-treeview')]
${LOC_ROLE_ACCOUNT_FIRST_NODE}     xpath=(//div[contains(@class,'k-treeview')]//span[contains(@class,'k-in')] | //ul[contains(@class,'k-treeview')]//li//span[contains(@class,'k-in')])[1]
# TreeView expansion — root expand icon
${LOC_ROLE_TREE_ROOT_EXPAND}       xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-i-expand')])[1] | (//div[contains(@class,'k-treeview')]//span[contains(@class,'k-i-expand')])[1]
# TreeView root node text
${LOC_ROLE_TREE_ROOT_NODE}         xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-in')])[1] | (//div[contains(@class,'k-treeview')]//span[contains(@class,'k-in')])[1]

# Role Name (MD: Name: roleName, max 250 chars)
${LOC_INPUT_ROLE_NAME}             xpath=//input[@name='roleName']

# Role Description (MD: Name: roleDescription, max 500 chars, optional)
${LOC_INPUT_ROLE_DESCRIPTION}      xpath=//input[@name='roleDescription'] | //textarea[@name='roleDescription']

# Data Masking checkbox (MD: Name: accountCheckbox)
${LOC_CHK_DATA_MASKING}            xpath=//input[@name='accountCheckbox']

# ── Permissions Table (MD: Step 4, Locator Reference) ────────────────
# DOM: js-role-view / js-role-edit are NAME attributes, not CSS classes

# View permission per screen (name='js-role-view')
${LOC_CHK_VIEW_PERMISSION}         xpath=//input[@name='js-role-view']
# Edit permission per screen (name='js-role-edit')
${LOC_CHK_EDIT_PERMISSION}         xpath=//input[@name='js-role-edit']
# View All header checkbox (name='js-role-viewheader')
${LOC_CHK_VIEW_ALL}                xpath=//input[@name='js-role-viewheader']
# Edit All header checkbox (name='js-role-editheader')
${LOC_CHK_EDIT_ALL}                xpath=//input[@name='js-role-editheader']

# Permissions wrapper: div.gc-module-selector-wrapper
${LOC_PERMISSIONS_TABLE}           xpath=//div[contains(@class,'gc-module-selector-wrapper')]
# Individual module tables inside the wrapper
${LOC_PERMISSIONS_MODULE_TABLE}    xpath=//table[contains(@class,'gc-module-selector-table')]

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
# Submit: <a href="javascript:void(0);" class="btn btn-custom-color cursor-pointer pull-right m-r-10 width-75">Submit</a>
${LOC_BTN_SUBMIT_ROLE}             xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit'] | //a[contains(text(),'Submit') and contains(@class,'btn')] | //button[contains(text(),'Submit')]
# Close: often <input type="button" class="btn-cancel-color" value="Close"> (see Label module); legacy <a> still supported
${LOC_BTN_CLOSE_ROLE}              xpath=//input[@type='button' and contains(@class,'btn-cancel-color') and @value='Close'] | //input[@type='submit' and contains(@class,'btn-cancel-color') and @value='Close'] | //a[contains(@class,'btn-cancel-color') and normalize-space()='Close'] | //a[contains(text(),'Close') and contains(@href,'ManageRole')] | //button[normalize-space()='Close'] | //a[normalize-space()='Close'] | //button[contains(normalize-space(.),'Close')]

# ── Search Input on List Page (MD: Locator Reference → Name: searchValue) ──
${LOC_ROLE_SEARCH_INPUT}           xpath=//input[@name='searchValue'] | //input[@placeholder='Enter Search Text']

# Optional filter inside Account TreeView panel (Kendo / SIM Order pattern)
${LOC_ROLE_ACCOUNT_TREE_SEARCH}    xpath=//div[contains(@id,'showTreeView')]//input[contains(@class,'search-textbox') or contains(@class,'inputtree')] | //div[contains(@class,'account-tree-dropdown')]//input[contains(@class,'search-textbox') or contains(@class,'inputtree')]

# ── Delete Button in Grid Row — Kendo icon link, FA trash, or title Delete/delete ──
# Template: row contains PLACEHOLDER in a td; action column may be <a class="k-grid-Delete"> or <i title="Delete">
${LOC_DELETE_ROLE_TEMPLATE}        //tr[.//td[contains(.,'PLACEHOLDER')]]//*[contains(@class,'k-grid-Delete') or contains(@class,'k-delete') or contains(@class,'fa-trash')][1] | //tr[.//td[contains(.,'PLACEHOLDER')]]//*[@title='Delete' or @title='delete' or contains(translate(@title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'delete')][1]

# ── Confirmation Dialog (MD: TC-ROLE-002 Step 4, Locator Reference → Yes/Confirm) ──
${LOC_DELETE_CONFIRM_DIALOG}       xpath=//div[contains(@class,'confirm-modal')] | //div[contains(@class,'modal') and contains(@class,'show')]
${LOC_DELETE_CONFIRM_BODY}         xpath=//div[contains(@class,'confirm-body')] | //div[contains(@class,'modal-body')]
${LOC_DELETE_CONFIRM_YES}          xpath=//button[normalize-space()='OK'] | //button[contains(text(),'Yes')] | //button[contains(text(),'Confirm')]
${LOC_DELETE_CONFIRM_CANCEL}       xpath=//button[contains(text(),'Cancel')] | //button[contains(text(),'No')]

# ── Toast Notifications ─────────────────────────────────────────────
${LOC_ROLE_TOAST_SUCCESS}          xpath=//*[contains(@class,'toast-success')] | //*[contains(@class,'Toastify__toast--success')]
${LOC_ROLE_TOAST_ERROR}            xpath=//*[contains(@class,'toast-error')] | //*[contains(@class,'Toastify__toast--error')]
${LOC_ROLE_TOAST_MESSAGE}          xpath=//*[contains(@class,'toast-message')] | //*[contains(@class,'Toastify__toast-body')]

# ── Validation Errors ────────────────────────────────────────────────
${LOC_ROLE_VALIDATION_ERROR}       xpath=//*[contains(@class,'alert-danger')] | //*[contains(@class,'error-message')] | //*[contains(@class,'field-validation-error')]

# ── Grid Row for Role (for verification) ─────────────────────────────
${LOC_ROLE_GRID_ROW_TEMPLATE}      //td[contains(text(),'PLACEHOLDER')]
