*** Variables ***
# ── Manage Devices — Grid ─────────────────────────────────────────────
${LOC_SM_GRID}                      id=gridData
${LOC_SM_GRID_ROWS}                 xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]

# ── Manage Devices — Search ───────────────────────────────────────────
${LOC_SM_SEARCH_DD}                 xpath=//div[@id='searchBoxId']//select[contains(@class,'search-box-dropdown')]
${LOC_SM_SEARCH_INPUT}              id=txtLimit
${LOC_SM_NORMAL_SEARCH_BTN}        id=normal-search-trigger
${LOC_SM_FILTER_BTN}               id=filter-search-trigger
${LOC_SM_FILTER_POPUP}             id=filterPopup
${LOC_SM_FILTER_ACCOUNT_INPUT}     id=accountInput
${LOC_SM_FILTER_ACCOUNT_CLOSE}     id=accountCloseBtn
${LOC_SM_APPLY_FILTER_BTN}         xpath=//button[@id='gc-apply-filters']
${LOC_SM_RESET_ALL_FILTER_BTN}     id=resetAllFilter

# ── Manage Devices — Row / Checkbox selection ─────────────────────────
${LOC_SM_FIRST_ROW_CB}             xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]

# ── Action Bar ────────────────────────────────────────────────────────
${LOC_SM_ACTION_FORM}              xpath=//form[@id='actionForm']
${LOC_SM_ACTION_DROP}              name=actionDrop
# SIM Movement: use last "Submit" in actionForm — first Submit(s) may be Case ID / other rows; target BU row Submit is rightmost.
${LOC_SM_SIM_MOVEMENT_SUBMIT}      xpath=(//form[@id='actionForm']//button[normalize-space()='Submit'])[last()]
${LOC_SM_SUBMIT_ACTION_BTN}        id=submitActionBtn
${LOC_SM_SUBMIT_ACTION_BTN_SCOPED}    xpath=(//form[@id='actionForm']//button[@id='submitActionBtn'])[last()]
${LOC_SM_SUBMIT_ACTION_BTN_ALT}    id=submitAction
${LOC_SM_CLOSE_RESET_BTN}         id=close_reset
# Confirmation after Submit (same pattern as Change State — savePopup + Proceed)
${LOC_SM_SAVE_POPUP}               id=savePopup
${LOC_SM_SAVE_POPUP_PROCEED}       xpath=//div[@id='savePopup']//button[@id='prceedBtn']

# ── SIM Movement Action Popup ───────────────────────────────────────────
# SIM Movement uses a tree-view modal that is identified by its unique elements.
# id=actionChangeComment is the comment textarea present only in this action popup.
${LOC_SM_COMMENT_TEXTAREA}        id=actionChangeComment
# Account hierarchy tree is hidden until "Select Account" is clicked; may render in showTreeView-* or Kendo popup.
${LOC_SM_SELECT_ACCOUNT_TREE_NODE}    xpath=(//div[contains(@id,'showTreeView')]//ul[contains(@class,'k-treeview-lines')]//span[contains(@class,'k-in')])[1] | (//ul[contains(@class,'k-treeview-lines')]//span[contains(@class,'k-in')])[1]
${LOC_SM_MODAL}                    xpath=//*[@id='actionChangeComment']/ancestor::div[contains(@class,'modal') or @role='dialog' or contains(@class,'popup') or contains(@class,'k-dialog')][1]
${LOC_SM_MODAL_TITLE}              xpath=//*[@id='actionChangeComment']/ancestor::div[1]/preceding-sibling::*//*[contains(@class,'modal-title') or contains(@class,'title')]
# Prefer tree inside SIM Movement action area (avoids other page treeviews); fall back to any Kendo tree.
${LOC_SM_MODAL_TREE}               xpath=(//*[@id='actionChangeComment']/ancestor::form[1]//ul[contains(@class,'k-treeview-lines')]//span[contains(@class,'k-in')])[1] | (//*[@id='actionChangeComment']/ancestor::div[contains(@class,'modal')][1]//ul[contains(@class,'k-treeview-lines')]//span[contains(@class,'k-in')])[1] | (//ul[contains(@class,'k-treeview-lines')]//li//span[contains(@class,'k-in')])[1]
${LOC_SM_PROCEED_BTN}              xpath=//*[@id='actionChangeComment']/ancestor::form//button[contains(@id,'proceed') or contains(@id,'Proceed') or contains(normalize-space(text()),'Proceed') or @type='submit'] | //button[@id='prceedBtn']
${LOC_SM_MODAL_CLOSE_BTN}         xpath=//*[@id='actionChangeComment']/ancestor::div[contains(@class,'modal') or @role='dialog' or contains(@class,'popup') or contains(@class,'k-dialog')][1]//button[contains(@class,'close') or contains(@class,'btn-cancel') or contains(normalize-space(text()),'Close') or contains(normalize-space(text()),'Cancel')]
# Device Plan dropdown — identified by its placeholder option "Device Plan Change"
# The action bar select element does not expose a predictable id/name/class,
# so we locate it by the option text that is always present as placeholder.
${LOC_SM_DP_DROPDOWN}              xpath=//select[.//option[normalize-space(text())='Device Plan Change']]
${LOC_SM_DP_DROPDOWN_ALT}         xpath=//*[@id='actionChangeComment']/ancestor::div[1]//select[last()]

# ── Manage Account — Edit button (EC row) ─────────────────────────────
${LOC_SM_ACCT_EDIT_BTN}           xpath=//div[@id='ManageAccountGrid']//button[contains(@class,'edit') or contains(text(),'Edit') or @title='Edit']

# ── SIM Details — Expand + Tabs ──────────────────────────────────────
${LOC_SM_TAB_NOTES}                xpath=//tr[contains(@class,'k-detail-row')]//a[contains(normalize-space(),'Notes')] | //ul[contains(@id,'tab')]//a[contains(text(),'Notes')]
${LOC_SM_TAB_GENERAL}             xpath=//ul[@id='tabHeading']//a[@href='#tab1' and contains(text(),'General')]

# ── Notes section ────────────────────────────────────────────────────
${LOC_SM_NOTES_GRID}               xpath=//div[contains(@class,'k-detail-row')]//div[contains(@class,'k-grid')]
${LOC_SM_NOTES_SM_SUCCESSFUL}      xpath=//div[contains(@class,'k-detail-row')]//td[contains(normalize-space(text()),'SIM Movement Successful')]
${LOC_SM_NOTES_SM_ENTRY}           xpath=//div[contains(@class,'k-detail-row')]//td[contains(normalize-space(text()),'SIM Movement')]

# ── Manage Account / Admin ────────────────────────────────────────────
${LOC_SM_NAV_ADMIN}                id=admin-menu-icon
${LOC_SM_ADMIN_ACCOUNT_TAB}        xpath=//ul[@id='pageHeading']//a[@href='/ManageAccount']
${LOC_SM_ACCOUNT_GRID}             id=ManageAccountGrid
${LOC_SM_ACCOUNT_SEARCH_INPUT}     xpath=//input[@name='searchValue' and @placeholder='Enter Search Text']
${LOC_SM_SHOW_CUST_TOGGLE}         id=switch
${LOC_SM_ACCT_TAB_CUSTOMER}        xpath=//ul[@id='tabHeading']//a[contains(text(),'Customer')]
${LOC_SM_ACCT_BU_TAB}              xpath=//ul[@id='tabHeading']//a[contains(text(),'Business Unit')]

# ── Audit Trail ───────────────────────────────────────────────────────
${LOC_SM_AUDIT_GRID}               id=ManageAuditTrailGrid
${LOC_SM_AUDIT_ACCOUNT_INPUT}      xpath=//input[@name='account' and @placeholder='Select Account']
${LOC_SM_AUDIT_SM_ROW}             xpath=//div[@id='ManageAuditTrailGrid']//td[contains(normalize-space(text()),'SIM Movement')]

# ── Header notifications (Request Id in div.alertrequestno; list in .infinite-scroll-component) ──
${LOC_SM_NOTIFICATION_BELL}        id=dropdownbell
# Panel may live inside #openNotificationPopup or only under .fixed-height-not (no id on wrapper)
${LOC_SM_NOTIFICATION_PANEL}       xpath=//*[@id='openNotificationPopup'] | //div[contains(@class,'fixed-height-not')]
${LOC_SM_NOTIFICATION_SCROLL}      xpath=//div[contains(@class,'infinite-scroll-component')]
# First list item’s Request No — top of scroll list after bell opens
${LOC_SM_NOTIFICATION_FIRST_RID}   xpath=(//div[contains(@class,'fixed-height-not')]//div[contains(@class,'alertrequestno')])[1]

# ── Batch Job Log ─────────────────────────────────────────────────────
# Kendo grid busy indicator (filter / expand detail)
${LOC_SM_K_LOADING_MASK}           xpath=//*[contains(@class,'k-loading-mask')]
${LOC_SM_BATCH_GRID}               xpath=//div[contains(@class,'k-grid')]
${LOC_SM_BATCH_JOB_SUCCESS}        xpath=//td[contains(@class,'success') or contains(normalize-space(text()),'Success') or contains(normalize-space(text()),'Completed')]
# Batch Job Log toolbar (dynamic id — use name+placeholder; scope to grid card when possible)
${LOC_SM_BATCH_SEARCH_INPUT}       xpath=(//div[contains(@class,'k-grid')]/ancestor::div[contains(@class,'card') or contains(@class,'panel') or contains(@class,'content')][1]//input[@name='searchValue' and @placeholder='Enter Search Text'])[1] | //input[@name='searchValue' and @placeholder='Enter Search Text'] | //input[@id='searchinput']

# ── Alerts / Toast ────────────────────────────────────────────────────
${LOC_SM_TOAST_SUCCESS}            xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_SM_TOAST_ERROR}              xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_SM_SUCCESS_MSG}              xpath=//*[contains(text(),'successfully') or contains(text(),'Success') or contains(text(),'Submitted')]
${LOC_SM_PERSONAL_DATA_ALERT}      xpath=//div[contains(text(),'personal data') or contains(.,'personal data')]
${LOC_SM_ALERT_CLOSE}              xpath=//button[@type='button' and (contains(@class,'close') or contains(text(),'×'))]

# ── SMF: SIM Movement result popup (auto-shows after Submit+Proceed) ──────────
# Popup title is the GC Request ID (starts with "GC")
${LOC_SMF_RESULT_POPUP}           xpath=//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]
${LOC_SMF_RESULT_POPUP_TITLE}     xpath=(//div[contains(@class,'modal-header') or contains(@class,'modal-title')]//*[starts-with(normalize-space(text()),'GC')])[1]
${LOC_SMF_RESULT_POPUP_CLOSE}     xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//button[contains(@class,'close') or contains(@aria-label,'Close')])[1]
${LOC_SMF_RESULT_POPUP_GRID}      xpath=//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]
${LOC_SMF_RESULT_POPUP_OLD_VAL}   xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]//tr[contains(@class,'k-master-row')])[1]//td[4]
${LOC_SMF_RESULT_POPUP_NEW_VAL}   xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]//tr[contains(@class,'k-master-row')])[1]//td[5]
${LOC_SMF_RESULT_POPUP_RESULT}    xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]//tr[contains(@class,'k-master-row')])[1]//td[6]
${LOC_SMF_RESULT_POPUP_STATUS}    xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]//tr[contains(@class,'k-master-row')])[1]//td[7]
${LOC_SMF_RESULT_POPUP_DETAILS}   xpath=(//div[contains(@class,'modal') and .//*[starts-with(normalize-space(text()),'GC')]]//div[contains(@class,'k-grid')]//tr[contains(@class,'k-master-row')])[1]//td[8]

# ── SMF: Audit Trail — Description column filter ──────────────────────────────
${LOC_SMF_AUDIT_DESC_FILTER_BTN}  xpath=//div[@id='ManageAuditTrailGrid']//th[contains(.,'DESCRIPTION')]//a[contains(@class,'k-grid-filter')]
${LOC_SMF_AUDIT_FILTER_INPUT}     xpath=//div[@id='ManageAuditTrailGrid']//div[contains(@class,'k-filter-menu')]//input[@type='text']
${LOC_SMF_AUDIT_FILTER_APPLY}     xpath=//div[@id='ManageAuditTrailGrid']//div[contains(@class,'k-filter-menu')]//button[contains(text(),'Filter') or @type='submit']
${LOC_SMF_AUDIT_FIRST_OLD_VAL}    xpath=(//div[@id='ManageAuditTrailGrid']//tr[contains(@class,'k-master-row')])[1]//td[8]
${LOC_SMF_AUDIT_FIRST_NEW_VAL}    xpath=(//div[@id='ManageAuditTrailGrid']//tr[contains(@class,'k-master-row')])[1]//td[9]
${LOC_SMF_AUDIT_FIRST_RESULT}     xpath=(//div[@id='ManageAuditTrailGrid']//tr[contains(@class,'k-master-row')])[1]//td[10]

# ── SMF: Notes tab — first row column values ──────────────────────────────────
# Handles both k-master-row (expandable) and k-alt/plain tr (flat) Kendo grids
${LOC_SMF_NOTES_FIRST_ROW}        xpath=(//tr[contains(@class,'k-detail-row')]//tbody/tr[not(contains(@class,'k-grouping-row')) and not(contains(@class,'k-header')) and not(contains(@class,'k-grid-norecords'))])[1]
