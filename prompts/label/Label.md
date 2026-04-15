# Label Module

## Overview
The Label module covers CRUD operations on labels within the STC CMP application. Labels can be created at KSA (OPCO) level, assigned to accounts, and then assigned/unassigned to SIMs via the Tag Assignment action on Manage Devices.

## CMP Pages
- **Manage Label:** `/ManageLabel` — Listing grid with search, edit actions
- **Create Label:** `/CreateLabel` — Form with Level, Account, Name, Color, Description
- **Tag Assignment:** Modal on `/ManageDevices` (action value `13`)

## Test Suite
- **File:** `tests/label_tests.robot`
- **Keywords:** `resources/keywords/label_keywords.resource`
- **Locators:** `resources/locators/label_locators.resource`
- **Variables:** `variables/label_variables.py`
- **Total Test Cases:** 28

## Test Cases

### Positive — Create
| TC ID | Name | Tags |
|-------|------|------|
| TC_LBL_001 | Create Label KSA Level Full Flow | smoke, regression, positive |
| TC_LBL_002 | Verify Create Label Page Elements Visible | regression, positive |
| TC_LBL_003 | Verify Create Label Button Visible On Listing For RW User | regression, positive |
| TC_LBL_008 | Account Dropdown Populated After Level Select | regression, positive |
| TC_LBL_022 | Create Label Success Without Optional Description | regression, positive |
| TC_LBL_023 | Verify Kendo Color Picker Value After Set | regression, positive |

### Positive — Read/Listing
| TC ID | Name | Tags |
|-------|------|------|
| TC_LBL_004 | Verify Manage Label Listing Grid Loads | smoke, regression, positive |
| TC_LBL_005 | Search Label In Listing Grid | regression, positive, search |
| TC_LBL_009 | Manage Label Listing Grid Column Headers | regression, positive |

### Positive — Edit
| TC ID | Name | Tags |
|-------|------|------|
| TC_LBL_006 | Edit Label Update Name | regression, positive, edit-label |
| TC_LBL_017 | Edit Label Update Description And Color | regression, positive, edit-label |
| TC_LBL_018 | Close Edit Form Discards Name Change | regression, positive, edit-label |
| TC_LBL_020 | Close Edit Form Without Changes Returns To Manage Label | regression, positive |

### Positive — Tag Assignment (Manage Devices)
| TC ID | Name | Tags |
|-------|------|------|
| TC_LBL_025 | Assign Label To SIM Via Tag Assignment | regression, positive, label-assignment |
| TC_LBL_026 | Unassign Label From SIM Via Tag Assignment | regression, positive, label-assignment |

### Negative — Validation
| TC ID | Name | Tags |
|-------|------|------|
| TC_LBL_007 | Close Create Form Reloads To Manage Label | regression, positive, navigation |
| TC_LBL_010 | Submit With No Mandatory Fields Should Show Validation | regression, negative |
| TC_LBL_011 | Missing Level Should Show Validation | regression, negative |
| TC_LBL_012 | Missing Account Should Show Validation | regression, negative |
| TC_LBL_013 | Missing Label Name Should Show Validation | regression, negative |
| TC_LBL_014 | Label Name Exceeds 100 Characters Should Show Validation | regression, negative, manual |
| TC_LBL_015 | Duplicate Label Name Should Show Error Toast | regression, negative |
| TC_LBL_016 | Change Level Resets Account Selection | regression, negative |
| TC_LBL_019 | Edit Label Submit Empty Name Should Show Validation | regression, negative, manual |
| TC_LBL_021 | Delete Label Not In TC009 Scope | regression, negative, manual |
| TC_LBL_024 | Description Exceeds 100 Characters Should Show Validation | regression, negative, manual |
| TC_LBL_027 | Assign Without Selecting Label Should Not Submit | regression, negative |
| TC_LBL_028 | Close Tag Assignment Without Submit Discards Changes | regression, negative |

## Key Variables
- `LBL_NAME` — Auto-generated label name with random suffix
- `LBL_COLOR_HEX` — Default color `#FF5733`
- `LBL_LEVEL_KSA` — `OPCO` level
- `LA_TAG_ASSIGNMENT_VALUE` — Action dropdown value `13` for Tag Assignment

## Run Commands
```bash
python run_tests.py --suite "Label" --env qe
python run_tests.py --suite "Label" --env qe --include smoke
python run_tests.py --suite "Label" --env qe --test "TC_LBL_025*"
```
