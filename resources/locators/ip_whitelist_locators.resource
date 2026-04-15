*** Variables ***
# ── Sidebar Navigation ───────────────────────────────────────────
${LOC_WL_MENU_SERVICE}                xpath=//*[@id="service-menu-icon"]

# ── Top Navigation Tabs (on Service page) ───────────────────────
${LOC_TAB_IP_WHITELISTING}            xpath=//*[@id="pageHeading"]//a[contains(@href,'/IPWhitelisting') or contains(text(),'IP Whitelisting')]

# ── Manage IP Whitelisting Listing Page ─────────────────────────
${LOC_WL_CREATE_POLICY_BTN}           xpath=//a[contains(@href,'/CreateIPWhitelisting')]
${LOC_WL_GRID}                        id=IPWhitelistingGrid
${LOC_WL_GRID_ROWS}                   xpath=//div[@id='IPWhitelistingGrid']//tbody/tr

# ── Create IP Whitelisting — Header Fields ──────────────────────
# Customer: React Select (not native select); click inner control, not only the testid wrapper
${LOC_WL_CUSTOMER_SELECT}             css:[data-testid="customerId"]
${LOC_WL_CUSTOMER_REACT_CONTROL}      xpath=(//*[@data-testid="customerId" and (contains(@class,'react-select__control') or contains(@class,'select__control'))] | //*[@data-testid="customerId"]//div[contains(@class,'react-select__control') or contains(@class,'select__control')])[1]
${LOC_WL_CUSTOMER_REACT_INPUT}        xpath=//*[@data-testid="customerId"]//input
${LOC_WL_CUSTOMER_FALLBACK_CONTROL}   xpath=//div[not(ancestor::div[@id='add-service-item-dialog']) and (contains(@class,'react-select__control') or contains(@class,'select__control'))][1]
${LOC_WL_CUSTOMER_REACT_OPTION}       xpath=//div[contains(@class,'react-select__menu') or contains(@class,'select__menu')]//div[contains(@class,'react-select__option') or contains(@class,'select__option')]
${LOC_WL_BU_SELECT}                   name=businessUnit

# ── Add Rule Button ──────────────────────────────────────────────
${LOC_WL_ADD_RULE_BTN}                xpath=//input[@type='button' and contains(@class,'add_rule_text')]

# ── Rules Grid ───────────────────────────────────────────────────
${LOC_WL_RULES_GRID}                  id=gridDataUsageReport
${LOC_WL_RULES_GRID_ROW}              xpath=//div[@id='gridDataUsageReport']//tr[contains(@class,'k-master-row')]

# ── Rule Dialog ──────────────────────────────────────────────────
${LOC_WL_RULE_DIALOG}                 id=add-service-item-dialog
${LOC_WL_SOURCE_SUBNET_CONTROL}       xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'react-select__control')]
${LOC_WL_SOURCE_SUBNET_OPTION}        xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'react-select__option')]
${LOC_WL_SOURCE_IP_INPUT}             xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'ReactTags__tagInput')]//input
${LOC_WL_SOURCE_IP_TAG}               xpath=//div[@id='add-service-item-dialog']//span[contains(@class,'ReactTags__tag')]
${LOC_WL_DESTINATION_ADDR}             id=destinationAddress
${LOC_WL_PORT_SELECT}                 xpath=//div[@id='add-service-item-dialog']//select[@name='port']
${LOC_WL_PORT_VALUE_INPUT}            xpath=//div[@id='add-service-item-dialog']//input[@name='portValue']
${LOC_WL_PROTOCOL_SELECT}             xpath=//div[@id='add-service-item-dialog']//select[@name='protocol']
${LOC_WL_RULE_DIALOG_SUBMIT}          xpath=//div[@id='add-service-item-dialog']//button[contains(@class,'btn-custom-color')]
${LOC_WL_RULE_DIALOG_CLOSE}           xpath=//div[@id='add-service-item-dialog']//button[contains(@class,'btn-cancel-color')]

# ── Create Page Action Buttons ───────────────────────────────────
${LOC_WL_CREATE_BTN}                  xpath=//input[@type='button' and contains(@class,'btn-custom-color') and not(contains(@class,'add_rule_text'))]
${LOC_WL_CLOSE_BTN}                   xpath=//input[@type='button' and contains(@class,'btn-cancel-color')]

# ── Validation ───────────────────────────────────────────────────
${LOC_WL_TOAST_SUCCESS}               xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_WL_TOAST_ERROR}                 xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_WL_ALERT_DANGER}                xpath=//div[contains(@class,'alert-danger')]
