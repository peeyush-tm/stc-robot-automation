*** Variables ***
# ── Sidebar Navigation ──────────────────────────────────────────────
${LOC_ADMIN_MENU}                  xpath=//span[contains(text(),'Admin')]/parent::a

# ── Top Navigation Tabs (Admin page) ────────────────────────────────
${LOC_TAB_SIM_RANGE}               xpath=//ul[@id="pageHeading"]//a[@href="/SIMRange"]

# ── SIM Range Page Tabs ─────────────────────────────────────────────
${LOC_TAB_ICCID_IMSI}             xpath=//ul[@id="tabHeading"]//a[@href="#iccid_imsi"]
${LOC_TAB_CONTROL}                xpath=//*[@id="tabControl"]
${LOC_PANE_ICCID_IMSI}            xpath=//*[@id="iccid_imsi"]

# ── SIM Range List Page ─────────────────────────────────────────────
${LOC_SR_CREATE_BTN}              xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Create SIM Range']
${LOC_SR_GRID}                    xpath=//*[@id="ManageSIMRangeGrid"]
${LOC_SR_GRID_ROWS}               xpath=//*[@id="ManageSIMRangeGrid"]//tbody/tr
${LOC_SR_GRID_FIRST_ROW}          xpath=//*[@id="ManageSIMRangeGrid"]//tbody/tr[1]
${LOC_SR_SEARCH_INPUT}            xpath=//input[@name="searchValue"]
${LOC_SR_SEARCH_BTN}              xpath=//a[@id="searchButton"]

# ── Create SIM Range — Main Fields ──────────────────────────────────
${LOC_SR_POOL_NAME}               xpath=//input[@name='poolName']
${LOC_SR_ACCOUNT_DD}              xpath=//*[@data-testid='AectAccoor']
${LOC_SR_DESCRIPTION}             xpath=//input[@name='description']
${LOC_SR_POOL_COUNT}              xpath=//input[@name='poolCount']
${LOC_SR_ASSETS_TYPE_DD}          xpath=//*[@data-testid='tassetsTypes']
${LOC_SR_SIM_CATEGORY_DD}         xpath=//*[@data-testid='tSIMCacoor']

# ── Accordion Panels ────────────────────────────────────────────────
${LOC_ICCID_PANEL}                id=definecondition
${LOC_IMSI_PANEL}                 id=collapseTwo
${LOC_IMSI_PANEL_TOGGLE}          xpath=//a[@href='#collapseTwo']

# ── Add Range Buttons ───────────────────────────────────────────────
${LOC_ADD_ICCID_BTN}              xpath=//button[contains(@title,'ICCID') and contains(@class,'add-action-button')]
${LOC_ADD_IMSI_BTN}               xpath=//button[contains(@title,'IMSI') and contains(@class,'add-action-button')]

# ── ICCID Range Popup (scoped to #addRangePopup) ────────────────────
${LOC_ICCID_POPUP}                id=addRangePopup
${LOC_ICCID_FROM}                 xpath=//div[@id='addRangePopup']//input[@name='fromInput' and not(@disabled)]
${LOC_ICCID_TO}                   xpath=//div[@id='addRangePopup']//input[@name='toInput' and not(@disabled)]
${LOC_ICCID_POPUP_SUBMIT}         xpath=//div[@id='addRangePopup']//button[contains(@class,'btn-custom-color') and not(@disabled)]
${LOC_ICCID_POPUP_CLOSE}          xpath=//div[@id='addRangePopup']//button[contains(@class,'btn-cancel-color')]

# ── IMSI Range Popup (scoped to #addImsiRangePopup) ──────────────────
${LOC_IMSI_POPUP}                 id=addImsiRangePopup
${LOC_IMSI_FROM}                  xpath=//div[@id='addImsiRangePopup']//input[@name='fromInputImsi' and not(@disabled)]
${LOC_IMSI_TO}                    xpath=//div[@id='addImsiRangePopup']//input[@name='toInputImsi' and not(@disabled)]
${LOC_IMSI_POPUP_SUBMIT}          xpath=//div[@id='addImsiRangePopup']//button[contains(@class,'btn-custom-color') and not(@disabled)]
${LOC_IMSI_POPUP_CLOSE}           xpath=//div[@id='addImsiRangePopup']//button[contains(@class,'btn-cancel-color')]

# ── Range Grid Tables ───────────────────────────────────────────────
${LOC_ICCID_GRID}                 id=iccidRangeTable
${LOC_IMSI_GRID}                  id=imsiRangeTable

# ── Final Form Actions ──────────────────────────────────────────────
${LOC_SR_SUBMIT_BTN}              xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']
${LOC_SR_CLOSE_BTN}               xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[contains(@class,'btn-cancel-color')]

# ── SIM Range Page Tabs — MSISDN ───────────────────────────────────
${LOC_TAB_MSISDN}                 xpath=//ul[@id="tabHeading"]//a[@href="#msisdn"]
${LOC_TAB_MSISDN_LI}             xpath=//ul[@id="tabHeading"]//li[@value='1']
${LOC_PANE_MSISDN}                xpath=//*[@id="msisdn"]

# ── MSISDN Accordion Panel ────────────────────────────────────────
${LOC_MSISDN_PANEL}               id=headingThree
${LOC_MSISDN_PANEL_TOGGLE}        xpath=//div[@id='headingThree']//a[@role='button']
${LOC_MSISDN_COLLAPSE}            id=collapseThree
${LOC_ADD_MSISDN_BTN}             xpath=//div[@id='collapseThree']//button[contains(@class,'add-action-button')]
${LOC_MSISDN_MAX_ROW_INDICATOR}   xpath=//div[@id='collapseThree']//span[contains(@class,'maxSimRow')]

# ── MSISDN Range Popup (scoped to #addMsisdnRangePopup) ───────────
${LOC_MSISDN_POPUP}               id=addMsisdnRangePopup
${LOC_MSISDN_FROM}                xpath=//div[@id='addMsisdnRangePopup']//input[@name='fromInputMsisdn']
${LOC_MSISDN_TO}                  xpath=//div[@id='addMsisdnRangePopup']//input[@name='toInputMsisdn']
${LOC_MSISDN_POPUP_SUBMIT}        xpath=//div[@id='addMsisdnRangePopup']//button[@id='prceedBtn']
${LOC_MSISDN_POPUP_CLOSE}         xpath=//div[@id='addMsisdnRangePopup']//button[contains(@class,'btn-cancel-color')]

# ── MSISDN Range Grid ─────────────────────────────────────────────
${LOC_MSISDN_GRID}                id=msisdnRangeTable
${LOC_MSISDN_GRID_ROW}            xpath=//div[@id='msisdnRangeTable']//tr[@data-uid]

# ── Validation ──────────────────────────────────────────────────────
${LOC_SR_TOAST_SUCCESS}           xpath=//div[contains(@class,'toast-success') or contains(@class,'Toastify__toast--success')]
${LOC_SR_TOAST_ERROR}             xpath=//div[contains(@class,'toast-error') or contains(@class,'Toastify__toast--error')]
${LOC_SR_ALERT_DANGER}            xpath=//div[contains(@class,'alert-danger')]
