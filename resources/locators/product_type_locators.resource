*** Variables ***
# ── Loading Overlay ──────────────────────────────────────────────────
${LOC_LOADING_INDICATOR}        xpath=//body[contains(@class,'loading-indicator')]

# ── Navigation Locators (verified from actual HTML) ──────────────────
${LOC_ADMIN_TOGGLE}             xpath=//i[contains(@class,'admin-menu-icon')]
${LOC_PRODUCT_TYPE_NAV}         link=SIM Product Type

# ── Manage User Page (loaded after clicking Admin) ──────────────────
${LOC_MU_GRID_DATA}             id=gridData

# ── Product Type Listing Page (ProductType.js) ──────────────────────
${LOC_PT_GRID_DATA}             id=gridData
${LOC_PT_SEARCH_FIELD}          xpath=//input[@name='searchValue']
${LOC_PT_SEARCH_BTN}            id=searchButton
${LOC_PT_SEARCH_CLOSE}          id=closeBtn
${LOC_PT_CREATE_BTN}            xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create SIM Product Type')]
${LOC_PT_EDIT_ICON}             xpath=//i[contains(@class,'k-grid-Edit')]
${LOC_PT_ASSIGN_CUST_ICON}      xpath=//i[@title='Assign Customers' and contains(@class,'k-grid-Assign-Customer')]

# ── Create Product Type Form (CreateProductType.js) ─────────────────
# Account is a custom dropdown (not native <select>); click to open, then click <div class="option">
${LOC_ACCOUNT_DD}               xpath=//*[@data-testid='accountIdet']
${LOC_ACCOUNT_SEARCH}           xpath=//input[contains(@class,'searchInput') and @placeholder='Search']
${LOC_ACCOUNT_OPTION_KSA}       xpath=//div[@data-testid='accountIdet' and contains(text(),'KSA_OPCO')]

# Service Type: standard <select>
#   <select name="servicetype" data-testid="servicetypeet" class="form-control">
${LOC_PT_SERVICE_TYPE_DD}       xpath=//select[@data-testid='servicetypeet']

${LOC_PT_NAME_INPUT}            xpath=//input[@name='productCatalogName']
${LOC_PT_SUB_TYPE_1_DD}         xpath=//*[@data-testid='serviceSubType1eet']
${LOC_PT_SUB_TYPE_2_INPUT}      xpath=//input[@name='serviceSubType2']
${LOC_PT_SUB_TYPE_3_INPUT}      xpath=//input[@name='serviceSubType3']
${LOC_PT_SUB_TYPE_4_INPUT}      xpath=//input[@name='serviceSubType4']
${LOC_PT_PACKAGING_SIZE}        xpath=//input[@name='packagingSize']
${LOC_PT_COMMENT_INPUT}         xpath=//input[@name='comment']
${LOC_PT_DESC_EN_INPUT}         xpath=//input[@name='descEnglish']
${LOC_PT_SUBMIT_BTN}            xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]
# Close: <a href="javascript:void(0);" class="btn btn-cancel-color cursor-pointer width-75">Close</a>
${LOC_PT_CLOSE_BTN}             xpath=//a[contains(@class,'btn-cancel-color') and contains(.,'Close')]

# ── Assign Customer Dialog (role='dialog') ──────────────────────────
# Modal title
${LOC_ASSIGN_POPUP}                 xpath=//div[@role='dialog']//h4[normalize-space()='Assign Customers']
# Close (X) button in dialog header
${LOC_ASSIGN_CLOSE_X}              xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//button[@type='button' and not(text())]
# Customers dropdown — multiple locator strategies for Kendo widget
${LOC_ASSIGN_SELECT_CUSTOMERS}     xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//input[contains(@class,'k-input') or @placeholder='Select Customers' or @role='listbox']
${LOC_ASSIGN_SELECT_WRAPPER}       xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//*[contains(@class,'k-multiselect-wrap') or contains(@class,'k-dropdown-wrap') or contains(@class,'k-widget')]
# Customers dropdown arrow
${LOC_ASSIGN_DD_ARROW}             xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//*[contains(@class,'k-select')]
# Dropdown list container (appears after clicking Select Customers)
${LOC_ASSIGN_CUSTOMERS_MENU}       xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//ul[contains(@class,'k-list') or contains(@class,'k-reset')]
# First EC option in the dropdown list
${LOC_ASSIGN_CUSTOMER_OPT_1}       xpath=(//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//li[contains(@class,'k-item')])[1]
# "Assign to All Customers" label
${LOC_ASSIGN_ALL_LABEL}            xpath=//div[@role='dialog']//span[normalize-space()='Assign to All Customers']
# Yes radio button
${LOC_ASSIGN_ALL_YES}              xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='Yes']//input[@type='radio']
# No radio button
${LOC_ASSIGN_ALL_NO}               xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='No']//input[@type='radio']
# Update (Assign dialog): <button class="btn btn-custom-color cursor-pointer width-75 m-r-10">Update</button>
# Scoped inside the modal dialog to avoid conflict with Create form's <a> Submit
${LOC_ASSIGN_UPDATE_BTN}           xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-custom-color')]
# Close (Assign dialog): <button class="btn btn-cancel-color cursor-pointer width-75">Close</button>
# Scoped inside the modal dialog to avoid conflict with Create form's <a> Close
${LOC_ASSIGN_CLOSE_BTN}            xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-cancel-color')]

# ── Grid Expand / No Data ──────────────────────────────────────────
# Expand icon (row collapsed): <a class="k-icon k-i-expand">
${LOC_PT_EXPAND_ICON}              xpath=//a[contains(@class,'k-i-expand')]
# Collapse icon (row expanded): <a class="k-icon k-i-collapse">
${LOC_PT_COLLAPSE_ICON}            xpath=//a[contains(@class,'k-i-collapse')]
# No Data Available: <p class="no-data-available dataAvilabel">No Data Available</p>
${LOC_PT_NO_DATA}                  xpath=//p[contains(@class,'no-data-available') and contains(text(),'No Data Available')]

# ── Toast Notifications (Toastify) ──────────────────────────────────
# Created: <div role="alert" class="Toastify__toast-body">SIM Product Type Created Successfully.</div>
${LOC_PT_CREATED_TOAST}         xpath=//div[@role='alert' and contains(text(),'SIM Product Type Created Successfully')]
# Updated: <div role="alert" class="Toastify__toast-body">Updated Successfully</div>
${LOC_PT_UPDATED_TOAST}         xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]
# Duplicate: <div role="alert" class="Toastify__toast-body">Product Type Name Already Exists</div>
${LOC_PT_DUPLICATE_TOAST}       xpath=//div[@role='alert' and contains(text(),'Product Type Name Already Exists')]
# No EC selected: <div role="alert" class="Toastify__toast-body">Please select at least one customer</div>
${LOC_PT_NO_EC_TOAST}           xpath=//div[@role='alert' and contains(text(),'Please select at least one customer')]
# Error: any Toastify error toast
${LOC_PT_ERROR_TOAST}           xpath=//div[@role='alert' and (contains(text(),'error') or contains(text(),'Error') or contains(text(),'Already Exists') or contains(text(),'Please select'))]
# Generic success (fallback)
${LOC_PT_SUCCESS_TOAST}         xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]
