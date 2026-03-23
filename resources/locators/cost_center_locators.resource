*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  NAVIGATION — Admin icon (sidebar) → ManageUser → Account tab → ManageAccount
# ══════════════════════════════════════════════════════════════════════
${LOC_CC_ADMIN_ICON}              xpath=//i[contains(@class,'admin-menu-icon')]
# Account tab in top navigation (ul#pageHeading) — navigates to /ManageAccount
${LOC_NAV_ACCOUNT_TAB}            xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]

# ══════════════════════════════════════════════════════════════════════
#  MANAGE ACCOUNT LISTING PAGE
# ══════════════════════════════════════════════════════════════════════
${LOC_GRID_MANAGE_ACCOUNT}        id=ManageAccountGrid
# Create Cost Center button: <a class="btn btn-custom-color" href="/CreateCostCenter">
${LOC_BTN_CREATE_COST_CENTER}     xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]
# Billing Account row expand icon (first row)
${LOC_BA_EXPAND_ICON}             xpath=//tr[@data-uid][1]//td[contains(@class,'k-hierarchy-cell')]/a
# Cost Center tab (tab9) inside expanded detail row
${LOC_TAB_COST_CENTER}            xpath=//li[@data-name='tab9']
# CostCenter nested grid
${LOC_GRID_COST_CENTER}           id=CostCenterAccount
# Edit button in CostCenter grid
${LOC_CC_GRID_EDIT_BTN}           xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Edit')]
# Delete button in CostCenter grid
${LOC_CC_GRID_DELETE_BTN}         xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Delete')]

# ══════════════════════════════════════════════════════════════════════
#  CREATE COST CENTER FORM
# ══════════════════════════════════════════════════════════════════════
# Parent Account — TreeView Dropdown (custom component, NOT a native <select>)
# Hierarchy: KSA_OPCO (root) → EC Account → BU Account (select this)
# The clickable input that opens the tree
${LOC_DDL_PARENT_ACCOUNT}              xpath=//input[@name='parentAccount']
# The treeview container that appears after clicking the input
${LOC_PARENT_ACCOUNT_TREEVIEW}         xpath=//div[@id='showTreeView-parentAccount']
# Root node expand icon
${LOC_PARENT_ACCOUNT_ROOT_EXPAND}      xpath=//div[@id='showTreeView-parentAccount']//ul[@class='k-treeview-lines']/li[contains(@class,'k-item')][1]/div//span[contains(@class,'k-i-expand')]
# Root node text (KSA_OPCO)
${LOC_PARENT_ACCOUNT_ROOT_NODE}        xpath=//div[@id='showTreeView-parentAccount']//ul[@class='k-treeview-lines']/li[contains(@class,'k-item')][1]//span[contains(@class,'k-in')]

# Account Name input: <input name="accountName" type="text" maxLength=100>
${LOC_INPUT_ACCOUNT_NAME}         xpath=//input[@name='accountName']

# Comment input: <input name="comment" type="text" maxLength=50>
${LOC_INPUT_COMMENT}              xpath=//input[@name='comment']

# Submit button: <input type="button" class="btn btn-custom-color width-75" value="Submit">
${LOC_BTN_SUBMIT}                 xpath=//input[@type='button' and contains(@class,'btn-custom-color')]

# Close button: <a class="btn btn-cancel-color cursor-pointer width-75">
${LOC_BTN_CLOSE}                  xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]

# ══════════════════════════════════════════════════════════════════════
#  VALIDATION ERRORS
# ══════════════════════════════════════════════════════════════════════
# Validation errors use <div class="alert alert-danger"> inside the form-group
${LOC_ERROR_PARENT_ACCOUNT}       xpath=//input[@name='parentAccount']/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'alert-danger')] | //label[contains(text(),'Parent Account')]/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'alert-danger')]
${LOC_ERROR_ACCOUNT_NAME}         xpath=//input[@name='accountName']/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'alert-danger')] | //label[contains(text(),'Account Name')]/ancestor::div[contains(@class,'form-group')]//div[contains(@class,'alert-danger')]

# ══════════════════════════════════════════════════════════════════════
#  TOAST NOTIFICATIONS
# ══════════════════════════════════════════════════════════════════════
${LOC_CC_SUCCESS_TOAST}           xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_CC_ERROR_TOAST}             xpath=//div[contains(@class,'Toastify__toast--error')]
