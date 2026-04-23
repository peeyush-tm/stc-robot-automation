# E2E Flow With Usage — Test Case Generation Prompt

> **Purpose:** Paste this file into any LLM (Claude, ChatGPT, etc.) or hand it to a human tester to generate **one or many** parallel variants of the E2E Flow With Usage suite — e.g. a matrix of Yearly / Half-Yearly / Quarterly / Monthly plan scenarios.
>
> **How to use:** Edit Part 1 (variation axis), fill Part 2 (one row per scenario), adjust Part 3 (fixed overrides shared by all scenarios). Parts 4–8 stay the same across fills.
>
> **Output:** For every row in Part 2 the generator produces one Robot Framework test case block + any scenario-specific keyword — ready to drop into `tests/e2e_flow_with_usage.robot` (or a new scenario variant file).

---

## Part 1 — Variation Axis

**Fill this section first.** It tells the generator how much to repeat.

```
BASELINE_SUITE:       tests/e2e_flow_with_usage.robot   (22 steps, do not modify)
VARIATION_AXES:       <<what differs across scenarios — e.g. "Bundle plan (yearly / halfyearly / quarterly / monthly)">>
NUMBER_OF_SCENARIOS:  <<integer — how many rows Part 2 has>>
TOTAL_DURATION_EACH:  <<approx runtime per scenario, e.g. "~1.0 hr" (fewer SIMs than baseline)>>
ENVIRONMENT:          <<qe | dev | staging | prod>>
```

---

## Part 2 — Scenario Matrix

**One row per scenario.** Adding a 5th scenario = adding a row (no other edits needed). Edit only the placeholder cells.

> Plan names are referenced by **config key** (resolved at runtime from `config/<env>.json`), not hardcoded. This keeps the prompt stable when plan names change and lets each environment seed its own values.

| # | SCENARIO_NAME | SCENARIO_ID | Tariff Config Key | Bundle Config Key | Notes |
|---|---|---|---|---|---|
| 1 | <<scenario 1 name>> | <<TC_E2EU_X>> | <<config key>> | <<config key>> | <<optional>> |
| 2 | <<scenario 2 name>> | <<TC_E2EU_Y>> | <<config key>> | <<config key>> | <<optional>> |
| 3 | <<scenario 3 name>> | <<TC_E2EU_Z>> | <<config key>> | <<config key>> | <<optional>> |
| … | | | | | |

### Required `config/<env>.json` entries

For every config key used above, add one entry to the env config. Example:

```json
{
  "<<CONFIG_KEY_NAME>>": "<<actual plan name in QE>>",
  ...
}
```

---

## Part 3 — Fixed Overrides (apply to ALL rows in Part 2)

These are the overrides that are **the same for every scenario**. Edit once, here. Leave any row as `USE BASELINE` to skip that override.

| # | Step | Fixed Override | Applies To |
|---|---|---|---|
| 1 | Step 1 · Onboard EC + BU (API) | USE BASELINE | ALL |
| 2 | Step 1b · Verify Account on UI | USE BASELINE | ALL |
| 3 | Step 2 · Create APN | <<e.g. Private Dynamic APN — random ID/name>> | ALL |
| 4 | Step 3 · Create CSR Journey | Use Tariff + Bundle from **Part 2** row config keys | ALL |
| 5 | Step 4 · Create SIM Range | <<e.g. 2 ICCID/IMSI on KSA_OPCO>> | ALL |
| 6 | Step 5 · Product Type | USE BASELINE | ALL |
| 7 | Step 5b · Expand EC/BU SIM limits | <<+2 to EC Max IMSI and BU Max SIM>> | ALL |
| 8 | Step 6 · SIM Order | <<Quantity = 2>> | ALL |
| 9 | Step 7 · Capture Order ID | USE BASELINE | ALL |
| 10 | Step 8 · Fetch EC/BU IDs from DB | USE BASELINE | ALL |
| 11 | Step 9 · Create Order SSH script | USE BASELINE | ALL |
| 12 | Step 10 · Validate New → In Progress | USE BASELINE | ALL |
| 13 | Step 11 · Generate + Upload Response | USE BASELINE | ALL |
| 14 | Step 12 · Read Order SSH script | USE BASELINE | ALL |
| 15 | Step 13 · Validate In Progress → Completed | USE BASELINE | ALL |
| 16 | Step 14 · Validate SIMs Warm | <<Verify 2 SIMs in Warm state>> | ALL |
| 17 | Step 15 · Approve Order via SOAP | USE BASELINE | ALL |
| 18 | Step 16 · Activate SIMs | <<Activate 2 of 2 SIMs>> | ALL |
| 19 | Step 16a · Inject Usage per IMSI | <<Inject 5 MB on 1 of 2 IMSIs>> | ALL |
| 20 | Step 16b · Validate Usage UI | <<1 IMSI with data usage > 0; the other with 0>> | ALL |
| 21 | Step 17 · Generate Invoice | USE BASELINE | ALL |
| 22 | Step 18 · Second CSR Journey | **SKIP** | ALL |
| 23 | Step 19 · Device Plan Change | **SKIP** | ALL |

### Scenario-specific overrides (optional)

If a single scenario needs to deviate from a fixed override above, add a row here:

| Scenario # (from Part 2) | Step | Scenario-specific override |
|---|---|---|
| — | — | — |

---

## Part 4 — Per-Step Reference (read-only)

Compact index so the reader/generator can locate each step quickly. All 22 steps are grouped into 6 phases.

| Step | Phase | Baseline Keyword | Fixed in Part 3? | Varies in Part 2? |
|---|---|---|---|---|
| 1 | 1 · Onboarding | `E2E Onboard EC BU Via API` | ✓ | — |
| 1b | 1 · Onboarding | `E2E Verify Account On UI` | ✓ | — |
| 2 | 1 · Onboarding | `E2E Create APN` | ✓ (APN type) | — |
| 3 | 1 · Onboarding | `E2E Create CSR Journey` | ✓ (uses config keys) | ✓ (Tariff+Bundle) |
| 4 | 2 · SIM Setup | `E2E Create SIM Range` | ✓ (qty) | — |
| 5 | 2 · SIM Setup | `E2E Create Product Type And Assign EC` | ✓ | — |
| 5b | 2 · SIM Setup | `E2E Expand EC And BU SIM Limits` | ✓ (delta) | — |
| 6 | 3 · SIM Order | `E2E Create SIM Order` | ✓ (qty) | — |
| 7–10 | 3 · SIM Order | grid / DB / SSH / grid | ✓ | — |
| 11–14 | 4 · Response Proc. | response files / SSH / grid / grid | ✓ (count) | — |
| 15 | 5 · Activation | `E2E Approve Order Via SOAP API` | ✓ | — |
| 16 | 5 · Activation | `E2E Activate SIMs And Capture IMSIs` | ✓ (count) | — |
| 16a | 5 · Activation | `E2E Perform Usage For All Activated IMSIs` | ✓ (1 of N at X MB) | — |
| 16b | 5 · Activation | `E2E Validate Usage In UI` | ✓ | — |
| 17 | 6 · Invoice+Post | `E2E Generate Invoice And Download CSV` | ✓ | — |
| 18 | 6 · Invoice+Post | `E2E Create Second CSR Journey` | ✓ (SKIP) | — |
| 19 | 6 · Invoice+Post | `E2E Perform Device Plan Change` | ✓ (SKIP) | — |

Full per-step detail: [documentation/E2E_FLOW_WITH_USAGE_GUIDE.md](../../documentation/E2E_FLOW_WITH_USAGE_GUIDE.md).

---

## Part 5 — Worked Example: Plan-Duration Matrix (4 scenarios)

> Concrete canonical fill. Use this as a reference when wiring similar scenarios.

### Part 1 values
```
BASELINE_SUITE:       tests/e2e_flow_with_usage.robot
VARIATION_AXES:       Bundle plan duration (Yearly / Half-Yearly / Quarterly / Monthly)
NUMBER_OF_SCENARIOS:  4
TOTAL_DURATION_EACH:  ~1.0 hr (2 SIMs, skip Step 18 + 19)
ENVIRONMENT:          qe
```

### Part 2 — Scenario Matrix

| # | SCENARIO_NAME | SCENARIO_ID | Tariff Config Key | Bundle Config Key | Notes |
|---|---|---|---|---|---|
| 1 | E2E With Usage — Yearly Plan | TC_E2EU_YEARLY | CSR_TARIFF_PLAN_UNLIMITED_PAYG | CSR_BUNDLE_PLAN_YEARLY | RPP-style |
| 2 | E2E With Usage — Half-Yearly Plan | TC_E2EU_HALFYEARLY | CSR_TARIFF_PLAN_UNLIMITED_PAYG | CSR_BUNDLE_PLAN_HALFYEARLY | — |
| 3 | E2E With Usage — Quarterly Plan | TC_E2EU_QUARTERLY | CSR_TARIFF_PLAN_UNLIMITED_PAYG | CSR_BUNDLE_PLAN_QUARTERLY | — |
| 4 | E2E With Usage — Monthly Plan | TC_E2EU_MONTHLY | CSR_TARIFF_PLAN_UNLIMITED_PAYG | CSR_BUNDLE_PLAN_MONTHLY | — |

### Required `config/qe.json` entries

```json
{
  "CSR_TARIFF_PLAN_UNLIMITED_PAYG": "TP1-QRA-070425_UNLIMITEDPAYG_1",
  "CSR_BUNDLE_PLAN_YEARLY":         "RPP-QRA-070425_1",
  "CSR_BUNDLE_PLAN_HALFYEARLY":     "HALFYRLY-SIMPLAN-QRA-070425_1",
  "CSR_BUNDLE_PLAN_QUARTERLY":      "QUARTERLY-SIMPLAN-QRA-070425_1",
  "CSR_BUNDLE_PLAN_MONTHLY":        "SIMPLAN-QRA-070425_1"
}
```

### Part 3 — Fixed Overrides (applied to all 4 scenarios above)

- **Step 2 · APN:** Private **Dynamic** APN, random ID/name (not Private static)
- **Step 4 · SIM Range:** 2 ICCID/IMSI/MSISDN on KSA_OPCO
- **Step 5b · Expand limits:** +2 to both EC Max IMSI and BU Max SIM
- **Step 6 · SIM Order:** Quantity = 2
- **Step 14 · Validate Warm:** 2 SIMs in Warm state
- **Step 16 · Activate:** 2 of 2 SIMs
- **Step 16a · Usage:** 5 MB on **1** IMSI; the **other IMSI receives no usage**
- **Step 16b · Validate Usage UI:** 1 IMSI shows > 0 MB; the other shows 0 MB
- **Step 17 · Invoice:** Generate and download (baseline)
- **Step 18 · Second CSR Journey:** **SKIP** for all scenarios
- **Step 19 · Device Plan Change:** **SKIP** for all scenarios

### Expected output

For each of the 4 scenarios above, the generator produces a Robot test case block in `tests/e2e_flow_with_usage.robot`:

```robot
# Scenario 1 — Yearly
TC_E2EU_YEARLY E2E With Usage Yearly Plan
    [Documentation]    Full E2E with Yearly Bundle (${CSR_BUNDLE_PLAN_YEARLY}) — 2 SIMs, usage on 1.
    [Tags]    e2e    e2e-with-usage    yearly    regression
    # ... steps 1 → 17 using overridden tariff/bundle/APN/qty
```

Run commands (one per scenario):

```bash
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "TC_E2EU_YEARLY*"
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "TC_E2EU_HALFYEARLY*"
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "TC_E2EU_QUARTERLY*"
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "TC_E2EU_MONTHLY*"
```

Or all four at once:
```bash
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "TC_E2EU_*"
```

---

## Part 6 — Known Implementation Gaps (must be fixed before scenarios can actually run)

These are capabilities the baseline framework does **not** support yet. Fill this prompt freely, but know that running the generated tests requires these to land first. Each gap lists: what's missing, suggested fix, and the file to edit.

### Gap 1 — Tariff / Bundle name parametrisation (Step 3)

**Current:** `E2E Create CSR Journey` (in [resources/keywords/e2e_keywords.resource](../../resources/keywords/e2e_keywords.resource)) reads `CSRJ_DEFAULT_TARIFF_PLAN` / `CSRJ_DEFAULT_BUNDLE_PLAN` from config. No way to override per test.

**Needed:** accept optional arguments so scenarios can pass the resolved plan name:

```robot
E2E Create CSR Journey
    [Arguments]    ${ec_name}    ${bu_name}    ${tariff_plan}=${CSRJ_DEFAULT_TARIFF_PLAN}    ${bundle_plan}=${CSRJ_DEFAULT_BUNDLE_PLAN}
```

Scenario test bodies resolve the config key and pass it:

```robot
${tariff}=    config_scalar    ${TARIFF_CONFIG_KEY}
${bundle}=    config_scalar    ${BUNDLE_CONFIG_KEY}
E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}    tariff_plan=${tariff}    bundle_plan=${bundle}
```

### Gap 2 — Single-IMSI usage injection (Step 16a)

**Current:** `E2E Perform Usage For All Activated IMSIs` (in [resources/keywords/usage_keywords.resource](../../resources/keywords/usage_keywords.resource)) iterates every IMSI in `@E2E_ACTIVATED_IMSIS`. No way to select a subset.

**Needed:** a companion keyword that takes the IMSI index (or a list of IMSIs) and injects usage only on those:

```robot
E2E Perform Usage For Selected IMSIs
    [Arguments]    ${imsi_indexes}=1    ${mb_per_imsi}=5
    # Pick @E2E_ACTIVATED_IMSIS[${imsi_indexes}] and call the existing per-IMSI usage keyword
```

### Gap 3 — Private **Dynamic** APN subtype (Step 2)

**Current:** [variables/apn_variables.py](../../variables/apn_variables.py) defines `APN_TYPE_PRIVATE = "1"` and `APN_TYPE_PUBLIC = "2"`. No distinction between Private (static) and Private (dynamic) allocation.

**Needed:**
1. Add an IP-allocation-type variable:
   ```python
   APN_IP_ALLOC_STATIC  = "1"
   APN_IP_ALLOC_DYNAMIC = "2"
   ```
2. Extend `Fill Primary Details` in `apn_keywords.resource` (or the E2E wrapper) to accept an allocation type and select it in the UI after choosing APN Type = Private.

---

## Part 7 — Output Format Requested from the Generator

For every row in Part 2, produce:

1. **One Robot Framework test case block** styled like the existing entries in [tests/e2e_flow_with_usage.robot](../../tests/e2e_flow_with_usage.robot):
   ```robot
   <SCENARIO_ID> <Human-readable title>
       [Documentation]    <what this scenario validates>
       [Tags]    e2e    e2e-with-usage    <scenario-tag>    regression
       <Scenario Keyword>   # calls baseline steps + overrides from Part 3
   ```

2. **One scenario keyword** per row (in the `*** Keywords ***` section or in `e2e_keywords.resource`) that chains the 22 baseline steps and applies the overrides. Skipped steps are simply omitted.

3. **A per-scenario markdown summary table**:
   | Step | Action | Duration | Result |

4. **Run commands** (see Part 5 for the pattern).

5. **Config-file delta** — the `config/<env>.json` additions needed for the scenario's config keys.

---

## Part 8 — Pre-commit Checklist

- [ ] All `<<placeholders>>` in Parts 1, 2 have been replaced (grep the file for `<<` — only Part 4 reference column or these checklist items should contain the string)
- [ ] Every `SCENARIO_ID` in Part 2 is unique and not already present in `tasks.csv` (grep `tasks.csv`)
- [ ] Every config key referenced in Part 2 exists in `config/<env>.json` with a real plan name (or is flagged for the QE team to seed)
- [ ] Part 3 fixed overrides reflect the scenario's actual intent (re-read after filling)
- [ ] Known Implementation Gaps (Part 6) either addressed in this PR or explicitly deferred with a linked ticket
- [ ] New scenario keywords, if any, are defined in `resources/keywords/e2e_keywords.resource` or a scenario-specific resource file
- [ ] `tasks.csv` has one row per new scenario (regenerate via `python _gen_tasks.py`)
- [ ] New scenario has been run end-to-end on `qe` at least once before merge
- [ ] PDF/HTML report contains expected step screenshots and per-phase timings

---

## Appendix — Baseline References

- Baseline test file: [tests/e2e_flow_with_usage.robot](../../tests/e2e_flow_with_usage.robot)
- Baseline keywords: [resources/keywords/e2e_keywords.resource](../../resources/keywords/e2e_keywords.resource)
- Usage keywords: [resources/keywords/usage_keywords.resource](../../resources/keywords/usage_keywords.resource)
- APN variables: [variables/apn_variables.py](../../variables/apn_variables.py)
- CSR Journey variables: [variables/csr_journey_variables.py](../../variables/csr_journey_variables.py)
- Step-by-step guide: [documentation/E2E_FLOW_WITH_USAGE_GUIDE.md](../../documentation/E2E_FLOW_WITH_USAGE_GUIDE.md)
- Suite-level spec: [prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md](E2E_Flow_With_Usage.md)
- tasks.csv regenerator: [_gen_tasks.py](../../_gen_tasks.py) (gitignored helper)
