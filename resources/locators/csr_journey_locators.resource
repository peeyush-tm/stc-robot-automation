*** Variables ***
# ── Loading Overlay ──────────────────────────────────────────────────
${LOC_LOADING_INDICATOR}        xpath=//body[contains(@class,'loading-indicator')]

# ── Navigation (Admin → CSR Journey) ─────────────────────────────────
${LOC_ADMIN_ICON}               xpath=//i[contains(@class,'admin-menu-icon')]
# Listing only (exclude Create); href may be ``/CSRJourney`` or hash-router variant
${LOC_CSR_JOURNEY_NAV}          xpath=//ul[@id='pageHeading']//a[contains(@href,'CSRJourney') and not(contains(@href,'Create'))]
${LOC_CSR_JOURNEY_NAV_SIDEBAR}  xpath=//a[contains(@href,'CSRJourney') and not(contains(@href,'Create'))][not(ancestor::ul[@id='pageHeading'])]

# ── CSR Journey Landing Page ─────────────────────────────────────────
# Select Customer: custom dropdown (div-based)
${LOC_CSRJ_CUSTOMER_DD_BTN}     xpath=//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectBtn')][1]
${LOC_CSRJ_CUSTOMER_DD_LIST}    xpath=//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectDropdown')][1]
${LOC_CSRJ_CUSTOMER_SEARCH}     xpath=//div[contains(@class,'selectcsrjourney')]//input[contains(@class,'searchInput')][1]
# Customer option: div name="customerId" data-testid="customerId" class="option select"
${LOC_CSRJ_CUSTOMER_OPTION}     xpath=//div[@name="customerId" and @data-testid="customerId" and contains(@class,"option")]
# Select Business Unit: click this div to open BU dropdown (then options with data-testid="bussinessUnit" become visible)
# Button: <div class="selectBtn form-control show" value="29300">billingAccountSANJ_1003</div>
# Second select inside CSR widget only (global [2] can hit a different module's react-select)
${LOC_CSRJ_BU_DD_BTN}           xpath=(//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectBtn')])[2]
# After customer is chosen, the customer menu closes — often only ONE selectDropdown remains; [2] never appears.
${LOC_CSRJ_BU_DD_LIST}          xpath=(//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectDropdown')])[last()]
${LOC_CSRJ_BU_SEARCH}           xpath=(//div[contains(@class,'selectcsrjourney')]//input[contains(@class,'searchInput')])[last()]
# BU option (visible after clicking BU button): select this account - div name="bussinessUnit" data-testid="bussinessUnit" class="option select" value="29300"
${LOC_CSRJ_BU_OPTION}           xpath=//div[@name="bussinessUnit" and @data-testid="bussinessUnit" and contains(@class,"option")]
# Create Order button: <button type="button" class="btn btn-custom-color pull-right width-75">Create Order</button>
${LOC_CSRJ_CREATE_ORDER_BTN}    xpath=//button[@type="button" and contains(@class,"btn-custom-color") and contains(@class,"pull-right") and normalize-space()="Create Order"]
# APN / Device Plan table — multiple ``#gridData`` nodes can exist; [1] is not always the visible CSR device-plan grid. Keywords poll + header wait.
${LOC_CSRJ_APN_TABLE}           xpath=(//*[@id='gridData'])[1]//table
${LOC_CSRJ_APN_TABLE_ALT2}      xpath=(//*[@id='gridData'])[2]//table
${LOC_CSRJ_APN_TABLE_LEGACY}    xpath=//table[contains(@class,'col-md-12')]
${LOC_CSRJ_APN_TABLE_BODY}      xpath=(//*[@id='gridData'])[1]//tbody
${LOC_CSRJ_APN_TABLE_BODY_ALT2}      xpath=(//*[@id='gridData'])[2]//tbody
${LOC_CSRJ_APN_TABLE_BODY_LEGACY}    xpath=//table[contains(@class,'col-md-12')]//tbody
${LOC_CSRJ_APN_HEADER_APNTYPE}    xpath=//th[contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'apn type')]
${LOC_CSRJ_APN_ROW_1}           xpath=(//*[@id='gridData'])[1]//tbody/tr[1]
# Filled at runtime by ``CSRJ Discover Device Plan Table Locators`` (CSRJ Wait For Landing Apn Table Visible / conflict flow)
${CSRJ_RUN_DEVICE_PLAN_TABLE}    ${EMPTY}
${CSRJ_RUN_DEVICE_PLAN_TBODY}    ${EMPTY}
# Set by ``CSRJ Evaluate Optional Skip Landing Grids By Env`` when ``CSRJ_ALLOW_EMPTY_DEVICE_GRID`` and landing is otherwise ready
${CSRJ_LANDING_GRIDS_OPTIONAL}    ${FALSE}
# Grid action icons
${LOC_CSRJ_CSR_SUMMARY_ICON}    xpath=//i[contains(@class,'k-grid-csrSummary')]
${LOC_CSRJ_EDIT_ICON}           xpath=//i[contains(@class,'k-grid-editNodeKendoPopup') and not(contains(@class,'csrSummary'))]
${LOC_CSRJ_DELETE_ICON}         xpath=//i[contains(@class,'k-grid-deleteNodeKendoPopup')]
${LOC_CSRJ_CHANGE_TP_ICON}      xpath=//i[contains(@class,'k-grid-changeTPNodeKendoPopup')]
# Main CSR grid — prefer Kendo #gridData (layout varies; csrjourneydev wrapper is not always under content/div[2])
${LOC_CSRJ_GRID}                xpath=(//*[@id='gridData'])[1]
# Row by device plan alias: use in keyword with Replace String to inject alias
${LOC_CSRJ_GRID_ROW_DELETE_BY_ALIAS}   xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row') and contains(.,'ALIAS_PLACEHOLDER')]//i[contains(@class,'k-grid-deleteNodeKendoPopup')]
${LOC_CSRJ_GRID_ROW_EDIT_BY_ALIAS}     xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row') and contains(.,'ALIAS_PLACEHOLDER')]//i[contains(@class,'k-grid-editNodeKendoPopup')]
# Delete confirmation modal (Kendo or generic)
${LOC_CSRJ_DELETE_CONFIRM_BTN}  xpath=//div[contains(@class,'k-window') or contains(@role,'dialog')]//button[normalize-space()='Delete' or normalize-space()='OK' or contains(@class,'k-primary')]
# Usage Based Charges grid
${LOC_CSRJ_USAGE_GRID}          xpath=//*[@id='UsageBaseCharges']
${LOC_CSRJ_USAGE_ROW_1}         xpath=//*[@id='UsageBaseCharges']//tbody/tr[1]
# Order Transaction History grid
${LOC_CSRJ_TXN_GRID}            xpath=(//*[@id='gridData'])[2]
${LOC_CSRJ_TXN_ROW_1}           xpath=(//*[@id='gridData'])[2]//tbody/tr[1]
# Order Summary heading
${LOC_CSRJ_ORDER_SUMMARY_HEADING}  xpath=//h4[normalize-space()='Order Summary']

# ── Create CSR Journey: Wizard Step Indicators ───────────────────────
${LOC_STEP_STANDARD}             xpath=//div[contains(@class,'flex-center') and contains(@class,'mt-40')]//p[normalize-space()='Standard Services']
${LOC_STEP_ADDITIONAL}           xpath=//div[contains(@class,'flex-center') and contains(@class,'mt-40')]//p[normalize-space()='Additional Services']
${LOC_STEP_ORDER_SUMMARY}        xpath=//div[contains(@class,'flex-center') and contains(@class,'mt-40')]//p[normalize-space()='Order Summary']

# ── Breadcrumb ───────────────────────────────────────────────────────
${LOC_BREADCRUMB_TP_SELECTION}   xpath=//div[contains(@class,'breadcrumb-page')]/span[1]
${LOC_BREADCRUMB_STANDARD}       xpath=//div[contains(@class,'breadcrumb-page')]//span[normalize-space()='Standard Services']
${LOC_BREADCRUMB_ADDITIONAL}     xpath=//div[contains(@class,'breadcrumb-page')]//span[normalize-space()='Additional Services']
${LOC_BREADCRUMB_SUMMARY}        xpath=//div[contains(@class,'breadcrumb-page')]//span[normalize-space()='Summary']

# ══════════════════════════════════════════════════════════════════════
#  STEP 1: STANDARD SERVICES
# ══════════════════════════════════════════════════════════════════════
# + Add button (Standard Services — add new device plan row in edit): <button class="add_button mb-5 padding-0 ">+ Add</button>
${LOC_SS_ADD_BTN}                xpath=//button[contains(@class,'add_button') and normalize-space(.)='+ Add']
# Tariff Plan: div name="tariffplan" data-testid="tariffplan" class="option" value="29955"
${LOC_SS_TARIFF_PLAN_DD}         xpath=//div[@data-testid="tariffplan"]//div[contains(@class,"selectBtn")]
${LOC_SS_TARIFF_PLAN_SEARCH}     xpath=//div[contains(@class,'form-group')][.//label[normalize-space()='Tariff Plan']]//input[contains(@class,'searchInput')]
${LOC_SS_TARIFF_PLAN_OPTION}     xpath=//div[@name="tariffplan" and @data-testid="tariffplan" and contains(@class,"option")]
# APN Type: <select name="apnCategory" data-testid="apnCategory" class="form-control">
${LOC_SS_APN_TYPE_DD}            xpath=//select[@name="apnCategory" and @data-testid="apnCategory"]
# Add APNs button — label/case varies: Add APN's, Add APNs, ADD APN, etc.
${LOC_SS_ADD_APNS_BTN}           xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'cursor-pointer') and contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'add apn')]
# Fetch Device Plan: <button class="btn btn-custom-color cursor-pointer">Fetch Device Plan</button>
${LOC_SS_FETCH_DP_BTN}           xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'cursor-pointer') and normalize-space()='Fetch Device Plan']
# Bundle Plan: <select name="bundleName" data-testid="bundleName" class="form-control">
${LOC_SS_BUNDLE_PLAN_DD}         xpath=//select[@name='bundleName' and @data-testid='bundleName']
${LOC_SS_BUNDLE_PLAN_DD_LAST}    xpath=(//select[@name='bundleName' and @data-testid='bundleName'])[last()]
# Device Plan alias input
${LOC_SS_DEVICE_PLAN_INPUT}      xpath=//input[@name='dpAliasName']
# Last device plan alias input (when adding second row: fill the new row)
${LOC_SS_DEVICE_PLAN_INPUT_LAST}   xpath=(//input[@name='dpAliasName'])[last()]
# End Date (Kendo datepicker); calendar icon to open picker: <span class="k-icon k-i-calendar"></span>
${LOC_SS_END_DATE_INPUT}         xpath=//input[@id='deviceEndDate']
${LOC_SS_END_DATE_CALENDAR}      xpath=//input[@id='deviceEndDate']/..//a[contains(@class,'k-select')]
${LOC_SS_END_DATE_CALENDAR_ICON}   xpath=//span[contains(@class,'k-icon') and contains(@class,'k-i-calendar')]
${LOC_SS_END_DATE_CALENDAR_ICON_LAST}   xpath=(//span[contains(@class,'k-icon') and contains(@class,'k-i-calendar')])[last()]
# Kendo calendar: today's date cell (in opened calendar popup)
${LOC_SS_CALENDAR_TODAY}         xpath=//div[contains(@class,'k-calendar')]//td[contains(@class,'k-today')]//a
# Service Plan
${LOC_SS_SERVICE_PLAN_INPUT}     xpath=//input[@name='ServicePlanName']
# Create Service Plan: <div class="text-right cursor-pointer p-5 createServicePlan">Create Service Plan</div>
${LOC_SS_CREATE_SP_LINK}         xpath=//div[contains(@class,'createServicePlan') and contains(@class,'cursor-pointer') and contains(@class,'p-5')]
${LOC_SS_CREATE_SP_LINK_LAST}    xpath=(//div[contains(@class,'createServicePlan') and contains(@class,'cursor-pointer')])[last()]
# Cancel / Save buttons (Standard Services form)
${LOC_SS_CANCEL_BTN}             xpath=//button[contains(@class,'btn-danger') and normalize-space()='Cancel']
${LOC_SS_SAVE_BTN}               xpath=//button[contains(@class,'save') and normalize-space()='Save']
# Save (device plan section): after Create Service Plan modal Save, click this page-level Save then Next
# querySelector: #content > div.flex-center > div.flex.flex-column > div:nth-child(3) > div.mt-10.p-10.bg-light-shade... > div.text-right.p-10.pb-0.border-top-1 > div > button.btn.save
${LOC_SS_DEVICE_PLAN_SAVE_BTN}   xpath=//*[@id='content']//div[contains(@class,'bg-light-shade')]//div[contains(@class,'text-right') and contains(@class,'border-top-1')]//button[contains(@class,'btn') and contains(@class,'save')]

# ── APN and IP Preference Modal (#apnSelectionModal) ─────────────────
${LOC_APN_MODAL}                 xpath=//*[@id='apnSelectionModal']
${LOC_APN_MODAL_TITLE}           xpath=//*[@id='apnSelectionModal']//h5[contains(@class,'modal-title') and normalize-space()='APN and IP Preference']
# React-select APN label: defaults here match dev; ``Load Environment Config From Json`` overwrites these locators per ``DEFAULT_CSR_MODAL_APN_NAME``.
${LOC_APN_MODAL_APN_INPUT}       xpath=//*[@id='apnSelectionModal']//div[contains(@class,'basic-multi-select')]//input[contains(@id,'react-select')]
${LOC_APN_MODAL_APN_SINGLE_VALUE}   xpath=//*[@id='apnSelectionModal']//div[contains(@class,'single-value') or contains(@class,'singleValue')]
${LOC_APN_MODAL_APN_OPTION}      xpath=//*[@id='apnSelectionModal']//div[contains(@class,'select__option') and normalize-space(.)='public_dynamic']
${LOC_APN_MODAL_IP_PREF_DD}      xpath=//*[@id='apnSelectionModal']//select[@name='ipPreference']
# Add APN dialog — Save: click via querySelector #apnSelectionModal ... button.btn.btn-custom-color.m-l-15.width-75
# HTML: <button class="btn btn-custom-color m-l-15 width-75">Save</button>
${LOC_APN_MODAL_SAVE}            xpath=//*[@id='apnSelectionModal']//div[contains(@class,'flex-center') and contains(@class,'justify-content-end')]//button[contains(@class,'btn-custom-color') and contains(@class,'m-l-15') and contains(@class,'width-75') and normalize-space(.)='Save']
${LOC_APN_MODAL_CLOSE}           xpath=//*[@id='apnSelectionModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Add Service Plan Modal (#addServicePlanModal) ────────────────────
${LOC_SP_MODAL}                  xpath=//*[@id='addServicePlanModal']
${LOC_SP_MODAL_TITLE}            xpath=//*[@id='addServicePlanModal']//h5[contains(@class,'modal-title')]
${LOC_SP_VOICE_MO}               xpath=//input[@id='Voice MO']
${LOC_SP_VOICE_MT}               xpath=//input[@id='Voice MT']
${LOC_SP_SMS}                    xpath=//input[@id='SMS']
${LOC_SP_DATA}                   xpath=//input[@id='Data']
${LOC_SP_VOICE_PAYG}             xpath=//button[@id='voicespayg']
${LOC_SP_SMS_PAYG}               xpath=//button[@id='smspayg']
${LOC_SP_DATA_PAYG}              xpath=//button[@id='datapayg']
${LOC_SP_ROAMING_TOGGLE}         xpath=//button[@id='toggleIsRoaming']
# NB-IoT as a Separate Service (fallback if enable-all script misses the toggle)
${LOC_SP_NBIOT_SEPARATE_TOGGLE}       xpath=//*[@id='addServicePlanModal']//label[contains(normalize-space(.),'NB-IoT as a Separate Service')]/ancestor::div[contains(@class,'row')][1]//button[contains(@class,'btn')]
${LOC_SP_NBIOT_SEPARATE_TOGGLE_ALT}   xpath=//*[@id='addServicePlanModal']//label[contains(normalize-space(.),'NB-IoT as a Separate Service')]/ancestor::*[contains(@class,'d-flex') or contains(@class,'form-group')][1]//button[contains(@class,'btn')]
# Add Service Plan — optional label click (script in ``CSRJ Enable All Options In Add Service Plan Modal`` covers full modal)
${LOC_SP_INTL_VOICE_LBL}         xpath=//*[@id='addServicePlanModal']//label[contains(normalize-space(.),'International Voice')]
# Create Service Plan dialog — Save (dialog opens when clicking Create Service Plan link)
# HTML: <button class="btn btn-custom-color m-l-15 width-75 ml-2 cursor-pointer" type="submit">Save</button>
${LOC_SP_MODAL_SAVE}             xpath=//*[@id='addServicePlanModal']//button[@type='submit' and contains(@class,'btn-custom-color') and contains(@class,'ml-2') and contains(@class,'cursor-pointer') and normalize-space(.)='Save']
${LOC_SP_MODAL_CLOSE}            xpath=//*[@id='addServicePlanModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Wholesale Plan Discount Modal (#wholeSaleDiscountModal) ──────────
${LOC_WS_MODAL}                  xpath=//*[@id='wholeSaleDiscountModal']
${LOC_WS_DEFAULT_RADIO}          xpath=//input[@id='default'][@name='discountType']
${LOC_WS_SPECIFIC_RADIO}         xpath=//input[@id='specific'][@name='discountType']
${LOC_WS_IOT_SUBSCRIPTION}       xpath=//input[@name='iot_subscription']
${LOC_WS_IOT_PAYG}               xpath=//input[@name='iot_payg']
${LOC_WS_IOT_VAS}                xpath=//input[@name='iot_vas']
${LOC_WS_MODAL_SAVE}             xpath=//*[@id='wholeSaleDiscountModal']//button[@type='submit' and normalize-space()='Save']
${LOC_WS_MODAL_CLOSE}            xpath=//*[@id='wholeSaleDiscountModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Account Level VAS Charges Accordion ──────────────────────────────
${LOC_ACCT_VAS_TOGGLE}           xpath=//a[@href='#accountlevelvasCharges' and @data-toggle='collapse']
${LOC_ACCT_VAS_MODAL}            xpath=//*[@id='addAccountLevelVasChargeModal']
${LOC_ACCT_VAS_CHARGE_DD}        xpath=//*[@id='addAccountLevelVasChargeModal']//select[@name='charge']
${LOC_ACCT_VAS_END_DATE}         xpath=//input[@id='accountVasEndDate']
${LOC_ACCT_VAS_AMOUNT}           xpath=//input[@name='accountVasAmount']
${LOC_ACCT_VAS_MODAL_SAVE}       xpath=//*[@id='addAccountLevelVasChargeModal']//button[contains(@class,'btn-custom-color') and normalize-space()='Save']
${LOC_ACCT_VAS_MODAL_CLOSE}      xpath=//*[@id='addAccountLevelVasChargeModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Device Level VAS Charges Accordion ───────────────────────────────
${LOC_DEV_VAS_TOGGLE}            xpath=//a[@href='#devicelevelvasCharges' and @data-toggle='collapse']
${LOC_DEV_VAS_MODAL}             xpath=//*[@id='addDeviceLevelVasChargeModal']
${LOC_DEV_VAS_DP_DD}             xpath=//*[@id='addDeviceLevelVasChargeModal']//select[@name='deviceplan']
${LOC_DEV_VAS_CHARGE_DD}         xpath=//*[@id='addDeviceLevelVasChargeModal']//select[@name='charge']
${LOC_DEV_VAS_END_DATE}          xpath=//input[@id='deviceVasEndDate']
${LOC_DEV_VAS_MODAL_SAVE}        xpath=//*[@id='addDeviceLevelVasChargeModal']//button[contains(@class,'btn-custom-color') and normalize-space()='Save']
${LOC_DEV_VAS_MODAL_CLOSE}       xpath=//*[@id='addDeviceLevelVasChargeModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Bottom Navigation Buttons (Standard Services) ───────────────────
${LOC_SS_CLOSE_BTN}              xpath=//button[contains(@class,'btn-cancel-color') and normalize-space()='Close'][last()]
# Next (Standard Services): <button class="btn btn-custom-color ml-2 width-75">Next</button>
${LOC_SS_NEXT_BTN}               xpath=//button[contains(@class,'btn-custom-color') and normalize-space()='Next' and (contains(@class,'width-75') or contains(@class,'ml-2'))]

# ══════════════════════════════════════════════════════════════════════
#  STEP 2: ADDITIONAL SERVICES
# ══════════════════════════════════════════════════════════════════════
# Addon Plan: react-select multi-select
${LOC_AS_ADDON_PLAN_CONTROL}     xpath=(//div[contains(@class,'basic-multi-select')]//div[contains(@class,'select__control')] | //div[contains(@class,'select__control') and not(ancestor::*[@id='addDiscountModal']) and not(ancestor::*[contains(@id,'apnSelectionModal')]) and not(ancestor::*[contains(@class,'discon')])])[1]
${LOC_AS_ADDON_PLAN_INPUT}       xpath=//input[@id='react-select-5-input']
${LOC_AS_ADDON_PLAN_OPTION_1}    xpath=(//div[contains(@class,'select__option')])[1]
${LOC_AS_ADDON_TABLE}            xpath=//div[contains(@class,'charge-tabs')]//table
${LOC_AS_ADDON_TABLE_ROW_1}      xpath=//div[contains(@class,'charge-tabs')]//table//tbody/tr[1]
# Discount Accordion
${LOC_AS_DISCOUNT_TOGGLE}        xpath=//*[@data-toggle='collapse' and (contains(translate(@href,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'discon') or contains(translate(@href,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'discount') or contains(translate(@href,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'disconpen'))]
${LOC_AS_DISCOUNT_ADD_BTN}       xpath=//*[contains(translate(@id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'disconpen') or contains(translate(@id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'discount') or @id='disconpenalties']//button[contains(@class,'add_button') or normalize-space()='+ Add' or contains(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'+ add')]
# Add Discount Modal (#addDiscountModal)
${LOC_AS_DISCOUNT_MODAL}         xpath=//*[@id='addDiscountModal']
${LOC_AS_DISCOUNT_CAT_DD}        xpath=//*[@id='addDiscountModal']//select[@name='discountCategory']
${LOC_AS_DISCOUNT_REACT_INPUT}   xpath=//input[@id='react-select-6-input']
${LOC_AS_DISCOUNT_START_DATE}    xpath=//input[@id='discountStartDate']
${LOC_AS_DISCOUNT_END_DATE}      xpath=//input[@id='discountEndDate']
${LOC_AS_DISCOUNT_PRICE}         xpath=//input[@name='discountprice']
${LOC_AS_DISCOUNT_MODAL_SAVE}    xpath=//*[@id='addDiscountModal']//button[contains(@class,'btn-custom-color') and normalize-space()='Save']
${LOC_AS_DISCOUNT_MODAL_CLOSE}   xpath=//*[@id='addDiscountModal']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close']
# Bottom Navigation Buttons (Additional Services)
${LOC_AS_CLOSE_BTN}              xpath=//button[contains(@class,'btn-cancel-color') and normalize-space()='Close'][not(ancestor::*[@id='addDiscountModal'])]
# Previous (Additional Services only): #content > ... > div.flex.flex-column > div.flex.justify-content-end > div > button
# querySelector: #content > div.flex-center > div.flex.flex-column > div.flex.justify-content-end > div > button.btn.btn-custom-color-black...
# Footer "Previous" class varies (black vs default); scope to #content and visible button text
${LOC_AS_PREV_BTN}               xpath=//button[contains(@class,'btn') and (normalize-space()='Previous' or normalize-space()='< Previous' or normalize-space()='Prev' or contains(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'previous')) and not(ancestor::*[@id='addDiscountModal']) and not(ancestor::*[contains(@class,'modal') and contains(@class,'show')])]
# Next: <button class="btn btn-custom-color width-75">Next</button>
${LOC_AS_NEXT_BTN}               xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'width-75') and normalize-space()='Next'][not(ancestor::*[@id='addDiscountModal'])]

# ══════════════════════════════════════════════════════════════════════
#  STEP 3: ORDER SUMMARY (Read-Only)
# ══════════════════════════════════════════════════════════════════════
# Customer & BU info
${LOC_SUM_CUSTOMER_LABEL}        xpath=//*[contains(@class,'gc-label') and normalize-space()='CUSTOMER']
${LOC_SUM_CUSTOMER_VALUE}        xpath=//*[contains(@class,'gc-label') and normalize-space()='CUSTOMER']/following-sibling::*[contains(@class,'gc-value')]
${LOC_SUM_BU_LABEL}              xpath=//*[contains(@class,'gc-label') and normalize-space()='BUSINESS UNIT']
${LOC_SUM_BU_VALUE}              xpath=//*[contains(@class,'gc-label') and normalize-space()='BUSINESS UNIT']/following-sibling::*[contains(@class,'gc-value')]
# Tariff Plan Accordion
${LOC_SUM_TP_TOGGLE}             xpath=//*[@href='#accordionTariffPlan' and @data-toggle='collapse']
${LOC_SUM_TP_PANEL}              xpath=//*[@id='accordionTariffPlan']
${LOC_SUM_TP_VALUE}              xpath=//*[@id='accordionTariffPlan']//*[contains(normalize-space(),'Tariff Plan')]/following-sibling::*[contains(@class,'gc-value')]
# Account Plan Accordion
${LOC_SUM_AP_TOGGLE}             xpath=//a[@href='#accordionAccountPlan' and @data-toggle='collapse']
${LOC_SUM_AP_PANEL}              xpath=//*[@id='accordionAccountPlan']
# Device Plan Accordion
${LOC_SUM_DP_TOGGLE}             xpath=//a[@href='#devicePlan' and @data-toggle='collapse']
${LOC_SUM_DP_PANEL}              xpath=//*[@id='devicePlan']
# Bottom Navigation Buttons (Summary)
${LOC_SUM_CLOSE_BTN}             xpath=(//*[@id='content']//button[contains(@class,'btn-cancel-color') and normalize-space()='Close'])[last()]
# Previous (Order Summary only): #content > ... > div.flex.flex-column > div:nth-child(3) > div.flex.justify-content-end > div > button
# querySelector: #content > div.flex-center > div.flex.flex-column > div:nth-child(3) > div.flex.justify-content-end > div > button.btn...
${LOC_SUM_PREV_BTN}              xpath=//*[@id='content']//div[contains(@class,'flex-center')]//div[contains(@class,'flex-column')]/div[position()=3]//div[contains(@class,'justify-content-end')]//button[contains(@class,'btn-custom-color-black') and contains(@class,'pull-right') and normalize-space()='Previous']
${LOC_SUM_SAVE_EXIT_BTN}         xpath=//button[contains(@class,'btn-custom-color') and (normalize-space()='Save & Exit' or (contains(normalize-space(.),'Save') and contains(normalize-space(.),'Exit')))]
# Summary screen — Save & Continue (click on Summary to save and continue)
# HTML: <button class="btn btn-custom-color  mr-2 m-r-10">Save & Continue</button>
${LOC_SUM_SAVE_CONTINUE_BTN}     xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'mr-2') and contains(@class,'m-r-10') and normalize-space(.)='Save & Continue']

# ── CSR Overwrite Modal ──────────────────────────────────────────────
${LOC_CSR_OVERWRITE_MODAL}       xpath=//*[@id='csrOverWriteModal']
${LOC_CSR_OVERWRITE_MSG}         xpath=//*[@id='csrOverWriteModal']//*[contains(text(),'CSR is overwritten')]
# Confirm/OK button in overwrite modal (primary or submit button, not close)
${LOC_CSR_OVERWRITE_CONFIRM_BTN}    xpath=//*[@id="csrOverWriteModal"]//button[contains(@class,"btn-custom-color") or contains(@class,"btn-primary")]

# ── Toast Notifications (Toastify) ───────────────────────────────────
${LOC_CSRJ_SUCCESS_TOAST}        xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]
${LOC_CSRJ_ERROR_TOAST}          xpath=//div[contains(@class,'Toastify__toast--error')] | //div[@role='alert' and (contains(text(),'error') or contains(text(),'Error'))]
# APN Type conflict error
${LOC_CSRJ_APN_CONFLICT_ERROR}   xpath=//div[contains(@class,'apnError')]

# ── Landing Page: Usage Based Charges Grid ───────────────────────────
${LOC_CSRJ_USAGE_CHARGE_NAME_HDR}   xpath=//*[@id='UsageBaseCharges']//div[contains(@class,'k-grid-header')]
${LOC_CSRJ_USAGE_GRID_CONTENT}      xpath=//*[@id='UsageBaseCharges']//div[contains(@class,'k-grid-content')]

# ── Landing Page: Transaction History Grid ───────────────────────────
${LOC_CSRJ_TXN_HISTORY_GRID}        xpath=(//*[@id='gridData'])[2]
${LOC_CSRJ_TXN_HISTORY_ROW_1}       xpath=(//*[@id='gridData'])[2]//tbody/tr[1]

# ── Landing Page: Order Summary & Journey Popup ──────────────────────
${LOC_CSRJ_ORDER_SUMMARY_HDG}       xpath=//h4[normalize-space()='Order Summary']
${LOC_CSRJ_JOURNEY_POPUP}           xpath=//*[@id='journeyPopup']

# ── Summary: Account Plan values ────────────────────────────────────
${LOC_SUM_AP_VALUE}                  xpath=//*[@id='accordionAccountPlan']//label[contains(normalize-space(),'Account Plan')]/following-sibling::span[@class='gc-value']
${LOC_SUM_APN_TYPE_IN_AP}           xpath=//*[@id='accordionAccountPlan']//label[contains(normalize-space(),'APN Type')]/following-sibling::span[@class='gc-value']

# ── Summary: Device Plan sub-tables ──────────────────────────────────
${LOC_SUM_DP_APN_IP_TABLE}          xpath=//*[@id='devicePlan']//div[contains(@class,'charge-tabs')][1]//table
${LOC_SUM_DP_ENTITLEMENT_TABLE}     xpath=//*[@id='devicePlan']//div[contains(@class,'charge-tabs')][2]//table
${LOC_SUM_DP_OTC_TABLE}             xpath=//*[@id='devicePlan']//div[contains(@class,'charge-tabs')][3]//table
${LOC_SUM_DP_SP_TABLE}              xpath=//*[@id='devicePlan']//div[contains(@class,'charge-tabs')][4]//table
${LOC_SUM_DP_TABLE_ROWS}            xpath=//*[@id='devicePlan']//table//tbody/tr

# ── Addon Plan: selected value tag ───────────────────────────────────
${LOC_AS_ADDON_SELECTED_TAG}        xpath=//div[contains(@class,'basic-multi-select') and not(ancestor::*[@id='addDiscountModal'])]//div[contains(@class,'select__multi-value')]

# ── Service Plan: disabled state ─────────────────────────────────────
${LOC_SS_SERVICE_PLAN_DISABLED}     xpath=//input[@name='ServicePlanName' and @disabled]

# ── Edit Device Plan Window (opens when clicking device plan name on Standard Services in edit mode) ──
# Device plan name link/cell to click and open edit window (first device plan row)
${LOC_SS_DP_NAME_LINK}              xpath=(//input[@name='dpAliasName'])[1]
# Edit Device Plan window Save button (same as device plan section save)
${LOC_SS_EDIT_DP_SAVE_BTN}          xpath=//*[@id='content']//div[contains(@class,'bg-light-shade')]//div[contains(@class,'text-right') and contains(@class,'border-top-1')]//button[contains(@class,'btn') and contains(@class,'save')]

# ── Service Plan Modal — Additional Checkboxes ─────────────────────
${LOC_SP_VOICE_OUTGOING}            xpath=//*[@id='addServicePlanModal']//input[@id='Voice Outgoing'] | //*[@id='addServicePlanModal']//input[contains(@id,'voice') and contains(@id,'utgoing')]
${LOC_SP_VOICE_INCOMING}            xpath=//*[@id='addServicePlanModal']//input[@id='Voice Incoming'] | //*[@id='addServicePlanModal']//input[contains(@id,'voice') and contains(@id,'ncoming')]
${LOC_SP_VOICE}                     xpath=//*[@id='addServicePlanModal']//input[@id='Voice']
${LOC_SP_INTL_VOICE}                xpath=//*[@id='addServicePlanModal']//input[@id='International Voice'] | //*[@id='addServicePlanModal']//input[contains(@id,'nternational')]
${LOC_SP_VOICE_RESTRICTION}         xpath=//*[@id='addServicePlanModal']//input[@id='Voice Restriction'] | //*[@id='addServicePlanModal']//input[contains(@id,'oice') and contains(@id,'estriction')]
${LOC_SP_SMS_MO_RESTRICTION}        xpath=//*[@id='addServicePlanModal']//input[@id='SMS MO Restriction'] | //*[@id='addServicePlanModal']//input[contains(@id,'SMS') and contains(@id,'MO')]
${LOC_SP_SMS_MT_RESTRICTION}        xpath=//*[@id='addServicePlanModal']//input[@id='SMS MT Restriction'] | //*[@id='addServicePlanModal']//input[contains(@id,'SMS') and contains(@id,'MT')]
${LOC_SP_DATA_NBIOT}                xpath=//*[@id='addServicePlanModal']//input[@id='Data NB-IoT'] | //*[@id='addServicePlanModal']//input[contains(@id,'NB-IoT') or contains(@id,'nbiot')]
${LOC_SP_NBIOT_PAYG}                xpath=//button[@id='nbiotdatapayg'] | //button[contains(@id,'nbiot') and contains(@id,'payg')]

# ── APN Modal — Multi-row elements ─────────────────────────────────
${LOC_APN_MODAL_ADD_ROW_BTN}        xpath=//*[@id='apnSelectionModal']//button[contains(@class,'btn-primary') or contains(@class,'add')] | //*[@id='apnSelectionModal']//*[contains(@class,'fa-plus')]/parent::*
${LOC_APN_MODAL_REMOVE_ROW_BTN}     xpath=//*[@id='apnSelectionModal']//*[contains(@class,'fa-minus') or contains(@class,'text-danger') or contains(@class,'btn-danger')]/parent::* | //*[@id='apnSelectionModal']//button[contains(@class,'danger')]
${LOC_APN_MODAL_CANCEL_BTN}         xpath=//*[@id='apnSelectionModal']//button[contains(@class,'btn-cancel') or normalize-space()='Cancel']

# ── Additional Services — Addon Table ──────────────────────────────
${LOC_AS_ADDON_AUTO_RENEWAL}        xpath=//td[contains(text(),'AUTO-RENEWAL') or contains(@class,'auto-renewal')]//button | //table//button[contains(@id,'autoRenewal')]
${LOC_AS_ADDON_AUTO_ENABLE}         xpath=//td[contains(text(),'AUTO-ENABLEMENT') or contains(@class,'auto-enable')]//button | //table//button[contains(@id,'autoEnable')]
${LOC_AS_ADDON_MAPPED_DP_ADD}       xpath=//td//*[contains(text(),'+Add') or contains(@class,'add')]

# ── Summary — Section Details ──────────────────────────────────────
${LOC_SUM_ACCT_OTC_TABLE}           xpath=//div[contains(@class,'account-plan')]//table[contains(@class,'one-time') or .//th[contains(text(),'One Time')]]
${LOC_SUM_ACCT_RC_TABLE}            xpath=//div[contains(@class,'account-plan')]//table[contains(@class,'recurring') or .//th[contains(text(),'Recurring')]]
${LOC_SUM_ACCT_VAS_TABLE}           xpath=//div[contains(@class,'account-plan')]//table[contains(@class,'vas') or .//th[contains(text(),'VAS')]]
${LOC_SUM_DISCOUNT_SECTION}         xpath=//*[contains(@class,'discount') or contains(text(),'Discount')]
${LOC_SUM_ADDON_SECTION}            xpath=//*[contains(@class,'addon') or contains(text(),'Add-on') or contains(text(),'Add On')]
${LOC_SUM_SUSPENSION_SECTION}       xpath=//*[contains(text(),'Suspension') or contains(@class,'suspension')]
