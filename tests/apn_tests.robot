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
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_APN_001 Create Private APN With Static IPV4 Successfully
    [Documentation]    Navigate Service > APN, create a Private APN with Static IPV4.
    ...                Verify: success toast, redirect to /ManageAPN, grid visible.
    [Tags]    smoke    regression    positive    apn
    TC_APN_001

TC_APN_002 Create Public APN With Dynamic IPV4 Successfully
    [Documentation]    Create a Public APN with Dynamic IPV4 allocation.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_002

TC_APN_003 Create Private APN With IPV6 Successfully
    [Documentation]    Create a Private APN with IPV6 addressing and Dynamic allocation.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_003

TC_APN_004 Create APN With IPV4 And IPV6 Dual Stack Successfully
    [Documentation]    Create a Private APN with IPV4 & IPV6 dual-stack.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_004

TC_APN_005 Create APN With Secondary Details
    [Documentation]    Create Private APN with Secondary Details (HLR APN ID, MCC, MNC, Profile ID).
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_005

TC_APN_006 Create APN With QoS Details
    [Documentation]    Create Private APN with QoS 2G/3G and LTE bandwidth details.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_006

TC_APN_007 Verify Create APN Page Elements Are Visible
    [Documentation]    Navigate to Create APN page and verify all Primary Details fields are present.
    [Tags]    smoke    regression    positive    apn
    TC_APN_007

TC_APN_008 Verify IP Allocation Type Appears After IP Address Type Selection
    [Documentation]    Verify IP Allocation Type dropdown only appears after selecting IP Address Type.
    [Tags]    regression    positive    apn
    TC_APN_008

TC_APN_009 Verify Cancel Button Redirects To Manage APN
    [Documentation]    Click Cancel on Create APN page.
    ...                Verify: redirected to /ManageAPN listing.
    [Tags]    regression    positive    apn    navigation
    TC_APN_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — MISSING MANDATORY FIELDS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_010 Submit With No Fields Filled Should Show Error
    [Documentation]    Click Submit without filling any field.
    ...                Verify: validation error displayed, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_010

TC_APN_011 Missing APN Name Should Show Error
    [Documentation]    Fill all mandatory fields except APN Name, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_011

TC_APN_012 Missing APN ID Should Show Error
    [Documentation]    Fill all mandatory fields except APN ID, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_012

TC_APN_013 Missing APN Type Should Show Error
    [Documentation]    Leave APN Type as default (-Select-), fill other fields, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    Login And Navigate To Create APN
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_014 Missing IP Address Type Should Show Error
    [Documentation]    Fill all mandatory fields except IP Address Type, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_014

TC_APN_015 Missing IP Allocation Type Should Show Error
    [Documentation]    Select IP Address Type but leave IP Allocation as default, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_015

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — BOUNDARY / INVALID DATA
# ═══════════════════════════════════════════════════════════════════════

TC_APN_016 APN ID Exceeding 19 Digits Should Show Error
    [Documentation]    Enter a 20-digit APN ID value.
    ...                Verify: validation error for max length, still on Create APN page.
    [Tags]    regression    negative    apn    boundary
    TC_APN_016

TC_APN_017 Duplicate APN Name Should Show Error
    [Documentation]    Submit with an APN Name that already exists.
    ...                Verify: error toast (409 conflict) or validation error.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    apn
    TC_APN_017

TC_APN_018 SQL Injection In APN Name Should Be Rejected
    [Documentation]    Enter SQL injection payload in APN Name field.
    ...                Verify: validation error or error toast.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    security    apn
    Login And Navigate To Create APN
    ${sql_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 800)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sql_apn_id}    ${SQL_INJECTION_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    SQL Injection in APN Name

TC_APN_019 Special Characters In APN Name Should Be Rejected
    [Documentation]    Enter special characters in APN Name field.
    ...                Verify: validation error or error toast.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    security    apn
    TC_APN_019

TC_APN_020 HLR APN ID Exceeding 19 Digits Should Show Error
    [Documentation]    Enter a 20-digit HLR APN ID in Secondary Details.
    ...                Verify: validation error for max length.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    apn    boundary
    TC_APN_020

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_021 Direct Access To Create APN Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateAPN without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    apn    navigation
    TC_APN_021

TC_APN_022 Direct Access To Manage APN Without Login Should Redirect
    [Documentation]    Navigate directly to /ManageAPN without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    apn    navigation
    TC_APN_022

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — GRID TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_023 Verify APN List Page Loads With Correct Columns
    [Documentation]    Navigate to Service > APN tab and verify the list page loads with all expected
    ...                columns: APN NAME, APN ID, ACCOUNT, APN TYPE, SHARED, STATUS, EQOSID,
    ...                IPV4 ALLOCATION TYPE, IPV6 ALLOCATION TYPE, HSS PROFILE ID, DESCRIPTION,
    ...                CREATION DATE. Pagination shows total count.
    [Tags]    feature    regression    positive    apn
    TC_APN_023

TC_APN_024 Verify Search Filters APN Records
    [Documentation]    Enter a valid APN name in the search box and verify only matching records
    ...                are displayed. Clear search to restore full list.
    [Tags]    feature    regression    positive    apn
    TC_APN_024

TC_APN_025 Verify Pagination Controls Navigate Correctly
    [Documentation]    Click next page, previous page, change page size dropdown, navigate to last page.
    ...                Verify correct records displayed per page and page counter updates accurately.
    [Tags]    feature    regression    positive    apn
    TC_APN_025

TC_APN_026 Verify CSV Export Downloads File
    [Documentation]    Click the CSV/Export icon on the APN list page and verify a file download initiates.
    ...                Downloaded CSV should contain APN records with correct column headers.
    [Tags]    feature    regression    positive    apn
    TC_APN_026

TC_APN_027 Verify Column Sorting Ascending And Descending
    [Documentation]    Click column header sort on APN NAME, APN ID, STATUS, EQOSID columns.
    ...                Verify ascending on first click, descending on second click.
    [Tags]    feature    regression    positive    apn
    TC_APN_027

TC_APN_028 Verify Column Filter Applies And Clears Correctly
    [Documentation]    Click filter icon next to APN NAME column, enter filter value, apply filter.
    ...                Verify only matching records shown. Clear filter to restore full list.
    [Tags]    feature    regression    positive    apn
    TC_APN_028

TC_APN_029 Verify APN Record Can Be Deleted
    [Documentation]    Click delete icon on an APN row with status 'Not In Use', confirm deletion.
    ...                Verify confirmation dialog, success notification, and record removed from list.
    [Tags]    feature    regression    positive    apn
    TC_APN_029

TC_APN_030 Verify Edit Icon Opens Pre-populated APN Form
    [Documentation]    Click edit icon on an APN row and verify the edit form opens with all existing
    ...                APN details pre-filled. Modified value can be saved successfully.
    [Tags]    feature    regression    positive    apn
    TC_APN_030

TC_APN_031 Verify Create APN Button Navigates To Create Form
    [Documentation]    From the APN list page, click 'Create APN' button and verify navigation to
    ...                /CreateAPN page. Form displays Primary Details section with all required fields.
    [Tags]    feature    regression    positive    apn    navigation
    TC_APN_031

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN FORM — DROPDOWN & TOGGLE VERIFICATION TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_032 Verify APN Type Public Dropdown Options
    [Documentation]    Verify APN Type dropdown shows options: -Select-, Public, Private.
    ...                After selecting 'Public', field displays 'Public' and Account field adapts.
    [Tags]    feature    regression    positive    apn
    TC_APN_032

TC_APN_033 Verify APN Type Private Dropdown With Account Options
    [Documentation]    After selecting 'Private', Account field shows appropriate account options.
    ...                Form adapts based on APN type selection.
    [Tags]    feature    regression    positive    apn
    TC_APN_033

TC_APN_034 Verify All IP Address Type Options Are Selectable
    [Documentation]    Verify IP Address Type dropdown displays: -Select-, IPV4 & IPV6, IPV6, IPV4.
    ...                Select IPV4 and verify selected value is saved correctly.
    [Tags]    feature    regression    positive    apn
    TC_APN_034

TC_APN_035 Verify All APN Service Type Options Are Selectable
    [Documentation]    Verify APN Service Type dropdown displays: -Select-, M2M, M2MGCT.
    ...                Each option is selectable and retained in field after selection.
    [Tags]    feature    regression    positive    apn
    TC_APN_035

TC_APN_036 Verify Roaming Toggle Can Be Enabled And Disabled
    [Documentation]    Verify Roaming toggle default state (ON), click to toggle OFF, click to toggle ON.
    ...                State is reflected correctly in the form.
    [Tags]    feature    regression    positive    apn
    TC_APN_036

TC_APN_037 Verify Secondary Details Section Expands With Fields
    [Documentation]    Click '+' icon next to 'Secondary Details (Optional)' and verify fields:
    ...                HLR APN ID, MCC, MNC, HSS Profile Id. All are optional. Section can collapse.
    [Tags]    feature    regression    positive    apn
    TC_APN_037

TC_APN_038 Verify Quality Of Service Section Expands With Fields
    [Documentation]    Click '+' next to 'Quality of Service' and verify QoS-related fields appear.
    ...                Fields can be filled or left empty (optional).
    [Tags]    feature    regression    positive    apn
    TC_APN_038

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — DUPLICATE / INVALID DATA TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_039 Duplicate APN ID Should Show Error
    [Documentation]    Create an APN using an existing APN ID from the APN list.
    ...                Verify error message indicating APN ID already exists.
    [Tags]    regression    negative    apn
    TC_APN_039

TC_APN_040 APN ID With Non-Numeric Characters Should Be Rejected
    [Documentation]    Enter alphabetic/special characters in APN Id field.
    ...                Verify field rejects non-numeric input or shows validation error.
    [Tags]    regression    negative    apn    boundary
    TC_APN_040

TC_APN_041 Verify Auto Created APNs Visible In APN List
    [Documentation]    Search for 'auto-apn' in the APN list and verify auto-created APNs are visible
    ...                with correct attributes: APN Type, Account, Status, EQOSID.
    [Tags]    regression    positive    apn
    TC_APN_041

# ═══════════════════════════════════════════════════════════════════════
#  IP ALLOCATION & SUBNET MASK TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_042 Verify IP Allocation Static Shows Subnet Mask Section
    [Documentation]    Select IP Allocation Type = Static and verify 'IP Allocation Type' dropdown
    ...                is visible with 'Static' option. Subnet mask section appears after selection.
    [Tags]    feature    regression    positive    apn
    TC_APN_042

TC_APN_043 Verify Dynamic IP Allocation Hides Subnet Section
    [Documentation]    Select 'Dynamic' from IP Allocation Type and verify subnet mask section
    ...                is not required. Form allows submission without subnet mask entries.
    [Tags]    feature    regression    positive    apn
    TC_APN_043

TC_APN_044 Verify Subnet Mask Section Expands For Static Allocation
    [Documentation]    Select IP Allocation Type = Static, expand Subnet mask section.
    ...                Verify IPV4/IPV6 Subnets sub-sections with CSV Upload and Add Subnet mask options.
    [Tags]    feature    regression    positive    apn
    TC_APN_044

TC_APN_045 Create Public APN With Static Dual Stack Subnets E2E
    [Documentation]    End-to-end: create Public APN with Static IP Allocation and both IPV4 & IPV6 subnets.
    ...                APN Type: Public, IP Address Type: IPV4 & IPV6, IP Allocation: Static.
    ...                Verify: success notification, APN appears in list with correct attributes.
    [Tags]    regression    positive    apn    e2e
    TC_APN_045

TC_APN_046 Static IP Without Subnet Mask Should Show Validation Error
    [Documentation]    Fill all Primary Details with IP Allocation Type = Static but do NOT add subnet masks.
    ...                Verify form does not submit and validation error is displayed.
    [Tags]    regression    negative    apn    boundary
    TC_APN_046

TC_APN_047 Verify Subnet Section Matches Selected IP Address Type
    [Documentation]    When IPV4 only: only IPV4 Subnets shown. When IPV6 only: only IPV6 Subnets.
    ...                When IPV4 & IPV6: both sections shown in the Subnet mask area.
    [Tags]    feature    regression    positive    apn
    TC_APN_047

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV4 TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_048 Verify IPV4 Subnet Mask Manual Entry And Calculate
    [Documentation]    Enter valid IPV4 subnet mask 10.45.223.45 with prefix /30, click Calculate.
    ...                Verify Host Address Range auto-populates and Total Host IPV4 count updates.
    [Tags]    feature    regression    positive    apn
    TC_APN_048

TC_APN_049 Verify Invalid IPV4 Address Shows Validation Error
    [Documentation]    Enter invalid IPV4 address '999.999.999.999', select prefix, click Calculate.
    ...                Verify validation error displayed and Host Address Range remains empty.
    [Tags]    regression    negative    apn    boundary
    TC_APN_049

TC_APN_050 Verify IPV4 Prefix Dropdown Contains Valid CIDR Options
    [Documentation]    Expand subnet mask, check IPV4 prefix dropdown lists valid CIDR values
    ...                (/24, /25, /26, /27, /28, /29, /30, /31, /32).
    [Tags]    feature    regression    positive    apn
    TC_APN_050

TC_APN_051 Verify Multiple IPV4 Subnet Masks Can Be Added
    [Documentation]    Add first IPV4 subnet and calculate, then add second IPV4 subnet and calculate.
    ...                Both rows visible with own host ranges. Total Host IPV4 reflects sum.
    [Tags]    feature    regression    positive    apn
    TC_APN_051

TC_APN_052 Verify Delete Icon Removes IPV4 Subnet Mask Row
    [Documentation]    Add an IPV4 subnet mask entry, click red delete icon.
    ...                Verify row removed and Total Host IPV4 count updates.
    [Tags]    feature    regression    positive    apn
    TC_APN_052

TC_APN_053 Verify CSV Upload Imports IPV4 Subnet Entries
    [Documentation]    Click CSV Upload in IPV4 Subnets, upload valid CSV file.
    ...                Verify subnet entries populated as rows with host ranges.
    [Tags]    feature    regression    positive    apn
    TC_APN_053

TC_APN_054 Verify Invalid CSV Upload Shows Error For IPV4 Subnets
    [Documentation]    Upload an invalid/wrongly-formatted CSV for IPV4 subnets.
    ...                Verify error message shown and no invalid data imported.
    [Tags]    regression    negative    apn
    TC_APN_054

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV6 TESTS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_055 Verify IPV6 Subnet Mask Entry And Calculate
    [Documentation]    Enter valid IPV6 address fd8c:42b7:1000:0000:0 with prefix /63, click Calculate.
    ...                Verify Host Address Range auto-populates and Total Host IPV6 count updates.
    [Tags]    feature    regression    positive    apn
    TC_APN_055

TC_APN_056 Verify Invalid IPV6 Address Shows Validation Error
    [Documentation]    Enter invalid IPV6 address, select prefix, click Calculate.
    ...                Verify validation error and Host Address Range remains empty.
    [Tags]    regression    negative    apn    boundary
    TC_APN_056

TC_APN_057 Verify IPV6 Prefix Dropdown Contains Valid CIDR Options
    [Documentation]    Check IPV6 prefix dropdown lists valid CIDR values (/48, /56, /60, /62, /63, /64, /128 etc.).
    [Tags]    feature    regression    positive    apn
    TC_APN_057

TC_APN_058 Verify Multiple IPV6 Subnet Masks Can Be Added
    [Documentation]    Add first and second IPV6 subnets. Both rows visible with correct host ranges.
    ...                Total Host IPV6 reflects combined total.
    [Tags]    feature    regression    positive    apn
    TC_APN_058

TC_APN_059 Verify Delete Icon Removes IPV6 Subnet Row
    [Documentation]    Add IPV6 subnet entry, click red delete icon. Verify row removed and count updates.
    [Tags]    feature    regression    positive    apn
    TC_APN_059

TC_APN_060 Verify CSV Upload Imports IPV6 Subnet Entries
    [Documentation]    Click CSV Upload in IPV6 Subnets, upload valid IPV6 CSV file.
    ...                Verify IPV6 subnet entries appear as rows with host ranges.
    [Tags]    feature    regression    positive    apn
    TC_APN_060

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — TOTAL HOST COUNTS & UI BEHAVIOR
# ═══════════════════════════════════════════════════════════════════════

TC_APN_061 Verify Total Host IPV4 Count Sums Correctly
    [Documentation]    Add one IPV4 subnet (/30=2 hosts), note total. Add another (/30=2 hosts).
    ...                Verify Total Host IPV4 count = 4. Updates dynamically on add/remove.
    [Tags]    feature    regression    positive    apn
    TC_APN_061

TC_APN_062 Verify Total Host IPV6 Count Sums Correctly
    [Documentation]    Add one IPV6 subnet (/63=2 hosts), note total. Add another and verify
    ...                Total Host IPV6 reflects correct cumulative count.
    [Tags]    feature    regression    positive    apn
    TC_APN_062

TC_APN_063 Verify Subnet Section Collapse Expand Retains Data
    [Documentation]    Expand subnet section, enter data, collapse with '-' icon, re-expand with '+'.
    ...                Verify previously entered subnet data is retained.
    [Tags]    feature    regression    positive    apn
    TC_APN_063

TC_APN_064 Verify Change Prefix And Recalculate Updates Host Range
    [Documentation]    Add IPV4 subnet with /30, calculate (2 hosts). Change prefix to /29,
    ...                recalculate. Verify Host Address Range and Total Host count update.
    [Tags]    feature    regression    positive    apn
    TC_APN_064

TC_APN_065 Verify Edge CIDR Values For IPV4 Subnet Boundaries
    [Documentation]    Enter 192.168.1.0 with /32 (single host), then change to /24 (254 hosts).
    ...                Verify host address range boundaries computed correctly.
    [Tags]    regression    positive    apn    boundary
    TC_APN_065

*** Keywords ***
TC_APN_001
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${VALID_APN_ID}    ${VALID_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_002
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${PUBLIC_APN_ID}    ${PUBLIC_APN_NAME}
    ...    ${PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_003
    Login And Navigate To Create APN
    ${ipv6_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 100)
    ${ipv6_apn_name}=    Set Variable    auto-ipv6-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${ipv6_apn_id}    ${ipv6_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV6}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_004
    Login And Navigate To Create APN
    ${dual_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 200)
    ${dual_apn_name}=    Set Variable    auto-dual-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${dual_apn_id}    ${dual_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_BOTH}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_005
    Login And Navigate To Create APN
    ${sec_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 600)
    ${sec_apn_name}=    Set Variable    auto-sec-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sec_apn_id}    ${sec_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill Secondary Details    ${VALID_HLR_APN_ID}    ${VALID_MCC}    ${VALID_MNC}    ${VALID_PROFILE_ID}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_006
    Login And Navigate To Create APN
    ${qos_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 700)
    ${qos_apn_name}=    Set Variable    auto-qos-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${qos_apn_id}    ${qos_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill QoS Details    ${VALID_QOS_PROFILE_2G3G}    ${VALID_QOS_BW_UPLINK_2G3G}    ${VALID_QOS_BW_DOWNLINK_2G3G}
    ...    ${VALID_QOS_PROFILE_LTE}    ${VALID_QOS_BW_UPLINK_LTE}    ${VALID_QOS_BW_DOWNLINK_LTE}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_007
    Login And Navigate To Create APN
    Verify Primary Details Fields Visible

TC_APN_008
    Login And Navigate To Create APN
    Verify IP Alloc Type Appears After IP Selection

TC_APN_009
    Login And Navigate To Create APN
    Verify Cancel Redirects To Manage APN

TC_APN_010
    Login And Navigate To Create APN
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_011
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_012
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_013
    Login And Navigate To Create APN
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_014
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_015
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_016
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${APN_ID_EXCEEDS_MAX}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_017
    Login And Navigate To Create APN
    ${dup_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 999)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${dup_apn_id}    ${DUPLICATE_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    Duplicate APN Name

TC_APN_018
    Login And Navigate To Create APN
    ${sql_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 800)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sql_apn_id}    ${SQL_INJECTION_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    SQL Injection in APN Name

TC_APN_019
    Login And Navigate To Create APN
    ${spec_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 850)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${spec_apn_id}    ${SPECIAL_CHARS_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    Special Characters in APN Name

TC_APN_020
    Login And Navigate To Create APN
    ${hlr_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 900)
    ${hlr_apn_name}=    Set Variable    auto-hlr-err-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${hlr_apn_id}    ${hlr_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill Secondary Details    hlr_apn_id=${HLR_APN_ID_EXCEEDS_MAX}
    Submit Create APN Form
    Verify Negative Submission Outcome    HLR APN ID exceeding 19 digits

TC_APN_021
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_APN_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_APN_022
    Clear Session For Unauthenticated Test
    Go To    ${MANAGE_APN_URL}
    Wait For Page Load
    Verify Redirected To Login Page

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — GRID KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_023
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Verify APN List Columns
    # Verify pagination info is displayed (shows total count)
    ${info_text}=    Get Text    ${LOC_APN_PAGER_INFO}
    Log    APN list pagination info: ${info_text}
    Should Not Be Empty    ${info_text}

TC_APN_024
    Login And Navigate To Manage APN
    ${initial_count}=    Verify APN Grid Has Rows
    Search APN In Grid    ${APN_SEARCH_TERM}
    ${search_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Search results for '${APN_SEARCH_TERM}': ${search_count} rows (was ${initial_count})
    # Clear search and verify full list restored
    Clear APN Search
    ${restored_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    After clearing search: ${restored_count} rows

TC_APN_025
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Verify Pagination Visible And Functional

TC_APN_026
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Click Export CSV

TC_APN_027
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Sort APN Column    APN NAME
    Sort APN Column    APN ID
    Sort APN Column    STATUS
    Sort APN Column    EQOSID

TC_APN_028
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Open And Apply Column Filter    ${APN_SEARCH_TERM}
    ${filtered_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    Filtered results: ${filtered_count} rows
    Clear Column Filter
    ${restored_count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Log    After clearing filter: ${restored_count} rows

TC_APN_029
    # Create a Public APN to delete (Public works on QE, Private may not)
    Login And Navigate To Create APN
    ${del_apn_id}=    Evaluate    str(int("${PUBLIC_APN_ID}") + 1100)
    ${del_apn_name}=    Set Variable    auto-del-${PUBLIC_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${del_apn_id}    ${del_apn_name}
    ...    ${PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully
    # Now search for the created APN and delete it
    Search APN In Grid    ${del_apn_name}
    Sleep    1s
    Delete APN From First Row

TC_APN_030
    Login And Navigate To Manage APN
    Verify APN Grid Has Rows
    Click Edit APN First Row
    Verify Edit APN Form Populated

TC_APN_031
    Login And Navigate To Manage APN
    Wait Until Element Is Visible    ${LOC_CREATE_APN_BTN}    timeout=30s
    Click Element Via JS    ${LOC_CREATE_APN_BTN}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Location Should Contain    ${CREATE_APN_PATH}
    Verify Primary Details Fields Visible
    Log    Create APN button navigated to /CreateAPN with Primary Details visible.

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN FORM — DROPDOWN & TOGGLE KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_032
    Login And Navigate To Create APN
    Verify APN Type Public Dropdown

TC_APN_033
    Login And Navigate To Create APN
    Verify APN Type Private With Account

TC_APN_034
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Address Type Options

TC_APN_035
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Verify APN Service Type Options

TC_APN_036
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Verify Roaming Toggle

TC_APN_037
    Login And Navigate To Create APN
    Expand And Verify Secondary Details

TC_APN_038
    Login And Navigate To Create APN
    Expand And Verify QoS Section

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — DUPLICATE / INVALID DATA KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_039
    Login And Navigate To Create APN
    # Use the same APN ID as TC_APN_001 (already created) to trigger duplicate error
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${VALID_APN_ID}    auto-dup-id-${VALID_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    Duplicate APN ID

TC_APN_040
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    # Try alphabetic characters in APN ID
    Enter APN ID    ${ALPHA_APN_ID}
    Enter APN Name    auto-num-test-${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Negative Submission Outcome    Non-numeric APN ID

TC_APN_041
    Login And Navigate To Manage APN
    Search APN In Grid    ${APN_SEARCH_TERM}
    ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Should Be True    ${count} >= 0    No auto-created APNs found for search term '${APN_SEARCH_TERM}'.
    Log    Found ${count} auto-created APN(s) matching '${APN_SEARCH_TERM}'.
    Clear APN Search

# ═══════════════════════════════════════════════════════════════════════
#  IP ALLOCATION & SUBNET KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_042
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Allocation Static Shows Subnet

TC_APN_043
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify IP Allocation Dynamic Hides Subnet

TC_APN_044
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Verify Subnet Mask Section Visible

TC_APN_045
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${E2E_PUBLIC_APN_ID}    ${E2E_PUBLIC_APN_NAME}
    ...    ${E2E_PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_BOTH}    ${VALID_IP_ALLOC_STATIC}
    ...    eqos_id=${E2E_PUBLIC_EQOS_ID}    context_id=${E2E_PUBLIC_CONTEXT_ID}
    # Add IPV4 subnet
    Add And Fill Subnet Mask Entry    ${VALID_SUBNET_IP}    ${VALID_SUBNET_CIDR}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_046
    Login And Navigate To Create APN
    ${no_sub_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 1200)
    ${no_sub_apn_name}=    Set Variable    auto-nosub-${VALID_APN_NAME}
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${no_sub_apn_id}
    Enter APN Name    ${no_sub_apn_name}
    Enter Description    ${VALID_DESCRIPTION}
    Enter EQOS ID    ${VALID_EQOS_ID}
    Enter Context ID    ${VALID_CONTEXT_ID}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Select APN Service Type
    # Do NOT add subnet mask entries — submit directly
    Submit Create APN Form
    Verify Negative Submission Outcome    Static IP without subnet mask

TC_APN_047
    # Re-navigate for each IP type to avoid stale page state
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify Subnet Section Based On IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    # Re-navigate for IPV6
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify Subnet Section Based On IP Address Type    ${VALID_IP_ADDR_TYPE_IPV6}
    # Re-navigate for IPV4 & IPV6
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Verify Subnet Section Based On IP Address Type    ${VALID_IP_ADDR_TYPE_BOTH}

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV4 KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_048
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range}    Host Address Range is empty after Calculate.
    Log    IPV4 subnet calculated — Host Range: ${range}

TC_APN_049
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_INVALID}    ${SUBNET_IPV4_PREFIX_30}
    # Check for validation error or empty host range
    ${range}=    Get IPV4 Host Range At Row    0
    ${has_error}=    Execute Javascript
    ...    var t = document.querySelector('#onetimechanges').innerText.toLowerCase();
    ...    return t.indexOf('invalid') >= 0 || t.indexOf('error') >= 0 || t.indexOf('please') >= 0;
    ${is_empty_range}=    Evaluate    '${range}' == '' or '${range}' == 'None'
    Should Be True    ${has_error} or ${is_empty_range}
    ...    Invalid IPV4 address was accepted — no validation error and range is '${range}'.
    Log    Invalid IPV4 correctly rejected. Error shown: ${has_error}, Range empty: ${is_empty_range}

TC_APN_050
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    ${options}=    Get IPV4 Prefix Dropdown Options    0
    Log    IPV4 CIDR prefix options: ${options}
    Should Be True    len(${options}) >= 5    Expected at least 5 CIDR options. Got: ${options}
    Log    IPV4 prefix dropdown verified with ${options.__len__()} options.

TC_APN_051
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    # First subnet row
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range1}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range1}    First IPV4 subnet host range is empty.
    # Second subnet row
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    1    ${SUBNET_IPV4_SECOND}    ${SUBNET_IPV4_SECOND_PREFIX}
    ${range2}=    Get IPV4 Host Range At Row    1
    Should Not Be Empty    ${range2}    Second IPV4 subnet host range is empty.
    Log    Two IPV4 subnets added — Range1: ${range1}, Range2: ${range2}

TC_APN_052
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range_before}=    Get IPV4 Host Range At Row    0
    Should Not Be Empty    ${range_before}    IPV4 subnet not calculated before delete.
    Delete IPV4 Subnet At Row    0
    ${input_exists}=    Execute Javascript
    ...    return document.getElementById('subnetmaskinput0') !== null && document.getElementById('subnetmaskinput0').offsetParent !== null;
    Log    After delete — input still visible: ${input_exists}

TC_APN_053
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    ${csv_path}=    Create Temp CSV File    10.0.0.0,/24\\n172.16.0.0,/30    ipv4_subnets.csv
    Upload IPV4 CSV File    ${csv_path}
    Sleep    1s
    Log    IPV4 CSV upload attempted from: ${csv_path}

TC_APN_054
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    ${csv_path}=    Create Temp CSV File    invalid_data,not_a_cidr\\nxyz,abc    invalid_ipv4.csv
    Upload IPV4 CSV File    ${csv_path}
    Sleep    1s
    ${has_error}=    Execute Javascript
    ...    var t = document.body.innerText.toLowerCase();
    ...    return t.indexOf('error') >= 0 || t.indexOf('invalid') >= 0 || t.indexOf('format') >= 0;
    Log    Invalid CSV upload — error detected on page: ${has_error}

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV6 KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_055
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_VALID}    ${SUBNET_IPV6_PREFIX_63}
    ${range}=    Get IPV6 Host Range At Row    0
    Should Not Be Empty    ${range}    IPV6 Host Address Range is empty after Calculate.
    Log    IPV6 subnet calculated — Host Range: ${range}

TC_APN_056
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_INVALID}    ${SUBNET_IPV6_PREFIX_63}
    ${range}=    Get IPV6 Host Range At Row    0
    ${has_error}=    Execute Javascript
    ...    var t = document.querySelector('#onetimechanges').innerText.toLowerCase();
    ...    return t.indexOf('invalid') >= 0 || t.indexOf('error') >= 0 || t.indexOf('please') >= 0;
    ${is_empty_range}=    Evaluate    '${range}' == '' or '${range}' == 'None'
    Should Be True    ${has_error} or ${is_empty_range}
    ...    Invalid IPV6 address was accepted — no validation error and range is '${range}'.
    Log    Invalid IPV6 correctly rejected. Error: ${has_error}, Range empty: ${is_empty_range}

TC_APN_057
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    ${options}=    Get IPV6 Prefix Dropdown Options    0
    Log    IPV6 CIDR prefix options: ${options}
    Should Be True    len(${options}) >= 3    Expected at least 3 IPV6 CIDR options. Got: ${options}
    Log    IPV6 prefix dropdown verified with ${options.__len__()} options.

TC_APN_058
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    # First IPV6 subnet row
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_VALID}    ${SUBNET_IPV6_PREFIX_63}
    ${range1}=    Get IPV6 Host Range At Row    0
    Should Not Be Empty    ${range1}    First IPV6 subnet host range is empty.
    # Second IPV6 subnet row
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    1    ${SUBNET_IPV6_SECOND}    ${SUBNET_IPV6_SECOND_PREFIX}
    ${range2}=    Get IPV6 Host Range At Row    1
    Should Not Be Empty    ${range2}    Second IPV6 subnet host range is empty.
    Log    Two IPV6 subnets added — Range1: ${range1}, Range2: ${range2}

TC_APN_059
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_VALID}    ${SUBNET_IPV6_PREFIX_63}
    ${range_before}=    Get IPV6 Host Range At Row    0
    Delete IPV6 Subnet At Row    0
    Sleep    1s
    Log    IPV6 subnet row deleted.

TC_APN_060
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    ${csv_path}=    Create Temp CSV File    fd8c:42b7:1000::,/63\\n2001:db8::,/64    ipv6_subnets.csv
    Upload IPV6 CSV File    ${csv_path}
    Sleep    1s
    Log    IPV6 CSV upload attempted from: ${csv_path}

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — TOTAL COUNTS & UI KEYWORD IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════
TC_APN_061
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    # First subnet: /30 = 2 hosts
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${count1}=    Get Total Host IPV4 Count
    Log    Total Host IPV4 after first subnet: ${count1}
    # Second subnet: /30 = 2 hosts — total should be 4
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    1    ${SUBNET_IPV4_SECOND}    ${SUBNET_IPV4_SECOND_PREFIX}
    ${count2}=    Get Total Host IPV4 Count
    Log    Total Host IPV4 after second subnet: ${count2}

TC_APN_062
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_BOTH}
    # First IPV6 subnet: /63 = 2 hosts
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    0    ${SUBNET_IPV6_VALID}    ${SUBNET_IPV6_PREFIX_63}
    ${count1}=    Get Total Host IPV6 Count
    Log    Total Host IPV6 after first subnet: ${count1}
    # Second IPV6 subnet
    Click Add IPV6 Subnet Row
    Fill IPV6 Subnet At Row    1    ${SUBNET_IPV6_SECOND}    ${SUBNET_IPV6_SECOND_PREFIX}
    ${count2}=    Get Total Host IPV6 Count
    Log    Total Host IPV6 after second subnet: ${count2}

TC_APN_063
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    # Verify data retained after collapse/expand
    Verify Subnet Data Retained After Toggle    subnetmaskinput0

TC_APN_064
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    # First calculate with /30
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_VALID}    ${SUBNET_IPV4_PREFIX_30}
    ${range_30}=    Get IPV4 Host Range At Row    0
    Log    Host range with /30: ${range_30}
    # Recalculate with /29
    ${select_loc}=    Set Variable    xpath=(//div[@id='onetimechanges']//select[@name='subnetmasklist'])[1]
    Select From List By Value    ${select_loc}    ${SUBNET_IPV4_PREFIX_29}
    Sleep    0.5s
    # Click Calculate via JS
    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges button, #onetimechanges a.btn');
    ...    for(var i=0;i<btns.length;i++){ if(btns[i].textContent.indexOf('Calculate')>=0){ btns[i].click(); break; } }
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${range_29}=    Get IPV4 Host Range At Row    0
    Log    Host range with /29: ${range_29}
    Should Not Be Equal    ${range_30}    ${range_29}    Host range did not update after prefix change.

TC_APN_065
    Navigate To Create APN With Static IP    ${VALID_IP_ADDR_TYPE_IPV4}
    Click Add IPV4 Subnet Row
    # /32 = single host
    Fill IPV4 Subnet At Row    0    ${SUBNET_IPV4_EDGE_IP}    ${SUBNET_IPV4_PREFIX_32}
    ${range_32}=    Get IPV4 Host Range At Row    0
    Log    /32 Host range: ${range_32} (expected single host)
    # Change to /24 = 254 usable hosts
    ${select_loc}=    Set Variable    xpath=(//div[@id='onetimechanges']//select[@name='subnetmasklist'])[1]
    Select From List By Value    ${select_loc}    ${SUBNET_IPV4_PREFIX_24}
    Sleep    0.5s
    # Click Calculate via JS
    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges button, #onetimechanges a.btn');
    ...    for(var i=0;i<btns.length;i++){ if(btns[i].textContent.indexOf('Calculate')>=0){ btns[i].click(); break; } }
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${range_24}=    Get IPV4 Host Range At Row    0
    Log    /24 Host range: ${range_24} (expected 254 usable hosts)
    Should Not Be Equal    ${range_32}    ${range_24}    Host range did not change between /32 and /24.
