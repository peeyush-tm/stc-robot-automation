*** Variables ***
# ── Navigation — Reports sidebar and Create button ───────────────────
${LOC_NAV_REPORTS}                 xpath=//a[contains(@href,'/Report') and not(contains(@href,'Create'))]
${LOC_BTN_CREATE_REPORT}           xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateReports')]

# ── Create Report Form — Dropdowns and inputs ──────────────────────────
# reportCategory: custom DIV.Dropdownlist component (no native <select>)
#   Structure: div.coldiv > div.Dropdownlist > div.searcharea >
#              [input.searchInput] + [div.select > div.selectBtn + div.selectDropdown]
#   Trigger: div.selectBtn.form-control  (NOT the outer div.Dropdownlist)
${LOC_DDL_REPORT_CATEGORY}         xpath=//label[contains(normalize-space(),'Report Category')]/following-sibling::div[contains(@class,'coldiv')]
${LOC_RC_TRIGGER}                  xpath=//label[contains(normalize-space(),'Report Category')]/following-sibling::div[contains(@class,'coldiv')]//div[contains(@class,'selectBtn')]
${LOC_RC_SEARCH_INPUT}             xpath=//label[contains(normalize-space(),'Report Category')]/following-sibling::div[contains(@class,'coldiv')]//input[contains(@class,'searchInput')]
${LOC_RC_DROPDOWN}                 xpath=//label[contains(normalize-space(),'Report Category')]/following-sibling::div[contains(@class,'coldiv')]//div[contains(@class,'selectDropdown')]
${LOC_DDL_VIEW_CRITERION}          xpath=//select[@name='viewCriteria']
${LOC_INPUT_FROM_DATE}             id=fromDate
${LOC_INPUT_TO_DATE}               id=toDate
${LOC_DDL_DISPLAY_LEVEL}           xpath=//select[@name='displayLevel']
${LOC_DDL_ACCOUNT}                 xpath=//select[@name='account']
${LOC_DDL_REPORT_FORMAT}           xpath=//select[@name='format']

# ── Validation error locators (Joi / inline) ───────────────────────────
# Report Category is a custom dropdown (no native select); error is inline text e.g. "Please Select Report Category"
${LOC_ERR_REPORT_CATEGORY}         xpath=//*[contains(normalize-space(),'Please Select Report Category') or contains(normalize-space(),'select report category')]
${LOC_ERR_VIEW_CRITERION}          xpath=//select[@name='viewCriteria']/following-sibling::*[contains(@class,'error') or contains(@class,'alert-danger')]
${LOC_ERR_DISPLAY_LEVEL}           xpath=//select[@name='displayLevel']/following-sibling::*[contains(@class,'error') or contains(@class,'alert-danger')]
${LOC_ERR_REPORT_FORMAT}           xpath=//select[@name='format']/following-sibling::*[contains(@class,'error') or contains(@class,'alert-danger')]

# ── Send Email ───────────────────────────────────────────────────────
# UI label is "Send E-mail Notification" (hyphen)
${LOC_CHK_SEND_EMAIL}              xpath=//div[contains(.,'E-mail') and contains(.,'Send')]//input[@type='checkbox'] | //label[contains(.,'E-mail') or contains(.,'Email')][contains(.,'Send') or contains(.,'send')]//input[@type='checkbox'] | //label[contains(.,'E-mail')]/following-sibling::input[@type='checkbox'][1]
${LOC_INPUT_EMAIL_RECIPIENT}       xpath=//input[contains(@placeholder,'email') or contains(@placeholder,'Email')]

# ── Form buttons ─────────────────────────────────────────────────────
${LOC_BTN_CREATE}                  xpath=//input[@type='button' and contains(@class,'btn-custom-color')]
${LOC_BTN_CLOSE}                   xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]

# ── Toasts ───────────────────────────────────────────────────────────
${LOC_TOAST_SUCCESS}               xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_TOAST_ERROR}                 xpath=//div[contains(@class,'Toastify__toast--error')]

# ── Report listing page — body / grid container ────────────────────────
${LOC_REPORT_PAGE_BODY}            xpath=//a[contains(@href,'/CreateReports')] | //div[contains(@class,'k-grid')]

# ── Report listing — filter section ──────────────────────────────────
${LOC_FILTER_REPORT_NAME}          xpath=//input[contains(@placeholder,'Report Name') or contains(@name,'reportName') or (preceding-sibling::*[contains(.,'Report Name')] or following-sibling::*[contains(.,'Report Name')])]
${LOC_FILTER_REPORT_NAME_INPUT}    xpath=//input[@placeholder='Enter Search Text' or @placeholder='Search' or contains(translate(@placeholder,'SEARCH','search'),'search')]
${LOC_BTN_APPLY_FILTER}            xpath=//button[contains(normalize-space(),'Apply Filter')] | //a[contains(normalize-space(),'Apply Filter')] | //*[self::button or self::a or self::span][contains(normalize-space(),'Apply Filter')]
${LOC_BTN_RESET_FILTER}            xpath=//*[normalize-space()='Reset']

# ── Report listing — Kendo grid ────────────────────────────────────────
${LOC_REPORT_GRID}                 xpath=//div[contains(@class,'k-grid')]
${LOC_REPORT_GRID_ANY}             xpath=//div[contains(@class,'k-grid')]
${LOC_REPORT_GRID_TBODY}           xpath=//div[contains(@class,'k-grid')]//tbody
${LOC_REPORT_GRID_FIRST_ROW}       xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]

# ── First row — REPORT NAME column
# Kendo grid adds a k-hierarchy-cell (td[1]) for the expand toggle before data cells.
# td[2] = ACTION (delete + download), td[3] = REPORT ID, td[4] = REPORT CATEGORY,
# td[5] = REPORT NAME, td[6] = DISPLAY LEVEL, td[7] = ACCOUNT
${LOC_FIRST_ROW_REPORT_NAME_CELL}  xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]//td[5]
${LOC_FIRST_ROW_ACTION_CELL}       xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]//td[2]

# ── Action column — Delete (trash) and Download (arrow) icons ──────────
# td[2] is the ACTION column; first <a> = delete, second <a> = download (only when report is ready)
${LOC_FIRST_ROW_DELETE_ICON}       xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]//td[2]//a[1]
${LOC_FIRST_ROW_DOWNLOAD_ICON}     xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]//td[2]//a[position()>1]
${LOC_FIRST_ROW_DOWNLOAD_LINK}     xpath=(//div[contains(@class,'k-grid')]//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')])[1]//td[2]//a[position()>1]
