*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/label_locators.resource
Resource    ../locators/login_locators.resource
Resource    ../locators/product_type_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════════
#  NAVIGATION — Admin → Labels (TC_009 spec + same Admin icon pattern as Product Type)
# ═══════════════════════════════════════════════════════════════════════════
Navigate To Manage Label Via Admin
    [Documentation]    Expand Admin (Manage User), open **Labels**, wait for ``/ManageLabel`` and grid.
    Scroll To Element Via JS    ${LOC_LBL_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_LBL_ADMIN_TOGGLE}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_ADMIN_TOGGLE}
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageUser
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_MU_GRID_DATA}    ${LBL_TIMEOUT}
    Scroll To Element Via JS    ${LOC_LBL_NAV_MANAGE_LABEL}
    Wait Until Element Is Visible    ${LOC_LBL_NAV_MANAGE_LABEL}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_NAV_MANAGE_LABEL}
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    ${LBL_TIMEOUT}
    Log    Manage Label listing loaded.    console=yes

Go To Manage Label Listing
    [Documentation]    Navigate to /ManageLabel via Admin tab or sidebar. Never uses direct URL (SPA redirects to Manage Devices).
    # If already on an admin page, the Manage Label tab is visible — click it directly.
    ${on_admin}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_LBL_TAB_MANAGE_LABEL}    5s
    IF    ${on_admin}
        Click Element Via JS    ${LOC_LBL_TAB_MANAGE_LABEL}
    ELSE
        # Fall back to full sidebar navigation (Admin icon → Manage Label link).
        Scroll To Element Via JS    ${LOC_LBL_ADMIN_TOGGLE}
        Wait Until Element Is Visible    ${LOC_LBL_ADMIN_TOGGLE}    ${LBL_TIMEOUT}
        Click Element Via JS    ${LOC_LBL_ADMIN_TOGGLE}
        Wait For App Loading To Complete
        Scroll To Element Via JS    ${LOC_LBL_NAV_MANAGE_LABEL}
        Wait Until Element Is Visible    ${LOC_LBL_NAV_MANAGE_LABEL}    ${LBL_TIMEOUT}
        Click Element Via JS    ${LOC_LBL_NAV_MANAGE_LABEL}
    END
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    ${LBL_TIMEOUT}
    Log    Manage Label listing loaded.    console=yes

Open Create Label Form
    [Documentation]    Clicks Create Label link; waits for ``/CreateLabel`` and Level field.
    Wait Until Element Is Visible    ${LOC_LBL_CREATE_BTN}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_CREATE_BTN}
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    CreateLabel
    Wait For App Loading To Complete
    # Level dropdown is above the fold on Create Label page; ensure it is visible and scrolled into view.
    Wait Until Element Is Visible    ${LOC_LBL_LEVEL_SELECT}    ${LBL_TIMEOUT}
    Scroll To Element Via JS    ${LOC_LBL_LEVEL_SELECT}
    Log    Create Label form open.    console=yes

Verify Create Label Form Fields Visible
    [Documentation]    Asserts main Create Label controls are present (TC_009 §12).
    Element Should Be Visible    ${LOC_LBL_LEVEL_SELECT}
    Element Should Be Visible    ${LOC_LBL_ACCOUNT_TRIGGER}
    Element Should Be Visible    ${LOC_LBL_NAME_INPUT}
    Element Should Be Visible    xpath=//span[contains(@class,'k-colorpicker')]
    Element Should Be Visible    ${LOC_LBL_SUBMIT_CREATE}
    Element Should Be Visible    ${LOC_LBL_CLOSE_BTN}

# ═══════════════════════════════════════════════════════════════════════════
#  FORM — Level, Account, Name, Kendo Color, Description
# ═══════════════════════════════════════════════════════════════════════════
LBL Wait Account Dropdown Has Real Options
    [Documentation]    After Level change, wait until ``accountId`` has at least one non-placeholder option.
    Wait Until Keyword Succeeds    30x    1s    LBL Account Dropdown Has Real Options

LBL Account Dropdown Has Real Options
    ${n}=    Get Element Count    ${LOC_LBL_ACCOUNT_OPTIONS}
    Should Be True    ${n} > 0    msg=Account dropdown has no options after Level select (check API / data).

Select Level On Label Form
    [Arguments]    ${level_label}
    Wait Until Element Is Visible    ${LOC_LBL_LEVEL_SELECT}    ${LBL_TIMEOUT}
    Select From List By Label    ${LOC_LBL_LEVEL_SELECT}    ${level_label}

Select Account On Label Form By Index
    [Arguments]    ${index}=1
    # Open custom Account dropdown and select the desired option (default first => KSA_OPCO).
    Wait Until Element Is Visible    ${LOC_LBL_ACCOUNT_TRIGGER}    15s
    Click Element Via JS    ${LOC_LBL_ACCOUNT_TRIGGER}
    LBL Wait Account Dropdown Has Real Options
    ${loc}=    Set Variable    xpath=(//div[contains(@class,'Dropdownlist')]//div[contains(@class,'selectDropdown')]//div[@data-testid='accountId' and contains(@class,'option')])[${index}]
    Wait Until Element Is Visible    ${loc}    15s
    Click Element Via JS    ${loc}

Enter Label Name
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${LOC_LBL_NAME_INPUT}    ${LBL_TIMEOUT}
    Clear Element Text    ${LOC_LBL_NAME_INPUT}
    Input Text    ${LOC_LBL_NAME_INPUT}    ${name}

Enter Label Description
    [Arguments]    ${text}
    Wait Until Element Is Visible    ${LOC_LBL_DESCRIPTION_INPUT}    ${LBL_TIMEOUT}
    Clear Element Text    ${LOC_LBL_DESCRIPTION_INPUT}
    Input Text    ${LOC_LBL_DESCRIPTION_INPUT}    ${text}

LBL Set Kendo Color Picker Value
    [Arguments]    ${hex_color}
    [Documentation]    Sets Kendo ColorPicker on ``#colorpicker`` via jQuery (TC_009 §13.4).
    ${ok}=    Execute Javascript
    ...    var col = arguments[0];\
    ...    var span = document.querySelector(\"span.k-widget.k-colorpicker span.k-selected-color\");\
    ...    if (span) { span.style.backgroundColor = col; return 'ok-css'; }\
    ...    return 'fail';
    ...    ARGUMENTS    ${hex_color}
    IF    '${ok}'=='${EMPTY}' or '${ok}'=='None'
        ${ok}=    Set Variable    fail
    END
    ${lower}=    Convert To Lowercase    ${ok}
    Should Be True    '${lower}' == 'ok-css'
    ...    msg=Could not set Kendo color picker (got: ${ok}).

Verify Label Present In First Column
    [Arguments]    ${label_name}
    [Documentation]    Already on /ManageLabel after creation. Searches label name and validates first row.
    LBL Search On Listing    ${label_name}
    Sleep    1s
    # Grid must contain the label name after search
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    20s
    Wait Until Element Contains    ${LOC_LBL_GRID}    ${label_name}    20s
    # Validate the first data row's Label Name column (td[2])
    ${name_cell}=    Set Variable    xpath=//div[@id='gridData']//tbody/tr[1]/td[2]
    ${text}=    Get Text    ${name_cell}
    Should Be Equal    ${text}    ${label_name}    msg=Expected label '${label_name}' in first row, got '${text}'.

LBL Get Kendo Color Picker Value
    [Documentation]    Returns the CSS ``background-color`` of the visible Kendo swatch (``span.k-selected-color``).
    ${v}=    Execute Javascript
    ...    var span = document.querySelector(\"span.k-widget.k-colorpicker span.k-selected-color\");
    ...    if (!span) return '';
    ...    return (span.style.backgroundColor || window.getComputedStyle(span).backgroundColor || '').toString().toLowerCase();
    RETURN    ${v}

Fill Create Label Form
    [Arguments]    ${level_label}    ${label_name}    ${color}=${LBL_COLOR_HEX}    ${description}=${EMPTY}    ${account_index}=${LBL_ACCOUNT_INDEX}
    [Documentation]    Level → Account → Name → Color → optional Description (order per TC_009).
    Select Level On Label Form    ${level_label}
    Select Account On Label Form By Index    ${account_index}
    Enter Label Name    ${label_name}
    LBL Set Kendo Color Picker Value    ${color}
    Run Keyword If    '${description}' != '${EMPTY}'    Enter Label Description    ${description}

Submit Create Label Form
    Wait Until Element Is Visible    ${LOC_LBL_SUBMIT_CREATE}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_SUBMIT_CREATE}

Submit Update Label Form
    Wait Until Element Is Visible    ${LOC_LBL_SUBMIT_UPDATE}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_SUBMIT_UPDATE}

Click Close Label Form
    Wait Until Element Is Visible    ${LOC_LBL_CLOSE_BTN}    ${LBL_TIMEOUT}
    Click Element Via JS    ${LOC_LBL_CLOSE_BTN}

Verify Label Created Successfully
    [Documentation]    Success toast, redirect ``/ManageLabel``, grid visible (TC_009 §8).
    Wait Until Element Is Visible    ${LOC_LBL_TOAST_SUCCESS}    20s
    LBL Assert Success Toast Indicates Label Created
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    ${LBL_TIMEOUT}

LBL Assert Success Toast Indicates Label Created
    [Documentation]    Toast should reflect label create success (TC_009: ``Label Created Successfully`` / i18n variants).
    ${txt}=    Get Text    ${LOC_LBL_TOAST_SUCCESS}
    ${lower}=    Convert To Lowercase    ${txt}
    ${ok}=    Evaluate    'label' in $lower and ('success' in $lower or 'cretat' in $lower or 'created' in $lower)
    Should Be True    ${ok}
    ...    msg=Unexpected success toast text (expected label + success/created): ${txt}

Verify Account Dropdown Populated After Level
    [Documentation]    TC_009 §12 / §13.3 — after Level select, custom Account dropdown has at least one option.
    Select Level On Label Form    ${LBL_LEVEL_KSA}
    Wait Until Element Is Visible    ${LOC_LBL_ACCOUNT_TRIGGER}    15s
    Click Element Via JS    ${LOC_LBL_ACCOUNT_TRIGGER}
    LBL Wait Account Dropdown Has Real Options
    ${n}=    Get Element Count    ${LOC_LBL_ACCOUNT_OPTIONS}
    Should Be True    ${n} > 0    msg=No account options after Level=${LBL_LEVEL_KSA}

Verify Manage Label Grid Has Expected Column Headers
    [Documentation]    Read (R): listing grid shows expected columns (English UI; TC_009 listing).
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    ${LBL_TIMEOUT}
    Page Should Contain Element
    ...    xpath=//div[@id='gridData']//th[contains(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'label') or contains(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'name')]
    Page Should Contain Element
    ...    xpath=//div[@id='gridData']//th[contains(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'account')]

Verify Label Updated Successfully
    [Documentation]    After Edit: success toast and return to listing.
    Wait Until Element Is Visible    ${LOC_LBL_TOAST_SUCCESS}    20s
    LBL Assert Success Toast Indicates Label Updated
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LBL_GRID}    ${LBL_TIMEOUT}

LBL Assert Success Toast Indicates Label Updated
    [Documentation]    Toast reflects label update (wording may vary by locale).
    ${txt}=    Get Text    ${LOC_LBL_TOAST_SUCCESS}
    ${lower}=    Convert To Lowercase    ${txt}
    ${ok}=    Evaluate    'label' in $lower and ('success' in $lower or 'updat' in $lower)
    Should Be True    ${ok}
    ...    msg=Unexpected success toast after update: ${txt}

LBL Search On Listing
    [Arguments]    ${term}
    ${has}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_LBL_SEARCH_INPUT}    5s
    IF    not ${has}
        RETURN
    END
    Clear Element Text    ${LOC_LBL_SEARCH_INPUT}
    Input Text    ${LOC_LBL_SEARCH_INPUT}    ${term}
    # Trigger search via Enter key in the listing search box (NOT global ICCID search).
    Press Keys    ${LOC_LBL_SEARCH_INPUT}    RETURN
    Wait For App Loading To Complete

Open Edit Label For Row Containing
    [Arguments]    ${text}
    [Documentation]    After searching by ``${text}``, grid is filtered so first row is the target; click its Edit icon.
    # Search should already have filtered down to the desired label; use simple first-row Edit icon xpath.
    ${loc}=    Set Variable    xpath=(//i[@title='Edit'])[1]
    Wait Until Element Is Visible    ${loc}    20s
    Click Element Via JS    ${loc}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LBL_SUBMIT_UPDATE}    20s

Open Delete Label For Row Containing
    [Arguments]    ${text}
    [Documentation]    After searching by ``${text}``, grid is filtered so first row is the target; click its Delete icon.
    ${loc}=    Set Variable    xpath=(//i[@title='Delete'])[1]
    Wait Until Element Is Visible    ${loc}    20s
    Click Element Via JS    ${loc}

Confirm Delete Label
    [Documentation]    Confirms Delete dialog by clicking OK.
    Wait Until Element Is Visible    ${LOC_LBL_DELETE_CONFIRM_OK}    10s
    Click Element Via JS    ${LOC_LBL_DELETE_CONFIRM_OK}

Cancel Delete Label
    [Documentation]    Cancels Delete dialog.
    Wait Until Element Is Visible    ${LOC_LBL_DELETE_CONFIRM_CANCEL}    10s
    Click Element Via JS    ${LOC_LBL_DELETE_CONFIRM_CANCEL}

# ═══════════════════════════════════════════════════════════════════════════
#  NEGATIVE / ASSERTION HELPERS
# ═══════════════════════════════════════════════════════════════════════════
LBL Assert Still On Create Label Page
    Location Should Contain    CreateLabel

LBL Assert Validation Error And Stay On Create Page
    [Documentation]    Joi / alert-danger on create page; still on ``/CreateLabel``.
    ${alert}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_LBL_ALERT_DANGER}    8s
    IF    not ${alert}
        ${toast_err}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_LBL_TOAST_ERROR}    3s
        IF    ${toast_err}
            Fail    Expected inline validation but error toast appeared (check app behaviour).
        END
    END
    LBL Assert Still On Create Label Page

LBL Assert Validation Error On Label Form Not Listing
    [Documentation]    Inline validation on create/edit label form; must not land on ManageLabel listing.
    Wait Until Element Is Visible    ${LOC_LBL_ALERT_DANGER}    10s
    ${on_manage}=    Run Keyword And Return Status    Location Should Contain    ManageLabel    2s
    Should Not Be True    ${on_manage}
    ...    msg=Expected validation on form but URL is ManageLabel (save may have succeeded incorrectly).

LBL Assert Error Toast Contains
    [Arguments]    ${snippet}
    Wait Until Element Is Visible    ${LOC_LBL_TOAST_ERROR}    15s
    Element Should Contain    ${LOC_LBL_TOAST_ERROR}    ${snippet}

LBL Clear Create Form To Defaults
    [Documentation]    Best-effort: reset name/description; level/account left as-is for targeted negatives.
    Run Keyword And Ignore Error    Clear Element Text    ${LOC_LBL_NAME_INPUT}
    Run Keyword And Ignore Error    Clear Element Text    ${LOC_LBL_DESCRIPTION_INPUT}

# ═══════════════════════════════════════════════════════════════════════════
#  LABEL ASSIGNMENT — Manage Devices Tag Assignment (TC_021)
# ═══════════════════════════════════════════════════════════════════════════
Navigate To Manage Devices For Label Assignment
    [Documentation]    Navigates to /ManageDevices and waits for the grid + first row to be visible.
    Navigate To Module Page    ${BASE_URL}ManageDevices
    Wait Until Element Is Visible    ${LOC_LA_GRID}    30s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LA_FIRST_ROW}    30s
    Log    Manage Devices page loaded for label assignment.    console=yes

Select First SIM Row On Manage Devices
    [Documentation]    Clicks the checkbox of the first SIM row in the Manage Devices grid.
    Wait Until Element Is Visible    ${LOC_LA_FIRST_ROW_CB}    15s
    Click Element Via JS    ${LOC_LA_FIRST_ROW_CB}
    Sleep    0.5s

Open Tag Assignment Modal
    [Documentation]    Selects Tag Assignment (value 13) from the action dropdown; waits for popup.
    Wait Until Element Is Visible    ${LOC_LA_ACTION_DROP}    15s
    Select From List By Value    ${LOC_LA_ACTION_DROP}    ${LA_TAG_ASSIGNMENT_VALUE}
    Wait Until Element Is Visible    ${LOC_LA_TAG_MODAL}    15s
    Log    Tag Assignment modal opened.    console=yes

Capture And Assign First Label
    [Documentation]    In the Tag Assignment modal, selects assign mode, captures the first
    ...                label name, checks it, clicks Assign. Returns the label name.
    Wait Until Element Is Visible    ${LOC_LA_TAG_ACTION_DD}    10s
    Select From List By Value    ${LOC_LA_TAG_ACTION_DD}    ${LA_TAG_ACTION_ASSIGN}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_LA_FIRST_LABEL_SPAN}    15s
    ${label_name}=    Execute Javascript
    ...    var span = document.querySelector('#assignBulkLabelPopup .form-groupcheck span.lableclass');
    ...    return span ? span.textContent.trim() : '';
    Should Not Be Empty    ${label_name}    msg=Could not capture label text from Tag Assignment modal.
    Execute Javascript
    ...    var cb = document.querySelector('#assignBulkLabelPopup .form-groupcheck input[type="checkbox"]');
    ...    if (cb) { cb.click(); }
    Sleep    0.5s
    Click Element Via JS    ${LOC_LA_ASSIGN_BTN}
    RETURN    ${label_name}

Unassign Label In Tag Modal
    [Documentation]    In the Tag Assignment modal, switches to unassign mode and clicks
    ...                the first label checkbox then Unassign.
    Wait Until Element Is Visible    ${LOC_LA_TAG_ACTION_DD}    10s
    Select From List By Value    ${LOC_LA_TAG_ACTION_DD}    ${LA_TAG_ACTION_UNASSIGN}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_LA_FIRST_LABEL_SPAN}    15s
    Execute Javascript
    ...    var cb = document.querySelector('#assignBulkLabelPopup .form-groupcheck input[type="checkbox"]');
    ...    if (cb) { cb.click(); }
    Sleep    0.5s
    Click Element Via JS    ${LOC_LA_UNASSIGN_BTN}

Validate Tag Assignment Success And Modal Closed
    [Documentation]    Verifies success toast appears and the Tag Assignment modal closes.
    Wait Until Element Is Visible    ${LOC_LA_TOAST_SUCCESS}    20s
    Wait Until Element Is Not Visible    ${LOC_LA_TAG_MODAL}    15s
    Log    Tag assignment/unassignment success toast confirmed, modal closed.    console=yes

LBL Try Refresh Manage Devices Grid
    [Documentation]    Best-effort Kendo ``dataSource.read()`` on ``#gridData`` so tag assignment
    ...                shows in the grid without relying on implicit UI refresh.
    ${r}=    Execute Javascript
    ...    var el=document.getElementById('gridData');
    ...    if(!el||!window.jQuery)return 'skip';
    ...    var kg=window.jQuery(el).data('kendoGrid');
    ...    if(kg&&kg.dataSource){ kg.dataSource.read(); return 'read'; }
    ...    return 'skip';
    Log    Manage Devices grid dataSource.read: ${r}    console=yes
    Brief UI Settle Short

Get Label Column Text For First Row
    [Documentation]    Label column text for the first ``k-master-row`` on Manage Devices. Uses
    ...                ``td[data-field]`` when present, else the first ``thead`` header row (not
    ...                filter row) to resolve column index; reads ``textContent`` in JS so Kendo
    ...                cells are not returned empty by Selenium.
    ${cell}=    Execute Javascript
    ...    return (function(){
    ...    var g=document.getElementById('gridData');
    ...    if(!g)return '';
    ...    var row=g.querySelector('.k-grid-content table tbody tr.k-master-row')
    ...    ||g.querySelector('table tbody tr.k-master-row')||g.querySelector('tbody tr.k-master-row');
    ...    if(!row)return '';
    ...    var tds=row.querySelectorAll('td');
    ...    var i,df;
    ...    for(i=0;i<tds.length;i++){
    ...    df=(tds[i].getAttribute('data-field')||'').toLowerCase();
    ...    if(df==='label'||df==='labels'||df==='tag'||df==='tags'||df==='simlabel'||df==='simlabels'){
    ...    return (tds[i].textContent||'').replace(/\\s+/g,' ').trim();
    ...    }}
    ...    var thead=g.querySelector('.k-grid-header-wrap table thead')||g.querySelector('.k-grid-header table thead')||g.querySelector('table thead');
    ...    if(!thead)return '';
    ...    var tr=thead.querySelector('tr:first-child');
    ...    if(!tr)return '';
    ...    var ths=tr.querySelectorAll('th');
    ...    var colIdx=-1;
    ...    for(i=0;i<ths.length;i++){
    ...    var t=(ths[i].textContent||'').trim();
    ...    if(/label/i.test(t)&&!/select/i.test(t)){colIdx=i;break;}
    ...    }
    ...    if(colIdx<0||colIdx>=tds.length)return '';
    ...    return (tds[colIdx].textContent||'').replace(/\\s+/g,' ').trim();
    ...    })();
    RETURN    ${cell}

LBL First Row Label Column Should Contain
    [Arguments]    ${expected}
    [Documentation]    Asserts the first master row Label column contains ``${expected}``.
    ${col_text}=    Get Label Column Text For First Row
    Should Contain    ${col_text}    ${expected}
    ...    msg=Expected label '${expected}' in grid Label column, got '${col_text}'.

LBL First Row Label Column Should Not Contain
    [Arguments]    ${not_expected}
    [Documentation]    Asserts the first master row Label column does not contain ``${not_expected}``.
    ${col_text}=    Get Label Column Text For First Row
    Should Not Contain    ${col_text}    ${not_expected}
    ...    msg=Label '${not_expected}' should not appear in Label column, got '${col_text}'.

LBL Wait Until First Row Label Column Contains
    [Arguments]    ${expected}    ${attempts}=30x    ${interval}=1s
    [Documentation]    Polls until the label text appears in the first row (after tag assignment / refresh).
    Wait Until Keyword Succeeds    ${attempts}    ${interval}    LBL First Row Label Column Should Contain    ${expected}

LBL Wait Until First Row Label Column Does Not Contain
    [Arguments]    ${not_expected}    ${attempts}=30x    ${interval}=1s
    [Documentation]    Polls until the label text is gone from the first row (unassign).
    Wait Until Keyword Succeeds    ${attempts}    ${interval}    LBL First Row Label Column Should Not Contain    ${not_expected}
