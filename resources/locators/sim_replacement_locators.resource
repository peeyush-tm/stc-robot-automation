*** Variables ***
# Reuse Manage Devices patterns (aligned with sim_movement + prompts)
${LOC_SR_GRID}                      id=gridData
${LOC_SR_MASTER_ROWS}               xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]
${LOC_SR_FIRST_MASTER_ROW}          xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_SR_FIRST_ROW_CB}              xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]
${LOC_SR_SEARCH_TYPE}               xpath=//div[@id='searchBoxId']//select[contains(@class,'search-box-dropdown')] | //select[@datatestid='simSID']
${LOC_SR_SEARCH_INPUT_TXT}          id=txtLimit
${LOC_SR_SEARCH_TRIGGER}            id=normal-search-trigger
${LOC_SR_SEARCH_INPUT_ALT}          xpath=//input[@id='searchinput']
${LOC_SR_ACTION_FORM}               xpath=//form[@id='actionForm']
${LOC_SR_ACTION_DROP}               xpath=//select[@name='actionDrop' or @data-testid='actionDrop']
${LOC_SR_ACTION_IMSI_SELECT}        xpath=//form[@id='actionForm']//select[@name='changeSelectedValue' or @data-testid='changeSelectedValue']
# SIM Replacement row only: id=submitAction. Never match by text "Submit" — a second Submit exists for Case ID (left group).
${LOC_SR_ACTION_SUBMIT}             xpath=//form[@id='actionForm']//button[@id='submitAction']
${LOC_SR_SAVE_POPUP}                id=savePopup
# Reason popup (reason select + Proceed)
${LOC_SR_POPUP_REASON_SELECT}       xpath=//div[@id='savePopup']//select[1]
${LOC_SR_POPUP_PROCEED}             xpath=//div[@id='savePopup']//button[@id='prceedBtn'] | //div[@id='savePopup']//button[contains(@class,'btn-custom-color')]
${LOC_SR_POPUP_SUBMIT}              xpath=//div[@id='savePopup']//button[@id='prceedBtn'] | //div[@id='savePopup']//button[contains(@class,'btn-custom-color')]
${LOC_SR_POPUP_CANCEL}              xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]
${LOC_SR_EXPAND_FIRST_ROW}          xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//td[contains(@class,'k-hierarchy-cell')]//a
${LOC_SR_DETAIL_ROW}                xpath=//tr[contains(@class,'k-detail-row')][1]
${LOC_SR_NOTES_TAB}                 xpath=//tr[contains(@class,'k-detail-row')]//a[contains(normalize-space(),'Notes')] | //ul[contains(@id,'tab')]//a[contains(text(),'Notes')]
${LOC_SR_NOTES_FIRST_CELL}          xpath=(//tr[contains(@class,'k-detail-row')]//div[contains(@class,'k-grid')]//td)[1]
${LOC_SR_TOAST_SUCCESS}             xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_SR_TOAST_ERROR}               xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_SR_K_LOADING}                 xpath=//*[contains(@class,'k-loading-mask')]
# Blank / Lost SIM listing — scope to main Kendo widget (#gridData) so the first ``k-grid`` on the page
# (empty chrome / nested widget) does not steal [1] and leave searches waiting on a non-data grid.
${LOC_SR_PAGE_GRID}                id=gridData
${LOC_SR_BLANK_FIRST_ROW}           xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_SR_TOOLBAR_SEARCH}            xpath=//input[@id='txtLimit'] | //input[@id='searchinput' or @name='searchValue']
# Blank SIMs — Kendo column-level filter on Account Name column
${LOC_SR_BLANK_ACCT_COL_FILTER}     xpath=(//th[contains(@class,'k-header') and .//*[contains(translate(normalize-space(.),'ACCOUNTME','accountme'),'account name')]]//a[contains(@class,'k-grid-filter')])[1]
${LOC_SR_BLANK_COL_FILTER_MENU}     xpath=//div[contains(@class,'k-filter-menu') and not(contains(@style,'display: none'))]
${LOC_SR_BLANK_COL_FILTER_INPUT}    xpath=(//div[contains(@class,'k-filter-menu')]//input[@type='text' or not(@type)])[1]
${LOC_SR_BLANK_COL_FILTER_APPLY}    xpath=(//div[contains(@class,'k-filter-menu')]//button[contains(@class,'k-primary') or (contains(@class,'k-button') and not(contains(translate(normalize-space(.),'CLEARC','clearc'),'clear')))])[1]
