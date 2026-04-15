# Rule Engine Tab 2 — debug NDJSON + Data Session Count–style trigger fill.
# #region agent log
import json
import os
import time

from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn

_DEFAULT_DEBUG_LOG = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "debug-7a554c.log"
)
_SESSION = "7a554c"
_DEBUG_LOG_ENV = "STC_DEBUG_SESSION_LOG"


def _debug_log_path() -> str:
    p = (os.environ.get(_DEBUG_LOG_ENV) or "").strip()
    return os.path.abspath(p) if p else _DEFAULT_DEBUG_LOG


def _ndjson(payload: dict) -> None:
    payload.setdefault("sessionId", _SESSION)
    payload.setdefault("timestamp", int(time.time() * 1000))
    path = _debug_log_path()
    try:
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(payload, default=str, ensure_ascii=True) + "\n")
    except OSError:
        pass  # debug log is non-critical; do not propagate


class ReTriggerDebug:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @keyword
    def re_debug_log(self, hypothesis_id, location, message, data_json="${EMPTY}", run_id="pre-fix"):
        """Append one NDJSON line (debug session 7a554c). data_json: Robot ${EMPTY} or JSON string."""
        data = None
        if data_json and str(data_json).strip() and "${EMPTY}" not in str(data_json):
            try:
                data = json.loads(data_json)
            except json.JSONDecodeError:
                data = {"raw": data_json}
        _ndjson(
            {
                "hypothesisId": hypothesis_id,
                "location": location,
                "message": message,
                "runId": run_id,
                "data": data,
            }
        )

    @keyword
    def re_debug_dump_trigger_pane(self, run_id="pre-fix"):
        """Dump all <select> elements under #defineTriggersTab for locator/DOM evidence."""
        try:
            sl = BuiltIn().get_library_instance("SeleniumLibrary")
            driver = sl.driver
            info = driver.execute_script(
                """
                var _t = document.querySelectorAll('div[id="defineTriggersTab"]');
                var pane = _t.length ? _t[_t.length - 1] : null;
                if (!pane) return {error: 'no_pane'};
                var sels = pane.querySelectorAll('select');
                var out = [];
                for (var i = 0; i < sels.length; i++) {
                  var s = sels[i];
                  var lab = '';
                  var p = s;
                  for (var k = 0; k < 8 && p; k++) {
                    var l = p.querySelector && p.querySelector('label');
                    if (l) { lab = (l.textContent || '').trim(); break; }
                    p = p.parentElement;
                  }
                  var opts = [];
                  for (var j = 0; j < Math.min(s.options.length, 10); j++) {
                    opts.push({v: s.options[j].value, t: (s.options[j].text || '').trim()});
                  }
                  out.push({
                    idx: i,
                    testid: s.getAttribute('data-testid') || '',
                    name: s.getAttribute('name') || '',
                    label: lab.substring(0, 120),
                    optionCount: s.options.length,
                    selectedText: s.selectedIndex >= 0 ? (s.options[s.selectedIndex].text || '').trim() : '',
                    sampleOpts: opts
                  });
                }
                function inRuleCatBtn(el) {
                  var p = el;
                  for (var bi = 0; bi < 15 && p; bi++) {
                    var tid = p.getAttribute && p.getAttribute('data-testid');
                    if (tid === 'ruleCategory' || tid === 'in_ruleCategory' || tid === 'selected_rule_category') return true;
                    p = p.parentElement;
                  }
                  return false;
                }
                var allB = pane.querySelectorAll('div[class*="selectBtn"]');
                var cbc = 0;
                var smpl = [];
                for (var bj = 0; bj < allB.length; bj++) {
                  if (inRuleCatBtn(allB[bj])) continue;
                  cbc++;
                  if (smpl.length < 10) {
                    smpl.push((allB[bj].textContent || '').replace(/\\s+/g, ' ').trim().substring(0, 100));
                  }
                }
                return {selectCount: sels.length, selects: out, customBtnCount: cbc, customBtnSample: smpl};
                """
            )
            _ndjson(
                {
                    "hypothesisId": "H_dump",
                    "location": "re_debug_dump_trigger_pane",
                    "message": "defineTriggersTab select snapshot",
                    "runId": run_id,
                    "data": info,
                }
            )
        except Exception:
            pass  # debug dump is non-critical

    @keyword
    def re_fill_session_count_style_trigger_selects(self, run_id="pre-fix"):
        """
        For SIM Lifecycle / Data Session Count style UI: after 'Connected Session', fill
        Parameter, Comparator, Condition, Duration, and Trigger-if selects by choosing the
        first non-placeholder option. Excludes rule category selects.
        """
        try:
            sl = BuiltIn().get_library_instance("SeleniumLibrary")
            driver = sl.driver
            result = driver.execute_script(
                """
                var _t = document.querySelectorAll('div[id="defineTriggersTab"]');
                var pane = _t.length ? _t[_t.length - 1] : null;
                if (!pane) return {ok: false, reason: 'no_pane'};

                function labelNear(el) {
                  var p = el;
                  for (var k = 0; k < 10 && p; k++) {
                    var labels = p.querySelectorAll && p.querySelectorAll('label');
                    if (labels && labels.length) {
                      var t = (labels[0].textContent || '').trim().toLowerCase();
                      if (t) return t;
                    }
                    p = p.parentElement;
                  }
                  return '';
                }

                function isPlaceholderOption(opt) {
                  var t = (opt.text || '').trim().toLowerCase();
                  var v = (opt.value || '').trim();
                  if (!v || v === '0') return true;
                  if (/^select\\s/.test(t)) return true;
                  if (t.indexOf('select parameter') >= 0) return true;
                  if (t.indexOf('select comparator') >= 0) return true;
                  if (t.indexOf('select condition') >= 0) return true;
                  if (t.indexOf('select duration') >= 0) return true;
                  if (t.indexOf('select trigger') >= 0) return true;
                  if (t.indexOf('device plan from') >= 0) return true;
                  if (t.indexOf('device plan to') >= 0) return true;
                  if (t.indexOf('please select') >= 0) return true;
                  return false;
                }

                function pickFirstReal(select) {
                  for (var i = 0; i < select.options.length; i++) {
                    if (!isPlaceholderOption(select.options[i])) {
                      select.selectedIndex = i;
                      select.dispatchEvent(new Event('change', {bubbles: true}));
                      select.dispatchEvent(new Event('input', {bubbles: true}));
                      return (select.options[i].text || '').trim();
                    }
                  }
                  return null;
                }

                var sels = pane.querySelectorAll('select');
                var actions = [];
                for (var i = 0; i < sels.length; i++) {
                  var s = sels[i];
                  if (s.disabled) continue;
                  var tid = (s.getAttribute('data-testid') || '');
                  if (tid === 'ruleCategory' || tid === 'in_ruleCategory' || tid === 'selected_rule_category')
                    continue;
                  var curOpt = s.selectedIndex >= 0 ? s.options[s.selectedIndex] : null;
                  var cur = curOpt ? (curOpt.text || '').trim() : '';
                  var lab = labelNear(s);
                  var looksPlaceholder = curOpt ? isPlaceholderOption(curOpt) : true;
                  var looksOpen = /select parameter|select comparator|select condition|select duration|select trigger|device plan from|device plan to|please select/i.test(cur);
                  var labHints = /parameter|comparator|condition|duration|trigger|device plan/i.test(lab);
                  if (!looksPlaceholder && !looksOpen && !labHints) continue;
                  var picked = pickFirstReal(s);
                  actions.push({
                    idx: i,
                    testid: tid,
                    label: lab.substring(0, 80),
                    was: cur.substring(0, 60),
                    picked: picked
                  });
                }
                /* Fill empty text inputs: Duration Value, Condition Value, etc. */
                var inputs = pane.querySelectorAll('input[type="text"], input[type="number"], input:not([type])');
                var inputActions = [];
                for (var j = 0; j < inputs.length; j++) {
                  var inp = inputs[j];
                  if (inp.disabled || inp.readOnly) continue;
                  if (inp.offsetParent === null) continue;
                  var val = (inp.value || '').trim();
                  var ph = (inp.placeholder || '').toLowerCase();
                  var inpLab = labelNear(inp);
                  var isDuration = ph.indexOf('duration') >= 0 || inpLab.indexOf('duration') >= 0;
                  var isCondition = ph.indexOf('condition') >= 0 || inpLab.indexOf('condition') >= 0;
                  /* Check if there is a validation message nearby indicating max value */
                  var nearbyText = '';
                  var parent = inp.parentElement;
                  for (var pp = 0; pp < 3 && parent; pp++) {
                    nearbyText += ' ' + (parent.textContent || '');
                    parent = parent.parentElement;
                  }
                  var hasDaysLimit = /between 1 and 30|days/i.test(nearbyText);
                  /* Also check if a sibling/nearby select shows DAYS/HOURS */
                  var nearSel = inp.closest && inp.closest('.row, .form-group, div');
                  if (nearSel) {
                    var selects = nearSel.querySelectorAll('select');
                    for (var si = 0; si < selects.length; si++) {
                      var selText = (selects[si].options[selects[si].selectedIndex] || {}).text || '';
                      if (/days/i.test(selText)) hasDaysLimit = true;
                    }
                  }
                  /* Detect HOURS vs DAYS nearby */
                  var hasHoursNear = false, hasDaysNear = false;
                  var nearDiv2 = inp.closest && inp.closest('.row, .form-group, div');
                  if (nearDiv2) {
                    var nss2 = nearDiv2.querySelectorAll('select');
                    for (var si2 = 0; si2 < nss2.length; si2++) {
                      var st2 = nss2[si2].selectedIndex >= 0 ? (nss2[si2].options[nss2[si2].selectedIndex].text||'').toLowerCase() : '';
                      if (/hours/i.test(st2)) hasHoursNear = true;
                      if (/days/i.test(st2)) hasDaysNear = true;
                    }
                  }
                  var hoursCtx = hasHoursNear || /12 to 24/i.test(nearbyText(inp).toLowerCase());
                  function bestFillVal() {
                    if (hoursCtx) return '12';
                    if (hasDaysLimit || hasDaysNear) return '5';
                    if (isDuration) return '12';
                    return '10';
                  }
                  if ((isDuration || isCondition) && !val) {
                    var fillVal = bestFillVal();
                    var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
                    nativeSetter.call(inp, fillVal);
                    inp.dispatchEvent(new Event('input', {bubbles: true}));
                    inp.dispatchEvent(new Event('change', {bubbles: true}));
                    inputActions.push({ idx: j, placeholder: ph.substring(0, 60), filled: fillVal });
                  } else if (val) {
                    var numV = parseInt(val);
                    var needFix = false;
                    if (hoursCtx && (numV < 12 || numV > 24)) needFix = true;
                    if ((hasDaysLimit || hasDaysNear) && numV > 30) needFix = true;
                    if (needFix) {
                      var fixVal = hoursCtx ? '12' : '5';
                      var nativeSetter3 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
                      nativeSetter3.call(inp, fixVal);
                      inp.dispatchEvent(new Event('input', {bubbles: true}));
                      inp.dispatchEvent(new Event('change', {bubbles: true}));
                      inputActions.push({ idx: j, placeholder: ph.substring(0, 60), was: val, fixed: fixVal });
                    }
                  }
                }
                return {ok: true, actions: actions, inputActions: inputActions};
                """
            )
            _ndjson(
                {
                    "hypothesisId": "H_fix",
                    "location": "re_fill_session_count_style_trigger_selects",
                    "message": "filled placeholder trigger selects",
                    "runId": run_id,
                    "data": result,
                }
            )
            return result
        except Exception:
            pass  # fill is best-effort; main Fill All Trigger Fields Via JS handles it

    @keyword
    def re_pane_needs_session_count_trigger_fill(self, run_id="pre-fix"):
        """
        True if the last #defineTriggersTab pane still shows DSC-style placeholders
        on any non–rule-category <select>. Uses strict rules so a lone \"Select Condition\"
        on Country/Operator (single-select Tab 2) does not trigger DSC fill; Connected
        Session keeps Select Parameter / Comparator / Duration (and multi-row Condition).
        """
        try:
            sl = BuiltIn().get_library_instance("SeleniumLibrary")
            driver = sl.driver
            raw = driver.execute_script(
                """
                var _t = document.querySelectorAll('div[id="defineTriggersTab"]');
                var pane = _t.length ? _t[_t.length - 1] : null;
                if (!pane) return {need: false, n: 0, reason: 'no_pane'};
                var sels = pane.querySelectorAll('select');
                var n = sels.length;
                var rePri = /^select\\s+(parameter|comparator|duration)|^device plan (from|to)$|^please select/i;
                var reCond = /^select\\s+condition/i;
                for (var i = 0; i < n; i++) {
                  var s = sels[i];
                  var tid = s.getAttribute('data-testid') || '';
                  if (tid === 'ruleCategory' || tid === 'in_ruleCategory'
                      || tid === 'selected_rule_category') continue;
                  if (s.disabled) continue;
                  if (s.selectedIndex < 0) continue;
                  var cur = (s.options[s.selectedIndex].text || '').trim();
                  if (rePri.test(cur)) {
                    return {need: true, n: n, reason: 'pri', idx: i,
                            cur: cur.substring(0, 80)};
                  }
                  if (reCond.test(cur) && n >= 3) {
                    return {need: true, n: n, reason: 'cond_multi', idx: i,
                            cur: cur.substring(0, 80)};
                  }
                }
                return {need: false, n: n, reason: 'none'};
                """
            )
            need = bool(raw.get("need")) if isinstance(raw, dict) else bool(raw)
            # #region agent log
            _ndjson(
                {
                    "hypothesisId": "H_dsc_layout",
                    "location": "re_pane_needs_session_count_trigger_fill",
                    "message": "placeholder_scan",
                    "runId": run_id,
                    "data": raw if isinstance(raw, dict) else {"need": need, "raw": raw},
                }
            )
            # #endregion
            return need
        except Exception:
            # #region agent log
            _ndjson(
                {
                    "hypothesisId": "H_dsc_layout",
                    "location": "re_pane_needs_session_count_trigger_fill",
                    "message": "error",
                    "runId": run_id,
                    "data": {"error": "suppressed"},
                }
            )
            # #endregion
            return False
