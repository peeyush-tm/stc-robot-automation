"""
Runtime CSR Journey landing: find the device-plan Kendo/legacy table in the live DOM.

Kendo often splits **header** and **body** into sibling ``table`` elements inside ``.k-grid``;
the scrollable content table may have **no** ``<th>`` — header text must be read from the
parent ``.k-grid`` widget, not only ``table.find_elements(th)``.
"""
from __future__ import annotations

import re
import time

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.by import By

ROBOT_LIBRARY_SCOPE = "GLOBAL"

# Prefer these XPath sets first (document order indices must match Selenium find_elements order).
_TABLE_XPATH_GROUPS: tuple[str, ...] = (
    "//*[@id='gridData']//table",
    "//div[contains(@class,'k-grid')]//table",
    "//*[@id='content']//table",
    "//table[contains(@class,'col-md-12')]",
    "//table",
)


def _norm_headers_in_table(table) -> str:
    """``th`` nodes that are descendants of this table element only."""
    parts: list[str] = []
    try:
        for th in table.find_elements(By.XPATH, ".//th"):
            t = (th.text or "").strip().lower()
            if t:
                parts.append(t)
    except StaleElementReferenceException:
        return ""
    return " ".join(parts)


def _kgrid_header_blob(driver, table) -> str:
    """All ``th`` text inside the nearest Kendo ``.k-grid`` ancestor (includes header table)."""
    try:
        s = driver.execute_script(
            """
            var t = arguments[0];
            var g = t.closest && t.closest('.k-grid');
            if (!g) return '';
            var parts = [];
            g.querySelectorAll('th, [role="columnheader"]').forEach(function(h) {
                var x = (h.textContent || h.getAttribute('title') || h.getAttribute('aria-label') || '')
                    .trim().toLowerCase();
                if (x) parts.push(x);
            });
            return parts.join(' ');
            """,
            table,
        )
        return (s or "").strip().lower()
    except Exception:
        return ""


def _full_header_blob(driver, table) -> str:
    a = _norm_headers_in_table(table)
    b = _kgrid_header_blob(driver, table)
    return f"{a} {b}".strip().lower()


def _looks_like_device_plan_grid(blob: str) -> bool:
    """Column wording varies by build and locale."""
    if not blob:
        return False
    b = blob.lower()
    c = re.sub(r"\s+", "", b)
    apn = (
        "apntype" in c
        or bool(re.search(r"apn\s*type", b))
        or bool(re.search(r"apn\s*category", b))
        or bool(re.search(r"apn\scategory", b))
        or ("apn" in b and "type" in b)
        or ("apn" in b and "category" in b)
    )
    plan = (
        "deviceplan" in c
        or "tariffplan" in c
        or "device plan" in b
        or "tariff plan" in b
        or ("tariff" in b and "plan" in b)
        or ("device" in b and "plan" in b)
        or "dp alias" in b
        or ("alias" in b and "device" in b)
    )
    # Some builds show APN Type + APNs before device/tariff columns render in the same pass
    apns_col = "apns" in c or bool(re.search(r"\bapns\b", b))
    return apn and (plan or apns_col)


def _inside_griddata(driver, table) -> bool:
    try:
        return bool(
            driver.execute_script(
                """
                var t = arguments[0];
                while (t) {
                    if (t.id === 'gridData') return true;
                    t = t.parentElement;
                }
                return false;
                """,
                table,
            )
        )
    except Exception:
        return False


def _has_csr_journey_row_actions(driver, table) -> bool:
    """Main CSR landing grid exposes Kendo command icons (row-level or toolbar)."""
    try:
        return bool(
            driver.execute_script(
                """
                var t = arguments[0];
                var g = t.closest && t.closest('.k-grid');
                if (!g) return false;
                var sel = 'i.k-grid-csrSummary, i.k-grid-editNodeKendoPopup, '
                    + 'i.k-grid-deleteNodeKendoPopup, i.k-grid-changeTPNodeKendoPopup';
                return !!g.querySelector(sel);
                """,
                table,
            )
        )
    except Exception:
        return False


def _scroll_to(driver, el) -> None:
    try:
        driver.execute_script("arguments[0].scrollIntoView({block:'center'});", el)
    except Exception:
        pass


def _nudge_scroll(driver) -> None:
    try:
        driver.execute_script("window.scrollTo(0, 0);")
        time.sleep(0.05)
        driver.execute_script(
            "window.scrollTo(0, Math.max(0, Math.floor((document.body && document.body.scrollHeight || 0) * 0.3)));"
        )
    except Exception:
        pass


def _accept_table(driver, table) -> bool:
    try:
        _scroll_to(driver, table)
        time.sleep(0.06)
        if not table.is_displayed():
            return False
    except StaleElementReferenceException:
        return False
    blob = _full_header_blob(driver, table)
    if _looks_like_device_plan_grid(blob):
        return True
    # Empty CSR (no rows yet): no row icons; still under gridData + header titles may be the only signal
    if _inside_griddata(driver, table) and _has_csr_journey_row_actions(driver, table):
        return True
    return False


def _first_matching_indexed_xpath(driver, xpath_many: str) -> str | None:
    try:
        tables = driver.find_elements(By.XPATH, xpath_many)
    except Exception:
        return None
    for i, t in enumerate(tables):
        try:
            if _accept_table(driver, t):
                return f"({xpath_many})[{i + 1}]"
        except StaleElementReferenceException:
            continue
    return None


def _blob_from_element_subtree(driver, root) -> str:
    """All th / columnheader text under a node (entire Kendo widget, not just one table)."""
    try:
        s = driver.execute_script(
            """
            var g = arguments[0];
            if (!g) return '';
            var parts = [];
            g.querySelectorAll('th, [role="columnheader"]').forEach(function(h) {
                var x = (h.textContent || h.getAttribute('title') || h.getAttribute('aria-label') || '')
                    .trim().toLowerCase();
                if (x) parts.push(x);
            });
            return parts.join(' ');
            """,
            root,
        )
        return (s or "").strip().lower()
    except Exception:
        return ""


def _xpath_for_first_visible_table_under_griddata(driver, grid_index: int) -> str | None:
    """``(//*[@id='gridData'])[n]//table[m]`` for first displayed table under that grid root."""
    try:
        roots = driver.find_elements(By.XPATH, "//*[@id='gridData']")
        if grid_index < 0 or grid_index >= len(roots):
            return None
        root = roots[grid_index]
        if not root.is_displayed():
            return None
        tables = root.find_elements(By.XPATH, ".//table")
        for j, t in enumerate(tables):
            try:
                if t.is_displayed():
                    return f"(//*[@id='gridData'])[{grid_index + 1}]//table[{j + 1}]"
            except StaleElementReferenceException:
                continue
    except Exception:
        return None
    return None


def _fallback_kendo_griddata_table(driver) -> str | None:
    """When header lives outside the scrollable ``table``, match on the whole ``#gridData`` widget."""
    try:
        roots = driver.find_elements(By.XPATH, "//*[@id='gridData']")
    except Exception:
        return None
    for i, root in enumerate(roots):
        try:
            if not root.is_displayed():
                continue
            has_kendo = driver.execute_script(
                """
                var g = arguments[0];
                return !!(g && (
                    g.querySelector('.k-grid-header') ||
                    g.querySelector('.k-grid-content') ||
                    g.classList.contains('k-grid')
                ));
                """,
                root,
            )
            if not has_kendo:
                continue
            blob = _blob_from_element_subtree(driver, root)
            if _looks_like_device_plan_grid(blob):
                xp = _xpath_for_first_visible_table_under_griddata(driver, i)
                if xp:
                    return xp
        except StaleElementReferenceException:
            continue
    return None


def _fallback_any_kendo_griddata_table(driver) -> str | None:
    """Last resort: visible ``#gridData`` with both Kendo header and content — CSR landing main grid."""
    try:
        roots = driver.find_elements(By.XPATH, "//*[@id='gridData']")
    except Exception:
        return None
    for i, root in enumerate(roots):
        try:
            if not root.is_displayed():
                continue
            ok = driver.execute_script(
                """
                var g = arguments[0];
                return !!(g.querySelector('.k-grid-content') && g.querySelector('table'));
                """,
                root,
            )
            if not ok:
                continue
            blob = _blob_from_element_subtree(driver, root)
            # Empty account: few columns; still require some CSR-ish signal
            if not (
                _looks_like_device_plan_grid(blob)
                or ("apn" in blob and "plan" in blob)
                or ("device" in blob and "plan" in blob)
            ):
                continue
            xp = _xpath_for_first_visible_table_under_griddata(driver, i)
            if xp:
                return xp
        except StaleElementReferenceException:
            continue
    return None


def _discover_once(driver) -> str | None:
    try:
        driver.execute_script("window.scrollTo(0, Math.max(0, (document.body.scrollHeight||0) * 0.25));")
    except Exception:
        pass
    _nudge_scroll(driver)
    for group in _TABLE_XPATH_GROUPS:
        xp = _first_matching_indexed_xpath(driver, group)
        if xp:
            return xp
    xp = _fallback_kendo_griddata_table(driver)
    if xp:
        return xp
    xp = _fallback_any_kendo_griddata_table(driver)
    if xp:
        return xp
    return _fallback_kgrid_table_after_csr_form(driver)


def _fallback_kgrid_table_after_csr_form(driver) -> str | None:
    """CSR widget is often above the main grid; grid may not use ``id=gridData`` in some builds."""
    xpath_many = (
        "//div[contains(@class,'selectcsrjourney')]/following::div[contains(@class,'k-grid')][.//table]//table"
    )
    try:
        tables = driver.find_elements(By.XPATH, xpath_many)
    except Exception:
        return None
    for i, t in enumerate(tables):
        try:
            if _accept_table(driver, t):
                return f"({xpath_many})[{i + 1}]"
        except StaleElementReferenceException:
            continue
    return None


class CsrLandingGridFinder:
    @keyword("CSRJ Discover Device Plan Table Locators")
    def csrj_discover_device_plan_table_locators(self, timeout="180", poll="2.0"):
        """Poll until a CSR device-plan grid ``table`` is found, then set
        ``\\${CSRJ_RUN_DEVICE_PLAN_TABLE}`` and ``\\${CSRJ_RUN_DEVICE_PLAN_TBODY}``."""
        builtin = BuiltIn()
        sl = builtin.get_library_instance("SeleniumLibrary")
        driver = sl.driver

        deadline = time.time() + float(timeout)
        poll_s = float(poll)
        last_err: Exception | None = None

        while time.time() < deadline:
            try:
                time.sleep(0.12)
                xp = _discover_once(driver)
                if xp:
                    table_loc = f"xpath={xp}"
                    tbody_loc = f"xpath={xp}//tbody"
                    builtin.set_suite_variable("${CSRJ_RUN_DEVICE_PLAN_TABLE}", table_loc)
                    builtin.set_suite_variable("${CSRJ_RUN_DEVICE_PLAN_TBODY}", tbody_loc)
                    builtin.log(f"CSRJ DOM: device-plan table → {table_loc}", "INFO")
                    return table_loc
            except Exception as e:  # noqa: BLE001
                last_err = e
            time.sleep(poll_s)

        # Debug: log header samples from gridData k-grids (no PII)
        try:
            dbg = driver.execute_script(
                """
                var out = [];
                document.querySelectorAll('#gridData, [id="gridData"]').forEach(function(root){
                  var g = root.classList && root.classList.contains('k-grid') ? root
                    : root.querySelector && root.querySelector('.k-grid');
                  if (!g) g = root;
                  var ths = g.querySelectorAll('th');
                  var t0 = ths.length ? (ths[0].textContent || '').trim().slice(0, 80) : '';
                  out.push('th_count=' + ths.length + ' first_th="' + t0 + '"');
                });
                return out.join(' | ');
                """
            )
            extra = f" Debug gridData scan: {dbg!r}" if dbg else ""
        except Exception as e:  # noqa: BLE001
            extra = f" Debug script failed: {e!r}"

        msg = "CSR Journey landing: no visible device-plan table matched (headers/Kendo .k-grid or CSR grid icons)." + extra
        if last_err:
            msg = f"{msg} Last error: {last_err!r}"
        raise AssertionError(msg)
