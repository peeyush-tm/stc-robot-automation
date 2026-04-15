# Rule Engine Tab 2 — visible-pane Rule Category (custom dropdown).
import json
import os
import time

from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn

_DEBUG_LOG_DEFAULT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "debug-7a554c.log"
)
_SESSION = "7a554c"
_DEBUG_LOG_ENV = "STC_DEBUG_SESSION_LOG"


def _debug_log_path() -> str:
    p = (os.environ.get(_DEBUG_LOG_ENV) or "").strip()
    return os.path.abspath(p) if p else _DEBUG_LOG_DEFAULT


def _locator_is_rule_engine_rule_category(locator) -> bool:
    """True if locator string is the Rule Engine Tab2 Rule Category custom button xpath."""
    s = str(locator)
    if "defineTriggersTab" not in s:
        return False
    return any(
        m in s for m in ("ruleCategory", "in_ruleCategory", "selected_rule_category")
    )


def _dbg(message: str, data: dict) -> None:
    # #region agent log
    try:
        payload = {
            "sessionId": _SESSION,
            "hypothesisId": "H_re_tab2",
            "location": "RuleEngineTab2",
            "message": message,
            "data": data,
            "timestamp": int(time.time() * 1000),
        }
        path = _debug_log_path()
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(payload, default=str) + "\n")
    except OSError as e:
        logger.warn("debug session log not writable (%s): %s" % (_debug_log_path(), e))
    # #endregion


_JS_HELPERS = """
function findBtnInRoot(root) {
  var roots = root.querySelectorAll(
    '[data-testid="ruleCategory"],[data-testid="in_ruleCategory"],[data-testid="selected_rule_category"]'
  );
  for (var r = 0; r < roots.length; r++) {
    var btn = roots[r].querySelector('div[class*="selectBtn"]');
    if (btn) return btn;
  }
  var labs = root.querySelectorAll('label');
  for (var i = 0; i < labs.length; i++) {
    if ((labs[i].textContent || '').indexOf('Rule Category') < 0) continue;
    var cur = labs[i];
    for (var k = 0; k < 12 && cur; k++) {
      var b = cur.querySelector && cur.querySelector('div[class*="selectBtn"]');
      if (b) return b;
      cur = cur.parentElement;
    }
  }
  return null;
}
function findAnyVisibleRuleCategoryBtnGlobal() {
  var roots = document.querySelectorAll(
    '[data-testid="ruleCategory"],[data-testid="in_ruleCategory"],[data-testid="selected_rule_category"]'
  );
  for (var i = roots.length - 1; i >= 0; i--) {
    var btn = roots[i].querySelector('div[class*="selectBtn"]');
    if (btn && btn.offsetParent !== null) return btn;
  }
  return null;
}
"""

_VISIBLE_BTN_CHECK = (
    _JS_HELPERS
    + """
var nodes = document.querySelectorAll('[id="defineTriggersTab"]');
for (var i = nodes.length - 1; i >= 0; i--) {
  var root = nodes[i];
  var tag = (root.tagName || '').toUpperCase();
  if (tag === 'A' || tag === 'BUTTON' || tag === 'INPUT') continue;
  var st = window.getComputedStyle(root);
  if (st.display === 'none') continue;
  if (parseFloat(st.opacity || '1') < 0.05) continue;
  var rect = root.getBoundingClientRect();
  if (rect.width < 2 && rect.height < 2) continue;
  var btn = findBtnInRoot(root);
  if (btn && btn.offsetParent !== null) return {ok: true, mode: 'pane', idx: i, tag: tag};
}
var g = findAnyVisibleRuleCategoryBtnGlobal();
if (g) return {ok: true, mode: 'global'};
return {ok: false, mode: 'none', paneCount: nodes.length};
"""
)

_VISIBLE_BTN_CLICK = (
    _JS_HELPERS
    + """
var nodes = document.querySelectorAll('[id="defineTriggersTab"]');
for (var i = nodes.length - 1; i >= 0; i--) {
  var root = nodes[i];
  var tag = (root.tagName || '').toUpperCase();
  if (tag === 'A' || tag === 'BUTTON' || tag === 'INPUT') continue;
  var st = window.getComputedStyle(root);
  if (st.display === 'none') continue;
  if (parseFloat(st.opacity || '1') < 0.05) continue;
  var rect = root.getBoundingClientRect();
  if (rect.width < 2 && rect.height < 2) continue;
  var btn = findBtnInRoot(root);
  if (btn && btn.offsetParent !== null) {
    btn.click();
    return {ok: true, mode: 'pane', idx: i};
  }
}
var g = findAnyVisibleRuleCategoryBtnGlobal();
if (g) {
  g.click();
  return {ok: true, mode: 'global'};
}
return {ok: false, mode: 'none', paneCount: nodes.length};
"""
)


def _timeout_sec(timeout) -> float:
    if isinstance(timeout, (int, float)):
        return float(timeout)
    t = str(timeout).strip().lower().replace(" ", "")
    if t.endswith("s"):
        t = t[:-1]
    try:
        return float(t)
    except ValueError:
        return 5.0


class RuleEngineTab2:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @keyword("Element Visible After Poll")
    def element_visible_after_poll(self, locator, timeout="5s") -> bool:
        """
        Polls for a visible element without using Wait Until Element Is Visible (avoids FAIL lines
        in output.xml when used from RE Rule Category Control Visible / native-vs-custom detection).
        """
        sl = BuiltIn().get_library_instance("SeleniumLibrary")
        deadline = time.time() + _timeout_sec(timeout)
        head = str(locator)[:140]
        while time.time() < deadline:
            try:
                el = sl.find_element(locator)
                if el.is_displayed():
                    _dbg("element_visible_after_poll", {"ok": True, "locator_head": head})
                    return True
            except Exception:
                pass
            time.sleep(0.2)
        _dbg("element_visible_after_poll", {"ok": False, "locator_head": head})
        return False

    @keyword("Locator Is Rule Engine Rule Category")
    def locator_is_rule_engine_rule_category(self, locator) -> bool:
        ok = _locator_is_rule_engine_rule_category(locator)
        _dbg(
            "locator_is_rule_engine_rule_category",
            {"ok": ok, "locator_head": str(locator)[:160]},
        )
        return ok

    @keyword("Visible Rule Category Select Button Present")
    def visible_rule_category_select_button_present(self) -> bool:
        sl = BuiltIn().get_library_instance("SeleniumLibrary")
        r = sl.driver.execute_script(_VISIBLE_BTN_CHECK)
        _dbg("visible_rule_category_select_button_present", r if isinstance(r, dict) else {"raw": r})
        if isinstance(r, dict):
            return bool(r.get("ok"))
        return bool(r)

    @keyword("Click Visible Rule Category Select Button")
    def click_visible_rule_category_select_button(self) -> bool:
        sl = BuiltIn().get_library_instance("SeleniumLibrary")
        r = sl.driver.execute_script(_VISIBLE_BTN_CLICK)
        _dbg("click_visible_rule_category_select_button", r if isinstance(r, dict) else {"raw": r})
        if isinstance(r, dict) and r.get("ok"):
            return True
        raise AssertionError(
            "No visible Rule Category selectBtn (pane scan + global fallback failed). "
            f"Detail: {r!r}"
        )
