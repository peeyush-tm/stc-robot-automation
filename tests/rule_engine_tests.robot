*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/rule_engine_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/rule_engine_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/rule_engine_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}    AND    Cleanup Automation Rules
Suite Teardown    Close All Browsers
Test Setup        Run Keywords    Ensure Session Is Active    AND    Proactive Browser Restart If Needed    interval=15
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_RE_001 Create Rule With SIM Lifecycle And Raise Alert Action
    [Documentation]    Full 4-tab wizard happy path: Navigate to Rule Engine listing,
    ...                click Create Rule, fill Primary Details (EC level, SIMLifecycle),
    ...                select first Rule Category trigger + save, set Account aggregation,
    ...                add Raise Alert action, submit, verify success toast and redirect.
    [Tags]    smoke    regression    positive    rule-engine    sim-lifecycle
    TC_RE_001

TC_RE_002 Create Rule With SIM Lifecycle Trigger Option 2
    [Documentation]    SIMLifecycle category with 2nd Rule Category option (e.g. Country or Operator change, Data Session Count, etc.).
    [Tags]    regression    positive    rule-engine    sim-lifecycle    trigger-2
    TC_RE_002

TC_RE_003 Create Rule With SIM Lifecycle Trigger Option 3
    [Documentation]    SIMLifecycle category with 3rd Rule Category option (e.g. Data Session End, Data Session Start, etc.).
    [Tags]    regression    positive    rule-engine    sim-lifecycle    trigger-3
    TC_RE_003

TC_RE_004 Create Rule With Fraud Prevention Trigger Option 1
    [Documentation]    FraudPrevention category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    fraud-prevention    trigger-1
    TC_RE_004

TC_RE_005 Create Rule With Fraud Prevention Trigger Option 2
    [Documentation]    FraudPrevention category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    fraud-prevention    trigger-2
    TC_RE_005

TC_RE_006 Create Rule With Cost Control Trigger Option 1
    [Documentation]    CostControl category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    cost-control    trigger-1
    TC_RE_006

TC_RE_007 Create Rule With Cost Control Trigger Option 2
    [Documentation]    CostControl category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    cost-control    trigger-2
    TC_RE_007

TC_RE_008 Create Rule With Others Category Trigger Option 1
    [Documentation]    Others category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    others    trigger-1
    TC_RE_008

TC_RE_009 Create Rule With Others Category Trigger Option 2
    [Documentation]    Others category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    others    trigger-2
    TC_RE_009

# ── Define Triggers Tab 2: one test per Rule Category option (each = one full new rule).
#     Tab 4 category×action: TC_RE_009E_* (each = one full new rule).
#     Regenerate fragment: python bin/gen_rule_engine_matrix_tests.py --out tests/_re_matrix_generated.robotfragment
TC_RE_009A01 SIMLifecycle Define Triggers Rule Category Option 01
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 1. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-01
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    1    AllSL

TC_RE_009A02 SIMLifecycle Define Triggers Rule Category Option 02
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 2. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-02
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    2    AllSL

TC_RE_009A03 SIMLifecycle Define Triggers Rule Category Option 03
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 3. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-03
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    3    AllSL

TC_RE_009A04 SIMLifecycle Define Triggers Rule Category Option 04
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 4. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-04
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    4    AllSL

TC_RE_009A05 SIMLifecycle Define Triggers Rule Category Option 05
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 5. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-05
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    5    AllSL

TC_RE_009A06 SIMLifecycle Define Triggers Rule Category Option 06
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 6. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-06
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    6    AllSL

TC_RE_009A07 SIMLifecycle Define Triggers Rule Category Option 07
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 7. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-07
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    7    AllSL

TC_RE_009A08 SIMLifecycle Define Triggers Rule Category Option 08
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 8. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-08
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    8    AllSL

TC_RE_009A09 SIMLifecycle Define Triggers Rule Category Option 09
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 9. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-09
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    9    AllSL

TC_RE_009A10 SIMLifecycle Define Triggers Rule Category Option 10
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 10. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-10
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    10    AllSL

TC_RE_009A11 SIMLifecycle Define Triggers Rule Category Option 11
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 11. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-11
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    11    AllSL

TC_RE_009A12 SIMLifecycle Define Triggers Rule Category Option 12
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 12. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-12
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    12    AllSL

TC_RE_009A13 SIMLifecycle Define Triggers Rule Category Option 13
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 13. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-13
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    13    AllSL

TC_RE_009A14 SIMLifecycle Define Triggers Rule Category Option 14
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 14. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-14
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    14    AllSL

TC_RE_009A15 SIMLifecycle Define Triggers Rule Category Option 15
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 15. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-15
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    15    AllSL

TC_RE_009A16 SIMLifecycle Define Triggers Rule Category Option 16
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 16. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-16
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    16    AllSL

TC_RE_009A17 SIMLifecycle Define Triggers Rule Category Option 17
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 17. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-17
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    17    AllSL

TC_RE_009A18 SIMLifecycle Define Triggers Rule Category Option 18
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 18. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-18
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    18    AllSL

TC_RE_009A19 SIMLifecycle Define Triggers Rule Category Option 19
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 19. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-19
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    19    AllSL

TC_RE_009A20 SIMLifecycle Define Triggers Rule Category Option 20
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 20. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-20
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    20    AllSL

TC_RE_009A21 SIMLifecycle Define Triggers Rule Category Option 21
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 21. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-21
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    21    AllSL

TC_RE_009A22 SIMLifecycle Define Triggers Rule Category Option 22
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 22. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-22
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    22    AllSL

TC_RE_009A23 SIMLifecycle Define Triggers Rule Category Option 23
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 23. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-23
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    23    AllSL

TC_RE_009A24 SIMLifecycle Define Triggers Rule Category Option 24
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 24. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-24
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    24    AllSL

TC_RE_009A25 SIMLifecycle Define Triggers Rule Category Option 25
    [Documentation]    One rule: Primary SIMLifecycle, Tab 2 Rule Category option index 25. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers    re-t2-opt-25
    Create Rule For Single Rule Category Option    ${RE_CATEGORY}    25    AllSL

TC_RE_009B01 Fraud Prevention Define Triggers Rule Category Option 01
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 1. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-01
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    1    AllFP

TC_RE_009B02 Fraud Prevention Define Triggers Rule Category Option 02
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 2. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-02
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    2    AllFP

TC_RE_009B03 Fraud Prevention Define Triggers Rule Category Option 03
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 3. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-03
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    3    AllFP

TC_RE_009B04 Fraud Prevention Define Triggers Rule Category Option 04
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 4. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-04
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    4    AllFP

TC_RE_009B05 Fraud Prevention Define Triggers Rule Category Option 05
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 5. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-05
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    5    AllFP

TC_RE_009B06 Fraud Prevention Define Triggers Rule Category Option 06
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 6. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-06
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    6    AllFP

TC_RE_009B07 Fraud Prevention Define Triggers Rule Category Option 07
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 7. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-07
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    7    AllFP

TC_RE_009B08 Fraud Prevention Define Triggers Rule Category Option 08
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 8. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-08
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    8    AllFP

TC_RE_009B09 Fraud Prevention Define Triggers Rule Category Option 09
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 9. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-09
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    9    AllFP

TC_RE_009B10 Fraud Prevention Define Triggers Rule Category Option 10
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 10. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-10
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    10    AllFP

TC_RE_009B11 Fraud Prevention Define Triggers Rule Category Option 11
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 11. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-11
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    11    AllFP

TC_RE_009B12 Fraud Prevention Define Triggers Rule Category Option 12
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 12. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-12
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    12    AllFP

TC_RE_009B13 Fraud Prevention Define Triggers Rule Category Option 13
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 13. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-13
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    13    AllFP

TC_RE_009B14 Fraud Prevention Define Triggers Rule Category Option 14
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 14. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-14
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    14    AllFP

TC_RE_009B15 Fraud Prevention Define Triggers Rule Category Option 15
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 15. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-15
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    15    AllFP

TC_RE_009B16 Fraud Prevention Define Triggers Rule Category Option 16
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 16. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-16
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    16    AllFP

TC_RE_009B17 Fraud Prevention Define Triggers Rule Category Option 17
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 17. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-17
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    17    AllFP

TC_RE_009B18 Fraud Prevention Define Triggers Rule Category Option 18
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 18. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-18
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    18    AllFP

TC_RE_009B19 Fraud Prevention Define Triggers Rule Category Option 19
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 19. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-19
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    19    AllFP

TC_RE_009B20 Fraud Prevention Define Triggers Rule Category Option 20
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 20. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-20
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    20    AllFP

TC_RE_009B21 Fraud Prevention Define Triggers Rule Category Option 21
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 21. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-21
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    21    AllFP

TC_RE_009B22 Fraud Prevention Define Triggers Rule Category Option 22
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 22. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-22
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    22    AllFP

TC_RE_009B23 Fraud Prevention Define Triggers Rule Category Option 23
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 23. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-23
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    23    AllFP

TC_RE_009B24 Fraud Prevention Define Triggers Rule Category Option 24
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 24. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-24
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    24    AllFP

TC_RE_009B25 Fraud Prevention Define Triggers Rule Category Option 25
    [Documentation]    One rule: Primary Fraud Prevention, Tab 2 Rule Category option index 25. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers    re-t2-opt-25
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_FRAUD}    25    AllFP

TC_RE_009C01 Cost Control Define Triggers Rule Category Option 01
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 1. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-01
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    1    AllCC

TC_RE_009C02 Cost Control Define Triggers Rule Category Option 02
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 2. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-02
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    2    AllCC

TC_RE_009C03 Cost Control Define Triggers Rule Category Option 03
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 3. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-03
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    3    AllCC

TC_RE_009C04 Cost Control Define Triggers Rule Category Option 04
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 4. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-04
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    4    AllCC

TC_RE_009C05 Cost Control Define Triggers Rule Category Option 05
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 5. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-05
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    5    AllCC

TC_RE_009C06 Cost Control Define Triggers Rule Category Option 06
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 6. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-06
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    6    AllCC

TC_RE_009C07 Cost Control Define Triggers Rule Category Option 07
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 7. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-07
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    7    AllCC

TC_RE_009C08 Cost Control Define Triggers Rule Category Option 08
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 8. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-08
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    8    AllCC

TC_RE_009C09 Cost Control Define Triggers Rule Category Option 09
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 9. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-09
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    9    AllCC

TC_RE_009C10 Cost Control Define Triggers Rule Category Option 10
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 10. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-10
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    10    AllCC

TC_RE_009C11 Cost Control Define Triggers Rule Category Option 11
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 11. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-11
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    11    AllCC

TC_RE_009C12 Cost Control Define Triggers Rule Category Option 12
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 12. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-12
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    12    AllCC

TC_RE_009C13 Cost Control Define Triggers Rule Category Option 13
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 13. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-13
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    13    AllCC

TC_RE_009C14 Cost Control Define Triggers Rule Category Option 14
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 14. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-14
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    14    AllCC

TC_RE_009C15 Cost Control Define Triggers Rule Category Option 15
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 15. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-15
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    15    AllCC

TC_RE_009C16 Cost Control Define Triggers Rule Category Option 16
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 16. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-16
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    16    AllCC

TC_RE_009C17 Cost Control Define Triggers Rule Category Option 17
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 17. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-17
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    17    AllCC

TC_RE_009C18 Cost Control Define Triggers Rule Category Option 18
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 18. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-18
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    18    AllCC

TC_RE_009C19 Cost Control Define Triggers Rule Category Option 19
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 19. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-19
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    19    AllCC

TC_RE_009C20 Cost Control Define Triggers Rule Category Option 20
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 20. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-20
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    20    AllCC

TC_RE_009C21 Cost Control Define Triggers Rule Category Option 21
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 21. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-21
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    21    AllCC

TC_RE_009C22 Cost Control Define Triggers Rule Category Option 22
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 22. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-22
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    22    AllCC

TC_RE_009C23 Cost Control Define Triggers Rule Category Option 23
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 23. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-23
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    23    AllCC

TC_RE_009C24 Cost Control Define Triggers Rule Category Option 24
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 24. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-24
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    24    AllCC

TC_RE_009C25 Cost Control Define Triggers Rule Category Option 25
    [Documentation]    One rule: Primary Cost Control, Tab 2 Rule Category option index 25. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers    re-t2-opt-25
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_COST}    25    AllCC

TC_RE_009D01 Others Define Triggers Rule Category Option 01
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 1. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-01
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    1    AllOT

TC_RE_009D02 Others Define Triggers Rule Category Option 02
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 2. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-02
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    2    AllOT

TC_RE_009D03 Others Define Triggers Rule Category Option 03
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 3. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-03
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    3    AllOT

TC_RE_009D04 Others Define Triggers Rule Category Option 04
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 4. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-04
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    4    AllOT

TC_RE_009D05 Others Define Triggers Rule Category Option 05
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 5. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-05
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    5    AllOT

TC_RE_009D06 Others Define Triggers Rule Category Option 06
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 6. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-06
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    6    AllOT

TC_RE_009D07 Others Define Triggers Rule Category Option 07
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 7. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-07
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    7    AllOT

TC_RE_009D08 Others Define Triggers Rule Category Option 08
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 8. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-08
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    8    AllOT

TC_RE_009D09 Others Define Triggers Rule Category Option 09
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 9. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-09
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    9    AllOT

TC_RE_009D10 Others Define Triggers Rule Category Option 10
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 10. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-10
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    10    AllOT

TC_RE_009D11 Others Define Triggers Rule Category Option 11
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 11. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-11
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    11    AllOT

TC_RE_009D12 Others Define Triggers Rule Category Option 12
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 12. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-12
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    12    AllOT

TC_RE_009D13 Others Define Triggers Rule Category Option 13
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 13. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-13
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    13    AllOT

TC_RE_009D14 Others Define Triggers Rule Category Option 14
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 14. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-14
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    14    AllOT

TC_RE_009D15 Others Define Triggers Rule Category Option 15
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 15. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-15
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    15    AllOT

TC_RE_009D16 Others Define Triggers Rule Category Option 16
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 16. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-16
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    16    AllOT

TC_RE_009D17 Others Define Triggers Rule Category Option 17
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 17. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-17
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    17    AllOT

TC_RE_009D18 Others Define Triggers Rule Category Option 18
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 18. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-18
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    18    AllOT

TC_RE_009D19 Others Define Triggers Rule Category Option 19
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 19. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-19
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    19    AllOT

TC_RE_009D20 Others Define Triggers Rule Category Option 20
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 20. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-20
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    20    AllOT

TC_RE_009D21 Others Define Triggers Rule Category Option 21
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 21. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-21
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    21    AllOT

TC_RE_009D22 Others Define Triggers Rule Category Option 22
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 22. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-22
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    22    AllOT

TC_RE_009D23 Others Define Triggers Rule Category Option 23
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 23. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-23
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    23    AllOT

TC_RE_009D24 Others Define Triggers Rule Category Option 24
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 24. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-24
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    24    AllOT

TC_RE_009D25 Others Define Triggers Rule Category Option 25
    [Documentation]    One rule: Primary Others, Tab 2 Rule Category option index 25. Indices beyond API count skip.
    [Tags]    regression    positive    rule-engine    others    all-triggers    re-t2-opt-25
    Create Rule For Single Rule Category Option    ${RE_CATEGORY_OTHER}    25    AllOT

TC_RE_009E_SL01 SIMLifecycle Tab4 Action Option 01
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 1 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-01
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    1    ComboSL

TC_RE_009E_SL02 SIMLifecycle Tab4 Action Option 02
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 2 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-02
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    2    ComboSL

TC_RE_009E_SL03 SIMLifecycle Tab4 Action Option 03
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 3 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-03
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    3    ComboSL

TC_RE_009E_SL04 SIMLifecycle Tab4 Action Option 04
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 4 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-04
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    4    ComboSL

TC_RE_009E_SL05 SIMLifecycle Tab4 Action Option 05
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 5 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-05
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    5    ComboSL

TC_RE_009E_SL06 SIMLifecycle Tab4 Action Option 06
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 6 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-06
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    6    ComboSL

TC_RE_009E_SL07 SIMLifecycle Tab4 Action Option 07
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 7 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-07
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    7    ComboSL

TC_RE_009E_SL08 SIMLifecycle Tab4 Action Option 08
    [Documentation]    One rule: Primary SIMLifecycle, Tab 4 Action type index 8 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    sim-lifecycle    category-action-combo    re-t4-act-08
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY}    8    ComboSL

TC_RE_009E_FP01 Fraud Prevention Tab4 Action Option 01
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 1 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-01
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    1    ComboFP

TC_RE_009E_FP02 Fraud Prevention Tab4 Action Option 02
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 2 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-02
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    2    ComboFP

TC_RE_009E_FP03 Fraud Prevention Tab4 Action Option 03
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 3 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-03
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    3    ComboFP

TC_RE_009E_FP04 Fraud Prevention Tab4 Action Option 04
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 4 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-04
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    4    ComboFP

TC_RE_009E_FP05 Fraud Prevention Tab4 Action Option 05
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 5 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-05
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    5    ComboFP

TC_RE_009E_FP06 Fraud Prevention Tab4 Action Option 06
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 6 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-06
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    6    ComboFP

TC_RE_009E_FP07 Fraud Prevention Tab4 Action Option 07
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 7 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-07
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    7    ComboFP

TC_RE_009E_FP08 Fraud Prevention Tab4 Action Option 08
    [Documentation]    One rule: Primary Fraud Prevention, Tab 4 Action type index 8 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    fraud-prevention    category-action-combo    re-t4-act-08
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_FRAUD}    8    ComboFP

TC_RE_009E_CC01 Cost Control Tab4 Action Option 01
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 1 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-01
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    1    ComboCC

TC_RE_009E_CC02 Cost Control Tab4 Action Option 02
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 2 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-02
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    2    ComboCC

TC_RE_009E_CC03 Cost Control Tab4 Action Option 03
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 3 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-03
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    3    ComboCC

TC_RE_009E_CC04 Cost Control Tab4 Action Option 04
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 4 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-04
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    4    ComboCC

TC_RE_009E_CC05 Cost Control Tab4 Action Option 05
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 5 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-05
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    5    ComboCC

TC_RE_009E_CC06 Cost Control Tab4 Action Option 06
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 6 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-06
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    6    ComboCC

TC_RE_009E_CC07 Cost Control Tab4 Action Option 07
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 7 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-07
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    7    ComboCC

TC_RE_009E_CC08 Cost Control Tab4 Action Option 08
    [Documentation]    One rule: Primary Cost Control, Tab 4 Action type index 8 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    cost-control    category-action-combo    re-t4-act-08
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_COST}    8    ComboCC

TC_RE_009E_OT01 Others Tab4 Action Option 01
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 1 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-01
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    1    ComboOT

TC_RE_009E_OT02 Others Tab4 Action Option 02
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 2 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-02
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    2    ComboOT

TC_RE_009E_OT03 Others Tab4 Action Option 03
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 3 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-03
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    3    ComboOT

TC_RE_009E_OT04 Others Tab4 Action Option 04
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 4 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-04
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    4    ComboOT

TC_RE_009E_OT05 Others Tab4 Action Option 05
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 5 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-05
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    5    ComboOT

TC_RE_009E_OT06 Others Tab4 Action Option 06
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 6 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-06
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    6    ComboOT

TC_RE_009E_OT07 Others Tab4 Action Option 07
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 7 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-07
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    7    ComboOT

TC_RE_009E_OT08 Others Tab4 Action Option 08
    [Documentation]    One rule: Primary Others, Tab 4 Action type index 8 (real options only). Beyond count skips.
    [Tags]    regression    positive    rule-engine    others    category-action-combo    re-t4-act-08
    Create Rule For Primary Category And Nth Action    ${RE_CATEGORY_OTHER}    8    ComboOT

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_RE_010 NEG01 Next On Tab1 With Rule Name Blank
    [Documentation]    Leave Rule Name empty on Tab 1, click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_010

TC_RE_011 NEG02 Next On Tab1 With Category Not Selected
    [Documentation]    Fill Rule Name and Description but leave Category as default. Click Next.
    ...                Wizard must stay on Tab 1 with validation error.
    [Tags]    regression    negative    rule-engine
    TC_RE_011

TC_RE_012 NEG03 Next On Tab1 With App Level Not Selected
    [Documentation]    Fill Rule Name, select Category, enter Description, but leave
    ...                Application Level as default. Click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_012

TC_RE_013 NEG04 Next On Tab1 With Customer Not Selected
    [Documentation]    Fill all Tab 1 fields except Customer Account. Click Next.
    ...                Wizard must stay on Tab 1 with validation error for Customer.
    [Tags]    regression    negative    rule-engine
    TC_RE_013

TC_RE_014 NEG05 Next On Tab1 With Device Plan Not Selected
    [Documentation]    Fill all Tab 1 fields including Customer, but leave Device Plan
    ...                as default -Select-. Click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_014

TC_RE_015 NEG06 Next On Tab2 With No Rule Category Selected
    [Documentation]    Complete Tab 1, advance to Tab 2, leave Rule Category unselected,
    ...                click Next. Wizard must stay on Tab 2.
    [Tags]    regression    negative    rule-engine
    TC_RE_015

TC_RE_016 NEG07 Next On Tab2 With No Trigger Saved
    [Documentation]    Complete Tab 1, advance to Tab 2, select Rule Category but do NOT
    ...                click Add/Save Trigger. Click Next. Wizard must stay on Tab 2.
    [Tags]    regression    negative    rule-engine
    TC_RE_016

TC_RE_017 NEG08 Next On Tab3 With No Aggregation Level
    [Documentation]    Complete Tabs 1-2, advance to Tab 3, leave Aggregation Level unselected,
    ...                click Next. Wizard must stay on Tab 3.
    [Tags]    regression    negative    rule-engine
    TC_RE_017

TC_RE_018 NEG09 Submit On Tab4 With No Action Saved
    [Documentation]    Complete Tabs 1-3, advance to Tab 4, click Submit without selecting
    ...                any Action Type or saving an action. Wizard must stay on Tab 4.
    [Tags]    regression    negative    rule-engine
    TC_RE_018

TC_RE_019 NEG10 Save Email Action Without Recipients
    [Documentation]    On Tab 4, select Email action type, click Save Action without adding
    ...                any email recipients. Validation error should appear.
    [Tags]    regression    negative    rule-engine
    TC_RE_019

TC_RE_020 NEG11 Invalid Email In Raise Alert To Field
    [Documentation]    On Tab 4, select Raise Alert action, type an invalid email address
    ...                in the ReactTags input, press Enter. Email tag should not be added
    ...                or validation error should appear.
    [Tags]    regression    negative    rule-engine
    TC_RE_020

TC_RE_021 NEG12 Close Wizard Mid Way
    [Documentation]    Navigate to Create Rule, fill Tab 1, click Close button.
    ...                No rule should be created; browser redirects to /RuleEngine listing.
    [Tags]    regression    negative    rule-engine
    TC_RE_021

TC_RE_022 NEG13 Rule Name Exceeds 50 Characters
    [Documentation]    Enter a 51-character string in Rule Name. The field should cap
    ...                at 50 characters (maxLength attribute) or Joi validation should fire.
    [Tags]    regression    negative    rule-engine
    TC_RE_022

TC_RE_023 NEG14 Device Plan Disabled When All DP Checked
    [Documentation]    On Tab 1, select Customer so Device Plan populates, then check the
    ...                "All Device Plan" checkbox. Device Plan dropdown must become disabled.
    [Tags]    regression    negative    rule-engine
    TC_RE_023

*** Keywords ***
TC_RE_001
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Validate Tab 1 Fields Visible
    Validate Previous Button Not Visible On Tab 1
    Fill Primary Details Tab
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    ${RE_RULE_NAME}
    Delete Rule From Listing By Name    ${RE_RULE_NAME}    skip_navigation=${TRUE}

TC_RE_002
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=SL_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    SL_Trg2_${RE_SUFFIX}
    Delete Rule From Listing By Name    SL_Trg2_${RE_SUFFIX}    skip_navigation=${TRUE}

TC_RE_003
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=SL_Trg3_${RE_SUFFIX}    category=${RE_CATEGORY}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=3
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    SL_Trg3_${RE_SUFFIX}
    Delete Rule From Listing By Name    SL_Trg3_${RE_SUFFIX}    skip_navigation=${TRUE}

TC_RE_004
    Create Rule End To End
    ...    rule_name=FP_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_FRAUD}
    ...    rule_category_index=1

TC_RE_005
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=FP_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_FRAUD}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    FP_Trg2_${RE_SUFFIX}
    Delete Rule From Listing By Name    FP_Trg2_${RE_SUFFIX}    skip_navigation=${TRUE}

TC_RE_006
    Create Rule End To End
    ...    rule_name=CC_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_COST}
    ...    rule_category_index=1

TC_RE_007
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=CC_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_COST}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    CC_Trg2_${RE_SUFFIX}
    Delete Rule From Listing By Name    CC_Trg2_${RE_SUFFIX}    skip_navigation=${TRUE}

TC_RE_008
    Create Rule End To End
    ...    rule_name=OT_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_OTHER}
    ...    rule_category_index=1

TC_RE_009
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=OT_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_OTHER}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    OT_Trg2_${RE_SUFFIX}
    Delete Rule From Listing By Name    OT_Trg2_${RE_SUFFIX}    skip_navigation=${TRUE}


TC_RE_010
    Navigate To Create Rule Page
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_011
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_012
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_013
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Sleep    1s
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_014
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    1
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan'); return el ? el.checked : false;
    IF    ${all_dp_checked}
        Execute Javascript    var el = document.getElementById('all_Device_Plan'); if (el) { el.click(); }
        Sleep    1s
    END
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_015
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 2
    Click Next Tab
    Validate Wizard Stays On Tab 2

TC_RE_016
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 2
    Wait For Loading Overlay To Disappear
    ${is_native}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=5s
    IF    ${is_native}
        Select From List By Index    ${LOC_RE_RULE_CATEGORY_SELECT}    1
    ELSE
        Select Rule Category Custom By Index    1
    END
    Sleep    1s
    Click Next Tab
    Validate Wizard Stays On Tab 2

TC_RE_017
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 3
    Click Next Tab
    Validate Wizard Stays On Tab 3

TC_RE_018
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Submit Rule
    Validate Wizard Stays On Tab 4

TC_RE_019
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s
    Select From List By Label    ${LOC_RE_ACTION_TYPE}    Email
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_RE_SAVE_ACTION_BTN}    timeout=10s
    Click Element    ${LOC_RE_SAVE_ACTION_BTN}
    Sleep    1s
    ${action_panel_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_ACTION_LIST_PANEL}
    Should Not Be True    ${action_panel_visible}
    ...    Email action should NOT be saved without recipients.

TC_RE_020
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s
    Select From List By Label    ${LOC_RE_ACTION_TYPE}    ${RE_ACTION_RAISE_ALERT}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=10s
    Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${RE_INVALID_EMAIL}
    Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
    Sleep    1s
    ${tag_exists}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_ALERT_EMAIL_TAG}
    IF    ${tag_exists}
        Log    Tag was added — checking for error toast or inline error.    level=WARN
    END
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TOAST_ERROR}    timeout=5s
    ${either_blocked}=    Evaluate    not ${tag_exists} or ${error_visible}
    Should Be True    ${either_blocked}
    ...    Invalid email should be blocked (no tag) or show an error toast.

TC_RE_021
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Close Wizard
    Validate Redirected To Rule Engine Listing

TC_RE_022
    Navigate To Create Rule Page
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=10s
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_LONG_RULE_NAME}
    ${actual_value}=    Get Element Attribute    ${LOC_RE_RULE_NAME}    value
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} <= ${RE_RULE_NAME_MAX_LENGTH}
    ...    Rule Name field accepted ${length} chars — must be capped at ${RE_RULE_NAME_MAX_LENGTH}.
    Log    Rule Name capped at ${length} characters (max ${RE_RULE_NAME_MAX_LENGTH}).    console=yes

TC_RE_023
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    1
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan'); return el ? el.checked : false;
    IF    ${all_dp_checked}
        Execute Javascript    var el = document.getElementById('all_Device_Plan'); if (el) { el.click(); }
        Sleep    1s
    END
    Wait Until Element Is Enabled    ${LOC_RE_DEVICE_PLAN}    timeout=20s
    Execute Javascript    var el = document.getElementById('all_Device_Plan'); if (el && !el.checked) { el.click(); }
    Sleep    1s
    Validate Device Plan Disabled
    Execute Javascript    var el = document.getElementById('all_Device_Plan'); if (el && el.checked) { el.click(); }
    Sleep    1s
    Element Should Be Enabled    ${LOC_RE_DEVICE_PLAN}
    Log    Device Plan correctly disabled when All DP checked, re-enabled when unchecked.    console=yes
