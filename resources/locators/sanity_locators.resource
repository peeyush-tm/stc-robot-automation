*** Variables ***
# ══════════════════════════════════════════════════════════════════════
#  COMMON SANITY LOCATORS — from GControl_IoT_Basic_Sanity_Suite.md
#  Section 3: Error Detection Criteria
#  Section 4: Grid Load Verification Criteria
# ══════════════════════════════════════════════════════════════════════

# Grid verification (Section 4)
${LOC_GRID_CONTAINER}             xpath=//div[contains(@class,'k-grid')]
${LOC_GRID_COLUMN_HEADER}        xpath=//th[@role='columnheader']
${LOC_GRID_PAGINATION}           xpath=//*[contains(@class,'k-pager-wrap')]
${LOC_GRID_LOADING_MASK}         xpath=//*[contains(@class,'k-loading-mask')]

# Error detection (Section 3)
${LOC_ERROR_HTTP_500}             xpath=//h1[contains(text(),'500')]
${LOC_ERROR_HTTP_404}             xpath=//h1[contains(text(),'404')]
${LOC_ERROR_ALERT_DANGER}        xpath=//*[contains(@class,'alert-danger')]
${LOC_ERROR_OVERLAY}             xpath=//*[contains(@class,'error-overlay')]
${LOC_ERROR_SOMETHING_WRONG}     xpath=//*[contains(text(),'Something went wrong')]
${LOC_ERROR_UNAUTHORIZED}        xpath=//*[contains(text(),'Unauthorized')]
# Exclude thead so column titles like "Error Code" do not fail sanity; real fetch errors render in body rows/content.
${LOC_ERROR_IN_GRID}             xpath=//div[contains(@class,'k-grid')]//*[contains(text(),'Error') and not(ancestor::thead)]

# Search bar
${LOC_SEARCH_INPUT}              xpath=//input[@placeholder='Enter Search Text']

# Sub-tab navigation (ul#pageHeading)
${LOC_PAGE_HEADING_UL}           xpath=//ul[@id='pageHeading']
