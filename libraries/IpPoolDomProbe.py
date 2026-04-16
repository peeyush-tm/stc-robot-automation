"""Capture Create IP Pool account / react-select / menu DOM for locator debugging."""

from __future__ import annotations

import json
import os

from robot.libraries.BuiltIn import BuiltIn


class IpPoolDomProbe:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    _JS = r"""
    return (function(){
      function summarize(el) {
        if (!el) return null;
        var cls = (el.className && String(el.className)) || '';
        var tid = el.getAttribute('data-testid') || '';
        var nid = el.id || '';
        var tag = el.tagName || '';
        var role = el.getAttribute('role') || '';
        var txt = (el.textContent || '').trim().substring(0, 100);
        return {
          tag: tag,
          id: nid,
          role: role,
          dataTestId: tid,
          class: cls.length > 160 ? cls.substring(0, 160) + '...' : cls,
          textSample: txt
        };
      }
      var out = { url: window.location.href, title: document.title };
      out.reactSelectMenus = [];
      document.querySelectorAll(
        '[class*="react-select__menu"],[class*="select__menu"],[class*="MenuList"],[class*="menu_list"]'
      ).forEach(function(m, i){ if (i < 12) out.reactSelectMenus.push(summarize(m)); });
      out.options = [];
      document.querySelectorAll(
        '[class*="react-select__option"],[class*="select__option"],div[role="option"],li[role="option"]'
      ).forEach(function(o, i){ if (i < 40) out.options.push(summarize(o)); });
      out.accountHints = [];
      document.querySelectorAll(
        '[data-testid*="account"],[data-testid*="Account"],label[for="accountId"],input[name="accountId"],input[name="accountSelected"],select[name="accountId"]'
      ).forEach(function(a, i){ if (i < 20) out.accountHints.push(summarize(a)); });
      out.treeHints = [];
      document.querySelectorAll(
        '.k-treeview .k-in, ul.treeview span, li.k-item .k-in, [class*="treeview"]'
      ).forEach(function(t, i){ if (i < 25) out.treeHints.push(summarize(t)); });
      out.treeItemChildren = [];
      var kItem = document.querySelector('li.k-item.k-treeview-item');
      if (kItem) {
        var kids = kItem.querySelectorAll('*');
        for (var ki=0; ki<kids.length && ki<30; ki++) {
          out.treeItemChildren.push(summarize(kids[ki]));
        }
        out.kItemInnerHTML = kItem.innerHTML.substring(0, 2000);
      }
      out.bodyDirectDivsMenuLike = [];
      document.querySelectorAll('body > div').forEach(function(d){
        var c = (d.className && String(d.className)) || '';
        if (c.indexOf('menu') >= 0 || c.indexOf('Menu') >= 0 || c.indexOf('portal') >= 0 ||
            c.indexOf('popup') >= 0 || c.indexOf('select') >= 0) {
          if (out.bodyDirectDivsMenuLike.length < 15) out.bodyDirectDivsMenuLike.push(summarize(d));
        }
      });
      return out;
    })();
    """

    def ip_pool_log_account_dom_probe(self, label="snapshot"):
        """Run in browser; log JSON to console and write ``ip_pool_dom_probe_<label>.json`` under ``${OUTPUTDIR}``."""
        builtin = BuiltIn()
        sl = builtin.get_library_instance("SeleniumLibrary")
        data = sl.driver.execute_script(self._JS)
        text = json.dumps(data, indent=2, default=str)
        safe = "".join(c if c.isalnum() or c in "-_" else "_" for c in str(label))[:80]
        outdir = builtin.get_variable_value("${OUTPUTDIR}") or os.getcwd()
        ip_pool_dir = os.path.join(str(outdir), "Ip_Pool")
        os.makedirs(ip_pool_dir, exist_ok=True)
        path = os.path.join(ip_pool_dir, "ip_pool_dom_probe_%s.json" % safe)
        parent = os.path.dirname(path)
        if parent:
            os.makedirs(parent, exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        builtin.log("IP Pool DOM probe [%s] → %s\n%s" % (label, path, text), console=True)
