*** Variables ***
# ── Navigation (Admin sidebar — same pattern as SIM Product Type) ───────────
${LOC_LBL_ADMIN_TOGGLE}           xpath=//i[contains(@class,'admin-menu-icon')]
${LOC_LBL_MANAGE_USER_GRID}       id=gridData
# Labels link after Admin expands (left sidebar menu)
${LOC_LBL_NAV_MANAGE_LABEL}       link=Manage Label
${LOC_LBL_TAB_MANAGE_LABEL}       xpath=//ul[@id='pageHeading']//a[@href='/ManageLabel']

# ── Manage Label listing ────────────────────────────────────────────────────
${LOC_LBL_GRID}                   id=gridData
# Create Label primary action on Manage Label listing (supports <a> or <button>)
${LOC_LBL_CREATE_BTN}             xpath=(//a[contains(@href,'/CreateLabel')] | //*[self::a or self::button][contains(normalize-space(.),'Create Label')])[1]
# Listing search box: "Enter Search Text" placeholder (above gridData, NOT the global ICCID search bar)
${LOC_LBL_SEARCH_INPUT}           xpath=//input[@placeholder='Enter Search Text']
${LOC_LBL_SEARCH_BTN}             xpath=//input[@placeholder='Enter Search Text']/following::*[self::button or self::span][contains(@class,'search') or @id='searchButton'][1]
${LOC_LBL_EDIT_ICON_IN_ROW}      xpath=//tr[contains(@class,'k-master-row')]//*[contains(@class,'k-grid-Edit') or contains(@class,'k-i-edit') or contains(@class,'fa-pencil')]

# Delete icon and confirmation popup on Manage Label listing
${LOC_LBL_DELETE_ICON_IN_ROW}      xpath=//tr[contains(@class,'k-master-row')]//*[contains(@class,'k-grid-Delete') or contains(@class,'fa-trash')][1]
${LOC_LBL_DELETE_CONFIRM_OK}       xpath=//div[contains(@class,\"modal-dialog\")]//button[normalize-space(.)=\"OK\"]
${LOC_LBL_DELETE_CONFIRM_CANCEL}   xpath=//div[contains(@class,\"modal-dialog\")]//button[normalize-space(.)=\"Cancel\"]

# ── Create / Edit Label form ────────────────────────────────────────────────
# Level dropdown: native <select name="level" data-testid="level">
${LOC_LBL_LEVEL_SELECT}           xpath=//select[@name='level' and @data-testid='level']
# Account: custom dropdown with search box + div.selectBtn + div.option items
${LOC_LBL_ACCOUNT_TRIGGER}        xpath=//div[contains(@class,'Dropdownlist')]//div[contains(@class,'select') and @data-testid='accountId']//div[contains(@class,'selectBtn')]
${LOC_LBL_ACCOUNT_SEARCH}         xpath=//div[contains(@class,'Dropdownlist')]//input[contains(@class,'searchInput')]
${LOC_LBL_ACCOUNT_OPTIONS}        xpath=//div[contains(@class,'Dropdownlist')]//div[contains(@class,'selectDropdown')]//div[@data-testid='accountId' and contains(@class,'option')]
${LOC_LBL_NAME_INPUT}             name=name
${LOC_LBL_COLOR_PICKER}           id=colorpicker
${LOC_LBL_DESCRIPTION_INPUT}      name=description
${LOC_LBL_SUBMIT_CREATE}         xpath=//input[@type='button' and contains(@class,'btn-custom-color') and @value='Submit']
${LOC_LBL_SUBMIT_UPDATE}         xpath=//input[@type='button' and contains(@class,'btn-custom-color') and @value='Update']
${LOC_LBL_CLOSE_BTN}             xpath=//input[@type='button' and contains(@class,'btn-cancel-color') and @value='Close']

# ── Validation & toasts ─────────────────────────────────────────────────────
${LOC_LBL_ALERT_DANGER}          xpath=//div[contains(@class,'alert-danger')]
${LOC_LBL_TOAST_SUCCESS}         xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_LBL_TOAST_ERROR}           xpath=//div[contains(@class,'Toastify__toast--error')]

# ── Tag Assignment on Manage Devices (TC_021) ──────────────────────────────
${LOC_LA_GRID}                    id=gridData
${LOC_LA_FIRST_ROW}               xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_LA_FIRST_ROW_CB}            xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]
${LOC_LA_ACTION_DROP}              name=actionDrop
${LOC_LA_TAG_MODAL}                id=assignBulkLabelPopup
${LOC_LA_TAG_ACTION_DD}            name=tagsAction
${LOC_LA_BULK_ASSIGN_SEARCH}       name=bulkAssign
${LOC_LA_BULK_UNASSIGN_SEARCH}     name=bulkUnassign
${LOC_LA_LABEL_CHECKBOXES}         xpath=//div[@id='assignBulkLabelPopup']//div[contains(@class,'form-groupcheck')]//input[@type='checkbox']
${LOC_LA_FIRST_LABEL_CB}           xpath=(//div[@id='assignBulkLabelPopup']//div[contains(@class,'form-groupcheck')]//input[@type='checkbox'])[1]
${LOC_LA_FIRST_LABEL_SPAN}         xpath=(//div[@id='assignBulkLabelPopup']//div[contains(@class,'form-groupcheck')]//span[contains(@class,'lableclass')])[1]
${LOC_LA_ASSIGN_BTN}               xpath=//div[@id='assignBulkLabelPopup']//button[contains(@class,'btn-custom-color') and normalize-space()='Assign']
${LOC_LA_UNASSIGN_BTN}             xpath=//div[@id='assignBulkLabelPopup']//button[contains(@class,'btn-custom-color') and normalize-space()='Unassign']
${LOC_LA_MODAL_CLOSE_BTN}          xpath=//div[@id='assignBulkLabelPopup']//button[contains(@class,'btn-cancel-color')]
${LOC_LA_TOAST_SUCCESS}            xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_LA_TOAST_ERROR}              xpath=//div[contains(@class,'Toastify__toast--error')]
