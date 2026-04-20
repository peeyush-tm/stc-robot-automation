*** Settings ***
Library    SeleniumLibrary
Library    ../../libraries/GridOOM.py

*** Keywords ***
Go To Url With Connection Retries
    [Documentation]    Navigates with retries for transient ``net::ERR_CONNECTION_TIMED_OUT`` / network blips.
    ...                If all attempts fail, fails with a hint to check VPN, BASE_URL in config, and server reachability.
    [Arguments]    ${url}    ${attempts}=3    ${pause_between}=5s
    FOR    ${i}    IN RANGE    ${attempts}
        ${ok}=    Run Keyword And Return Status    Go To    ${url}
        IF    ${ok}
            RETURN
        END
        ${n}=    Evaluate    int(${i}) + 1
        Log    Initial navigation to ${url} failed (attempt ${n} of ${attempts}). Retrying after ${pause_between}...    level=WARN
        Sleep    ${pause_between}
    END
    Fail
    ...    Could not load ${url} after ${attempts} attempts. Common causes: net::ERR_CONNECTION_TIMED_OUT (VPN off, corporate firewall, wrong BASE_URL in config/<ENV>.json), or QE/server unreachable. Ping or open the URL in a browser from this machine to verify.

Install Global Page Size Limiter
    [Documentation]    Uses Chrome DevTools Protocol (CDP) ``Page.addScriptToEvaluateOnNewDocument`` to inject
    ...                mitigations BEFORE page JS: (1) append ``pageSize=50`` on matching grid API URLs when no
    ...                ``pageSize``/``search`` is present; (2) wrap ``JSON.parse`` and cap OData/Kendo/DataTables
    ...                style totals (incl. ``@odata.count``, ``recordsTotal``) to 10000; (3) rewrite XHR/fetch
    ...                JSON bodies; (4) ``Proxy`` on ``Array`` so ``new Array(n)`` with ``n`` > 100000 becomes
    ...                length 100000 (safety net if totals still slip through).
    ...                Kendo often uses ``addEventListener("readystatechange")`` (not ``onreadystatechange``), so
    ...                URL-only injection is not enough for ``V8 javascript OOM (invalid array length)``.
    ...                Called once per ``Open Test Browser``; survives navigations. Apply Account Filter URLs with
    ...                ``search=`` are left unchanged on the request side. Script body: ``libraries/GridOOM.py``.
    ${_script}=    Get Grid Oom Patch Script
    ${_params}=    Create Dictionary    source=${_script}
    ${_sel}=    Get Library Instance    SeleniumLibrary
    TRY
        # Must use $_sel / $_params — $sel/$params do not exist and Evaluate fails silently into EXCEPT (no OOM fix).
        Evaluate    $_sel.driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", $_params)
        Log    Global grid OOM mitigations installed via CDP (pageSize=50, total caps, JSON.parse + XHR/fetch + Array clamp).    level=INFO
    EXCEPT    AS    ${_cdp_err}
        Log    CDP page-script injection failed (${_cdp_err}) — OOM mitigations not active.    level=WARN
    END

Inject Grid Oom Patch Into Current Page
    [Documentation]    Evaluates the same IIFE as CDP ``Install Global Page Size Limiter`` on the **already loaded**
    ...                document. Idempotent (``__stcGridOomPatchV2``). Use before filter clicks if CDP missed or
    ...                for SPA navigations that reuse one document without a full reload.
    ${js}=    Get Grid Oom Patch Script
    Run Keyword And Ignore Error    Execute Javascript    ${js}

Open Test Browser
    [Documentation]    Opens browser with the configured settings. Handles SSL warnings for HTTPS IP addresses.
    ...                Supports: chrome, headlesschrome, firefox, edge.
    ...                After creating the WebDriver, installs a global CDP page-size limiter (50 rows per API
    ...                call) that prevents Kendo Grid's ``new Array(totalCount)`` from causing
    ...                ``V8 javascript OOM (invalid array length)`` on heavy Manage Devices / SIM pages.
    [Arguments]    ${url}    ${browser}
    IF    '${browser}' == 'headlesschrome'
        ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
        ${hlw}=    Evaluate    __import__('os').environ.get('STC_CHROME_HEADLESS_WINDOW_SIZE','1680,945')
        ${blk}=    Evaluate    __import__('os').environ.get('STC_CHROME_BLOCK_IMAGES','0')
        # Use bundled Chrome binary when STC_CHROME_BINARY is set (server environments)
        ${custom_binary}=    Evaluate    __import__('os').environ.get('STC_CHROME_BINARY','')
        IF    '${custom_binary}' != ''
            Evaluate    setattr($chrome_options, 'binary_location', '${custom_binary}')
        END
        # SSL / certificate bypass
        Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
        Call Method    ${chrome_options}    add_argument    --allow-insecure-localhost
        Call Method    ${chrome_options}    add_argument    --allow-running-insecure-content
        Evaluate    $chrome_options.set_capability('acceptInsecureCerts', True)
        Evaluate    $chrome_options.add_argument('--headless=new')
        ${hws}=    Catenate    SEPARATOR=    --window-size=    ${hlw}
        Evaluate    $chrome_options.add_argument("""${hws}""")
        Call Method    ${chrome_options}    add_argument    --disable-gpu
        Call Method    ${chrome_options}    add_argument    --disable-gpu-compositing
        Call Method    ${chrome_options}    add_argument    --no-sandbox
        Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
        Call Method    ${chrome_options}    add_argument    --disable-extensions
        Call Method    ${chrome_options}    add_argument    --disable-infobars
        Call Method    ${chrome_options}    add_argument    --disable-background-networking
        IF    '${blk}' == '1'
            Evaluate    $chrome_options.add_experimental_option('prefs', {'profile.default_content_setting_values': {'images': 2}})
            Log    STC_CHROME_BLOCK_IMAGES=1: blocking images to reduce headless Chrome memory.    level=INFO
        END
        Evaluate    $chrome_options.add_argument('--disk-cache-size=1')
        Evaluate    $chrome_options.add_argument('--remote-debugging-port=0')
        Evaluate    $chrome_options.add_argument('--js-flags=--max-old-space-size=4096 --max-semi-space-size=256 --expose-gc --gc-interval=1000')
        Evaluate    $chrome_options.add_argument('--disable-features=BackForwardCache,Translate,IsolateOrigins,site-per-process,AudioServiceOutOfProcess')
        Evaluate    $chrome_options.add_argument('--disable-default-apps')
        Evaluate    $chrome_options.add_argument('--aggressive-cache-discard')
        Evaluate    $chrome_options.add_argument('--disable-notifications')
        Evaluate    $chrome_options.add_argument('--disable-background-timer-throttling')
        Evaluate    $chrome_options.add_argument('--disable-renderer-backgrounding')
        Evaluate    $chrome_options.add_argument('--disable-backgrounding-occluded-windows')
        Evaluate    $chrome_options.add_argument('--disable-sync')
        Evaluate    $chrome_options.add_argument('--disable-breakpad')
        Call Method    ${chrome_options}    add_argument    --mute-audio
        Create Webdriver    Chrome    options=${chrome_options}
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}s
        Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}s
        # Set script timeout to 120s so long JS polls (rule creation, async waits) don't abort at 30s default
        ${sl}=    Get Library Instance    SeleniumLibrary
        Evaluate    $sl.driver.set_script_timeout(120)
        # CRITICAL FIX for headless: --window-size argument is often ignored by --headless=new mode.
        # Explicitly force a large viewport so elements don't render off-screen (which is why elements
        # appeared "not visible" on server but worked fine locally in headed Chrome).
        ${win_w}=    Evaluate    int("${hlw}".split(",")[0])
        ${win_h}=    Evaluate    int("${hlw}".split(",")[1])
        Evaluate    $sl.driver.set_window_size(${win_w}, ${win_h})
        Log    Headless viewport forced to ${win_w}x${win_h} via set_window_size().    console=yes
        Install Global Page Size Limiter
        Go To Url With Connection Retries    ${url}
        Inject Grid Oom Patch Into Current Page
    ELSE IF    '${browser}' == 'chrome'
        ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
        ${hw}=    Evaluate    __import__('os').environ.get('STC_CHROME_HEADED_WINDOW_SIZE','1680,945')
        ${wmax}=    Evaluate    __import__('os').environ.get('STC_CHROME_HEADED_MAXIMIZED','0')
        ${blk}=    Evaluate    __import__('os').environ.get('STC_CHROME_BLOCK_IMAGES','0')
        Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
        Call Method    ${chrome_options}    add_argument    --allow-insecure-localhost
        Call Method    ${chrome_options}    add_argument    --disable-extensions
        Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
        Call Method    ${chrome_options}    add_argument    --disable-background-networking
        Call Method    ${chrome_options}    add_argument    --disable-gpu
        Call Method    ${chrome_options}    add_argument    --disable-gpu-compositing
        Call Method    ${chrome_options}    add_argument    --no-sandbox
        Call Method    ${chrome_options}    add_argument    --mute-audio
        Call Method    ${chrome_options}    add_argument    --no-first-run
        Call Method    ${chrome_options}    add_argument    --disable-infobars
        Call Method    ${chrome_options}    add_argument    --start-maximized
        IF    '${blk}' == '1'
            Evaluate    $chrome_options.add_experimental_option('prefs', {'profile.default_content_setting_values': {'images': 2}})
            Log    STC_CHROME_BLOCK_IMAGES=1: blocking images to reduce headed Chrome memory.    level=INFO
        END
        Evaluate    $chrome_options.add_argument('--disk-cache-size=1')
        Evaluate    $chrome_options.add_argument('--remote-debugging-port=0')
        Evaluate    $chrome_options.add_argument('--js-flags=--max-old-space-size=4096 --max-semi-space-size=256 --expose-gc --gc-interval=1000')
        Evaluate    $chrome_options.add_argument('--disable-features=BackForwardCache,Translate,IsolateOrigins,site-per-process,AudioServiceOutOfProcess')
        Evaluate    $chrome_options.add_argument('--disable-default-apps')
        Evaluate    $chrome_options.add_argument('--aggressive-cache-discard')
        Evaluate    $chrome_options.add_argument('--disable-notifications')
        Evaluate    $chrome_options.add_argument('--disable-background-timer-throttling')
        Evaluate    $chrome_options.add_argument('--disable-renderer-backgrounding')
        Evaluate    $chrome_options.add_argument('--disable-backgrounding-occluded-windows')
        Evaluate    $chrome_options.add_argument('--disable-sync')
        Evaluate    $chrome_options.add_argument('--disable-breakpad')
        Evaluate    $chrome_options.set_capability('acceptInsecureCerts', True)
        Create Webdriver    Chrome    options=${chrome_options}
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}s
        Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}s
        # Set script timeout to 120s so long JS polls (rule creation, async waits) don't abort at 30s default
        ${sl}=    Get Library Instance    SeleniumLibrary
        Evaluate    $sl.driver.set_script_timeout(120)
        Maximize Browser Window
        Install Global Page Size Limiter
        Go To Url With Connection Retries    ${url}
        Inject Grid Oom Patch Into Current Page
    ELSE IF    '${browser}' == 'firefox'
        Open Browser    about:blank    ${browser}
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}s
        Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}s
        Go To Url With Connection Retries    ${url}
    ELSE IF    '${browser}' == 'edge'
        Open Browser    about:blank    ${browser}
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}s
        Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}s
        Go To Url With Connection Retries    ${url}
    ELSE
        Open Browser    about:blank    ${browser}
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}s
        Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}s
        Go To Url With Connection Retries    ${url}
    END

Request Page Garbage Collection Best Effort
    [Documentation]    Runs V8 ``gc()`` in the page when Chrome was started with ``--expose-gc`` (see ``Open Test Browser``).
    ...                Helps after large Kendo grids / SPA navigations. No-op if ``gc`` is unavailable; failures ignored.
    Run Keyword And Ignore Error
    ...    Execute Javascript    try{if(typeof gc==='function'){gc();}}catch(e){}

Page Is Chrome OOM Crash
    [Documentation]    Returns ``${True}`` only for **real** Chrome crash / error-tab signals — not generic SPA DOM.
    ...                Previously ``#main-frame-error`` / ``.interstitial-wrapper`` matched normal CMP pages and caused
    ...                ``Navigate To Module Page`` to **restart Chrome on every navigation** (many windows per test).
    ...                Now: ``chrome-error://`` URL, or **Aw, Snap** UI, or Chrome-style **Out of Memory** error line.
    ...                If JS is unreachable (process dead), returns ``${True}``.
    ${js_ok}=    Run Keyword And Return Status
    ...    Execute Javascript    return true
    IF    not ${js_ok}
        Log    Chrome JS execution failed — process likely crashed.    level=WARN
        RETURN    ${True}
    END
    ${oom}=    Execute Javascript
    ...    return (function(){var h='';try{h=(window.location&&window.location.href)||'';}catch(e){return true;}var hl=h.toLowerCase();if(hl.indexOf('chrome-error')>=0)return true;var t='';try{t=((document.body&&document.body.innerText)||'').toLowerCase();}catch(e2){return false;}if(t.indexOf('aw, snap')>=0)return true;if(t.indexOf('out of memory')>=0&&t.indexOf('error code')>=0)return true;return false;})()
    RETURN    ${oom}

Close Test Browser
    [Documentation]    Closes all browser instances.
    Close All Browsers

Force Kill Chrome Processes
    [Documentation]    OS-level force-kill of all chrome/chromedriver processes.
    ...                Works on both Windows (taskkill) and Linux (pkill).
    ...                Call this after ``Close All Browsers`` when Chrome may have OOM-crashed and left
    ...                zombie processes — a dead WebDriver session cannot be cleaned by Selenium alone.
    ${is_windows}=    Evaluate    __import__('platform').system() == 'Windows'
    IF    ${is_windows}
        Run Keyword And Ignore Error
        ...    Evaluate    __import__('subprocess').call(['taskkill','/F','/IM','chrome.exe','/T'],stdout=open(os.devnull,'w'),stderr=open(os.devnull,'w'))    os
        Run Keyword And Ignore Error
        ...    Evaluate    __import__('subprocess').call(['taskkill','/F','/IM','chromedriver.exe','/T'],stdout=open(os.devnull,'w'),stderr=open(os.devnull,'w'))    os
    ELSE
        Run Keyword And Ignore Error
        ...    Evaluate    __import__('subprocess').call(['pkill','-9','-f','chromedriver'],stdout=open(os.devnull,'w'),stderr=open(os.devnull,'w'))    os
        Run Keyword And Ignore Error
        ...    Evaluate    __import__('subprocess').call(['pkill','-9','-f','headless_shell'],stdout=open(os.devnull,'w'),stderr=open(os.devnull,'w'))    os
        Run Keyword And Ignore Error
        ...    Evaluate    __import__('subprocess').call(['pkill','-9','-f','chrome'],stdout=open(os.devnull,'w'),stderr=open(os.devnull,'w'))    os
    END
    Sleep    1.5s

Navigate To URL
    [Documentation]    Navigates to the given URL and waits for page load.
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Load

Clear Session State
    [Documentation]    Clears cookies and session/local storage to ensure a clean state.
    Delete All Cookies
    Execute Javascript    window.sessionStorage.clear();
    Execute Javascript    window.localStorage.clear();

Navigate To URL With Clean Session
    [Documentation]    Clears session state, then navigates to the URL.
    [Arguments]    ${url}
    Clear Session State
    Go To    ${url}
    Wait For Page Load

Input Text Into Field
    [Documentation]    Waits for element and enters text.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Input Text    ${locator}    ${text}

Clear And Input Text Into Field
    [Documentation]    Clears a field and enters new text.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Clear Element Text    ${locator}
    Input Text    ${locator}    ${text}

Click Element Safely
    [Documentation]    Waits for loading overlay to disappear, then clicks element.
    [Arguments]    ${locator}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Wait Until Element Is Enabled    ${locator}    timeout=30s
    Click Element    ${locator}

Click Element Via JS
    [Documentation]    Waits for loading overlay, then clicks via JavaScript (bypasses overlay issues).
    [Arguments]    ${locator}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${locator}    timeout=30s
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Click Element Via JS Force
    [Documentation]    Same as Click Element Via JS but skips the visibility check — use when the element
    ...                is present in DOM but not Robot-visible (below the fold, covered by an overlay,
    ...                or only triggered via JS). Caller is responsible for scrolling into view.
    [Arguments]    ${locator}
    Wait For Loading Overlay To Disappear
    Wait Until Page Contains Element    ${locator}    timeout=30s
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${element}

Scroll To Element Via JS
    [Documentation]    Scrolls the page until the element is in view.
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({behavior: "smooth", block: "center"});    ARGUMENTS    ${element}

Select Option By Label Via JS
    [Documentation]    Selects a dropdown option by visible label using JavaScript.
    [Arguments]    ${locator}    ${label}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    var select = arguments[0]; for(var i=0; i<select.options.length; i++){ if(select.options[i].text.trim()==='${label}'){ select.selectedIndex=i; select.dispatchEvent(new Event('change')); break; } }
    ...    ARGUMENTS    ${element}

Select Option By Index Via JS
    [Documentation]    Selects a dropdown option by index using JavaScript.
    [Arguments]    ${locator}    ${index}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    arguments[0].selectedIndex=${index}; arguments[0].dispatchEvent(new Event('change'));
    ...    ARGUMENTS    ${element}

Capture Step Screenshot
    [Documentation]    Takes a named screenshot at a specific step.
    ...                Name format: descriptive label (no .png extension needed).
    ...                The STCReportListener renames the file to {TC_ID}_step_NN_{name}.png
    ...                and moves it into the module subfolder automatically.
    [Arguments]    ${step_name}
    Capture Page Screenshot    ${step_name}.png

Capture Test Screenshot
    [Documentation]    Captures screenshot on test failure.
    Run Keyword If Test Failed    Capture Page Screenshot

Open Browser And Navigate
    [Documentation]    Opens a fresh browser, clears session state, and navigates to the URL.
    [Arguments]    ${url}    ${browser}
    Open Test Browser    ${url}    ${browser}

Capture Screenshot And Close Browser
    [Documentation]    Captures screenshot on both pass and failure, then closes the browser.
    ...                Do **not** use as Suite Teardown — ``Run Keyword If Test Failed/Passed`` are only
    ...                valid in test teardown; use ``Close All Browsers`` for suite teardown instead.
    Run Keyword If Test Failed    Capture Page Screenshot
    Run Keyword If Test Passed    Capture Page Screenshot
    Close All Browsers

Handle Test Teardown
    [Documentation]    Captures screenshot on both pass and failure.
    ...                Does NOT close the browser so the suite-level session is
    ...                preserved for subsequent tests.
    ...                Screenshots are renamed and moved to the module subfolder
    ...                by STCReportListener: {TC_ID}_step_NN_PASS.png / _FAIL.png
    Run Keyword If Test Failed    Capture Page Screenshot
    Run Keyword If Test Passed    Capture Page Screenshot

Wait For Page Load
    [Documentation]    Waits for the page to fully load (React rendering complete).
    ...                Retries up to 3 times for transient network issues.
    Wait Until Keyword Succeeds    3x    1s    Wait For Document Ready
    Wait For Loading Overlay To Disappear

Wait For App Loading To Complete
    [Documentation]    Alias for Wait For Page Load. Waits until document is ready and loading overlay gone.
    ...                Accepts optional timeout argument for backward compatibility.
    [Arguments]    ${timeout}=60s
    Wait Until Keyword Succeeds    3x    1s    Wait For Document Ready
    Wait For Loading Overlay To Disappear

Wait For Document Ready
    [Documentation]    Checks that document.readyState is complete.
    Wait For Condition    return document.readyState === 'complete'    timeout=30s

Wait For Loading Overlay To Disappear
    [Documentation]    Waits until the body.loading-indicator overlay is gone.
    ...                The CMP app adds class "loading-indicator" to <body> during API calls.
    ...                Some builds also use a ``#loading-indicator`` div that intercepts clicks (e.g. CSR react-select).
    ...                If the indicator is stuck for > 10s, force-removes it via JS and warns (to avoid long stalls).
    ${cleared}=    Run Keyword And Return Status
    ...    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=10s
    IF    not ${cleared}
        Log    Loading overlay stuck for 10s — force-removing via JS.    level=WARN
        Execute Javascript    document.body.classList.remove('loading-indicator');
        Brief UI Settle Short
    END
    ${div_clear}=    Run Keyword And Return Status
    ...    Wait For Condition
    ...    return (function(){ var el = document.getElementById('loading-indicator'); if (!el) return true; var st = window.getComputedStyle(el); if (st.display === 'none' || st.visibility === 'hidden') return true; if (parseFloat(st.opacity || '1') < 0.05) return true; return el.offsetParent === null; })()
    ...    timeout=20s
    IF    not ${div_clear}
        Log    loading-indicator div still blocking UI after 20s — disabling pointer-events via JS.    level=WARN
        Execute Javascript    (function(){ var el=document.getElementById('loading-indicator'); if(el){ el.style.pointerEvents='none'; el.style.display='none'; } })();
        Brief UI Settle Short
    END

Brief UI Settle Short
    [Documentation]    Tiny pause after DOM updates (~200ms). Prefer over Sleep 1s when overlay already cleared.
    Sleep    0.22s

Brief UI Settle
    [Documentation]    Short pause for Kendo/UI repaint after spinner gone. Prefer over Sleep 1s–2s.
    Sleep    0.45s

Brief UI Settle Long
    [Documentation]    Slightly longer settle (modals, grid reflow). Prefer over Sleep 3s where no explicit condition exists.
    Sleep    0.9s

Proactive Browser Restart If Needed
    [Documentation]    Proactively restarts Chrome every N tests to prevent memory buildup crashes.
    ...                Tracks test count via suite variable. Call from Test Setup of heavy suites.
    ...                Default interval is 10 tests.
    [Arguments]    ${interval}=10
    ${counter}=    Get Variable Value    ${_PROACTIVE_RESTART_COUNTER}    ${0}
    ${counter}=    Evaluate    ${counter} + 1
    Set Suite Variable    ${_PROACTIVE_RESTART_COUNTER}    ${counter}
    ${needs_restart}=    Evaluate    ${counter} > 1 and ${counter} % ${interval} == 0
    IF    ${needs_restart}
        Log    Proactive browser restart (test #${counter}, interval=${interval}) to prevent Chrome memory crash.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Sleep    2s    reason=Let Chrome processes clean up gracefully
        Open Test Browser    ${BASE_URL}    ${BROWSER}
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
    END
