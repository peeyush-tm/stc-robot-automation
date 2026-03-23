*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  LIVE ORDER PAGE — /LiveOrder
# ══════════════════════════════════════════════════════════════════════

# ── Sidebar Navigation ──────────────────────────────────────────────
${LOC_SO_ORDERS_MENU}              xpath=//a[@id='orders']
${LOC_SO_SUB_LIVE_ORDER}           xpath=//a[@id='orders']/parent::li//ul[contains(@class,'sub')]//a[@href='/LiveOrder']
${LOC_SO_SUB_ORDER_HISTORY}        xpath=//a[@id='orders']/parent::li//ul[contains(@class,'sub')]//a[@href='/OrderHistory']

# ── Page Tab Navigation ─────────────────────────────────────────────
${LOC_SO_TAB_LIVE_ORDER}           xpath=//ul[@id='pageHeading']//a[@href='/LiveOrder']
${LOC_SO_TAB_ORDER_HISTORY}        xpath=//ul[@id='pageHeading']//a[@href='/OrderHistory']

# ── Toolbar ─────────────────────────────────────────────────────────
${LOC_SO_SEARCH_INPUT}             xpath=//input[@name='searchValue']
${LOC_SO_SEARCH_BTN}               xpath=//a[@id='searchButton']
${LOC_SO_CREATE_ORDER_BTN}         xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Create SIM Order']
${LOC_SO_DOWNLOAD_CSV_BTN}         xpath=//div[@id='downloadCSVSIMOrder']

# ── Kendo Grid — #simOrderGrid ──────────────────────────────────────
${LOC_SO_GRID}                     xpath=//div[@id='simOrderGrid']
${LOC_SO_GRID_ROWS}                xpath=//div[@id='simOrderGrid']//tbody/tr[contains(@class,'k-master-row')]
${LOC_SO_GRID_FIRST_ROW}           xpath=//div[@id='simOrderGrid']//tbody/tr[contains(@class,'k-master-row')][1]

# ── Row Action Buttons (first row) ──────────────────────────────────
${LOC_SO_ROW_CANCEL_BTN}           xpath=//div[@id='simOrderGrid']//tbody/tr[1]//a[contains(@class,'k-grid-Delete') and contains(@class,'printOrderdelete')]
${LOC_SO_ROW_DOWNLOAD_BTN}         xpath=//div[@id='simOrderGrid']//tbody/tr[1]//a[contains(@class,'k-grid-Edit') and contains(@class,'printOrderprint')]
${LOC_SO_ROW_FAIL_BTN}             xpath=//div[@id='simOrderGrid']//tbody/tr[1]//a[contains(@class,'k-grid-Fail')]
${LOC_SO_ROW_RETRY_BTN}            xpath=//div[@id='simOrderGrid']//tbody/tr[1]//a[contains(@class,'k-grid-Retry')]
${LOC_SO_ROW_EXPAND_BTN}           xpath=//div[@id='simOrderGrid']//tbody/tr[1]//td[contains(@class,'k-hierarchy-cell')]/a

# ── Cancel Order Modal — #savePopup ─────────────────────────────────
${LOC_SO_CANCEL_MODAL}             xpath=//div[@id='savePopup']
${LOC_SO_CANCEL_MODAL_TITLE}       xpath=//div[@id='savePopup']//h4[contains(@class,'modal-title')]
${LOC_SO_CANCEL_REASON_INPUT}      xpath=//input[@name='cancelReason']
${LOC_SO_CANCEL_REMARKS_TEXTAREA}  xpath=//textarea[@id='cancelRemarks']
${LOC_SO_CANCEL_PROCEED_BTN}       xpath=//button[@id='prceedBtn']
${LOC_SO_CANCEL_CLOSE_BTN}         xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]
${LOC_SO_CANCEL_CLOSE_X}           xpath=//div[@id='savePopup']//button[contains(@class,'close')]

# ── Pagination ──────────────────────────────────────────────────────
${LOC_SO_PAGE_INFO}                xpath=//span[contains(@class,'k-pager-info')]

# ── Status Legend ───────────────────────────────────────────────────
${LOC_SO_LEGEND}                   xpath=//ul[contains(@class,'legent_style')]

# ══════════════════════════════════════════════════════════════════════
#  CREATE SIM ORDER PAGE — /CreateSIMOrder
# ══════════════════════════════════════════════════════════════════════

# ── Breadcrumb ──────────────────────────────────────────────────────
${LOC_SO_BC_LIVE_ORDER}            xpath=//ul[contains(@class,'breadcrumb')]//a[@href='/LiveOrder']
${LOC_SO_BC_CREATE}                xpath=//ul[contains(@class,'breadcrumb')]//li[normalize-space()='Create']

# ── Wizard Step Navigator ───────────────────────────────────────────
${LOC_SO_WIZARD_CONTAINER}         xpath=//section[@id='process-tab']
${LOC_SO_STEP1_LI}                 xpath=//li[@id='order']
${LOC_SO_STEP1_LINK}               xpath=//a[@id='orderDetails']
${LOC_SO_STEP2_LI}                 xpath=//li[@id='shipping']
${LOC_SO_STEP2_LINK}               xpath=//a[@id='shippingDetails']
${LOC_SO_STEP3_LI}                 xpath=//li[@id='preview']
${LOC_SO_STEP3_LINK}               xpath=//a[@id='previewDetails']
${LOC_SO_STEP1_PANE}               xpath=//div[@id='discover']
${LOC_SO_STEP2_PANE}               xpath=//div[@id='strategy']
${LOC_SO_STEP3_PANE}               xpath=//div[@id='optimization']

# ── Step 1: Order Details (#discover) ───────────────────────────────
${LOC_SO_STEP1_HEADING}            xpath=//div[@id='discover']//h4[normalize-space()='Order Details']
${LOC_SO_SIM_REPLACEMENT_YES}      xpath=//div[@id='discover']//input[@name='isBlank' and @value='true']
${LOC_SO_SIM_REPLACEMENT_NO}       xpath=//div[@id='discover']//input[@name='isBlank' and @value='false']
${LOC_SO_ACCOUNT_INPUT}            xpath=//input[@name='accountSelected']
${LOC_SO_ACCOUNT_TREEVIEW_SEARCH}  xpath=//input[contains(@class,'search-textbox') and contains(@class,'inputtree')]
${LOC_SO_ACCOUNT_TREEVIEW}         xpath=//div[@id='discover']//div[contains(@class,'k-widget k-treeview')]
${LOC_SO_SIM_CATEGORY_CONTAINER}   xpath=//div[@data-testid='orderSimCategory' and contains(@class,'select')]
${LOC_SO_SIM_CATEGORY_BTN}         xpath=//div[@data-testid='orderSimCategory']//div[contains(@class,'selectBtn')]
${LOC_SO_SIM_TYPE_SELECT}          xpath=//select[@name='simType']
${LOC_SO_SIM_PRODUCT_CONTAINER}    xpath=//div[@data-testid='productCatalog' and contains(@class,'select')]
${LOC_SO_SIM_PRODUCT_BTN}          xpath=//div[@data-testid='productCatalog']//div[contains(@class,'selectBtn')]
${LOC_SO_QUANTITY_INPUT}           xpath=//input[@name='quantity' and @type='number']
${LOC_SO_ORDER_ID_INPUT}           xpath=//input[@name='orderId']
${LOC_SO_DELIVERY_DATE_INPUT}      id=deliveryDateInput
${LOC_SO_ACTIVATION_AUTO}          xpath=//input[@name='activationOption' and @value='autoActivation']
${LOC_SO_ACTIVATION_MANUAL}        xpath=//input[@name='activationOption' and @value='nonAutoActivation']
${LOC_SO_SIM_STATE_CONTAINER}      xpath=//div[@data-testid='simState' and contains(@class,'select')]
${LOC_SO_SIM_STATE_BTN}            xpath=//div[@data-testid='simState']//div[contains(@class,'selectBtn')]
${LOC_SO_DEVICE_PLAN_SELECT}       xpath=//*[@data-testid='selectPlacnpdert']
${LOC_SO_SERVICE_PLAN_SELECT}      xpath=//*[@data-testid='servicePlan']
${LOC_SO_BTN_STEP1_NEXT}           xpath=//div[@id='discover']//a[@href='#strategy']

# ── Step 2: Shipping Details (#strategy) ────────────────────────────
${LOC_SO_STEP2_HEADING}            xpath=//div[@id='strategy']//h4[normalize-space()='Shipping Details']
${LOC_SO_ADDRESS_LINE1}            xpath=//input[@name='addressLine1']
${LOC_SO_ADDRESS_LINE2}            xpath=//input[@name='addressLine2']
${LOC_SO_COUNTRY_CONTAINER}        xpath=//div[@data-testid='countryname' and contains(@class,'select')]
${LOC_SO_COUNTRY_BTN}              xpath=//div[@data-testid='countryname']//div[contains(@class,'selectBtn')]
${LOC_SO_COUNTRY_SEARCH}           xpath=//div[@data-testid='countryname']/parent::div//input[@class='searchInput']
${LOC_SO_AREA_INPUT}               xpath=//input[@name='state']
${LOC_SO_CITY_INPUT}               xpath=//input[@name='city']
${LOC_SO_POSTAL_CODE_INPUT}        xpath=//input[@name='pinCode']
${LOC_SO_BILLING_NAME_INPUT}       xpath=//input[@name='billingContactName']
${LOC_SO_EMAIL_INPUT}              xpath=//input[@name='emailAddress']
${LOC_SO_PRIMARY_PHONE_INPUT}      xpath=//input[@name='primaryPhone']
${LOC_SO_SECONDARY_PHONE_INPUT}    xpath=//input[@name='secondaryPhone']
${LOC_SO_BTN_STEP2_PREV}           xpath=//div[@id='strategy']//a[@href='#discover']
${LOC_SO_BTN_STEP2_NEXT}           xpath=//div[@id='strategy']//a[@href='#optimization']

# ── Step 3: Preview / Order Summary (#optimization) ─────────────────
${LOC_SO_STEP3_HEADING}            xpath=//div[@id='optimization']//h4[normalize-space()='Order Summary']
${LOC_SO_PREVIEW_SHIPPING}         xpath=//div[@id='optimization']//div[contains(@class,'shippingdetailsdiv')]
${LOC_SO_PREVIEW_ORDER}            xpath=//div[@id='optimization']//div[contains(@class,'shippingdetailsdivoderdtilas')]
${LOC_SO_TC_CHECKBOX}              xpath=//input[@id='termsAndConditions' and @type='checkbox']
${LOC_SO_BTN_STEP3_PREV}           xpath=//div[@id='optimization']//a[@href='#strategy']
${LOC_SO_BTN_SUBMIT}               xpath=//div[@id='optimization']//a[normalize-space()='Submit']
${LOC_SO_BTN_CLOSE}                xpath=//div[@id='optimization']//a[@href='/LiveOrder' and contains(@class,'btn-cancel-color')]

# ── Terms & Conditions Modal ────────────────────────────────────────
${LOC_SO_TC_MODAL}                 xpath=//div[@id='termsConditionsPopup']
${LOC_SO_TC_MODAL_CONTINUE}        xpath=//button[@id='prceedBtnGeneralAPN']
${LOC_SO_TC_MODAL_CANCEL}          xpath=//div[@id='termsConditionsPopup']//button[contains(@class,'btn-cancel-color')]

# ── Post-Submission / Toasts ────────────────────────────────────────
${LOC_SO_TOAST_SUCCESS}            xpath=//div[contains(@class,'toast-success') or contains(@class,'Toastify__toast--success')]
${LOC_SO_TOAST_ERROR}              xpath=//div[contains(@class,'toast-error') or contains(@class,'Toastify__toast--error')]
${LOC_SO_ALERT_DANGER}             xpath=//div[contains(@class,'alert-danger')]
