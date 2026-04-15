*** Variables ***
# ── Sidebar Navigation (reuse from APN locators) ────────────────
${LOC_IP_MENU_SERVICE}                xpath=//*[@id="service-menu-icon"]

# ── Top Navigation Tabs (on Service page) ───────────────────────
${LOC_TAB_IP_POOLING}                 xpath=//*[@id="pageHeading"]//a[contains(@href,'/manageIPPooling') or contains(text(),'IP Pooling')]

# ── Manage IP Pooling Listing Page ──────────────────────────────
${LOC_IP_CREATE_BTN}                  xpath=//a[contains(@href,'/CreateIPPooling')]
${LOC_IP_GRID}                        xpath=//div[contains(@class,'k-grid')]
${LOC_IP_GRID_ROWS}                   xpath=//div[contains(@class,'k-grid')]//tbody/tr

# ── Create IP Pool — Form Fields ────────────────────────────────
${LOC_IP_ACCOUNT_TREE}                xpath=//div[@for='accountId'] | //*[@data-testid='accountId'] | //div[contains(@class,'treeview') or contains(@class,'account')][1]
${LOC_IP_ACCOUNT_TREE_ALT}            xpath=//*[@data-testid='accountId']
${LOC_IP_ACCOUNT_TREE_FIRST}          xpath=//ul[contains(@class,'treeview')]//li[1]//span[contains(@class,'item')] | //div[contains(@class,'react-select__menu')]//div[contains(@class,'react-select__option')][1] | //li[contains(@class,'k-item')][1]
${LOC_IP_APN_TYPE}                    name=apnCategory
${LOC_IP_NUMBER_OF_IPS}               name=numberOfIps
${LOC_IP_APN_SELECT}                  css:[data-testid='APNPrfiln']

# ── Step 1 — Create Button ──────────────────────────────────────
${LOC_IP_CREATE_STEP_BTN}             xpath=//input[@type='button' and contains(@class,'btn-custom-color') and @value='Create']

# ── IP Details Panel ─────────────────────────────────────────────
${LOC_IP_NEXT_IPV4}                   xpath=//label[contains(.,'Next Available IPV4')]/following-sibling::span
${LOC_IP_NEXT_IPV6}                   xpath=//label[contains(.,'Next Available IPV6')]/following-sibling::span
${LOC_IP_GENERATED_IPS}               xpath=//label[contains(@class,'gc-label') and contains(.,'Generated')]/following-sibling::span
${LOC_IP_REQUESTED_IPS}               xpath=//label[contains(@class,'gc-label') and contains(.,'Requested')]/following-sibling::span
${LOC_IP_APN_NAME_LABEL}              xpath=//label[contains(@class,'gc-label') and contains(.,'APN Name')]/following-sibling::span
${LOC_IP_ACCOUNT_NAME_LABEL}          xpath=//label[contains(@class,'gc-label') and contains(.,'Account Name')]/following-sibling::span
${LOC_IP_IPV4_TABLE}                  xpath=//td[text()='IPV4']/ancestor::table
${LOC_IP_IPV6_TABLE}                  xpath=//td[text()='IPV6']/ancestor::table

# ── Step 2 — Submit Button ──────────────────────────────────────
${LOC_IP_SUBMIT_BTN}                  xpath=//input[@type='button' and @value='Submit']

# ── Close / Cancel Button ───────────────────────────────────────
${LOC_IP_CLOSE_BTN}                   xpath=//input[@type='button' and contains(@class,'btn-cancel-color')]

# ── Validation ───────────────────────────────────────────────────
${LOC_IP_TOAST_SUCCESS}               xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_IP_TOAST_ERROR}                 xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_IP_ALERT_DANGER}                xpath=//div[contains(@class,'alert-danger')]
