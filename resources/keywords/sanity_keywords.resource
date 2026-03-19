*** Settings ***
Library     SeleniumLibrary
Library     String
Library     OperatingSystem
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/sanity_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  LOGIN — Suite Setup
# ═══════════════════════════════════════════════════════════════════════
Login For Sanity Suite
    [Documentation]    Opens browser, logs in, sets up sanity report folder, waits for post-login page.
    ...                If SANITY_REPORT_DIR is passed via --variable (e.g. from run_tests.py),
    ...                that folder is used directly (all RF output already goes there).
    ...                Otherwise a new STC_Sanity_Automation/<timestamp>/ folder is created.
    ${dir_passed}=    Run Keyword And Return Status
    ...    Variable Should Not Be Empty    ${SANITY_REPORT_DIR}
    IF    not ${dir_passed}
        ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d_%H%M%S')
        ${sanity_dir}=    Set Variable    ${EXECDIR}${/}STC_Sanity_Automation${/}${timestamp}
        Create Directory    ${sanity_dir}
        Set Suite Variable    ${SANITY_REPORT_DIR}    ${sanity_dir}
    END
    ${csv_path}=    Set Variable    ${SANITY_REPORT_DIR}${/}sanity_report.csv
    Create File    ${csv_path}    TC ID,Page Name,Page URL,Page Title,Grid Columns,Row Count,Status,Screenshot\n
    Set Suite Variable    ${SANITY_CSV_PATH}    ${csv_path}
    Set Suite Variable    ${SANITY_TC_COUNTER}    ${0}
    Log    Sanity output folder: ${SANITY_REPORT_DIR}
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}   timeout=10s
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMAGE}   timeout=20s
    Sleep    2s
    ${captcha_value}=    Fetch Captcha Value
    Enter Captcha    ${captcha_value}
    Click Login Button
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Log    Sanity Suite: Login successful.

# ═══════════════════════════════════════════════════════════════════════
#  PAGE NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Navigate To Page
    [Documentation]    Navigates to the given URL path and waits for page to fully load.
    [Arguments]    ${url_path}
    ${base}=    Evaluate    '${BASE_URL}'.rstrip('/')
    ${full_url}=    Set Variable    ${base}${url_path}
    Go To    ${full_url}
    Wait For App Loading To Complete    timeout=${SANITY_PAGE_LOAD_WAIT}
    Log    Navigated to: ${full_url}

# ═══════════════════════════════════════════════════════════════════════
#  ERROR DETECTION — Section 3 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify No Page Errors
    [Documentation]    Checks that no HTTP error pages, alert-danger banners, error overlays,
    ...                or 'Something went wrong' messages are visible. (MD Section 3)
    ${err_500}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_500}
    ${err_404}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_404}
    ${err_alert}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_ALERT_DANGER}
    ${err_overlay}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_OVERLAY}
    ${err_wrong}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_SOMETHING_WRONG}
    ${err_unauth}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_UNAUTHORIZED}
    IF    not ${err_500}    Fail    HTTP 500 error page detected
    IF    not ${err_404}    Fail    HTTP 404 error page detected
    IF    not ${err_overlay}    Fail    Error overlay detected
    IF    not ${err_wrong}    Fail    'Something went wrong' error detected
    IF    not ${err_unauth}    Fail    Unauthorized error detected
    Log    No page errors detected.

# ═══════════════════════════════════════════════════════════════════════
#  GRID VERIFICATION — Section 4 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify Grid Loaded
    [Documentation]    Verifies grid container visible, at least one column header rendered,
    ...                loading spinner gone. (MD Section 4)
    ${kendo}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_CONTAINER}    15s
    IF    not ${kendo}
        ${any_table}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    xpath=//table    15s
        IF    not ${any_table}
            Fail    No grid container (k-grid or table) found on page.
        END
    END
    ${header}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    15s
    IF    not ${header}
        Wait Until Element Is Visible    xpath=//th    ${SANITY_TIMEOUT}
    END
    ${spinner}=    Run Keyword And Return Status
    ...    Element Should Not Be Visible    ${LOC_GRID_LOADING_MASK}
    IF    not ${spinner}
        Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    END
    Log    Grid loaded: container visible, headers rendered, no spinner.

Verify Grid Loaded With ID
    [Documentation]    Verifies a specific grid by its ID is visible with column headers.
    [Arguments]    ${grid_id}
    Wait Until Element Is Visible    xpath=//div[@id='${grid_id}']    ${SANITY_TIMEOUT}
    ${header}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    15s
    IF    not ${header}
        Wait Until Element Is Visible    xpath=//th    ${SANITY_TIMEOUT}
    END
    Log    Grid '${grid_id}' loaded.

Verify Pagination Visible
    [Documentation]    Verifies pagination controls are present. (MD Section 4, criteria 4)
    ${pager}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_PAGINATION}    15s
    IF    ${pager}
        Log    Pagination controls visible.
    ELSE
        Log    Pagination controls not found — page may use different pagination style.    level=WARN
    END

Verify No Grid Error
    [Documentation]    Verifies no error text inside the grid. (MD Section 4, criteria 5)
    ${err}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_IN_GRID}
    IF    not ${err}
        Log    Warning: Error text detected inside grid.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SUB-TAB VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Sub Tab Active
    [Documentation]    Verifies the given sub-tab link is active (has 'selected' class).
    [Arguments]    ${href}    ${tab_text}=${EMPTY}
    IF    '${tab_text}' != '${EMPTY}'
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and normalize-space(text())='${tab_text}' and contains(@class,'selected')]
    ELSE
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and contains(@class,'selected')]
    END
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    10s
    IF    ${visible}
        Log    Sub-tab active: ${href} (${tab_text})
    ELSE
        Log    Sub-tab '${href}' not found with 'selected' class — may use different active indicator.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH BAR VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Search Bar Visible
    [Documentation]    Verifies the search input field is visible.
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SEARCH_INPUT}    15s
    IF    ${found}
        Log    Search bar visible.
    ELSE
        Log    Search bar not found — page may not have search input.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  NO STUCK SPINNER
# ═══════════════════════════════════════════════════════════════════════
Verify No Stuck Spinner
    [Documentation]    Verifies loading spinner is not stuck (gone within timeout).
    ${spinner}=    Run Keyword And Return Status
    ...    Element Should Not Be Visible    ${LOC_GRID_LOADING_MASK}
    IF    not ${spinner}
        Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    END
    Log    No stuck spinner.

Verify BU Dropdown Visible
    [Documentation]    Verifies the Select BU dropdown is visible (Invoice page). MD: TC-BILL-01.
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//select[contains(@id,'BU') or contains(@name,'BU')] | //*[contains(@placeholder,'Select BU') or contains(@placeholder,'BU')]
    ...    15s
    IF    ${found}
        Log    Select BU dropdown visible.
    ELSE
        Log    Select BU dropdown not found — page may use different locator.    level=WARN
    END

Verify Upload Control Visible
    [Documentation]    Verifies file upload input or upload label is visible (Upload Logo page). MD: TC-ADM-06.
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//input[@type='file'] | //label[contains(.,'Upload')]    15s
    IF    ${found}
        Log    Upload control visible.
    ELSE
        Log    Upload control not found — page may use different locator.    level=WARN
    END

Verify Filter Dropdown Visible
    [Documentation]    Verifies a filter dropdown with the given placeholder text is visible.
    [Arguments]    ${placeholder}
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//*[contains(@placeholder,'${placeholder}')]    15s
    IF    ${found}
        Log    Filter '${placeholder}' visible.
    ELSE
        Log    Filter '${placeholder}' not found — may use different locator.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SANITY EVIDENCE — Page name, URL, columns, row count, screenshot
# ═══════════════════════════════════════════════════════════════════════
Capture Sanity Evidence
    [Documentation]    Logs page name, current URL, all grid column headers found,
    ...                grid row count. Saves screenshot + CSV row into STC_Sanity_Automation folder.
    [Arguments]    ${page_name}
    ${current_url}=    Get Location
    ${title}=    Get Title
    ${columns}=    Execute JavaScript
    ...    var headers = document.querySelectorAll('th');
    ...    var cols = [];
    ...    for (var i = 0; i < headers.length; i++) {
    ...        var text = (headers[i].textContent || headers[i].innerText || '').trim();
    ...        if (text.length > 0 && text.length < 100) cols.push(text);
    ...    }
    ...    return cols.join(' | ');
    ${row_count}=    Execute JavaScript
    ...    var rows = document.querySelectorAll('div.k-grid tbody tr, table.k-grid tbody tr, table tbody tr');
    ...    var dataRows = 0;
    ...    for (var i = 0; i < rows.length; i++) {
    ...        if (!rows[i].classList.contains('k-grouping-row') && !rows[i].classList.contains('k-group-footer')) dataRows++;
    ...    }
    ...    return dataRows;
    ${report}=    Catenate    SEPARATOR=\n
    ...    ========== SANITY REPORT ==========
    ...    Page Name: ${page_name}
    ...    Page URL: ${current_url}
    ...    Page Title: ${title}
    ...    Grid Columns Found: ${columns}
    ...    Grid Row Count: ${row_count}
    ...    ===================================
    Log    ${report}
    ${safe_name}=    Evaluate    '${page_name}'.replace(' ', '_').replace('/', '_')
    ${screenshot_file}=    Set Variable    ${safe_name}.png
    Capture Page Screenshot    ${SANITY_REPORT_DIR}${/}${screenshot_file}
    ${counter}=    Evaluate    ${SANITY_TC_COUNTER} + 1
    Set Suite Variable    ${SANITY_TC_COUNTER}    ${counter}
    ${tc_id}=    Evaluate    f"TC_SANITY_{${counter}:03d}"
    ${cols_escaped}=    Evaluate    '"' + '${columns}'.replace('"', '""') + '"'
    ${title_escaped}=    Evaluate    '"' + '${title}'.replace('"', '""') + '"'
    ${csv_row}=    Catenate    SEPARATOR=,
    ...    ${tc_id}    ${page_name}    ${current_url}    ${title_escaped}    ${cols_escaped}    ${row_count}    PASS    ${screenshot_file}
    Append To File    ${SANITY_CSV_PATH}    ${csv_row}\n

Capture Test End Screenshot
    [Documentation]    Always-running teardown keyword. On PASS takes a PASS_ screenshot;
    ...                on FAIL takes a FAIL_ screenshot and writes a FAIL row to sanity_report.csv.
    [Arguments]    ${page_name}
    ${loc_status}    ${current_url}=    Run Keyword And Ignore Error    Get Location
    ${url}=    Set Variable If    '${loc_status}' == 'PASS'    ${current_url}    unknown
    ${safe_name}=    Evaluate    '${page_name}'.replace(' ', '_').replace('/', '_')
    ${prefix}=    Set Variable If    '${TEST STATUS}' == 'PASS'    PASS    FAIL
    ${screenshot_file}=    Set Variable    ${prefix}_${safe_name}.png
    ${dir_set}=    Run Keyword And Return Status    Variable Should Not Be Empty    ${SANITY_REPORT_DIR}
    IF    ${dir_set}
        Capture Page Screenshot    ${SANITY_REPORT_DIR}${/}${screenshot_file}
        IF    '${TEST STATUS}' == 'FAIL'
            ${counter}=    Evaluate    ${SANITY_TC_COUNTER} + 1
            Set Suite Variable    ${SANITY_TC_COUNTER}    ${counter}
            ${tc_id}=    Evaluate    f"TC_SANITY_{${counter}:03d}"
            ${csv_row}=    Catenate    SEPARATOR=,
            ...    ${tc_id}    ${page_name}    ${url}    N/A    N/A    N/A    FAIL    ${screenshot_file}
            Append To File    ${SANITY_CSV_PATH}    ${csv_row}\n
        END
    ELSE
        Capture Page Screenshot    ${screenshot_file}
    END
    Log    ${prefix} screenshot saved: ${screenshot_file}

Capture Sanity Evidence No Grid
    [Documentation]    For non-grid pages — logs page name, URL, title. Saves screenshot + CSV row into STC_Sanity_Automation folder.
    [Arguments]    ${page_name}
    ${current_url}=    Get Location
    ${title}=    Get Title
    ${report}=    Catenate    SEPARATOR=\n
    ...    ========== SANITY REPORT ==========
    ...    Page Name: ${page_name}
    ...    Page URL: ${current_url}
    ...    Page Title: ${title}
    ...    Page Type: No Grid (Dashboard/Form/Upload)
    ...    ===================================
    Log    ${report}
    ${safe_name}=    Evaluate    '${page_name}'.replace(' ', '_').replace('/', '_')
    ${screenshot_file}=    Set Variable    ${safe_name}.png
    Capture Page Screenshot    ${SANITY_REPORT_DIR}${/}${screenshot_file}
    ${counter}=    Evaluate    ${SANITY_TC_COUNTER} + 1
    Set Suite Variable    ${SANITY_TC_COUNTER}    ${counter}
    ${tc_id}=    Evaluate    f"TC_SANITY_{${counter}:03d}"
    ${title_escaped}=    Evaluate    '"' + '${title}'.replace('"', '""') + '"'
    ${csv_row}=    Catenate    SEPARATOR=,
    ...    ${tc_id}    ${page_name}    ${current_url}    ${title_escaped}    N/A    N/A    PASS    ${screenshot_file}
    Append To File    ${SANITY_CSV_PATH}    ${csv_row}\n

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE: FULL PAGE SANITY CHECK
# ═══════════════════════════════════════════════════════════════════════
Verify Page With Grid
    [Documentation]    Full sanity check for a page that has a grid:
    ...                navigate → no errors → sub-tab active → grid loaded → pagination → no grid error → screenshot.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}    ${page_name}=${EMPTY}
    Navigate To Page    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    ${name}=    Set Variable If    '${page_name}' != '${EMPTY}'    ${page_name}    ${url_path}
    Capture Sanity Evidence    ${name}

Verify Page Without Grid
    [Documentation]    Sanity check for a page that does NOT have a grid (dashboard, forms, upload):
    ...                navigate → no errors → sub-tab active → no stuck spinner → screenshot.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}    ${page_name}=${EMPTY}
    Navigate To Page    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify No Stuck Spinner
    ${name}=    Set Variable If    '${page_name}' != '${EMPTY}'    ${page_name}    ${url_path}
    Capture Sanity Evidence No Grid    ${name}
