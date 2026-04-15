# Report Module

## Overview
The Report module tests creating, downloading, and validating reports within the STC CMP application. Supports multiple report categories (Data Usage), view criteria (Day/Week/Month), display levels (OPCO), and formats (CSV/PDF/XLSX). Also tests email delivery of reports.

## CMP Pages
- **Report Listing:** `/Report` — Grid with search, download actions
- **Create Report:** `/CreateReports` — Report configuration form

## Test Suite
- **File:** `tests/report_tests.robot`
- **Keywords:** `resources/keywords/report_keywords.resource`
- **Locators:** `resources/locators/report_locators.resource`
- **Variables:** `variables/report_variables.py`
- **Total Test Cases:** 14

## Test Cases

### Positive
| TC ID | Name | Tags |
|-------|------|------|
| TC_015_001 | Create Report Happy Path And Validate Grid | smoke, regression, positive |
| TC_015_002 | Create Report And Download File | regression, positive, download |
| TC_015_003 | Create Report With Send Email | regression, positive, email |
| TC_015_004 | Create Report Weekly View | regression, positive, extended |
| TC_015_005 | Create Report Monthly View | regression, positive, extended |
| TC_015_006 | Create Report PDF Format | regression, positive, extended |
| TC_015_007 | Create Report XLSX Format | regression, positive, extended |
| TC_015_008 | Close Button Redirects To Report Listing | regression, positive, navigation |

### Negative
| TC ID | Name | Tags |
|-------|------|------|
| TC_015_NEG_01 | No Report Category Should Show Error | regression, negative |
| TC_015_NEG_02 | No View Criterion Should Show Error | regression, negative |
| TC_015_NEG_03 | No Display Level Should Show Error | regression, negative |
| TC_015_NEG_04 | No Report Format Should Show Error | regression, negative |
| TC_015_NEG_05 | Send Email Without Recipients Should Show Error | regression, negative, email |
| TC_015_NEG_06 | Close Without Submit Redirects To Report | regression, negative |

## Key Variables
- `REPORT_CATEGORY_NAME` — `Usage Report`
- `VIEW_CRITERION_VALUE` — `DAY` (default), `WEEK`, `MONTH`
- `DISPLAY_LEVEL_VALUE` — `OPCO`
- `REPORT_FORMAT_VALUE` — `CSV` (default), `PDF`, `XLSX`
- `EMAIL_RECIPIENT` — `test.automation@example.com`

## Run Commands
```bash
python run_tests.py --suite "Report" --env qe
python run_tests.py --suite "Report" --env qe --include smoke
python run_tests.py --suite "Report" --env qe --test "TC_015_NEG_*"
```
