*** Variables ***
# ── Grid / Table Locators (shared with ManageDevices page) ───────────
${LOC_DP_GRID}                     id=gridData
${LOC_DP_GRID_ROWS}                xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]
${LOC_DP_FIRST_ROW}                xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_DP_FIRST_ROW_CB}             xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]
${LOC_DP_GRID_HEADERS}             xpath=//div[@id='gridData']//thead//th

# ── Search Input ─────────────────────────────────────────────────────
${LOC_DP_SEARCH_INPUT}             id=searchinput
${LOC_DP_SEARCH_CLOSE}             id=closeBtn
${LOC_DP_NORMAL_SEARCH}            id=normal-search-trigger
${LOC_DP_FILTER_SEARCH}            id=filter-search-trigger

# ── Filter Area ──────────────────────────────────────────────────────
${LOC_DP_FILTER_AREA}              id=filterArea
${LOC_DP_RESET_ALL_FILTER}         id=resetAllFilter
${LOC_DP_FILTER_POPUP}             id=filterPopup
${LOC_DP_ACCOUNT_INPUT}            id=accountInput
${LOC_DP_ACCOUNT_CLOSE_BTN}        id=accountCloseBtn

# ── Action Bar Locators ──────────────────────────────────────────────
${LOC_DP_ACTION_FORM}              xpath=//form[@id='actionForm']
${LOC_DP_ACTION_DROP}              name=actionDrop
${LOC_DP_CHANGE_STATE_SEC}         id=changeState
${LOC_DP_PLAN_DROP}                name=changeSelectedValue
${LOC_DP_SUBMIT_ACTION_BTN}        id=submitAction

# ── Change Device Plan Popup (savePopup) ─────────────────────────────
# For Change Device Plan, showDevicePlanAndServicePlan=false.
# Only Reason dropdown and Comment box are rendered inside the popup.
${LOC_DP_POPUP}                    id=savePopup
${LOC_DP_POPUP_TITLE}              xpath=//div[@id='savePopup']//h4[contains(@class,'modal-title')]
${LOC_DP_POPUP_X_BTN}              xpath=//div[@id='savePopup']//button[contains(@class,'close')]
${LOC_DP_REASON_DROP}              xpath=//*[@data-testid='simStatwReasonsd']
${LOC_DP_COMMENT_BOX}              id=actionChangeComment
${LOC_DP_PROCEED_BTN}              id=prceedBtn
${LOC_DP_POPUP_CLOSE_BTN}          xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]

# ── Validation ───────────────────────────────────────────────────────
${LOC_DP_TOAST_SUCCESS}            xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_DP_TOAST_ERROR}              xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_DP_ALERT_DANGER}             xpath=//div[contains(@class,'alert-danger')]
