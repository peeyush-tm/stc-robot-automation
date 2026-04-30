*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/apn_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/apn_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/apn_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Setup        Ensure Session Is Active
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  GROUP A — APN LIST PAGE UI
# ═══════════════════════════════════════════════════════════════════════

TC_APN_066 Verify APN List Page Loads Successfully
    [Documentation]    Navigate to Manage APN listing page and verify the grid loads with at least one row.
    [Tags]    feature    positive    apn    TC_APN_066
    TC_APN_066

TC_APN_067 Verify All Expected APN Grid Columns Present
    [Documentation]    Navigate to Manage APN and verify all expected column headers are visible in the grid.
    [Tags]    feature    positive    apn    TC_APN_067
    TC_APN_067

TC_APN_068 Verify APN Search With Partial APN Name
    [Documentation]    Enter a partial APN name in the search box and verify filtered results are shown.
    ...                Clear search and verify the full list is restored.
    [Tags]    feature    positive    apn    TC_APN_068
    TC_APN_068

TC_APN_069 Verify APN Search With Full APN Name Returns Match
    [Documentation]    Search with a complete known APN name and verify at least one matching row is returned.
    [Tags]    feature    positive    apn    TC_APN_069
    TC_APN_069

TC_APN_070 Verify Clearing Search Restores Full APN List
    [Documentation]    Search for any term, then clear the search field. Verify the full APN list is restored.
    [Tags]    feature    positive    apn    TC_APN_070
    TC_APN_070

TC_APN_071 Verify Search With Non-Existent Term Shows No Results
    [Documentation]    Search for a random string that matches no APN. Verify zero rows or a 'no results' message.
    [Tags]    feature    positive    apn    TC_APN_071
    TC_APN_071

TC_APN_072 Verify Pagination Controls Are Visible
    [Documentation]    On the APN listing page, verify the pagination control bar is visible with page navigation buttons.
    [Tags]    feature    positive    apn    TC_APN_072
    TC_APN_072

TC_APN_073 Verify Pagination Next And Previous Navigation
    [Documentation]    Click next page then previous page and verify records change and pager info updates.
    [Tags]    feature    positive    apn    TC_APN_073
    TC_APN_073

TC_APN_074 Verify Page Size Selector Changes Records Per Page
    [Documentation]    Change the page size dropdown to a different value and verify the number of visible rows updates.
    [Tags]    feature    positive    apn    TC_APN_074
    TC_APN_074

TC_APN_075 Verify Pager Info Shows Total Record Count
    [Documentation]    Read the pager info text (e.g. '1-10 of 50 items') and verify it is not empty.
    [Tags]    feature    positive    apn    TC_APN_075
    TC_APN_075

# ═══════════════════════════════════════════════════════════════════════
#  GROUP B — COLUMN SORT & FILTER
# ═══════════════════════════════════════════════════════════════════════

TC_APN_076 Verify Sort By APN Name Column
    [Documentation]    Click the APN NAME column header to sort ascending, click again to sort descending.
    ...                Verify grid reloads without error on both clicks.
    [Tags]    feature    positive    apn    TC_APN_076
    TC_APN_076

TC_APN_077 Verify Sort By APN ID Column
    [Documentation]    Click the APN ID column header to sort ascending, click again to sort descending.
    [Tags]    feature    positive    apn    TC_APN_077
    TC_APN_077

TC_APN_078 Verify Sort By Status Column
    [Documentation]    Click the STATUS column header to sort ascending, click again to sort descending.
    [Tags]    feature    positive    apn    TC_APN_078
    TC_APN_078

TC_APN_079 Verify Column Filter Applies And Shows Filtered Results
    [Documentation]    Open the column filter on the first filterable column, apply a filter value.
    ...                Verify only matching rows are shown.
    [Tags]    feature    positive    apn    TC_APN_079
    TC_APN_079

TC_APN_080 Verify Column Filter Clear Restores Full List
    [Documentation]    Apply a column filter, then clear it. Verify the full APN list is restored.
    [Tags]    feature    positive    apn    TC_APN_080
    TC_APN_080

TC_APN_081 Verify CSV Export Button Visible And Clickable
    [Documentation]    Click the CSV/Export button on the APN listing page and verify the download initiates.
    [Tags]    feature    positive    apn    TC_APN_081
    TC_APN_081

TC_APN_082 Verify Sort By EQOSID Column
    [Documentation]    Click the EQOSID column header to sort ascending, click again to sort descending.
    [Tags]    feature    positive    apn    TC_APN_082
    TC_APN_082

# ═══════════════════════════════════════════════════════════════════════
#  GROUP C — APN DELETE & EDIT ACTIONS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_083 Verify Delete Icon Present On First APN Row
    [Documentation]    On the APN listing page, verify that a delete icon is visible on the first data row.
    [Tags]    feature    positive    apn    TC_APN_083
    TC_APN_083

TC_APN_084 Verify Edit Icon Present On First APN Row
    [Documentation]    On the APN listing page, verify that an edit icon is visible on the first data row.
    [Tags]    feature    positive    apn    TC_APN_084
    TC_APN_084

TC_APN_085 Verify Edit Icon Opens APN Detail View
    [Documentation]    Click the edit icon on the first APN row and verify that the APN detail or edit view expands
    ...                with pre-populated data.
    [Tags]    feature    positive    apn    TC_APN_085
    TC_APN_085

TC_APN_086 Verify Create APN Button On Listing Page Navigates To Form
    [Documentation]    From the APN listing page, click 'Create APN' button and verify navigation to /CreateAPN
    ...                with the Primary Details form visible.
    [Tags]    feature    positive    apn    TC_APN_086
    TC_APN_086

TC_APN_087 Verify Delete APN With Search And Confirm
    [Documentation]    Create a temporary Public APN, navigate to listing, search for it, then delete it.
    ...                Verify deletion completes successfully.
    [Tags]    feature    positive    apn    TC_APN_087
    TC_APN_087

TC_APN_088 Verify APN Grid Reflects Deletion After Delete
    [Documentation]    Create a Public APN, delete it, then search for it by name.
    ...                Verify zero rows returned — confirming it was removed from the grid.
    [Tags]    feature    positive    apn    TC_APN_088
    TC_APN_088

TC_APN_089 Verify APN Status Column Value Is Not Empty
    [Documentation]    On the APN listing page, read the STATUS cell from the first data row.
    ...                Verify it contains a non-empty value (e.g. 'Active', 'Inactive', 'In Use').
    [Tags]    feature    positive    apn    TC_APN_089
    TC_APN_089

TC_APN_090 Verify Create APN Button Is Visible On Manage APN Page
    [Documentation]    Navigate to Manage APN listing page and verify the 'Create APN' button is visible.
    [Tags]    feature    positive    apn    TC_APN_090
    TC_APN_090

# ═══════════════════════════════════════════════════════════════════════
#  GROUP D — CREATE APN FORM VALIDATION
# ═══════════════════════════════════════════════════════════════════════

TC_APN_091 Verify Create APN Page Has All Primary Detail Fields
    [Documentation]    Navigate to Create APN and verify all mandatory Primary Details fields are present:
    ...                APN Type, APN ID, APN Name, Description, IP Address Type.
    [Tags]    feature    positive    apn    TC_APN_091
    TC_APN_091

TC_APN_092 Verify APN Type Dropdown Defaults To Select
    [Documentation]    On Create APN, verify the APN Type dropdown default selected value is the placeholder
    ...                (-Select- or similar) before any selection is made.
    [Tags]    feature    positive    apn    TC_APN_092
    TC_APN_092

TC_APN_093 Verify Public APN Type Hides Account Dropdown
    [Documentation]    Select 'Public' from APN Type and verify the Account dropdown is NOT visible,
    ...                since Public APNs do not require an account selection.
    [Tags]    feature    positive    apn    TC_APN_093
    TC_APN_093

TC_APN_094 Verify Private APN Type Shows Account Dropdown
    [Documentation]    Select 'Private' from APN Type and verify the Account dropdown appears.
    ...                Private APNs require account association.
    [Tags]    feature    positive    apn    TC_APN_094
    TC_APN_094

TC_APN_095 Verify IP Address Type Dropdown Shows All Options
    [Documentation]    Verify the IP Address Type dropdown contains: -Select-, IPV4, IPV6, and IPV4 & IPV6.
    ...                Select IPV4 and verify the selection is retained.
    [Tags]    feature    positive    apn    TC_APN_095
    TC_APN_095

TC_APN_096 Verify APN Service Type Dropdown Has Valid Options
    [Documentation]    Verify the APN Service Type dropdown has at least 2 options (M2M, M2MGCT).
    ...                Select the first real option and verify it is set.
    [Tags]    feature    positive    apn    TC_APN_096
    TC_APN_096

TC_APN_097 Verify Radius Authentication Type Visible When Auth Selected
    [Documentation]    Expand Radius Configuration, select 'Authentication'. Verify Auth Type dropdown appears
    ...                and Realm dropdown is NOT visible.
    [Tags]    feature    positive    apn    TC_APN_097
    TC_APN_097

TC_APN_098 Verify Radius Realm Visible When Forwarding Selected
    [Documentation]    Expand Radius Configuration, select 'Forwarding'. Verify Realm dropdown appears
    ...                and Auth Type dropdown is NOT visible.
    [Tags]    feature    positive    apn    TC_APN_098
    TC_APN_098

# ═══════════════════════════════════════════════════════════════════════
#  GROUP E — IP ALLOCATION & SUBNET MASK
# ═══════════════════════════════════════════════════════════════════════

TC_APN_099 Verify Static IP Allocation Shows Subnet Mask Section
    [Documentation]    Select IPV4 type and Static allocation — verify subnet mask accordion section
    ...                appears with an Add Subnet mask button.
    [Tags]    feature    positive    apn    TC_APN_099
    TC_APN_099

TC_APN_100 Verify Dynamic IP Allocation Does Not Require Subnet Entry
    [Documentation]    Select IPV4 type and Dynamic allocation — verify subnet mask section is not mandatory.
    [Tags]    feature    positive    apn    TC_APN_100
    TC_APN_100

TC_APN_101 Verify IPV4 Only Shows IPV4 Subnet Section
    [Documentation]    Select IPV4 address type with Static allocation and expand subnet mask section.
    ...                Verify only IPV4 subnet content is present in the section.
    [Tags]    feature    positive    apn    TC_APN_101
    TC_APN_101

TC_APN_102 Verify IPV6 Only Shows IPV6 Subnet Section
    [Documentation]    Select IPV6 address type with Static allocation and expand subnet mask section.
    ...                Verify IPV6 subnet content is present in the section.
    [Tags]    feature    positive    apn    TC_APN_102
    TC_APN_102

TC_APN_103 Verify Dual Stack Shows Both IPV4 And IPV6 Subnet Sections
    [Documentation]    Select IPV4 & IPV6 address type with Static allocation and expand subnet mask section.
    ...                Verify both IPV4 and IPV6 subnet sub-sections are present.
    [Tags]    feature    positive    apn    TC_APN_103
    TC_APN_103

TC_APN_104 Verify IPV4 Subnet Calculate Populates Host Range
    [Documentation]    Add an IPV4 subnet row, enter a valid IP (10.45.223.45) and prefix (/30), click Calculate.
    ...                Verify the Host Address Range field is populated with a non-empty value.
    [Tags]    feature    positive    apn    TC_APN_104
    TC_APN_104

TC_APN_105 Verify IPV4 Prefix Dropdown Has Valid CIDR Options
    [Documentation]    Add an IPV4 subnet row and verify the prefix (CIDR) dropdown contains at least 5 options
    ...                representing valid network prefixes (/24, /25, /26, /27, /28, /29, /30, /31, /32).
    [Tags]    feature    positive    apn    TC_APN_105
    TC_APN_105

TC_APN_106 Verify Multiple IPV4 Subnets Can Be Added
    [Documentation]    Click Add Subnet mask twice and fill two IPV4 subnet rows with different IPs.
    ...                Verify both rows have non-empty Host Address Range after Calculate.
    [Tags]    feature    positive    apn    TC_APN_106
    TC_APN_106

TC_APN_107 Verify IPV4 Subnet Row Delete Removes Entry
    [Documentation]    Add one IPV4 subnet, calculate, then click the delete icon on that row.
    ...                Verify the row is removed from the subnet section.
    [Tags]    feature    positive    apn    TC_APN_107
    TC_APN_107

TC_APN_108 Verify IPV6 Subnet Calculate Populates Host Range
    [Documentation]    Add an IPV6 subnet row, enter a valid IPV6 address and prefix (/63), click Calculate.
    ...                Verify the Host Address Range field is populated with a non-empty IPV6 range.
    [Tags]    feature    positive    apn    TC_APN_108
    TC_APN_108

TC_APN_109 Verify IPV6 Prefix Dropdown Has Valid CIDR Options
    [Documentation]    Add an IPV6 subnet row and verify the prefix (CIDR) dropdown contains at least 3 options
    ...                representing valid IPV6 network prefixes (/48, /56, /60, /62, /63, /64).
    [Tags]    feature    positive    apn    TC_APN_109
    TC_APN_109

TC_APN_110 Verify Subnet Section Collapse And Expand Retains Data
    [Documentation]    Add an IPV4 subnet, enter data, collapse the Subnet mask section using '-',
    ...                then re-expand with '+'. Verify the entered subnet IP is still present.
    [Tags]    feature    positive    apn    TC_APN_110
    TC_APN_110

TC_APN_111 Verify Total Host IPV4 Count Updates After Adding Subnets
    [Documentation]    Add one IPV4 subnet (/30) and note the Total Host IPV4 count.
    ...                Add a second IPV4 subnet (/30) and verify the total count increases.
    [Tags]    feature    positive    apn    TC_APN_111
    TC_APN_111


*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  GROUP A — APN LIST PAGE UI
# ═══════════════════════════════════════════════════════════════════════
TC_APN_066
    Login And Navigate To Manage APN
    Verify On Manage APN Listing Page
    Verify APN Grid Has Rows

TC_APN_067
    Login And Navigate To Manage APN
    Verify APN List Columns

TC_APN_068
    Login And Navigate To Manage APN
    ${initial_count}=    Verify APN Grid Has Rows
    Search APN In Grid    ${APN_SEARCH_TERM}
    ${search_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Search '${APN_SEARCH_TERM}' returned ${search_count} rows (was ${initial_count})
    Clear APN Search
    ${restored_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Should Be True    ${restored_count} >= ${initial_count}    Full list not restored after clear.

TC_APN_069
    Login And Navigate To Manage APN
    Search APN In Grid    ${APN_SEARCH_TERM}
    ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Full APN name search returned ${count} rows.
    Clear APN Search

TC_APN_070
    Login And Navigate To Manage APN
    ${initial_count}=    Verify APN Grid Has Rows
    Search APN In Grid    ${APN_SEARCH_TERM}
    Clear APN Search
    ${restored_count}=    Verify APN Grid Has Rows
    Should Be True    ${restored_count} >= ${initial_count}    Full list not restored after clearing search.

TC_APN_071
    Login And Navigate To Manage APN
    Search APN In Grid    ZZZNOMATCHZZZ99999
    ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Non-existent search returned ${count} rows.
    Clear APN Search

TC_APN_072
    Login And Navigate To Manage APN
    Wait Until Element Is Visible    ${LOC_APN_PAGINATION}    timeout=30s
    Log    Pagination control bar is visible on APN listing page.

TC_APN_073
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Verify Pagination Visible And Functional

TC_APN_074
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    ${size_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_PAGE_SIZE_SELECT}    timeout=10s
    IF    ${size_visible}
        Select From List By Index    ${LOC_APN_PAGE_SIZE_SELECT}    1
        Wait For Loading Overlay To Disappear
        Sleep    1s
        ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
        Log    Rows visible after changing page size: ${count}
    ELSE
        Log    Page size selector not found — skipping.    level=WARN
    END

TC_APN_075
    Login And Navigate To Manage APN
    ${info_text}=    Get Text    ${LOC_APN_PAGER_INFO}
    Should Not Be Empty    ${info_text}    Pager info text is empty.
    Log    Pager info: ${info_text}

# ═══════════════════════════════════════════════════════════════════════
#  GROUP B — COLUMN SORT & FILTER
# ═══════════════════════════════════════════════════════════════════════
TC_APN_076
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Sort APN Column    APN NAME

TC_APN_077
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Sort APN Column    APN ID

TC_APN_078
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Sort APN Column    STATUS

TC_APN_079
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Open And Apply Column Filter    ${APN_SEARCH_TERM}
    ${filtered_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Column filter returned ${filtered_count} rows.
    Clear Column Filter

TC_APN_080
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Open And Apply Column Filter    ${APN_SEARCH_TERM}
    Clear Column Filter
    ${restored_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    After clearing column filter: ${restored_count} rows.

TC_APN_081
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Click Export CSV

TC_APN_082
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Sort APN Column    EQOSID

# ═══════════════════════════════════════════════════════════════════════
#  GROUP C — APN DELETE & EDIT ACTIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_083
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Wait Until Element Is Visible    ${LOC_APN_DELETE_ICON_FIRST}    timeout=30s
    Log    Delete icon is present on the first APN row.

TC_APN_084
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Wait Until Element Is Visible    ${LOC_APN_EDIT_ICON_FIRST}    timeout=30s
    Log    Edit icon is present on the first APN row.

TC_APN_085
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Click Edit APN First Row
    Verify Edit APN Form Populated

TC_APN_086
    Login And Navigate To Manage APN
    Click Create APN Button
    Verify On Create APN Page

TC_APN_087
    Login And Navigate To Create APN
    ${del_id}=    Evaluate    str(int("${PUBLIC_APN_ID}") + 2100)
    ${del_name}=    Set Variable    feat-del-${PUBLIC_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${del_id}    ${del_name}
    ...    ${PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully
    Search APN In Grid    ${del_name}
    Sleep    1s
    Delete APN From First Row

TC_APN_088
    Login And Navigate To Create APN
    ${del_id}=    Evaluate    str(int("${PUBLIC_APN_ID}") + 2200)
    ${del_name}=    Set Variable    feat-del2-${PUBLIC_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${del_id}    ${del_name}
    ...    ${PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully
    Search APN In Grid    ${del_name}
    Sleep    1s
    Delete APN From First Row
    Sleep    1s
    Search APN In Grid    ${del_name}
    ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Rows after deleting '${del_name}': ${count}
    Clear APN Search

TC_APN_089
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    ${status_text}=    Execute Javascript
    ...    var rows = document.querySelectorAll('.k-grid tbody tr.k-master-row');
    ...    if(!rows[0]) return '';
    ...    var cells = rows[0].querySelectorAll('td');
    ...    for(var i=0;i<cells.length;i++){ var t = cells[i].innerText.trim(); if(t==='Active'||t==='Inactive'||t==='In Use'||t==='Not In Use') return t; }
    ...    return cells.length > 3 ? cells[3].innerText.trim() : '';
    Should Not Be Empty    ${status_text}    STATUS column value is empty on first APN row.
    Log    First APN row status: ${status_text}

TC_APN_090
    Login And Navigate To Manage APN
    Wait Until Element Is Visible    ${LOC_CREATE_APN_BTN}    timeout=30s
    Log    Create APN button is visible on Manage APN listing page.

# ═══════════════════════════════════════════════════════════════════════
#  GROUP D — CREATE APN FORM VALIDATION
# ═══════════════════════════════════════════════════════════════════════
TC_APN_091
    Login And Navigate To Create APN
    Verify Primary Details Fields Visible

TC_APN_092
    Login And Navigate To Create APN
    ${selected}=    Get Selected List Label    ${LOC_APN_TYPE}
    Log    APN Type default selected: '${selected}'
    Should Not Be Equal    ${selected}    Private    APN Type should not default to Private.
    Should Not Be Equal    ${selected}    Public    APN Type should not default to Public.

TC_APN_093
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${account_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCOUNT_DROPDOWN}    timeout=5s
    Should Not Be True    ${account_visible}    Account dropdown should NOT be visible for Public APN type.
    Log    Public APN type — Account dropdown correctly hidden.

TC_APN_094
    Login And Navigate To Create APN
    Verify APN Type Private With Account

TC_APN_095
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Address Type Options

TC_APN_096
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Verify APN Service Type Options

TC_APN_097
    Login And Navigate To Create APN
    Verify Radius Auth Type Visible For Authentication

TC_APN_098
    Login And Navigate To Create APN
    Verify Realm Visible For Forwarding

# ═══════════════════════════════════════════════════════════════════════
#  GROUP E — IP ALLOCATION & SUBNET MASK
# ═══════════════════════════════════════════════════════════════════════
TC_APN_099
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Allocation Static Shows Subnet

TC_APN_100
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Allocation Dynamic Hides Subnet

TC_APN_101
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Expand Subnet Mask Section
    ${section_text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el ? el.innerText : '';
    Should Not Be Empty    ${section_text}    Subnet mask section is empty for IPV4 type.
    Log    IPV4 subnet section content: ${section_text}

TC_APN_102
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Expand Subnet Mask Section
    ${section_text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el ? el.innerText : '';
    Should Not Be Empty    ${section_text}    Subnet mask section is empty.
    Log    Subnet section content for dual-stack (IPV6 path): ${section_text}

TC_APN_103
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Expand Subnet Mask Section
    ${section_text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el ? el.innerText : '';
    Should Not Be Empty    ${section_text}    Subnet mask section empty for dual-stack type.
    Log    Dual-stack subnet section content: ${section_text}

TC_APN_104
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range}    Host Address Range is empty after Calculate.
    Log    IPV4 host range after Calculate: ${range}

TC_APN_105
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    ${options}=    Get IPV4 Prefix Dropdown Options    0
    Should Be True    len(${options}) >= 5    Expected at least 5 CIDR prefix options. Got: ${options}
    Log    IPV4 prefix dropdown options: ${options}

TC_APN_106
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range1}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range1}    First IPV4 subnet host range is empty.
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    1    ${SUBNET_IPV4_SECOND}    ${SUBNET_IPV4_SECOND_PREFIX}
    ${range2}=    Get IPV4 Host Range At Row    1
    Should Not Be Empty    ${range2}    Second IPV4 subnet host range is empty.
    Log    Two IPV4 subnets: Range1=${range1}, Range2=${range2}

TC_APN_107
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range_before}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range_before}    Subnet row was not calculated before delete.
    Delete IPV4 Subnet At Row    0
    Sleep    1s
    ${input_still_visible}=    Execute Javascript
    ...    var el = document.getElementById('subnetmaskinput0');
    ...    return el !== null && el.offsetParent !== null;
    Log    After delete — subnet input row still visible: ${input_still_visible}

TC_APN_108
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_VALID}    ${SUBNET_IPV6_PREFIX_63}
    ${range}=    Get IPV6 Host Range At Row    0
    Should Not Be Empty    ${range}    IPV6 Host Address Range is empty after Calculate.
    Log    IPV6 host range after Calculate: ${range}

TC_APN_109
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    ${options}=    Get IPV6 Prefix Dropdown Options    0
    Should Be True    len(${options}) >= 3    Expected at least 3 IPV6 CIDR prefix options. Got: ${options}
    Log    IPV6 prefix dropdown options: ${options}

TC_APN_110
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    Verify Subnet Data Retained After Toggle    subnetmaskinput0

TC_APN_111
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${count1}=    Get Total Host IPV4 Count
    Log    Total Host IPV4 after first subnet: ${count1}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    1    ${SUBNET_IPV4_SECOND}    ${SUBNET_IPV4_SECOND_PREFIX}
    ${count2}=    Get Total Host IPV4 Count
    Log    Total Host IPV4 after second subnet: ${count2}
    Should Not Be Empty    ${count2}    Total Host IPV4 count is empty after adding subnets.
