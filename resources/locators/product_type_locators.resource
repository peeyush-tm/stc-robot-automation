*** Variables ***
# ── Navigation (left sidebar → Admin icon → SIM Product Type link) ────────────
${LOC_ADMIN_ICON}             xpath=//i[contains(@class,'admin-menu-icon')]
${LOC_PRODUCT_TYPE_NAV}       link=SIM Product Type

# ── Product Type Listing Page (ProductType.js) ───────────────────────────────
${LOC_PT_GRID}                id=grid
${LOC_PT_GRID_DATA}           id=gridData
${LOC_PT_SEARCH_FIELD}        xpath=//input[@name='searchValue']
${LOC_PT_SEARCH_BTN}          id=searchButton
${LOC_PT_SEARCH_CLOSE}        id=closeBtn
${LOC_PT_EXPORT_CSV}          id=export
${LOC_CREATE_PT_BTN}          xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create SIM Product Type')]
# Grid row action icons (jQuery-injected by dataBound)
${LOC_EDIT_ICON}              xpath=//i[contains(@class,'k-grid-Edit')]
${LOC_DELETE_ICON}            xpath=//i[contains(@class,'k-grid-Delete')]
${LOC_ASSIGN_CUST_ICON}       xpath=//i[contains(@class,'k-grid-Assign-Customer')]
${LOC_EDIT_POPUP}             id=EditPopup
${LOC_DELETE_POPUP}           id=DeletePopup

# ── Create Product Type Form (/CreateProductType — CreateProductType.js) ──────
# Account is a custom dropdown (not native <select>); click to open, then click <div class="option">
${LOC_ACCOUNT_DD}             xpath=//*[@data-testid='accountIdet']
${LOC_ACCOUNT_SEARCH}         xpath=//input[contains(@class,'searchInput') and @placeholder='Search']
${LOC_ACCOUNT_OPTION_KSA}     xpath=//div[@data-testid='accountIdet' and contains(text(),'KSA_OPCO')]
${LOC_PT_NAME_INPUT}          xpath=//input[@name='productCatalogName']
${LOC_SERVICE_TYPE_DD}        xpath=//*[@data-testid='servicetypeet']
${LOC_SUB_TYPE_1_DD}          xpath=//*[@data-testid='serviceSubType1eet']
${LOC_SUB_TYPE_2_INPUT}       xpath=//input[@name='serviceSubType2']
${LOC_SUB_TYPE_3_INPUT}       xpath=//input[@name='serviceSubType3']
${LOC_SUB_TYPE_4_INPUT}       xpath=//input[@name='serviceSubType4']
${LOC_PROFILE_NAME}           xpath=//input[@name='profileName']
${LOC_PACKAGING_SIZE}         xpath=//input[@name='packagingSize']
${LOC_CAN_ORDER_YES}          xpath=//input[@type='radio' and @name='canBeOrdered' and @value='true']
${LOC_CAN_ORDER_NO}           xpath=//input[@type='radio' and @name='canBeOrdered' and @value='false']
${LOC_COMMENT_INPUT}          xpath=//input[@name='comment']
${LOC_DESC_EN_INPUT}          xpath=//input[@name='descEnglish']
${LOC_DESC_AR_INPUT}          xpath=//input[@name='descArabic']
# Submit/Close are <a> tags, NOT <button>; use Click Element, not Submit Form
${LOC_SUBMIT_BTN}             xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]
${LOC_CLOSE_BTN}              xpath=//a[contains(@class,'btn-cancel-color') and contains(.,'Close')]

# ── Assign Customer Popup (#AssignCustomerPopup) ─────────────────────────────
${LOC_ASSIGN_POPUP}           xpath=//*[@id='AssignCustomerPopup']
${LOC_ASSIGN_TITLE}           xpath=//*[@id='AssignCustomerPopup']//h4[contains(@class,'modal-title')]
${LOC_ASSIGN_X_BTN}           xpath=//*[@id='AssignCustomerPopup']/div[1]/div[1]/div[1]/button[1]
${LOC_CUSTOMERS_INPUT}        xpath=//*[@id='react-select-3-input']
${LOC_CUSTOMERS_DD_CTRL}      xpath=//div[contains(@class,'select__control')]
${LOC_CUSTOMERS_MENU}         xpath=//div[contains(@class,'select__menu')]
${LOC_CUSTOMER_OPT_1}         xpath=(//div[contains(@class,'select__option')])[1]
${LOC_SEL_ALL_YES}            xpath=//*[@id='AssignCustomerPopup']//input[@name='selectAllCustomers'][@value='true']
${LOC_SEL_ALL_NO}             xpath=//*[@id='AssignCustomerPopup']//input[@name='selectAllCustomers'][@value='false']
${LOC_ASSIGN_UPDATE_BTN}      xpath=//*[@id='customers']/div[1]/button[1]
${LOC_ASSIGN_CLOSE_BTN}       xpath=//*[@id='customers']/div[1]/button[2]

# ── Loading Overlay ──────────────────────────────────────────────────────────
${LOC_LOADING_OVERLAY}        xpath=//body[contains(@class,'loading-indicator')]

# ── Post-Submission (Toastify) ────────────────────────────────────────────────
${LOC_SUCCESS_TOAST}          xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]
${LOC_PT_CREATED_TOAST}       xpath=//div[@role='alert' and contains(text(),'SIM Product Type Created Successfully')]
${LOC_PT_UPDATED_TOAST}       xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]
${LOC_ERROR_TOAST}            xpath=//div[contains(@class,'Toastify__toast-body') and contains(text(),'error') or contains(text(),'Error')]
