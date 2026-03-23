# CDR reason code
CDR_REASON_CODE = "EOC"

# Grid column header for usage validation (Manage Devices page) — data usage only
DATA_USAGE_COLUMN_HEADER = "DATA USAGE (MB)"

# Usage type definitions: each entry drives one User Request + CDR pair per IMSI.
# Only data usage is performed (voice and SMS usage cases removed).
# - label: human-readable name for logging
# - type: User Request API & CDR API query param
# - subType: empty for Data
# - volume: CDR API volume param (data=5MB in bytes)
USAGE_TYPES = [
    {"label": "Data", "type": "data", "subType": "", "volume": "5242880"},
]
