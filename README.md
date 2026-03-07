## Structure

- **config/** — Environment config (UI + API)
- **data/** — Test data CSV files
- **libraries/** — Custom Python (e.g. CSV reader)
- **prompts/** — Module reference docs (login, roles, users, etc.)
- **resources/keywords/** — Reusable keyword libraries
- **resources/locators/** — XPath/CSS locator definitions
- **tests/** — Robot Framework test suites
- **variables/** — Python variable files (shared seed + per-module)
- **reports/** — Generated test reports

## Setup

```bash
pip install -r requirements.txt
pip install robotframework-requests
```

## Run

```bash
python run_tests.py
python run_tests.py tests/login_tests.robot
python run_tests.py --include smoke --env dev
```

See project documentation for full commands and options.
