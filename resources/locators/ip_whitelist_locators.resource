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
# Customer + BU use the STC custom-dropdown pattern (same as CSR Journey / SIM Order):
#   outer wrapper has data-testid; the clickable trigger is div.selectBtn; options are
#   div.option inside the same data-testid wrapper. NOT React Select.
${LOC_WL_CUSTOMER_SELECT}             css:[data-testid="customerId"]
${LOC_WL_CUSTOMER_TRIGGER}            xpath=//*[@data-testid="customerId"]//div[contains(@class,'selectBtn')]
${LOC_WL_CUSTOMER_OPTIONS}            xpath=//*[@data-testid="customerId"]//div[contains(@class,'option')]
${LOC_WL_BU_SELECT}                   css:[data-testid="businessUnit"]
${LOC_WL_BU_TRIGGER}                  xpath=//*[@data-testid="businessUnit"]//div[contains(@class,'selectBtn')]
${LOC_WL_BU_OPTIONS}                  xpath=//*[@data-testid="businessUnit"]//div[contains(@class,'option')]

# ── Add Rule Button ──────────────────────────────────────────────
${LOC_WL_ADD_RULE_BTN}                xpath=//input[@type='button' and contains(@class,'add_rule_text')]

# ── Rules Grid ───────────────────────────────────────────────────
${LOC_WL_RULES_GRID}                  id=gridDataUsageReport
${LOC_WL_RULES_GRID_ROW}              xpath=//div[@id='gridDataUsageReport']//tr[contains(@class,'k-master-row')]

# ── Rule Dialog ──────────────────────────────────────────────────
${LOC_WL_RULE_DIALOG}                 id=add-service-item-dialog
# Source Address Subnet is React Select; the wrapper on QE has class 'dropDrownSelect'.
# Click anywhere on that wrapper to open; its options render via React Select's portal.
${LOC_WL_SOURCE_SUBNET_CONTROL}       xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'dropDrownSelect') or contains(@class,'react-select__control') or contains(@class,'select__control')]
${LOC_WL_SOURCE_SUBNET_INPUT}         xpath=//div[@id='add-service-item-dialog']//input[starts-with(@id,'react-select-') and contains(@id,'-input')]
${LOC_WL_SOURCE_SUBNET_OPTION}        xpath=(//div[contains(@id,'react-select-') and contains(@id,'-option')] | //div[contains(@class,'react-select__option') or contains(@class,'select__option')])[not(contains(@class,'is-disabled'))]
# Source IP is a ReactTags input; on QE the field itself has data-testid="input".
${LOC_WL_SOURCE_IP_INPUT}             xpath=//div[@id='add-service-item-dialog']//input[@data-testid='input' or contains(@class,'ReactTags__tagInputField')]
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
