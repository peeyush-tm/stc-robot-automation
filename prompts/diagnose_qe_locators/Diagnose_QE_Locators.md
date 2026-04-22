# Diagnose QE Locators (Utility Suite)

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Diagnose_QE_Locators` |
| **Suite File** | `tests/diagnose_qe_locators.robot` |
| **Type** | Diagnostic utility — **no assertions** |
| **Total Tests** | 4 diagnostic tasks |
| **Intended For** | Developers debugging QE-only locator failures |

## Run Commands

```bash
python run_tests.py tests/diagnose_qe_locators.robot --env qe
python run_tests.py tests/diagnose_qe_locators.robot --env qe --test "Diagnose SIM Range Page"
```

## Purpose

When a locator works in dev/staging but fails in QE, this suite logs the runtime DOM state of the affected pages so you can compare selectors across environments. It is **not a functional test** — every task only prints what it finds.

## Diagnostic Tasks

| Task | Page | What It Logs |
|------|------|-------------|
| Diagnose SIM Range Page | `<BASE_URL>/CreateSIMRange` | All `<input>` + `<select>` elements — tag, name, id, placeholder, data-testid, type |
| Diagnose CSR Journey Page | `<BASE_URL>/CreateCSRJourney` | Custom dropdown containers — class, data-testid, id (first 30) |
| Diagnose SIM Order Page | `<BASE_URL>/CreateSIMOrder` | Inputs + custom dropdowns visible on Step 1 |
| Diagnose Manage Devices Grid | `<BASE_URL>/ManageDevices` | Grid headers + filter popup elements |

Output is written to the Robot log (`Log To Console`) so it shows in the terminal and in `reports/<timestamp>/combined_log.html`.

## When To Use

1. A test fails on QE with "element not visible" — run the matching diagnostic task and compare the printed locators with what the keyword expects.
2. Before adding a locator, run this to see what IDs/classes/data-testids the page renders.
3. After a CMP UI upgrade, re-run to detect locator drift.

## Prerequisites

- Valid OpCo login credentials in `config/<env>.json`
- Access to the target pages (no special roles)

## Notes

- This suite is **excluded from `tasks.csv` and the sanity run** — it's a dev tool, not part of the regression set.
- Tests never fail from an element being missing — they just log an empty or partial list. Read the output carefully.
- Safe to run in any environment; does not create, edit, or delete any data.
