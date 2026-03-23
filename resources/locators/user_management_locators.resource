*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  USER MANAGEMENT LOCATORS — from TC_Create_And_Delete_User.md
#  All XPaths taken line by line from the MD file
# ══════════════════════════════════════════════════════════════════════

# ── Navigation (MD: Navigation Path) ─────────────────────────────────
# Sidebar Admin icon → lands on ManageUser by default
${LOC_SIDEBAR_ADMIN}              xpath=//i[contains(@class,'admin-menu-icon')]
# User sub-tab in top navigation (ul#pageHeading) — stays on /ManageUser
${LOC_SIDEBAR_USER}               xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageUser')] | //ul[@id='pageHeading']//a[contains(text(),'User')]

# ── Manage User Page (MD: Step 4, Grid Columns) ─────────────────────
${LOC_MANAGE_USER_HEADING}        xpath=//*[contains(text(),'Users')]
${LOC_MANAGE_USER_GRID}           xpath=//div[contains(@class,'k-grid')]
${LOC_MANAGE_USER_PAGINATION}     xpath=//*[contains(@class,'k-pager-wrap')]
${LOC_MANAGE_USER_SEARCH}         xpath=//input[@placeholder='Enter Search Text']

# ── Create User Button (MD: Step 5) ──────────────────────────────────
${LOC_BTN_CREATE_USER}            xpath=//a[@href='/CreateUser'] | //button[contains(text(),'Create User')] | //a[contains(text(),'Create User')]

# ── Create User Form Fields (MD: Form Field Reference + XPaths) ──────

# Account — TreeView Dropdown
# The clickable trigger: try multiple patterns (the actual element varies by page)
${LOC_UM_ACCOUNT_TRIGGER}           xpath=//input[@name='parentAccount'] | //input[@name='accountId'] | //input[contains(@name,'account') or contains(@name,'Account')] | //div[contains(@class,'account-tree-dropdown')] | //label[contains(text(),'Account')]/following-sibling::*//input | //label[contains(text(),'Account')]/parent::*//input
# The treeview container that appears after clicking
${LOC_UM_ACCOUNT_TREEVIEW}          xpath=//div[contains(@id,'showTreeView')] | //div[contains(@class,'k-treeview')]
# Root node expand icon
${LOC_UM_ACCOUNT_ROOT_EXPAND}       xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-i-expand')])[1] | (//div[contains(@class,'k-treeview')]//span[contains(@class,'k-i-expand')])[1]
# Root node text (KSA_OPCO)
${LOC_UM_ACCOUNT_ROOT_NODE}         xpath=(//div[contains(@id,'showTreeView')]//span[contains(@class,'k-in')])[1] | (//div[contains(@class,'k-treeview')]//span[contains(@class,'k-in')])[1]

# Username (MD: Step 7, name='userName', min 5, max 50)
${LOC_INPUT_USERNAME}             xpath=//input[@name='userName']

# First Name (MD: Step 8, name='firstName')
${LOC_INPUT_FIRST_NAME}           xpath=//input[@name='firstName']

# Last Name (MD: Step 9, name='lastName')
${LOC_INPUT_LAST_NAME}            xpath=//input[@name='lastName']

# Primary Phone (MD: Step 10, name='telephoneNumber', min 5, max 16 digits)
${LOC_INPUT_PRIMARY_PHONE}        xpath=//input[@name='telephoneNumber']

# Email Address (MD: Step 11, name='emailId')
${LOC_INPUT_EMAIL}                xpath=//input[@name='emailId']

# Confirm Email Address (MD: Step 12, name='confirmEmailId')
${LOC_INPUT_CONFIRM_EMAIL}        xpath=//input[@name='confirmEmailId']

# User Category (select[@name='userAccountType'])
${LOC_DDL_USER_CATEGORY_SELECT}   xpath=//select[@name='userAccountType']

# Role — Custom dropdown (same component as CSR Journey tariff/customer dropdowns)
# Structure: container div[@data-testid] → selectBtn (trigger) + selectDropdown with option divs
# Primary: CSR-style data-testid container → selectBtn inside (proven pattern)
# Fallback: label-based navigation through form-group
${LOC_ROLE_DD_BTN}                xpath=//div[@data-testid='roleSelectedValueuet' and not(contains(@class,'option'))]//div[contains(@class,'selectBtn')] | //div[contains(@class,'form-group')][.//div[@data-testid='roleSelectedValueuet']]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Role')]/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Role')]/following-sibling::div//div[contains(@class,'selectBtn')]

# Country — Custom dropdown (same pattern)
${LOC_COUNTRY_DD_BTN}             xpath=//div[@data-testid='countrySelectedValueuet' and not(contains(@class,'option'))]//div[contains(@class,'selectBtn')] | //div[contains(@class,'form-group')][.//div[@data-testid='countrySelectedValueuet']]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Country')]/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Country')]/following-sibling::div//div[contains(@class,'selectBtn')]

# Time Zone — Custom dropdown (same pattern)
${LOC_TIMEZONE_DD_BTN}            xpath=//div[@data-testid='timeZoneSelectedValueuet' and not(contains(@class,'option'))]//div[contains(@class,'selectBtn')] | //div[contains(@class,'form-group')][.//div[@data-testid='timeZoneSelectedValueuet']]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Time Zone') or contains(text(),'Timezone')]/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'selectBtn')] | //label[contains(text(),'Time Zone') or contains(text(),'Timezone')]/following-sibling::div//div[contains(@class,'selectBtn')]

# OTP Delivery Channel Checkboxes (MD: Step 16)
${LOC_CHK_SMS}                    xpath=//input[@name='sms'] | //input[@type='checkbox' and contains(@id,'sms')]
${LOC_CHK_EMAIL_OTP}              xpath=//input[@name='email'] | //input[@type='checkbox' and contains(@id,'email')]

# Optional Fields (MD: Form Field Reference — feature-flagged)
${LOC_INPUT_SECONDARY_PHONE}      xpath=//input[@name='secondaryPhone'] | //input[@name='secondaryTelephoneNumber']
${LOC_RADIO_LOCAL_TIME_YES}       xpath=//input[@name='localTime' and @value='true'] | //input[@name='localTime' and @value='Yes']
${LOC_RADIO_LOCAL_TIME_NO}        xpath=//input[@name='localTime' and @value='false'] | //input[@name='localTime' and @value='No']

# ── Form Buttons (MD: Buttons on Create User Form) ───────────────────
# Submit: <a href="javascript:void(0);" class="btn btn-custom-color cursor-pointer width-75">Submit</a>
${LOC_BTN_SUBMIT}                 xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit'] | //a[contains(text(),'Submit') and contains(@class,'btn')] | //button[contains(text(),'Submit')]
# Close: <a class="btn btn-cancel-color width-75" href="/ManageUser">Close</a>
${LOC_BTN_CLOSE_FORM}             xpath=//a[contains(@class,'btn-cancel-color') and normalize-space()='Close'] | //a[contains(text(),'Close') and @href='/ManageUser'] | //button[contains(text(),'Close')]

# ── Validation Errors ────────────────────────────────────────────────
${LOC_VALIDATION_ERROR}           xpath=//*[contains(@class,'alert-danger')] | //*[contains(@class,'error-message')] | //*[contains(@class,'field-validation-error')]
${LOC_TOAST_SUCCESS}              xpath=//*[contains(@class,'toast-success')] | //*[contains(@class,'Toastify__toast--success')] | //*[contains(@class,'toast') and contains(@class,'success')]
${LOC_TOAST_ERROR}                xpath=//*[contains(@class,'toast-error')] | //*[contains(@class,'Toastify__toast--error')] | //*[contains(@class,'toast') and contains(@class,'error')]
${LOC_TOAST_MESSAGE}              xpath=//*[contains(@class,'toast-message')] | //*[contains(@class,'Toastify__toast-body')]

# ── Delete User (MD: TC_002 Steps + Confirmation Dialog Reference) ───
# Delete icon in Action column — icon with title="Delete User"
# Template: //tr[td[contains(text(),'USERNAME')]]//i[@title='Delete User']
${LOC_DELETE_ICON_TEMPLATE}       //tr[td[contains(text(),'PLACEHOLDER')]]//i[@title='Delete User']

# Confirmation Dialog (MD: Confirmation Dialog Reference)
${LOC_DELETE_DIALOG}              xpath=//div[contains(@class,'confirm-modal')] | //div[contains(@class,'modal') and contains(@class,'show')]
${LOC_DELETE_DIALOG_HEADING}      xpath=//div[contains(@class,'confirm-heading')] | //div[contains(@class,'modal-header')]//*[contains(text(),'Delete User')]
${LOC_DELETE_DIALOG_BODY}         xpath=//div[contains(@class,'confirm-body')] | //div[contains(@class,'modal-body')]
${LOC_DELETE_DIALOG_OK}           xpath=//button[contains(text(),'OK')]
${LOC_DELETE_DIALOG_CANCEL}       xpath=//button[contains(text(),'Cancel')]

# ── Grid Row for User (MD: Grid Columns on Manage User Page) ────────
# Used to verify user exists/doesn't exist in grid
# Template: //td[contains(text(),'USERNAME')]
${LOC_GRID_USER_ROW_TEMPLATE}     //td[contains(text(),'PLACEHOLDER')]
