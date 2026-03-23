# Rule Engine Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Rule_Engine` |
| **Suite File** | `tests/rule_engine_tests.robot` |
| **Variables File** | `variables/rule_engine_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/RuleEngine` (list), `<BASE_URL>/CreateRule` (wizard) |
| **Total TCs** | 28 |
| **Tags** | `rule-engine`, `sim-lifecycle`, `fraud-prevention`, `cost-control`, `others`, `all-triggers`, `category-action-combo`, `boundary`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite Rule_Engine
python run_tests.py tests/rule_engine_tests.robot
python run_tests.py --suite Rule_Engine --include smoke
python run_tests.py --suite Rule_Engine --include rule-engine
python run_tests.py --suite Rule_Engine --include sim-lifecycle
python run_tests.py --suite Rule_Engine --test "TC_RE_001*"
```

## Module Description

The **Rule Engine** module allows administrators to create automated rules that respond to SIM and network events. Rules are created through a 4-tab wizard:

1. **Tab 1 — Rule Info:** Rule Name, Category, App Level, Customer, Device Plan
2. **Tab 2 — Define Triggers:** Rule Category options (SIM Lifecycle, Fraud Prevention, Cost Control, Others), trigger conditions
3. **Tab 3 — Aggregation:** Aggregation Level setting
4. **Tab 4 — Define Actions:** Action type (e.g. Raise Alert, Send Email), action details

**Navigation:** Login → Admin sidebar → Rule Engine → Create Rule → `/CreateRule`

## Rule Categories & Triggers

| Category | Trigger Options |
|----------|----------------|
| SIM Lifecycle | Option 1 (State change), Option 2, Option 3 |
| Fraud Prevention | Option 1 (Usage threshold), Option 2 |
| Cost Control | Option 1 (Cost threshold), Option 2 |
| Others | Option 1 (Custom event), Option 2 |

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_RE_001 | Create Rule With SIM Lifecycle And Raise Alert Action | Positive | smoke, regression, rule-engine, sim-lifecycle |
| TC_RE_002 | Create Rule With SIM Lifecycle Trigger Option 2 | Positive | regression, rule-engine, sim-lifecycle, trigger-2 |
| TC_RE_003 | Create Rule With SIM Lifecycle Trigger Option 3 | Positive | regression, rule-engine, sim-lifecycle, trigger-3 |
| TC_RE_004 | Create Rule With Fraud Prevention Trigger Option 1 | Positive | regression, rule-engine, fraud-prevention, trigger-1 |
| TC_RE_005 | Create Rule With Fraud Prevention Trigger Option 2 | Positive | regression, rule-engine, fraud-prevention, trigger-2 |
| TC_RE_006 | Create Rule With Cost Control Trigger Option 1 | Positive | regression, rule-engine, cost-control, trigger-1 |
| TC_RE_007 | Create Rule With Cost Control Trigger Option 2 | Positive | regression, rule-engine, cost-control, trigger-2 |
| TC_RE_008 | Create Rule With Others Category Trigger Option 1 | Positive | regression, rule-engine, others, trigger-1 |
| TC_RE_009 | Create Rule With Others Category Trigger Option 2 | Positive | regression, rule-engine, others, trigger-2 |
| TC_RE_009A | Create Rules For All SIM Lifecycle Rule Category Options | Positive | regression, rule-engine, sim-lifecycle, all-triggers |
| TC_RE_009B | Create Rules For All Fraud Prevention Rule Category Options | Positive | regression, rule-engine, fraud-prevention, all-triggers |
| TC_RE_009C | Create Rules For All Cost Control Rule Category Options | Positive | regression, rule-engine, cost-control, all-triggers |
| TC_RE_009D | Create Rules For All Others Rule Category Options | Positive | regression, rule-engine, others, all-triggers |
| TC_RE_009E | Create Rules For All Category And Action Combinations | Positive | regression, rule-engine, category-action-combo |
| TC_RE_010 | NEG01 Next On Tab1 With Rule Name Blank | Negative | regression, rule-engine |
| TC_RE_011 | NEG02 Next On Tab1 With Category Not Selected | Negative | regression, rule-engine |
| TC_RE_012 | NEG03 Next On Tab1 With App Level Not Selected | Negative | regression, rule-engine |
| TC_RE_013 | NEG04 Next On Tab1 With Customer Not Selected | Negative | regression, rule-engine |
| TC_RE_014 | NEG05 Next On Tab1 With Device Plan Not Selected | Negative | regression, rule-engine |
| TC_RE_015 | NEG06 Next On Tab2 With No Rule Category Selected | Negative | regression, rule-engine |
| TC_RE_016 | NEG07 Next On Tab2 With No Trigger Saved | Negative | regression, rule-engine |
| TC_RE_017 | NEG08 Next On Tab3 With No Aggregation Level | Negative | regression, rule-engine |
| TC_RE_018 | NEG09 Submit On Tab4 With No Action Saved | Negative | regression, rule-engine |
| TC_RE_019 | NEG10 Save Email Action Without Recipients | Negative | regression, rule-engine |
| TC_RE_020 | NEG11 Invalid Email In Raise Alert To Field | Negative | regression, rule-engine |
| TC_RE_021 | NEG12 Close Wizard Mid Way | Negative | regression, rule-engine |
| TC_RE_022 | NEG13 Rule Name Exceeds 50 Characters | Negative | regression, rule-engine |
| TC_RE_023 | NEG14 Device Plan Disabled When All DP Checked | Negative | regression, rule-engine |

## Test Case Categories

### Positive — Single Trigger Happy Path (9 TCs)
- **TC_RE_001** — SIM Lifecycle + Trigger Option 1 + Raise Alert action. Full 4-tab wizard.
- **TC_RE_002–003** — SIM Lifecycle Trigger Options 2 and 3.
- **TC_RE_004–005** — Fraud Prevention Trigger Options 1 and 2.
- **TC_RE_006–007** — Cost Control Trigger Options 1 and 2.
- **TC_RE_008–009** — Others Trigger Options 1 and 2.

### Positive — All Triggers Sweep (5 TCs)
- **TC_RE_009A** — Iterates through all SIM Lifecycle trigger options in a single test.
- **TC_RE_009B** — All Fraud Prevention trigger options.
- **TC_RE_009C** — All Cost Control trigger options.
- **TC_RE_009D** — All Others trigger options.
- **TC_RE_009E** — Matrix of all Category × Action combinations.

### Negative — Tab 1 Validation (5 TCs)
- **TC_RE_010** — Rule Name blank → Next blocked.
- **TC_RE_011** — Category not selected → Next blocked.
- **TC_RE_012** — App Level not selected → Next blocked.
- **TC_RE_013** — Customer not selected → Next blocked.
- **TC_RE_014** — Device Plan not selected → Next blocked.

### Negative — Tab 2 Validation (2 TCs)
- **TC_RE_015** — No Rule Category selected on Tab 2 → Next blocked.
- **TC_RE_016** — No Trigger saved (dialog opened but not confirmed) → Next blocked.

### Negative — Tab 3 Validation (1 TC)
- **TC_RE_017** — No Aggregation Level set → Next blocked.

### Negative — Tab 4 Validation (3 TCs)
- **TC_RE_018** — No Action saved → Submit blocked.
- **TC_RE_019** — Email action dialog open without recipients → Save blocked.
- **TC_RE_020** — Invalid email format in Raise Alert recipient field → error.

### Negative — Wizard UX (3 TCs)
- **TC_RE_021** — Close wizard mid-way (Tab 2 or 3) → redirected to listing without saving.
- **TC_RE_022** — Rule Name > 50 characters → validation error (boundary).
- **TC_RE_023** — "All Device Plans" checkbox checked → individual Device Plan dropdown becomes disabled.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/rule_engine_tests.robot` | Test suite |
| `resources/keywords/rule_engine_keywords.resource` | Wizard tab keywords, trigger dialog keywords |
| `resources/locators/rule_engine_locators.resource` | XPath locators (4-tab wizard) |
| `variables/rule_engine_variables.py` | Rule names, trigger configs, email recipients |

## Automation Notes

- Rule wizard has 4 tabs; keywords track active tab index to target correct elements.
- Trigger configuration opens a sub-dialog inside Tab 2 — keywords wait for the dialog, fill it, and confirm.
- Action configuration in Tab 4 opens another sub-dialog (Raise Alert / Send Email).
- `All Device Plans` checkbox and Device Plan dropdown have an exclusivity constraint handled by the UI.
- Rule Names are randomly generated per run to avoid duplicates.
- TC_RE_009E is a data-driven-style test iterating over a matrix of category/action combinations.
