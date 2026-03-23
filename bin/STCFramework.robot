*** Settings ***
Library     SeleniumLibrary
Library     ${CURDIR}/../libraries/DynamicTestCases.py
Library     ${CURDIR}/../libraries/ConfigLoader.py
Library     ${CURDIR}/../libraries/FrameworkCSV.py
Library     OperatingSystem
Library     Collections
Library     String

Resource    ${CURDIR}/../resources/keywords/browser_keywords.resource

Suite Setup    Execute Test Framework
Suite Teardown    Run Keyword And Ignore Error    Close All Browsers

*** Variables ***
${SUITE_FILTER}    ${EMPTY}

*** Test Cases ***
Power On Self Test
    [Tags]    Always
    Skip    Dynamic tests added in Suite Setup

*** Keywords ***
Execute Test Framework
    TRY
        Load Environment Config From Json    ${ENV}
        ${BASE_DIR}=    Normalize Path    ${CURDIR}/..
        Set Suite Variable    ${BASE_DIR}    ${BASE_DIR}
        Set Suite Variable    ${SUITES_FILE}    ${BASE_DIR}/suites/suites.csv
        Set Suite Variable    ${SUITES_PATH}    ${BASE_DIR}/suites
        Set Suite Variable    ${TASK_PATH}    ${BASE_DIR}/tasks
        Set Suite Variable    ${TESTS_PATH}    ${BASE_DIR}/tests
        ${task_registry}=    Create Dictionary
        Set Suite Variable    ${task_registry}    ${task_registry}
        Load Task Registry Files
        Load Task Type Files
        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
        Load Suite File
    EXCEPT    AS    ${err}
        Fatal Error    [FATAL]: Error while initializing the test framework.\n${err}
    END

# ── Task registry ────────────────────────────────────────────────────────────

Load Task Registry Files
    Log To Console    Loading task registry from ${TASK_PATH}
    @{dirs}=    List Directories In Directory    ${TASK_PATH}    absolute=False
    FOR    ${dir}    IN    @{dirs}
        @{files}=    List Files In Directory    ${TASK_PATH}/${dir}    *.csv    absolute=True
        FOR    ${file}    IN    @{files}
            Load Task Registry    ${file}
        END
    END

Load Task Registry
    [Arguments]    ${FILE}
    Log To Console    Load task registry from ${FILE}
    @{tasks}=    Read Csv File To Associative    ${FILE}
    FOR    ${task}    IN    @{tasks}
        ${isactive}=    Get From Dictionary    ${task}    isactive
        ${taskid}=    Get From Dictionary    ${task}    taskid
        IF    '${isactive}' == 'true'
            Set To Dictionary    ${task_registry}    ${taskid}=${task}
        ELSE
            Log To Console    Skipping task [${taskid}] as not active
        END
    END

# ── Suite / resource loading ─────────────────────────────────────────────────

Load Task Type Files
    Log To Console    Loading task type files from ${TESTS_PATH}
    ${dir_exists}=    Run Keyword And Return Status    Directory Should Exist    ${TESTS_PATH}
    IF    not ${dir_exists}
        Log To Console    No tests directory found, skipping
        RETURN
    END
    @{rows}=    Read Csv File To List    ${SUITES_FILE}    skip_header=True
    FOR    ${row}    IN    @{rows}
        ${suite_id}=    Set Variable    ${row[1]}
        ${test_file_override}=    Set Variable    ${row[4]}
        ${test_file}=    Resolve Test File    ${suite_id}    ${test_file_override}
        IF    '${test_file}' == '${EMPTY}'
            Continue For Loop
        END
        ${path}=    Set Variable    ${BASE_DIR}/${test_file}
        ${exists}=    Run Keyword And Return Status    File Should Exist    ${path}
        IF    ${exists}
            Import Resource    ${path}
        ELSE
            Log To Console    WARNING: Test file not found for suite [${suite_id}]: ${path}
        END
    END

Load Suite File
    TRY
        @{rows}=    Read Csv File To List    ${SUITES_FILE}    skip_header=True
        FOR    ${row}    IN    @{rows}
            ${suite_id}=    Set Variable    ${row[1]}
            ${active}=    Set Variable    ${row[3]}
            IF    '${SUITE_FILTER}' != '${EMPTY}' and '${SUITE_FILTER}' != '${suite_id}'
                Continue For Loop
            END
            IF    '${active}' == 'true'
                Log To Console    Executing suite [${suite_id}]
                Execute Suite    ${suite_id}    ${suite_id}
            ELSE
                Log To Console    Skipping suite [${suite_id}] as not active
            END
        END
    EXCEPT    AS    ${err}
        Fatal Error    ${err}
    END

Load Suite Variables
    [Arguments]    ${suite_id}    ${variables_file_override}=${EMPTY}
    ${var_file}=    Resolve Variables File    ${suite_id}    ${variables_file_override}
    IF    '${var_file}' == '${EMPTY}'
        Log To Console    No variables file found for suite [${suite_id}], skipping
        RETURN
    END
    # Strip leading "variables/" prefix if present — Import Variables needs a full path
    ${path}=    Set Variable    ${BASE_DIR}/${var_file}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${path}
    IF    ${exists}
        Import Variables    ${path}
    ELSE
        Log To Console    WARNING: Variables file not found for suite [${suite_id}]: ${path}
    END

Execute Suite
    [Arguments]    ${COMPONENT}    ${SUITE}
    # Look up the overrides from suites.csv for this suite
    ${vars_override}=    Get Suite Csv Column    ${SUITE}    variables_file
    Load Suite Variables    ${COMPONENT}    ${vars_override}
    ${suite_csv}=    Set Variable    ${SUITES_PATH}/${COMPONENT}/${SUITE}.csv
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${suite_csv}
    IF    not ${exists}
        Log To Console    Suite file not found: ${suite_csv}
        RETURN
    END
    @{tcases}=    Read Csv File To Associative    ${suite_csv}
    ${noOfTc}=    Get Length    ${tcases}
    IF    ${noOfTc} > 0
        Add Testcases To Suite    ${SUITE}    ${tcases}
    ELSE
        Log To Console    Skipping ${SUITE}, no test cases
    END

# ── Dynamic file resolution ───────────────────────────────────────────────────

Resolve Test File
    [Documentation]    Returns the robot file path for a suite.
    ...    Priority:
    ...      1. Explicit override from suites.csv test_file column
    ...      2. Convention: tests/<suite_id_lower>_tests.robot
    ...      3. Convention: tests/<suite_id_lower>.robot  (e.g. e2e flows without _tests suffix)
    ...      4. Returns ${EMPTY} if nothing found
    [Arguments]    ${suite_id}    ${override}=${EMPTY}
    IF    '${override}' != '${EMPTY}'
        # Normalise: strip leading slash / whitespace
        ${clean}=    Strip String    ${override}
        RETURN    ${clean}
    END
    ${lower}=    Convert To Lower Case    ${suite_id}
    # Try <suite_lower>_tests.robot
    ${candidate}=    Set Variable    tests/${lower}_tests.robot
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${BASE_DIR}/${candidate}
    IF    ${exists}
        RETURN    ${candidate}
    END
    # Try <suite_lower>.robot  (no _tests suffix)
    ${candidate2}=    Set Variable    tests/${lower}.robot
    ${exists2}=    Run Keyword And Return Status    File Should Exist    ${BASE_DIR}/${candidate2}
    IF    ${exists2}
        RETURN    ${candidate2}
    END
    Log To Console    WARNING: Could not resolve test file for suite [${suite_id}]
    RETURN    ${EMPTY}

Resolve Variables File
    [Documentation]    Returns the variables file path for a suite.
    ...    Priority:
    ...      1. Explicit override from suites.csv variables_file column
    ...      2. Convention: variables/<suite_id_lower>_variables.py
    ...      3. Returns ${EMPTY} if nothing found (no variables — still valid)
    [Arguments]    ${suite_id}    ${override}=${EMPTY}
    IF    '${override}' != '${EMPTY}'
        ${clean}=    Strip String    ${override}
        # Support bare filename (e.g. "sim_range_variables.py") or full path
        ${has_slash}=    Run Keyword And Return Status    Should Contain    ${clean}    /
        IF    ${has_slash}
            RETURN    ${clean}
        ELSE
            RETURN    variables/${clean}
        END
    END
    ${lower}=    Convert To Lower Case    ${suite_id}
    ${candidate}=    Set Variable    variables/${lower}_variables.py
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${BASE_DIR}/${candidate}
    IF    ${exists}
        RETURN    ${candidate}
    END
    RETURN    ${EMPTY}

Get Suite Csv Column
    [Documentation]    Reads suites.csv and returns the value of a named column for
    ...                the given suite_id.  Returns ${EMPTY} if not found or column absent.
    [Arguments]    ${suite_id}    ${column_name}
    @{rows}=    Read Csv File To Associative    ${SUITES_FILE}
    FOR    ${row}    IN    @{rows}
        ${id}=    Get From Dictionary    ${row}    suite_id
        IF    '${id}' == '${suite_id}'
            ${has_col}=    Run Keyword And Return Status
            ...    Dictionary Should Contain Key    ${row}    ${column_name}
            IF    ${has_col}
                ${val}=    Get From Dictionary    ${row}    ${column_name}
                RETURN    ${val}
            END
            RETURN    ${EMPTY}
        END
    END
    RETURN    ${EMPTY}

# ── Test case execution ───────────────────────────────────────────────────────

Add Tags To TC
    [Arguments]    ${status}    ${tc}    ${tags}
    IF    '${status}' == 'true'
        @{taglist}=    Split String    ${tags}    |
        Add Tags    ${tc}    @{taglist}
    ELSE
        Add Tags    ${tc}    Inactive
    END

Add Testcases To Suite
    [Arguments]    ${SUITE}    ${tclist}
    FOR    ${tc}    IN    @{tclist}
        ${testcaseid}=    Get From Dictionary    ${tc}    testcaseid
        ${testcasename}=    Get From Dictionary    ${tc}    testcasename
        ${tasklist}=    Get From Dictionary    ${tc}    tasklist
        ${variables}=    Get From Dictionary    ${tc}    variables
        ${isdatadriven}=    Get From Dictionary    ${tc}    isdatadriven
        ${datafile}=    Get From Dictionary    ${tc}    datafile
        ${isactive}=    Get From Dictionary    ${tc}    isactive
        ${taglist}=    Get From Dictionary    ${tc}    taglist
        IF    '${isdatadriven}' == 'true'
            ${data_path}=    Set Variable    ${TESTDATA_PATH}/${datafile}
            ${dataExists}=    Run Keyword And Return Status    File Should Exist    ${data_path}
            IF    ${dataExists}
                @{data}=    Read Csv File To Associative    ${data_path}
                FOR    ${row}    IN    @{data}
                    ${id}=    Get From Dictionary    ${row}    seq
                    ${dataVariables}=    Get From Dictionary    ${row}    variables
                    ${status}=    Get From Dictionary    ${row}    status
                    ${rc}=    Add Test Case    ${SUITE}-${testcaseid}-${id}    Execute Testcase    ${testcaseid}-${id}    ${testcasename}-${id}    ${tasklist}    ${dataVariables}
                    Add Tags To TC    ${status}    ${rc}    ${taglist}
                END
            ELSE
                ${rc}=    Add Test Case    ${SUITE}-${testcaseid}-${testcasename}    Execute Testcase    ${testcaseid}    ${testcasename}    ${tasklist}    ${variables}
                Add Tags To TC    false    ${rc}    ${taglist}
            END
        ELSE
            ${rc}=    Add Test Case    ${SUITE}-${testcaseid}-${testcasename}    Execute Testcase    ${testcaseid}    ${testcasename}    ${tasklist}    ${variables}
            Add Tags To TC    ${isactive}    ${rc}    ${taglist}
        END
    END

Execute Testcase
    [Arguments]    ${TESTCASEID}    ${TESTCASENAME}    ${TASKLIST}    ${VARIABLES}
    TRY
        @{tasks}=    Split String    ${TASKLIST}    |
        ${tc_run_status}=    Set Variable    PASS
        FOR    ${task_id}    IN    @{tasks}
            ${value}=    Get From Dictionary    ${task_registry}    ${task_id}
            ${tasktype}=    Get From Dictionary    ${value}    tasktype
            ${taskparams}=    Get From Dictionary    ${value}    taskparams
            ${expectations}=    Get From Dictionary    ${value}    expectations
            IF    '${taskparams}' != '' and '${taskparams}' != 'None'
                @{arglist}=    Split String    ${taskparams}    |
                ${tc_run_status}=    Run Keyword And Ignore Error    ${tasktype}    @{arglist}
            ELSE
                ${tc_run_status}=    Run Keyword And Ignore Error    ${tasktype}
            END
            Log To Console    Task ${tasktype} expected [${expectations}] got [status->${tc_run_status[0]}]
            IF    'status->${tc_run_status[0]}' != '${expectations}' and '${expectations}' != 'status->ANY'
                IF    '${tc_run_status[0]}' == 'FAIL'
                    FAIL    ${tc_run_status[1]}
                ELSE
                    FAIL    Task ${tasktype} failed: ${tc_run_status[1]}
                END
            END
        END
    EXCEPT    AS    ${err}
        FAIL    ${err}
    END
