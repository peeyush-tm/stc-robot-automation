# Cost Center Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Cost_Center` |
| **Suite File** | `tests/cost_center_tests.robot` |
| **Variables File** | `variables/cost_center_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageAccount` (list, expand BU → Cost Center tab) |
| **Total TCs** | 26 |
| **Tags** | `cost-center`, `navigation`, `form`, `ui`, `dropdown`, `validation`, `duplicate`, `boundary`, `sanitization`, `cancel`, `listing`, `tab`, `grid`, `permission`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite Cost_Center
python run_tests.py tests/cost_center_tests.robot
python run_tests.py --suite Cost_Center --include smoke
python run_tests.py --suite Cost_Center --include cost-center
python run_tests.py --suite Cost_Center --test "TC_CC_007*"
```

## Module Description

The **Cost Center** module manages sub-accounts under a Billing Account. Cost Centers are created from the Manage Account page by expanding a Billing Account node and navigating to the Cost Center tab. The form requires an Account Name and a Parent Account selection (TreeView).

**Navigation:** Login → Admin sidebar → Manage Account → expand Billing Account row → Cost Center tab → Create Cost Center button → form panel

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_CC_001 | Navigate To ManageAccount Page | Positive | smoke, cost-center, navigation |
| TC_CC_002 | Verify Create Cost Center Button Visible | Positive | smoke, cost-center, permission |
| TC_CC_003 | Open Create Cost Center Form | Positive | smoke, cost-center, form |
| TC_CC_004 | Verify All Form Fields Present | Positive | cost-center, form, ui |
| TC_CC_005 | Verify Parent Account TreeView Has Nodes | Positive | cost-center, form, dropdown |
| TC_CC_006 | Verify Submit Button Is Present And Enabled | Positive | cost-center, form, ui |
| TC_CC_007 | Create Cost Center With All Fields | Positive | smoke, regression, cost-center, e2e |
| TC_CC_008 | Create Cost Center Without Comment | Positive | regression, cost-center, e2e |
| TC_CC_009 | Verify No Validation Errors With Valid Data | Positive | cost-center, validation |
| TC_CC_010 | Submit With Empty Account Name | Negative | cost-center, validation |
| TC_CC_011 | Submit Without Selecting Parent Account | Negative | cost-center, validation |
| TC_CC_012 | Submit With Both Mandatory Fields Empty | Negative | cost-center, validation |
| TC_CC_013 | Submit With Only Spaces In Account Name | Negative | cost-center, validation, edge |
| TC_CC_014 | Duplicate Cost Center Name | Negative | cost-center, validation, duplicate |
| TC_CC_015 | Account Name Exceeds 100 Characters | Negative | cost-center, boundary |
| TC_CC_016 | Account Name Exactly 100 Characters | Positive | cost-center, boundary, edge |
| TC_CC_017 | Comment Exceeds 50 Characters | Negative | cost-center, boundary |
| TC_CC_018 | Comment Exactly 50 Characters | Positive | cost-center, boundary, edge |
| TC_CC_020 | Account Name With Semicolons Stripped | Negative | cost-center, sanitization, edge |
| TC_CC_021 | Close Form Without Submitting | Negative | cost-center, cancel |
| TC_CC_022 | Close Empty Form | Negative | cost-center, cancel, edge |
| TC_CC_023 | Close After Selecting Only Parent Account | Negative | cost-center, cancel, edge |
| TC_CC_024 | Expand Billing Account And Verify Cost Center Tab | Positive | cost-center, listing, tab |
| TC_CC_025 | Open Cost Center Tab And Verify Grid Loads | Positive | cost-center, listing, grid |
| TC_CC_026 | Verify Edit Delete Buttons In Cost Center Grid | Positive | cost-center, listing, permission |

## Test Case Categories

### Positive — Navigation & Page Access (5 TCs)
- **TC_CC_001** — Navigate to Manage Account page via sidebar; page loads.
- **TC_CC_002** — Create Cost Center button is visible (confirms role has create permission).
- **TC_CC_003** — Clicking Create Cost Center opens the form panel.
- **TC_CC_024** — Expand a Billing Account row; Cost Center tab appears.
- **TC_CC_025** — Click Cost Center tab; grid loads with existing cost centers.
- **TC_CC_026** — Grid rows show Edit and Delete action icons.

### Positive — Form Validation (4 TCs)
- **TC_CC_004** — Form shows Account Name, Parent Account TreeView, and Comment fields.
- **TC_CC_005** — Parent Account TreeView has at least one node (Billing Account visible).
- **TC_CC_006** — Submit button is present and enabled by default.
- **TC_CC_009** — Filling all valid fields shows no validation errors on submit.

### Positive — Happy Path (2 TCs)
- **TC_CC_007** — Create with Account Name + Parent Account + Comment. Verifies success toast and cost center appears in grid.
- **TC_CC_008** — Create without Comment (Comment is optional). Verifies success.

### Positive — Boundary (2 TCs)
- **TC_CC_016** — Account Name exactly 100 characters → accepted.
- **TC_CC_018** — Comment exactly 50 characters → accepted.

### Negative — Mandatory Validation (4 TCs)
- **TC_CC_010** — Empty Account Name → validation error.
- **TC_CC_011** — Parent Account not selected → validation error.
- **TC_CC_012** — Both Account Name and Parent Account empty → both errors shown.
- **TC_CC_013** — Account Name with only spaces → treated as empty, validation error.

### Negative — Business Rules (2 TCs)
- **TC_CC_014** — Duplicate Cost Center name under same account → conflict error.
- **TC_CC_020** — Semicolons in Account Name are stripped/rejected (input sanitization).

### Negative — Boundary (2 TCs)
- **TC_CC_015** — Account Name > 100 characters → validation error.
- **TC_CC_017** — Comment > 50 characters → validation error.

### Negative — Cancel / Close (3 TCs)
- **TC_CC_021** — Close the form after filling data → form closes without saving.
- **TC_CC_022** — Close an empty form → form closes, no error.
- **TC_CC_023** — Close after selecting only Parent Account → no save.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/cost_center_tests.robot` | Test suite |
| `resources/keywords/cost_center_keywords.resource` | Cost Center form and grid keywords |
| `resources/locators/cost_center_locators.resource` | XPath locators |
| `variables/cost_center_variables.py` | Account names (random), comment values, max-length strings |
| `prompts/cost_center/TC_013_Create_Cost_Center_RF.md` | Detailed specification |

## Automation Notes

- The Parent Account field uses a **Kendo TreeView** component — keyword clicks the dropdown trigger, waits for nodes, then clicks the desired node.
- Account Name is randomly generated per run to avoid duplicate conflicts.
- The `Manage Account` page requires expanding Billing Account rows (accordion pattern) to reveal sub-tabs.
- Boundary string generation (100 chars, 50 chars) uses Python `'A' * N` expressions in variables.
