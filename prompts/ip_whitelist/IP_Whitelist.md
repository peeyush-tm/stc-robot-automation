# IP Whitelisting Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `IP_Whitelist` |
| **Suite File** | `tests/ip_whitelist_tests.robot` |
| **Variables File** | `variables/ip_whitelist_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/manageIPWhitelisting` (list), `<BASE_URL>/CreateIPWhitelisting` (create) |
| **Total TCs** | 20 |
| **Tags** | `ip_whitelist`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite IP_Whitelist
python run_tests.py tests/ip_whitelist_tests.robot
python run_tests.py --suite IP_Whitelist --include smoke
python run_tests.py --suite IP_Whitelist --include ip_whitelist
python run_tests.py --suite IP_Whitelist --test "TC_WL_001*"
```

## Module Description

The **IP Whitelisting** module allows administrators to create IP whitelisting policies for customer Business Units (BU). A policy is created by selecting a Customer and BU, then adding one or more firewall rules via a popup dialog (Protocol, Port Type, Destination IP). The policy is only saved after at least one rule is added.

**Navigation:** Login → Service sidebar → IP Whitelisting tab → Create button → `/CreateIPWhitelisting`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_WL_001 | E2E Create IP Whitelisting Policy TCP Any Port | Positive | smoke, regression, ip_whitelist |
| TC_WL_002 | Verify IP Whitelisting Listing Page Loads | Positive | smoke, regression, ip_whitelist |
| TC_WL_003 | Verify Create IP Whitelisting Form Elements Visible | Positive | smoke, regression, ip_whitelist |
| TC_WL_004 | Verify BU Dropdown Populates After Customer Selection | Positive | regression, ip_whitelist |
| TC_WL_005 | Verify Rule Dialog Opens After Customer And BU Selected | Positive | regression, ip_whitelist |
| TC_WL_006 | Verify Rule Appears In Grid After Submitting | Positive | regression, ip_whitelist |
| TC_WL_007 | Verify Create Button Enabled After Adding Rule | Positive | regression, ip_whitelist |
| TC_WL_008 | Create Policy With EnterPort And Specific Port Value | Positive | regression, ip_whitelist |
| TC_WL_009 | Verify Cancel Button Redirects To Listing | Positive | regression, ip_whitelist, navigation |
| TC_WL_010 | Add Rule Without Customer Should Not Open Dialog | Negative | regression, ip_whitelist |
| TC_WL_011 | Add Rule Without BU Should Not Open Dialog | Negative | regression, ip_whitelist |
| TC_WL_012 | Create Button Disabled With No Rules | Negative | regression, ip_whitelist |
| TC_WL_013 | Submit Rule With No Fields Should Show Error | Negative | regression, ip_whitelist |
| TC_WL_014 | Submit Rule Without Destination Should Show Error | Negative | regression, ip_whitelist |
| TC_WL_015 | Submit Rule With Invalid Destination Address | Negative | regression, ip_whitelist |
| TC_WL_016 | Port Value Exceeding 65535 Should Show Error | Negative | regression, ip_whitelist, boundary |
| TC_WL_017 | Close Rule Dialog Without Submitting | Negative | regression, ip_whitelist |
| TC_WL_018 | Close Create Page Before Submitting | Negative | regression, ip_whitelist, navigation |
| TC_WL_019 | Direct Access To Create IP Whitelisting Without Login | Negative | regression, security, ip_whitelist, navigation |
| TC_WL_020 | Direct Access To IP Whitelisting List Without Login | Negative | regression, security, ip_whitelist, navigation |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_WL_001** — Select Customer, select BU, click Add Rule, in rule dialog: Protocol=TCP, Port Type=Any, enter Destination IP, submit rule. Rule appears in grid. Click Create to save the policy.

### Positive — UI Verification (8 TCs)
- **TC_WL_002** — IP Whitelisting listing page loads with grid.
- **TC_WL_003** — Create form shows Customer, BU, Add Rule button, and grid area.
- **TC_WL_004** — BU dropdown is empty until Customer is selected; then it populates.
- **TC_WL_005** — Add Rule button opens the rule dialog only when both Customer and BU are selected.
- **TC_WL_006** — After submitting a rule, it appears as a row in the rules grid.
- **TC_WL_007** — Create button is disabled until at least one rule is added; enabled after.
- **TC_WL_008** — Create policy with Port Type=EnterPort and a specific port number (e.g. 8080).
- **TC_WL_009** — Cancel button returns to listing without saving.

### Negative — Dialog Prerequisites Not Met (2 TCs)
- **TC_WL_010** — Clicking Add Rule before Customer is selected does not open the dialog.
- **TC_WL_011** — Clicking Add Rule before BU is selected does not open the dialog.

### Negative — Policy / Rule Validation (6 TCs)
- **TC_WL_012** — No rules added → Create button remains disabled.
- **TC_WL_013** — Submit rule dialog with no fields → all field errors shown.
- **TC_WL_014** — Submit rule without Destination IP → error.
- **TC_WL_015** — Submit rule with invalid IP format → error.
- **TC_WL_016** — Port value > 65535 → error (TCP port boundary).
- **TC_WL_017** — Closing the rule dialog without submitting does not add a rule.

### Negative — Navigation (1 TC)
- **TC_WL_018** — Close the Create page before submitting policy → returns to listing, no save.

### Negative — Auth / Navigation (2 TCs)
- **TC_WL_019** — Direct `/CreateIPWhitelisting` without session → login redirect.
- **TC_WL_020** — Direct `/manageIPWhitelisting` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/ip_whitelist_tests.robot` | Test suite |
| `resources/keywords/ip_whitelist_keywords.resource` | Policy and rule dialog keywords |
| `resources/locators/ip_whitelist_locators.resource` | XPath locators |
| `variables/ip_whitelist_variables.py` | Customer, BU names, IP addresses, port values |
| `prompts/ip_whitelist/TC_010_Create_IP_Whitelisting_RF.md` | Detailed specification |

## Automation Notes

- BU dropdown is **dependent** on Customer selection — keyword waits for options to appear.
- Rule dialog is a modal; keyword waits for it to appear/disappear before continuing.
- Valid TCP port range is 0–65535; the application validates on submit.
- Destination IP must match the IPv4 or CIDR format expected by the API.
