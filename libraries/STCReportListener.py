"""
STC Automation – Robot Framework Listener v2
============================================
Hooks into every test run to:
  1. Create a  {module_name}/  subdirectory inside the report folder for
     each suite/module that executes.
  2. Rename every Capture Page Screenshot call from the default
     "selenium-screenshot-N.png" to:
         {TC_ID}_step_{N:02d}_{description}.png
     where description is derived from keyword args ("FAIL" / "PASS" for
     teardown captures, or the explicit name passed to Capture Step Screenshot).
  3. Move the renamed PNG into the module subdirectory.
  4. Append test metadata (status, tags, doc, elapsed, screenshot paths) to
     stc_test_data.json inside the report folder.  The PDF generator reads
     this file after the run.

Environment variable consumed:
    STC_REPORT_FOLDER   – absolute path to the timestamped report folder.
    Set automatically by run_tests.py; also propagated to every robot subprocess.

Registered via:
    --listener  libraries/STCReportListener.py
  (no colon-separated arg – the env-var avoids Windows drive-letter colon clash)
"""

import glob
import json
import os
import re
import shutil


class STCReportListener:
    """Robot Framework Listener API v2."""

    ROBOT_LISTENER_API_VERSION = 2

    # ── init ─────────────────────────────────────────────────────────────────

    def __init__(self):
        self._report_folder = os.environ.get("STC_REPORT_FOLDER", "").strip()
        if not self._report_folder:
            # fall back to cwd so the listener is harmless even without the env-var
            self._report_folder = os.getcwd()
        self._report_folder = os.path.abspath(self._report_folder)

        # current-run state
        self._suite_name: str = ""
        self._module_name: str = ""
        self._test_name: str = ""
        self._tc_id: str = ""
        self._ss_counter: int = 0        # screenshot counter within the current test
        self._module_dir: str = ""

        # keyword call stack (lowercase names) for parent-context detection
        self._kw_stack: list = []

        # snapshot of PNGs taken just before each Capture call
        self._pre_ss_files: set = set()

        # immutable baseline at the start of each test (used for straggler sweep)
        self._test_baseline_pngs: set = set()

        # per-test accumulated screenshot paths
        self._current_ss: list = []

        # all tests across the entire run (written to JSON on close)
        self._all_tests: list = []

    # ── name / path helpers ──────────────────────────────────────────────────

    @staticmethod
    def _suite_to_module(suite_name: str) -> str:
        """
        Convert a suite name to a tidy folder name.
        'Ip Pool Tests' → 'IP_Pool'
        'Login Tests'   → 'Login'
        """
        name = re.sub(r"\s+[Tt]ests?\b", "", suite_name).strip()
        name = re.sub(r"[\s_]+", "_", name)
        return name or "Unknown"

    @staticmethod
    def _extract_tc_id(test_name: str) -> str:
        """Pull 'TC_IPP_001' out of 'TC_IPP_001 E2E Create …' (or make a safe slug)."""
        m = re.match(r"^(TC_[A-Z0-9]+_\d+)", test_name)
        if m:
            return m.group(1)
        return re.sub(r"\W+", "_", test_name[:20]).strip("_")

    @staticmethod
    def _safe_filename(s: str, maxlen: int = 45) -> str:
        s = str(s).replace(".png", "").replace(".PNG", "")
        s = re.sub(r"[^\w\s\-]", "", s)
        s = re.sub(r"[\s_]+", "_", s.strip())
        return (s[:maxlen].strip("_")) or "screenshot"

    # ── PNG detection helpers ─────────────────────────────────────────────────

    def _snapshot_pngs(self) -> set:
        return set(glob.glob(os.path.join(self._report_folder, "*.png")))

    def _new_pngs(self) -> list:
        """Return PNGs that appeared after the last snapshot, sorted by mtime."""
        current = self._snapshot_pngs()
        return sorted(
            current - self._pre_ss_files,
            key=lambda p: os.path.getmtime(p),
        )

    # ── listener events ──────────────────────────────────────────────────────

    def start_suite(self, name, attrs):  # noqa: D401
        self._suite_name = name
        self._module_name = self._suite_to_module(name)

    def start_test(self, name, attrs):
        self._test_name = name
        self._tc_id = self._extract_tc_id(name)
        self._ss_counter = 0
        self._kw_stack = []
        self._current_ss = []

        if self._module_name:
            self._module_dir = os.path.join(self._report_folder, self._module_name)
            os.makedirs(self._module_dir, exist_ok=True)
        else:
            self._module_dir = self._report_folder

        # baseline snapshot (excludes PNGs already present from earlier tests)
        self._pre_ss_files = self._snapshot_pngs()
        # immutable copy — never mutated — used in end_test straggler sweep
        self._test_baseline_pngs = set(self._pre_ss_files)

    def start_keyword(self, name, attrs):
        kw_lower = (name or "").lower()
        self._kw_stack.append(kw_lower)

        # Snapshot PNGs just before each capture so we know exactly which new
        # file was created by this specific call.
        if "capture page screenshot" in kw_lower:
            self._ss_counter += 1
            self._pre_ss_files = self._snapshot_pngs()

    def end_keyword(self, name, attrs):
        kw_lower = (name or "").lower()
        is_capture = "capture page screenshot" in kw_lower

        if is_capture and self._module_dir:
            # Determine a human-readable description for the filename.
            parent = self._kw_stack[-2] if len(self._kw_stack) >= 2 else ""
            args = attrs.get("args", [])

            if "run keyword if test failed" in parent:
                desc = "FAIL"
            elif "run keyword if test passed" in parent:
                desc = "PASS"
            elif args and args[0]:
                raw = str(args[0])
                # Skip the default Selenium auto-name pattern
                if re.match(r"^selenium-screenshot-\d+\.png$", raw, re.I):
                    desc = "step"
                else:
                    desc = self._safe_filename(raw)
            else:
                desc = "step"

            for src in self._new_pngs():
                fn = f"{self._tc_id}_step_{self._ss_counter:02d}_{desc}.png"
                dst = os.path.join(self._module_dir, fn)
                # Prevent overwrite by appending a counter suffix
                n = 1
                while os.path.exists(dst):
                    fn = f"{self._tc_id}_step_{self._ss_counter:02d}_{desc}_{n}.png"
                    dst = os.path.join(self._module_dir, fn)
                    n += 1
                try:
                    shutil.move(src, dst)
                    self._current_ss.append(dst)
                    # Update baseline so subsequent calls don't re-detect this file
                    self._pre_ss_files.discard(src)
                    self._pre_ss_files.add(dst)
                except OSError:
                    # If move fails keep original path so PDF can still reference it
                    self._current_ss.append(src)

        # Pop after processing (so parent is still visible during this callback)
        if self._kw_stack:
            self._kw_stack.pop()

    def end_test(self, name, attrs):
        # ── Straggler sweep ──────────────────────────────────────────────────
        # SeleniumLibrary's built-in screenshot_on_failure (and any other
        # internal capture) creates PNGs in the root report folder without
        # triggering the listener's start/end_keyword hooks.  Catch them here
        # and move them into the module subfolder so nothing stays at root.
        if self._module_dir:
            remaining = sorted(
                set(self._snapshot_pngs()) - self._test_baseline_pngs,
                key=lambda p: os.path.getmtime(p),
            )
            status = attrs.get("status", "UNKNOWN")
            desc = "FAIL" if status == "FAIL" else "PASS"
            for src in remaining:
                self._ss_counter += 1
                fn = f"{self._tc_id}_step_{self._ss_counter:02d}_{desc}.png"
                dst = os.path.join(self._module_dir, fn)
                n = 1
                while os.path.exists(dst):
                    fn = f"{self._tc_id}_step_{self._ss_counter:02d}_{desc}_{n}.png"
                    dst = os.path.join(self._module_dir, fn)
                    n += 1
                try:
                    shutil.move(src, dst)
                    self._current_ss.append(dst)
                except OSError:
                    self._current_ss.append(src)

        self._all_tests.append(
            {
                "name": name,
                "id": self._tc_id,
                "suite": self._suite_name,
                "module": self._module_name,
                "status": attrs.get("status", "UNKNOWN"),
                "message": attrs.get("message", ""),
                "tags": list(attrs.get("tags", [])),
                "elapsed_ms": attrs.get("elapsedtime", 0),
                "doc": attrs.get("doc", ""),
                "screenshots": list(self._current_ss),
            }
        )
        self._current_ss = []

    def close(self):
        """Append this run's test data to stc_test_data.json."""
        path = os.path.join(self._report_folder, "stc_test_data.json")
        existing: list = []
        if os.path.isfile(path):
            try:
                with open(path, "r", encoding="utf-8") as fh:
                    existing = json.load(fh)
                if not isinstance(existing, list):
                    existing = []
            except (OSError, json.JSONDecodeError):
                existing = []

        combined = existing + self._all_tests
        try:
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(combined, fh, indent=2, ensure_ascii=False)
        except OSError as exc:
            print(f"  WARNING [STCReportListener]: could not write {path}: {exc}")
