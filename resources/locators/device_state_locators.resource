*** Variables ***
# ── Grid / Table Locators ─────────────────────────────────────────────
${LOC_DSC_GRID}                    id=gridData
${LOC_DSC_GRID_TBODY}              xpath=//div[@id='gridData']//tbody[@role='rowgroup']
${LOC_DSC_GRID_ROWS}               xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]
${LOC_DSC_FIRST_ROW}               xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_DSC_FIRST_ROW_CB}            xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]
${LOC_DSC_GRID_HEADERS}            xpath=//div[@id='gridData']//thead//th

# ── Search Input ──────────────────────────────────────────────────────
${LOC_DSC_SEARCH_INPUT}            id=searchinput
${LOC_DSC_SEARCH_CLOSE}            id=closeBtn
${LOC_DSC_NORMAL_SEARCH}           id=normal-search-trigger
${LOC_DSC_FILTER_SEARCH}           id=filter-search-trigger

# ── Filter Area ───────────────────────────────────────────────────────
${LOC_DSC_FILTER_AREA}             id=filterArea
${LOC_DSC_RESET_ALL_FILTER}        id=resetAllFilter
${LOC_DSC_FILTER_POPUP}            id=filterPopup
${LOC_DSC_SIM_STATE_FILTER}        xpath=//div[@id='filterArea']//*[contains(translate(text(),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),'SIM STATE')]
${LOC_DSC_ACCOUNT_INPUT}           id=accountInput
${LOC_DSC_ACCOUNT_CLOSE_BTN}       id=accountCloseBtn

# ── Action Bar Locators ──────────────────────────────────────────────
${LOC_DSC_ACTION_FORM}             xpath=//form[@id='actionForm']
${LOC_DSC_ACTION_DROP}             name=actionDrop
${LOC_DSC_CHANGE_STATE_SEC}        id=changeState
${LOC_DSC_STATE_DROP}              name=changeSelectedValue
${LOC_DSC_STATE_SUBMIT_BTN}        id=submitAction

# ── State Change Popup (savePopup) ───────────────────────────────────
${LOC_DSC_POPUP}                   id=savePopup
${LOC_DSC_POPUP_TITLE}             xpath=//div[@id='savePopup']//h4[contains(@class,'modal-title')]
${LOC_DSC_SVC_PLAN_DROP}           xpath=//*[@data-testid='simStatwReason']
${LOC_DSC_DEV_PLAN_DROP}           xpath=//*[@data-testid='simStatwReasons']
${LOC_DSC_REASON_DROP}             xpath=//*[@data-testid='simStatwReasonsd']
${LOC_DSC_COMMENT_BOX}             id=actionChangeComment
${LOC_DSC_PROCEED_BTN}             id=prceedBtn
${LOC_DSC_POPUP_CLOSE_BTN}         xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]
${LOC_DSC_POPUP_X_BTN}             xpath=//div[@id='savePopup']//button[contains(@class,'close')]

# ── Expand row / Detail panel (Manage Devices) ─────────────────────────
# Expand icon on first master row (blue triangle) — try anchor or any clickable in hierarchy cell
${LOC_DSC_FIRST_ROW_EXPAND}        xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//td[contains(@class,'k-hierarchy-cell')]//a
${LOC_DSC_FIRST_ROW_EXPAND_ALT}    xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//td[contains(@class,'k-hierarchy-cell')]//*[contains(@class,'k-icon') or name()='span' or name()='a']
# Usage tab inside expanded detail row — tab may be a, span, li, or button; text "Usage"
${LOC_DSC_DETAIL_USAGE_TAB_LINK}   xpath=//div[@id='gridData']//tr[contains(@class,'k-detail-row')]//a[contains(normalize-space(text()),'Usage')]
${LOC_DSC_DETAIL_USAGE_TAB_ALT}    xpath=//div[@id='gridData']//tr[contains(@class,'k-detail-row')]//*[contains(normalize-space(text()),'Usage') and (name()='a' or name()='span' or name()='li' or name()='button')]
# Broader: any clickable "Usage" under gridData (detail may not use k-detail-row class)
${LOC_DSC_DETAIL_USAGE_TAB_ANY}    xpath=//div[@id='gridData']//*[contains(normalize-space(.),'Usage') and (name()='a' or name()='span' or name()='li' or name()='button' or name()='div')]

# ── Validation ────────────────────────────────────────────────────────
${LOC_DSC_TOAST_SUCCESS}           xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_DSC_TOAST_ERROR}             xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_DSC_ALERT_DANGER}            xpath=//div[contains(@class,'alert-danger')]
