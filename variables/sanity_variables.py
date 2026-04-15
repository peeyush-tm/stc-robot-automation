# Sanity Suite Variables — from GControl_IoT_Basic_Sanity_Suite.md
# OPTIMISED: reduced from 60s/30s — sanity checks only verify page loads,
# not background processing. 20s page wait + 15s element wait is ample.
SANITY_TIMEOUT = "25s"
SANITY_PAGE_LOAD_WAIT = "25s"

# Folder for screenshots and CSV output (set by run_tests.py via --variable, or auto-created)
SANITY_REPORT_DIR = ""
