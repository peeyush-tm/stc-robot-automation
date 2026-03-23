*** Variables ***
# ── Sidebar Navigation ───────────────────────────────────────────
${LOC_RE_NAV_RULE_ENGINE}             xpath=//a[@id='rule-engine-menu-icon']
${LOC_RE_NAV_RULE_ENGINE_ALT}         xpath=//a[contains(@href,'/RuleEngine') and not(contains(@href,'Create')) and not(contains(@href,'Log')) and not(contains(@href,'Audit'))]

# ── Rule Engine Listing Page ────────────────────────────────────
${LOC_RE_CREATE_BTN}                  xpath=//a[@href='/CreateRuleEngine' or contains(@href,'/CreateRuleEngine')]
${LOC_RE_LISTING_GRID}                id=gridData

# ── Wizard Tab Headers ──────────────────────────────────────────
${LOC_RE_TAB_PRIMARY}                 id=primaryTab
${LOC_RE_TAB_TRIGGERS}                id=defineTriggersTab
${LOC_RE_TAB_ASSIGN}                  id=assignDevicesTab
${LOC_RE_TAB_ACTION}                  id=actionTab

# ── Wizard Tab Content Panes ────────────────────────────────────
${LOC_RE_PANE_PRIMARY}                id=PrimaryDetails
${LOC_RE_PANE_TRIGGERS}               xpath=//div[@id='defineTriggersTab' and contains(@class,'tab-pane')]
${LOC_RE_PANE_ASSIGN}                 xpath=//div[@id='assignDevicesTab' and contains(@class,'tab-pane')]
${LOC_RE_PANE_ACTION}                 xpath=//div[@id='actionTab' and contains(@class,'tab-pane')]

# ── Tab 1 — Primary Details Fields ──────────────────────────────
${LOC_RE_RULE_NAME}                   name=ruleName
${LOC_RE_CATEGORY}                    xpath=//select[@data-testid='in_category']
${LOC_RE_DESCRIPTION}                 name=description
${LOC_RE_EDIT_PERMISSIONS}            id=editPermissions
${LOC_RE_VIEW_PERMISSIONS}            id=viewPermissions
${LOC_RE_APP_LEVEL}                   xpath=//select[@data-testid='in_applicationLabel']
${LOC_RE_ALL_DEVICE_PLAN}             id=all_Device_Plan
${LOC_RE_DEVICE_PLAN}                 xpath=//select[@data-testid='selected_Device_Plan_ID']
${LOC_RE_DEVICE_PLAN_OPTIONS}         xpath=//select[@data-testid='selected_Device_Plan_ID']/option[not(@value='') and not(@value='0')]

# ── Tab 1 — Custom Div Dropdowns (Customer / BU / CC) ──────────
${LOC_RE_CUSTOMER_WRAPPER}            xpath=//div[@data-testid='selected_EC_Account_ID']
${LOC_RE_CUSTOMER_BTN}                xpath=//div[@data-testid='selected_EC_Account_ID']//div[contains(@class,'selectBtn')]
${LOC_RE_CUSTOMER_OPTIONS}            xpath=//div[@data-testid='selected_EC_Account_ID']//div[contains(@class,'selectDropdown')]//div[contains(@class,'option')]
${LOC_RE_CUSTOMER_SEARCH}             xpath=//div[@data-testid='selected_EC_Account_ID']/ancestor::div[contains(@class,'searcharea')]//input[contains(@class,'searchInput')]
${LOC_RE_BU_WRAPPER}                  xpath=//div[@data-testid='selected_BU_Account_ID']
${LOC_RE_BU_BTN}                      xpath=//div[@data-testid='selected_BU_Account_ID']//div[contains(@class,'selectBtn')]
${LOC_RE_BU_OPTIONS}                  xpath=//div[@data-testid='selected_BU_Account_ID']//div[contains(@class,'selectDropdown')]//div[contains(@class,'option')]
${LOC_RE_BU_SEARCH}                   xpath=//div[@data-testid='selected_BU_Account_ID']/ancestor::div[contains(@class,'searcharea')]//input[contains(@class,'searchInput')]
${LOC_RE_CC_WRAPPER}                  xpath=//div[@data-testid='selected_CC_Account_ID']
${LOC_RE_CC_BTN}                      xpath=//div[@data-testid='selected_CC_Account_ID']//div[contains(@class,'selectBtn')]
${LOC_RE_CC_OPTIONS}                  xpath=//div[@data-testid='selected_CC_Account_ID']//div[contains(@class,'selectDropdown')]//div[contains(@class,'option')]

# ── Wizard Bottom Navigation Buttons ────────────────────────────
${LOC_RE_PREVIOUS_BTN}                xpath=//input[@type='button' and contains(@class,'btn-custom-color-black') and @name='Base']
${LOC_RE_NEXT_BTN}                    xpath=//input[@type='button' and @name='Primary' and contains(@class,'btn-custom-color')]
${LOC_RE_SUBMIT_BTN}                  xpath=//input[@type='button' and contains(@class,'btn-custom-color') and not(contains(@class,'black')) and not(contains(@class,'cancel')) and not(@name='Primary')]
${LOC_RE_CLOSE_BTN}                   xpath=//input[@type='button' and contains(@class,'btn-cancel-color')]

# ── Tab 2 — Define Triggers Fields ──────────────────────────────
# Rule Category may be a native <select> or a custom div dropdown depending on app version.
# We define locators for both; the keyword will try native first, then custom.
${LOC_RE_RULE_CATEGORY_SELECT}        xpath=//select[@data-testid='ruleCategory']
${LOC_RE_RULE_CATEGORY_DIV}           xpath=//div[@data-testid='ruleCategory']
${LOC_RE_RULE_CATEGORY_BTN}           xpath=//div[@data-testid='ruleCategory']//div[contains(@class,'selectBtn')]
${LOC_RE_RULE_CATEGORY_OPTIONS}       xpath=//div[@data-testid='ruleCategory']//div[contains(@class,'selectDropdown')]//div[contains(@class,'option')]
# Trigger form fields can vary by Rule Category; support multiple names/placeholders.
# "Select Trigger: If" / "Select Condition" — required when Rule Category (e.g. Country or Operator change) shows it; error: "Please Select a Default Condition"
${LOC_RE_TRIGGER_DEFAULT_CONDITION}   xpath=//div[@id='defineTriggersTab']//select[not(@data-testid='ruleCategory') and not(@data-testid='conditionalssd') and .//option[contains(normalize-space(text()),'Select Condition')]]
${LOC_RE_TRIGGER_CONDITION_VALUE}     xpath=//input[@name='text1' or @placeholder='Condition Value']
${LOC_RE_TRIGGER_CONDITION_VALUE_ALT}     xpath=//div[@id='defineTriggersTab']//input[not(@type='hidden')]
${LOC_RE_TRIGGER_COMPARATOR}          xpath=//select[@data-testid='conditionalssd']
${LOC_RE_TRIGGER_SAVE_BTN}            xpath=//button[contains(@class,'btn-custom-color') and (contains(text(),'Save') or contains(text(),'Add'))]

# ── Tab 3 — Assign Devices Fields ──────────────────────────────
${LOC_RE_AGGREGATION}                 xpath=//select[@data-testid='aggregationLevel']
${LOC_RE_REST_PERIOD}                 xpath=//select[@data-testid='in_reset_period']
${LOC_RE_TAG}                         name=tagId

# ── Tab 4 — Action Fields ──────────────────────────────────────
${LOC_RE_ACTION_TYPE}                 xpath=//select[@data-testid='racactionType']
${LOC_RE_ALERT_EMAIL_INPUT}           xpath=//div[@id='actionTab']//div[contains(@class,'ReactTags__tagInput')]//input
${LOC_RE_ALERT_EMAIL_TAG}             xpath=//div[@id='actionTab']//span[contains(@class,'ReactTags__tag')]
${LOC_RE_ALERT_NAME}                  id=raiseAlertTriggerName
${LOC_RE_ALERT_DESC}                  id=raiseAlertTriggerDesc
${LOC_RE_SAVE_ACTION_BTN}             xpath=//div[@id='actionTab']//button[contains(@class,'btn-custom-color') and not(contains(@class,'cursor-pointer'))]
${LOC_RE_ACTION_CLOSE_BTN}            xpath=//div[@id='actionTab']//button[contains(@class,'btn-cancel-color')]
${LOC_RE_ACTION_LIST_PANEL}           xpath=//div[contains(@class,'tabActionrule') or contains(@class,'save-action') or contains(@class,'savedAction')]
${LOC_RE_SAVED_ACTION_ENTRY}          xpath=//div[contains(@class,'actionTab') or @id='actionTab']//*[contains(text(),'Raise Alert') or contains(text(),'Email') or contains(text(),'SMS') or contains(text(),'SIM State')]

# ── Validation / Toasts ─────────────────────────────────────────
${LOC_RE_TOAST_SUCCESS}               xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_RE_TOAST_ERROR}                 xpath=//div[contains(@class,'Toastify__toast--error')]
