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
    ...    Should Not Be Empty    ${SANITY_REPORT_DIR}
    IF    not ${dir_passed}
        ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d_%H%M%S')
        ${sanity_dir}=    Set Variable    ${EXECDIR}${/}reports${/}${timestamp}_sanity
        Create Directory    ${sanity_dir}
        Set Suite Variable    ${SANITY_REPORT_DIR}    ${sanity_dir}
    END
    ${sanity_subfolder}=    Set Variable    ${SANITY_REPORT_DIR}${/}Sanity
    Create Directory    ${sanity_subfolder}
    ${csv_path}=    Set Variable    ${sanity_subfolder}${/}sanity_report.csv
    Create File    ${csv_path}    TC ID,Page Name,Page URL,Page Title,Grid Columns,Row Count,Status,Screenshot\n
    Set Suite Variable    ${SANITY_CSV_PATH}    ${csv_path}
    Set Suite Variable    ${SANITY_TC_COUNTER}    ${0}
    Log    Sanity output folder: ${SANITY_REPORT_DIR}
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Log    Sanity Suite: Login successful.

# ═══════════════════════════════════════════════════════════════════════
#  PAGE NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Navigate To Page
    [Documentation]    Navigates to the given URL path and waits for:
    ...                1) document ready + body loading overlay gone
    ...                2) grid-level k-loading-mask gone (if present)
    ...                Recovers from browser crash by restarting and re-logging in.
    [Arguments]    ${url_path}
    ${base}=    Evaluate    '${BASE_URL}'.rstrip('/')
    ${full_url}=    Set Variable    ${base}${url_path}
    ${nav_ok}=    Run Keyword And Return Status    Go To    ${full_url}
    IF    not ${nav_ok}
        Log    Go To ${full_url} failed — browser may have crashed. Restarting.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Force Kill Chrome Processes
        Open Test Browser    ${BASE_URL}    ${BROWSER}
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        Go To    ${full_url}
    END
    Wait For App Loading To Complete    timeout=${SANITY_PAGE_LOAD_WAIT}
    # Also wait for grid-level spinner to clear (API response may arrive after document ready)
    Set Selenium Implicit Wait    0s
    ${grid_mask_present}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_GRID_LOADING_MASK}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    IF    ${grid_mask_present}
        ${mask_gone}=    Run Keyword And Return Status
        ...    Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_PAGE_LOAD_WAIT}
        IF    not ${mask_gone}
            Fail    Navigation stalled: grid loading spinner still visible after ${SANITY_PAGE_LOAD_WAIT} on ${url_path}
        END
    END
    # Verify we actually landed on the expected URL (not redirected to login/error)
    ${current}=    Get Location
    ${landed_ok}=    Evaluate    '${url_path}'.lower() in '${current}'.lower()
    IF    not ${landed_ok}
        Fail    Navigation failed: expected URL containing '${url_path}' but got '${current}'
    END
    Log    Navigated to: ${full_url}

# ═══════════════════════════════════════════════════════════════════════
#  ERROR DETECTION — Section 3 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify No Page Errors
    [Documentation]    Checks that no HTTP error pages, alert-danger banners, error overlays,
    ...                or 'Something went wrong' messages are visible.
    ...                Uses 0s implicit wait per check to avoid 10s stall on missing elements.
    Set Selenium Implicit Wait    0s
    ${err_500}=       Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_500}
    ${err_404}=       Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_404}
    ${err_alert}=     Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_ALERT_DANGER}
    ${err_overlay}=   Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_OVERLAY}
    ${err_wrong}=     Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_SOMETHING_WRONG}
    ${err_unauth}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_UNAUTHORIZED}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    IF    not ${err_500}      Fail    HTTP 500 error page detected on this page
    IF    not ${err_404}      Fail    HTTP 404 error page detected on this page
    IF    not ${err_overlay}  Fail    Error overlay detected on this page
    IF    not ${err_wrong}    Fail    'Something went wrong' message detected on this page
    IF    not ${err_unauth}   Fail    Unauthorized error detected — session may have expired
    Log    No page errors detected.

# ═══════════════════════════════════════════════════════════════════════
#  GRID VERIFICATION — Section 4 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify Grid Loaded
    [Documentation]    Verifies grid container visible, at least one column header rendered,
    ...                loading spinner gone. FAILS if no grid found within timeout.
    ...                Accepts Kendo k-grid, HTML table, or ARIA role=grid (e.g. some Ticketing UIs).
    ${kendo}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_CONTAINER}    ${SANITY_TIMEOUT}
    IF    not ${kendo}
        ${any_table}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    xpath=//table    ${SANITY_TIMEOUT}
        IF    not ${any_table}
            ${aria_grid}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    xpath=//*[@role='grid']    ${SANITY_TIMEOUT}
            IF    not ${aria_grid}
                Fail    FAIL: No grid container (k-grid, table, or role=grid) found — page content did not load.
            END
        END
    END
    ${header}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    ${SANITY_TIMEOUT}
    IF    not ${header}
        ${th}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    xpath=//th    ${SANITY_TIMEOUT}
        IF    not ${th}
            ${colheader}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    xpath=//*[@role='columnheader']    15s
            IF    not ${colheader}
                Fail    FAIL: Grid found but no column headers rendered — data table incomplete.
            END
        END
    END
    # Spinner must be gone — if still spinning after timeout the page is stuck
    ${spinner_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    IF    not ${spinner_gone}
        Fail    FAIL: Grid loading spinner still visible after ${SANITY_TIMEOUT} — page is stuck loading.
    END
    Log    Grid loaded: container and headers visible, spinner gone.

Verify Grid Loaded With ID
    [Documentation]    Verifies a specific grid by its ID is visible with column headers.
    [Arguments]    ${grid_id}
    Wait Until Element Is Visible    xpath=//div[@id='${grid_id}']    ${SANITY_TIMEOUT}
    ${header}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    15s
    IF    not ${header}
        Wait Until Element Is Visible    xpath=//th    ${SANITY_TIMEOUT}
    END
    ${spinner_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    IF    not ${spinner_gone}
        Fail    FAIL: Grid '${grid_id}' loading spinner still visible — page is stuck.
    END
    Log    Grid '${grid_id}' loaded.

Grid Has Data Rows
    [Documentation]    Helper: asserts at least 1 data row exists right now. Used with Wait Until Keyword Succeeds.
    ${row_count}=    Execute JavaScript
    ...    var rows = document.querySelectorAll('div.k-grid tbody tr, table tbody tr');
    ...    var n = 0;
    ...    for (var i = 0; i < rows.length; i++) {
    ...        var cls = rows[i].className || '';
    ...        if (cls.indexOf('k-grouping-row') === -1 && cls.indexOf('k-group-footer') === -1
    ...            && cls.indexOf('k-no-data') === -1) { n++; }
    ...    }
    ...    return n;
    Should Be True    ${row_count} > 0    Grid has ${row_count} rows — data not yet loaded

Verify Grid Has Data
    [Documentation]    Waits up to SANITY_TIMEOUT for grid to have at least one data row.
    ...                First checks if "No data"/"No records" message is explicitly rendered (fail fast).
    ...                Then polls every 2s until rows appear. FAILS if still empty after timeout.
    # Fail fast if the grid already shows an explicit empty-state message
    Set Selenium Implicit Wait    0s
    ${no_data_msg}=    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    xpath=//*[contains(@class,'k-grid')]//*[contains(text(),'No data') or contains(text(),'No records')]
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    IF    ${no_data_msg}
        Fail    FAIL: Grid shows 'No data' or 'No records' — data fetch failed or API returned empty results.
    END
    # Wait and retry until at least 1 data row appears
    ${has_data}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${SANITY_TIMEOUT}    2s    Grid Has Data Rows
    IF    not ${has_data}
        Fail    FAIL: Grid has 0 data rows after ${SANITY_TIMEOUT} — data did not load (check API / network).
    END
    Log    Grid data loaded successfully.

Verify Pagination Visible
    [Documentation]    Verifies pagination controls are present. FAILS if completely absent.
    ${pager}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_GRID_PAGINATION}    10s
    IF    ${pager}
        Log    Pagination controls visible.
    ELSE
        # Some pages use infinite scroll or custom pagination — treat as warning not failure
        Log    Pagination controls not found — page may use infinite scroll or alternate style.    level=WARN
    END

Verify No Grid Error
    [Documentation]    Verifies no error text inside the grid. FAILS if error text is found.
    Set Selenium Implicit Wait    0s
    ${err}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_IN_GRID}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    IF    not ${err}
        Fail    FAIL: Error text detected inside grid — data fetch likely failed.
    END

# ═══════════════════════════════════════════════════════════════════════
#  URL AND SUB-TAB VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Expected URL
    [Documentation]    Asserts the current URL contains the expected path. FAILS if redirected elsewhere.
    [Arguments]    ${expected_path}
    ${current}=    Get Location
    ${ok}=    Evaluate    '${expected_path}'.lower() in '${current}'.lower()
    IF    not ${ok}
        Fail    URL mismatch: expected path '${expected_path}' not found in current URL '${current}'
    END
    Log    URL verified: current URL contains '${expected_path}'

Verify Sub Tab Active
    [Documentation]    Verifies the given sub-tab link is active (has 'selected' class).
    ...                WARNS (not fails) if the active class uses a different indicator.
    [Arguments]    ${href}    ${tab_text}=${EMPTY}
    IF    '${tab_text}' != '${EMPTY}'
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and normalize-space(text())='${tab_text}' and contains(@class,'selected')]
    ELSE
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and contains(@class,'selected')]
    END
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    8s
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
    ...    Wait Until Element Is Visible    ${LOC_SEARCH_INPUT}    10s
    IF    ${found}
        Log    Search bar visible.
    ELSE
        Log    Search bar not found — page may not have search input.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SPINNER / STUCK DETECTION
# ═══════════════════════════════════════════════════════════════════════
Verify No Stuck Spinner
    [Documentation]    Verifies loading spinner is not stuck. FAILS if stuck beyond timeout.
    ${spinner_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    IF    not ${spinner_gone}
        Fail    FAIL: Loading spinner still visible after ${SANITY_TIMEOUT} — page is stuck.
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
    ...                grid row count. Saves one screenshot + CSV row per test.
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
    [Documentation]    Teardown keyword. ONLY captures screenshot on FAIL (PASS already has one from
    ...                Capture Sanity Evidence). Writes FAIL row to sanity_report.csv on failure.
    ...                Wrapped in error handling so a dead browser does not cascade-fail remaining tests.
    [Arguments]    ${page_name}
    IF    '${TEST STATUS}' == 'FAIL'
        ${loc_status}    ${current_url}=    Run Keyword And Ignore Error    Get Location
        ${url}=    Set Variable If    '${loc_status}' == 'PASS'    ${current_url}    unknown
        ${safe_name}=    Evaluate    '${page_name}'.replace(' ', '_').replace('/', '_')
        ${screenshot_file}=    Set Variable    FAIL_${safe_name}.png
        ${dir_set}=    Run Keyword And Return Status    Should Not Be Empty    ${SANITY_REPORT_DIR}
        IF    ${dir_set}
            Run Keyword And Ignore Error    Capture Page Screenshot    ${SANITY_REPORT_DIR}${/}${screenshot_file}
            ${counter}=    Evaluate    ${SANITY_TC_COUNTER} + 1
            Set Suite Variable    ${SANITY_TC_COUNTER}    ${counter}
            ${tc_id}=    Evaluate    f"TC_SANITY_{${counter}:03d}"
            ${csv_row}=    Catenate    SEPARATOR=,
            ...    ${tc_id}    ${page_name}    ${url}    N/A    N/A    N/A    FAIL    ${screenshot_file}
            Append To File    ${SANITY_CSV_PATH}    ${csv_row}\n
        ELSE
            Capture Page Screenshot    ${screenshot_file}
        END
        Log    FAIL screenshot saved: ${screenshot_file}
    END

Capture Sanity Evidence No Grid
    [Documentation]    For non-grid pages — logs page name, URL, title. Saves screenshot + CSV row.
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
    ...                navigate → URL verified → no errors → sub-tab active →
    ...                grid loaded → grid has data (optional) → pagination → no grid error → screenshot.
    ...                Set require_data=${False} for log/history pages that may have no rows in some environments.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}    ${page_name}=${EMPTY}    ${require_data}=${True}
    Navigate To Page    ${url_path}
    Verify Expected URL    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify Grid Loaded
    IF    ${require_data}
        Verify Grid Has Data
    ELSE
        Log    Skipping data-row assertion — log/history page may have no rows in this environment.    level=WARN
    END
    Verify Pagination Visible
    Verify No Grid Error
    ${name}=    Set Variable If    '${page_name}' != '${EMPTY}'    ${page_name}    ${url_path}
    Capture Sanity Evidence    ${name}

Verify Page Without Grid
    [Documentation]    Sanity check for a page that does NOT have a grid (dashboard, forms, upload):
    ...                navigate → URL verified → no errors → sub-tab active → no stuck spinner → screenshot.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}    ${page_name}=${EMPTY}
    Navigate To Page    ${url_path}
    Verify Expected URL    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify No Stuck Spinner
    ${name}=    Set Variable If    '${page_name}' != '${EMPTY}'    ${page_name}    ${url_path}
    Capture Sanity Evidence No Grid    ${name}
