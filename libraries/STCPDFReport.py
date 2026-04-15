"""
STC Automation – PDF Report Generator
======================================
Generates a professional PDF execution report from a completed test run.

Inputs (all inside report_folder):
  combined_output.xml   – merged Robot Framework XML (produced by rebot)
  stc_test_data.json    – screenshot paths + metadata from STCReportListener
  {Module}/             – per-module screenshot PNG files

Output:
  execution_report.pdf  (inside report_folder)

Usage (called automatically by run_tests.py, or standalone):
  python libraries/STCPDFReport.py <report_folder> [--env ENV]
"""

from __future__ import annotations

import json
import math
import os
import re
import sys
from collections import OrderedDict
from datetime import datetime, timedelta
from typing import Dict, List, Optional

# ── ReportLab ────────────────────────────────────────────────────────────────
try:
    from reportlab.lib import colors
    from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
    from reportlab.lib.units import cm, mm
    from reportlab.lib.utils import ImageReader
    from reportlab.platypus import (
        HRFlowable,
        Image,
        KeepTogether,
        PageBreak,
        Paragraph,
        SimpleDocTemplate,
        Spacer,
        Table,
        TableStyle,
    )

    HAS_REPORTLAB = True
except ImportError:
    HAS_REPORTLAB = False

# ── Robot Framework result API ───────────────────────────────────────────────
try:
    from robot.api import ExecutionResult

    HAS_ROBOT_API = True
except ImportError:
    HAS_ROBOT_API = False

# ─────────────────────────────────────────────────────────────────────────────
#  Colour palette
# ─────────────────────────────────────────────────────────────────────────────
C_NAVY     = colors.HexColor("#1A3A5C")   # header / cover background
C_BLUE     = colors.HexColor("#2E86AB")   # module banner
C_PASS     = colors.HexColor("#27AE60")   # PASS green
C_FAIL     = colors.HexColor("#E74C3C")   # FAIL red
C_LIGHT    = colors.HexColor("#F4F6F8")   # alternating row background
C_BORDER   = colors.HexColor("#BDC3C7")   # table border
C_TEXT     = colors.HexColor("#2C3E50")   # body text
C_SUBTEXT  = colors.HexColor("#7F8C8D")   # secondary text
C_WHITE    = colors.white
C_GOLD     = colors.HexColor("#F39C12")   # accent

PAGE_W, PAGE_H = A4
MARGIN = 2 * cm
CONTENT_W = PAGE_W - 2 * MARGIN          # ~170 mm

# ─────────────────────────────────────────────────────────────────────────────
#  Paragraph styles
# ─────────────────────────────────────────────────────────────────────────────

def _build_styles() -> dict:
    base = getSampleStyleSheet()

    def s(name, **kw) -> ParagraphStyle:
        return ParagraphStyle(name, **kw)

    return {
        "cover_title": s(
            "cover_title",
            fontName="Helvetica-Bold",
            fontSize=30,
            textColor=C_WHITE,
            alignment=TA_CENTER,
            spaceAfter=6,
        ),
        "cover_sub": s(
            "cover_sub",
            fontName="Helvetica",
            fontSize=13,
            textColor=C_GOLD,
            alignment=TA_CENTER,
            spaceAfter=4,
        ),
        "cover_info": s(
            "cover_info",
            fontName="Helvetica",
            fontSize=10,
            textColor=C_WHITE,
            alignment=TA_CENTER,
            spaceAfter=3,
        ),
        "section_heading": s(
            "section_heading",
            fontName="Helvetica-Bold",
            fontSize=11,
            textColor=C_NAVY,
            spaceBefore=14,
            spaceAfter=4,
        ),
        "module_label": s(
            "module_label",
            fontName="Helvetica-Bold",
            fontSize=12,
            textColor=C_WHITE,
            leftIndent=6,
        ),
        "tc_id": s(
            "tc_id",
            fontName="Helvetica-Bold",
            fontSize=9,
            textColor=C_NAVY,
        ),
        "tc_name": s(
            "tc_name",
            fontName="Helvetica-Bold",
            fontSize=9,
            textColor=C_TEXT,
        ),
        "tc_doc": s(
            "tc_doc",
            fontName="Helvetica-Oblique",
            fontSize=8,
            textColor=C_SUBTEXT,
            spaceAfter=2,
        ),
        "tc_tags": s(
            "tc_tags",
            fontName="Helvetica",
            fontSize=8,
            textColor=C_SUBTEXT,
        ),
        "ss_caption": s(
            "ss_caption",
            fontName="Helvetica-Oblique",
            fontSize=7.5,
            textColor=C_SUBTEXT,
            alignment=TA_CENTER,
            spaceAfter=4,
        ),
        "body": s(
            "body",
            fontName="Helvetica",
            fontSize=9,
            textColor=C_TEXT,
            spaceAfter=2,
        ),
        "footer": s(
            "footer",
            fontName="Helvetica",
            fontSize=7.5,
            textColor=C_SUBTEXT,
        ),
    }


# ─────────────────────────────────────────────────────────────────────────────
#  Page template callbacks
# ─────────────────────────────────────────────────────────────────────────────

_GEN_TS = datetime.now().strftime("%Y-%m-%d %H:%M")


def _draw_page_chrome(canvas, doc):
    """Draw header rule + footer on every page except the cover (page 1)."""
    if doc.page == 1:
        return
    canvas.saveState()
    # top rule
    canvas.setStrokeColor(C_BLUE)
    canvas.setLineWidth(0.8)
    canvas.line(MARGIN, PAGE_H - MARGIN + 4 * mm, PAGE_W - MARGIN, PAGE_H - MARGIN + 4 * mm)
    # footer rule
    canvas.line(MARGIN, MARGIN - 4 * mm, PAGE_W - MARGIN, MARGIN - 4 * mm)
    # footer text
    canvas.setFont("Helvetica", 7.5)
    canvas.setFillColor(C_SUBTEXT)
    canvas.drawString(MARGIN, MARGIN - 9 * mm, f"STC Automation Execution Report  |  Generated: {_GEN_TS}")
    canvas.drawRightString(
        PAGE_W - MARGIN,
        MARGIN - 9 * mm,
        f"Page {doc.page}",
    )
    canvas.restoreState()


# ─────────────────────────────────────────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────────────────────────────────────────

def _ms_to_str(ms: int) -> str:
    if ms < 1000:
        return f"{ms} ms"
    secs = ms / 1000
    if secs < 60:
        return f"{secs:.2f} s"
    m, s = divmod(int(secs), 60)
    return f"{m}m {s:02d}s"


def _make_image(path: str, max_w: float, max_h: float = 9 * cm) -> Optional[Image]:
    """Return a scaled ReportLab Image, capped at max_w and max_h."""
    if not path or not os.path.isfile(path):
        return None
    try:
        reader = ImageReader(path)
        img_w, img_h = reader.getSize()
        if img_w == 0:
            return None
        ratio = img_h / img_w
        w = min(max_w, img_w)
        h = w * ratio
        if h > max_h:
            h = max_h
            w = h / ratio
        return Image(path, width=w, height=h)
    except Exception:
        return None


def _status_color(status: str):
    return C_PASS if status.upper() == "PASS" else C_FAIL


def _status_label(status: str) -> str:
    return "✓  PASS" if status.upper() == "PASS" else "✗  FAIL"


def _clean_name(full_name: str, tc_id: str) -> str:
    """Strip leading TC_ID prefix from the display name."""
    if tc_id and full_name.startswith(tc_id):
        return full_name[len(tc_id):].strip()
    return full_name


def _caption_from_path(path: str) -> str:
    """'TC_IPP_001_step_02_FAIL.png' → 'Step 02 – FAIL'"""
    fn = os.path.splitext(os.path.basename(path))[0]
    # strip leading TC_ID prefix
    fn = re.sub(r"^TC_[A-Z0-9]+_\d+_", "", fn)
    # 'step_02_FAIL' → 'Step 02 – FAIL'
    fn = re.sub(r"^step_(\d+)_?", r"Step \1 – ", fn, flags=re.I)
    fn = fn.replace("_", " ").strip(" –")
    return fn or os.path.basename(path)


def _resolve_screenshots(test: dict, report_folder: str) -> list:
    """
    Return valid screenshot paths for a test.
    Primary:  paths from stc_test_data.json (already absolute, checked for existence).
    Fallback: glob the module subfolder for any {TC_ID}_*.png files, sorted by name.
    This ensures screenshots always appear in the PDF even if JSON metadata is stale.
    """
    import glob as _glob

    paths = [p for p in test.get("screenshots", []) if p and os.path.isfile(p)]
    if paths:
        return paths

    # Fallback: scan module folder
    module = test.get("module", "")
    tc_id  = test.get("id", "")
    if module and tc_id:
        module_dir = os.path.join(report_folder, module)
        if os.path.isdir(module_dir):
            found = sorted(_glob.glob(os.path.join(module_dir, f"{tc_id}_*.png")))
            if found:
                return found

    return []


def _ss_status_color(path: str):
    """Return FAIL red or PASS green based on filename keyword."""
    upper = os.path.basename(path).upper()
    if "FAIL" in upper:
        return C_FAIL
    return C_PASS


def _build_screenshot_grid(screenshots: list, styles: dict) -> list:
    """
    Render screenshots in a 2-per-row grid.
    Each cell has a colored border (red=FAIL, green=PASS) and a caption below.
    """
    elems: list = []
    col_w = (CONTENT_W - 0.6 * cm) / 2   # 2 columns with gutter
    max_h = 8 * cm

    for i in range(0, len(screenshots), 2):
        pair = screenshots[i:i + 2]
        img_row = []
        cap_row = []
        style_cmds = [
            ("ALIGN",         (0, 0), (-1, -1), "CENTER"),
            ("VALIGN",        (0, 0), (-1, 0),  "BOTTOM"),
            ("VALIGN",        (0, 1), (-1, 1),  "TOP"),
            ("TOPPADDING",    (0, 0), (-1, -1), 4),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ("LEFTPADDING",   (0, 0), (-1, -1), 4),
            ("RIGHTPADDING",  (0, 0), (-1, -1), 4),
        ]

        for col_idx, path in enumerate(pair):
            caption    = _caption_from_path(path)
            border_clr = _ss_status_color(path)
            is_fail    = border_clr == C_FAIL
            dot_color  = "#E74C3C" if is_fail else "#27AE60"

            img = _make_image(path, col_w - 0.4 * cm, max_h)
            img_row.append(img if img else Paragraph(
                f'[{os.path.basename(path)}]', styles["ss_caption"]
            ))
            cap_row.append(Paragraph(
                f'<font color="{dot_color}"><b>{"✗" if is_fail else "✓"}</b></font>'
                f'  {caption}',
                styles["ss_caption"],
            ))
            # colored border around image cell
            style_cmds.append(("BOX", (col_idx, 0), (col_idx, 0), 1.5, border_clr))

        # pad odd screenshot count
        while len(img_row) < 2:
            img_row.append("")
            cap_row.append("")

        tbl = Table([img_row, cap_row], colWidths=[col_w, col_w])
        tbl.setStyle(TableStyle(style_cmds))
        elems.append(tbl)
        elems.append(Spacer(1, 0.2 * cm))

    return elems


# ─────────────────────────────────────────────────────────────────────────────
#  Data loading
# ─────────────────────────────────────────────────────────────────────────────

def _load_json_data(report_folder: str) -> Dict[str, dict]:
    """Return dict keyed by test name → metadata dict from stc_test_data.json."""
    path = os.path.join(report_folder, "stc_test_data.json")
    if not os.path.isfile(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data: list = json.load(fh)
        return {item["name"]: item for item in data if isinstance(item, dict)}
    except Exception:
        return {}


def _find_xml(report_folder: str) -> Optional[str]:
    """Prefer combined_output.xml; fall back to the first output_N_*.xml found."""
    combined = os.path.join(report_folder, "combined_output.xml")
    if os.path.isfile(combined):
        return combined
    import glob as _glob
    candidates = sorted(_glob.glob(os.path.join(report_folder, "output_*.xml")))
    return candidates[0] if candidates else None


def _parse_xml(xml_path: str) -> Optional[object]:
    if not HAS_ROBOT_API:
        return None
    try:
        return ExecutionResult(xml_path)
    except Exception:
        return None


# ─────────────────────────────────────────────────────────────────────────────
#  Build the ordered module → [test_record] map
# ─────────────────────────────────────────────────────────────────────────────

def _collect_tests(rf_result, json_map: dict) -> "OrderedDict[str, list]":
    """
    Walk the RF result tree; merge screenshot data from json_map.
    Returns OrderedDict: module_name → [test_record, ...]
    """
    modules: OrderedDict = OrderedDict()

    def _elapsed_ms(test) -> int:
        try:
            td = test.elapsed_time
            if isinstance(td, timedelta):
                return int(td.total_seconds() * 1000)
            return int(float(td))
        except Exception:
            return 0

    def _visit(suite):
        for child in suite.suites:
            _visit(child)
        for test in suite.tests:
            name = test.name
            j = json_map.get(name, {})
            module = j.get("module") or _suite_to_module_simple(suite.name)
            tc_id = j.get("id") or _extract_tc_id_simple(name)
            record = {
                "id": tc_id,
                "name": name,
                "display_name": _clean_name(name, tc_id),
                "suite": suite.name,
                "module": module,
                "status": test.status,
                "message": test.message or "",
                "tags": [str(t) for t in test.tags],
                "elapsed_ms": j.get("elapsed_ms") or _elapsed_ms(test),
                "doc": (test.doc or j.get("doc", "")).strip(),
                "screenshots": j.get("screenshots", []),
            }
            modules.setdefault(module, []).append(record)

    if rf_result:
        _visit(rf_result.suite)

    # If RF parse failed but we have JSON data, fall back to JSON alone
    if not modules and json_map:
        for name, j in json_map.items():
            module = j.get("module", "Unknown")
            tc_id = j.get("id", _extract_tc_id_simple(name))
            record = {
                "id": tc_id,
                "name": name,
                "display_name": _clean_name(name, tc_id),
                "suite": j.get("suite", ""),
                "module": module,
                "status": j.get("status", "UNKNOWN"),
                "message": j.get("message", ""),
                "tags": j.get("tags", []),
                "elapsed_ms": j.get("elapsed_ms", 0),
                "doc": j.get("doc", ""),
                "screenshots": j.get("screenshots", []),
            }
            modules.setdefault(module, []).append(record)

    return modules


def _suite_to_module_simple(suite_name: str) -> str:
    name = re.sub(r"\s+[Tt]ests?\b", "", suite_name).strip()
    return re.sub(r"[\s_]+", "_", name) or "Unknown"


def _extract_tc_id_simple(test_name: str) -> str:
    m = re.match(r"^(TC_[A-Z0-9]+_\d+)", test_name)
    return m.group(1) if m else re.sub(r"\W+", "_", test_name[:20]).strip("_")


# ─────────────────────────────────────────────────────────────────────────────
#  Flowable builders
# ─────────────────────────────────────────────────────────────────────────────

def _build_cover(styles: dict, env: str, modules: dict, run_ts: str,
                  title: str = "STC AUTOMATION", total_elapsed_ms: int = 0) -> list:
    """Cover page flowables."""
    total = sum(len(v) for v in modules.values())
    passed = sum(1 for tests in modules.values() for t in tests if t["status"] == "PASS")
    failed = total - passed
    pass_rate = f"{passed / total * 100:.1f}%" if total else "—"

    elems = []

    # ── full-width navy background rectangle drawn via canvas trick ──
    # We use a 1-row table as background panel
    cover_data = [[Paragraph(title.upper(), styles["cover_title"])]]
    cover_tbl = Table(cover_data, colWidths=[CONTENT_W])
    cover_tbl.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), C_NAVY),
                ("TOPPADDING", (0, 0), (-1, -1), 30),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    elems.append(Spacer(1, 2 * cm))
    elems.append(cover_tbl)

    # subtitle band
    sub_data = [[Paragraph("Test Execution Report", styles["cover_sub"])]]
    sub_tbl = Table(sub_data, colWidths=[CONTENT_W])
    sub_tbl.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), C_BLUE),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ]
        )
    )
    elems.append(sub_tbl)
    elems.append(Spacer(1, 0.8 * cm))

    # run metadata table
    meta_rows = [
        ["Run Date / Time", run_ts],
        ["Environment", env.upper()],
        ["Total Test Cases", str(total)],
        ["Passed", str(passed)],
        ["Failed", str(failed)],
        ["Pass Rate", pass_rate],
        ["Modules Executed", str(len(modules))],
    ]
    if total_elapsed_ms > 0:
        meta_rows.append(["Total Execution Time", _ms_to_str(total_elapsed_ms)])
    meta_tbl = Table(
        meta_rows,
        colWidths=[5 * cm, CONTENT_W - 5 * cm],
        hAlign="CENTER",
    )
    meta_tbl.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
                ("FONTNAME", (1, 0), (1, -1), "Helvetica"),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("TEXTCOLOR", (0, 0), (-1, -1), C_TEXT),
                ("BACKGROUND", (0, 0), (-1, -1), C_LIGHT),
                ("ROWBACKGROUNDS", (0, 0), (-1, -1), [C_WHITE, C_LIGHT]),
                ("BOX", (0, 0), (-1, -1), 0.5, C_BORDER),
                ("INNERGRID", (0, 0), (-1, -1), 0.3, C_BORDER),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                # colour the value cells for pass/fail counts
                ("TEXTCOLOR", (1, 3), (1, 3), C_PASS),   # Passed value
                ("FONTNAME", (1, 3), (1, 3), "Helvetica-Bold"),
                ("TEXTCOLOR", (1, 4), (1, 4), C_FAIL if failed else C_PASS),
                ("FONTNAME", (1, 4), (1, 4), "Helvetica-Bold"),
            ]
        )
    )
    elems.append(meta_tbl)
    elems.append(PageBreak())
    return elems


def _build_summary(styles: dict, modules: dict) -> list:
    """Executive summary page: module-level pass/fail table."""
    elems = []
    elems.append(Paragraph("Executive Summary", styles["section_heading"]))
    elems.append(HRFlowable(width=CONTENT_W, thickness=1, color=C_BLUE, spaceAfter=8))

    header = ["Module", "Total", "Passed", "Failed", "Pass Rate", "Duration"]
    rows = [header]
    grand_total = grand_pass = grand_fail = 0
    grand_ms = 0

    for module, tests in modules.items():
        total = len(tests)
        passed = sum(1 for t in tests if t["status"] == "PASS")
        failed = total - passed
        ms = sum(t["elapsed_ms"] for t in tests)
        rate = f"{passed / total * 100:.1f}%" if total else "—"
        rows.append([
            module.replace("_", " "),
            str(total),
            str(passed),
            str(failed),
            rate,
            _ms_to_str(ms),
        ])
        grand_total += total
        grand_pass += passed
        grand_fail += failed
        grand_ms += ms

    grand_rate = f"{grand_pass / grand_total * 100:.1f}%" if grand_total else "—"
    rows.append(["TOTAL", str(grand_total), str(grand_pass), str(grand_fail), grand_rate, _ms_to_str(grand_ms)])

    col_w = [5.5 * cm, 1.6 * cm, 1.8 * cm, 1.8 * cm, 2.2 * cm, 3 * cm]
    tbl = Table(rows, colWidths=col_w, repeatRows=1)

    style_cmds = [
        # Header row
        ("BACKGROUND", (0, 0), (-1, 0), C_NAVY),
        ("TEXTCOLOR", (0, 0), (-1, 0), C_WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, 0), 9),
        ("ALIGN", (0, 0), (-1, 0), "CENTER"),
        # Data rows
        ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
        ("FONTSIZE", (0, 1), (-1, -1), 8.5),
        ("ROWBACKGROUNDS", (0, 1), (-1, -2), [C_WHITE, C_LIGHT]),
        ("ALIGN", (1, 1), (-1, -1), "CENTER"),
        ("ALIGN", (0, 1), (0, -1), "LEFT"),
        # Total row
        ("BACKGROUND", (0, -1), (-1, -1), C_NAVY),
        ("TEXTCOLOR", (0, -1), (-1, -1), C_WHITE),
        ("FONTNAME", (0, -1), (-1, -1), "Helvetica-Bold"),
        ("FONTSIZE", (0, -1), (-1, -1), 9),
        # Grid
        ("BOX", (0, 0), (-1, -1), 0.5, C_BORDER),
        ("INNERGRID", (0, 0), (-1, -1), 0.3, C_BORDER),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
    ]

    # Colour Passed / Failed data cells
    for i, (module, tests) in enumerate(modules.items(), start=1):
        passed = sum(1 for t in tests if t["status"] == "PASS")
        failed = len(tests) - passed
        if passed:
            style_cmds.append(("TEXTCOLOR", (2, i), (2, i), C_PASS))
            style_cmds.append(("FONTNAME", (2, i), (2, i), "Helvetica-Bold"))
        if failed:
            style_cmds.append(("TEXTCOLOR", (3, i), (3, i), C_FAIL))
            style_cmds.append(("FONTNAME", (3, i), (3, i), "Helvetica-Bold"))

    tbl.setStyle(TableStyle(style_cmds))
    elems.append(tbl)
    elems.append(PageBreak())
    return elems


def _build_module_section(styles: dict, module: str, tests: list, report_folder: str = "") -> list:
    """Flowables for one module: banner + test case cards."""
    elems = []

    # Module banner
    banner_data = [[Paragraph(f"  {module.replace('_', ' ').upper()}", styles["module_label"])]]
    banner = Table(banner_data, colWidths=[CONTENT_W])
    passed = sum(1 for t in tests if t["status"] == "PASS")
    total  = len(tests)
    banner.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), C_BLUE),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ]
        )
    )
    # summary sub-row
    summary_data = [[
        Paragraph(
            f"Tests: {total}   |   "
            f'<font color="#27AE60">Passed: {passed}</font>   |   '
            f'<font color="#E74C3C">Failed: {total - passed}</font>',
            ParagraphStyle(
                "mod_sum",
                fontName="Helvetica",
                fontSize=8.5,
                textColor=C_WHITE,
                leftIndent=8,
            ),
        )
    ]]
    summary_tbl = Table(summary_data, colWidths=[CONTENT_W])
    summary_tbl.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), C_NAVY),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    elems.append(KeepTogether([banner, summary_tbl]))
    elems.append(Spacer(1, 0.3 * cm))

    for test in tests:
        elems += _build_test_card(styles, test, report_folder)
        elems.append(Spacer(1, 0.25 * cm))

    elems.append(PageBreak())
    return elems


def _build_test_card(styles: dict, test: dict, report_folder: str = "") -> list:
    """Flowables for a single test case."""
    from xml.sax.saxutils import escape as _esc
    elems: list = []
    status      = test["status"]
    s_color     = _status_color(status)
    s_label     = _status_label(status)
    tc_id       = test["id"]
    display     = test["display_name"] or test["name"]
    duration    = _ms_to_str(test["elapsed_ms"])
    tags        = "  ·  ".join(test["tags"]) if test["tags"] else "—"
    doc_text    = _esc(test["doc"] or "")
    msg_text    = _esc(test["message"] or "")

    # ── TC header row ────────────────────────────────────────────────────────
    id_w   = 2.2 * cm
    name_w = CONTENT_W - id_w - 3.2 * cm - 2.8 * cm
    tc_header = Table(
        [[
            Paragraph(tc_id, styles["tc_id"]),
            Paragraph(display, styles["tc_name"]),
            Paragraph(s_label, ParagraphStyle(
                "tc_status", fontName="Helvetica-Bold", fontSize=9, textColor=s_color
            )),
            Paragraph(duration, ParagraphStyle(
                "tc_dur", fontName="Helvetica", fontSize=8.5, textColor=C_SUBTEXT, alignment=TA_RIGHT
            )),
        ]],
        colWidths=[id_w, name_w, 3.2 * cm, 2.8 * cm],
    )
    tc_header.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), C_LIGHT),
                ("LINEBELOW", (0, 0), (-1, 0), 1.2, s_color),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ]
        )
    )
    elems.append(KeepTogether([tc_header]))

    # ── tags + doc row ────────────────────────────────────────────────────────
    detail_rows = []
    detail_rows.append([
        Paragraph("Tags:", ParagraphStyle("lbl", fontName="Helvetica-Bold", fontSize=8, textColor=C_SUBTEXT)),
        Paragraph(tags, styles["tc_tags"]),
    ])
    if doc_text:
        detail_rows.append([
            Paragraph("Doc:", ParagraphStyle("lbl2", fontName="Helvetica-Bold", fontSize=8, textColor=C_SUBTEXT)),
            Paragraph(doc_text, styles["tc_doc"]),
        ])
    if msg_text and status == "FAIL":
        detail_rows.append([
            Paragraph("Error:", ParagraphStyle("lbl3", fontName="Helvetica-Bold", fontSize=8, textColor=C_FAIL)),
            Paragraph(
                msg_text[:400] + ("…" if len(msg_text) > 400 else ""),
                ParagraphStyle("err_msg", fontName="Helvetica", fontSize=8, textColor=C_FAIL),
            ),
        ])

    if detail_rows:
        det_tbl = Table(detail_rows, colWidths=[1.3 * cm, CONTENT_W - 1.3 * cm])
        det_tbl.setStyle(
            TableStyle(
                [
                    ("TOPPADDING", (0, 0), (-1, -1), 3),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
                    ("LEFTPADDING", (0, 0), (-1, -1), 6),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ]
            )
        )
        elems.append(det_tbl)

    # ── screenshots ──────────────────────────────────────────────────────────
    screenshots = _resolve_screenshots(test, report_folder)
    if screenshots:
        elems.append(Spacer(1, 0.2 * cm))
        elems.append(Paragraph(
            f"Screenshots  <font color='#7F8C8D'>({len(screenshots)})</font>",
            ParagraphStyle("ss_hdr", fontName="Helvetica-Bold", fontSize=8.5, textColor=C_NAVY),
        ))
        elems.append(HRFlowable(width=CONTENT_W, thickness=0.4, color=C_BORDER, spaceAfter=5))
        elems += _build_screenshot_grid(screenshots, styles)

    # bottom border
    elems.append(HRFlowable(width=CONTENT_W, thickness=0.3, color=C_BORDER, spaceAfter=0))
    return elems


# ─────────────────────────────────────────────────────────────────────────────
#  Main entry point
# ─────────────────────────────────────────────────────────────────────────────

def generate_pdf(report_folder: str, env: str = "dev", title: str = "STC AUTOMATION",
                  pdf_name: str = "execution_report.pdf",
                  total_elapsed_ms: int = 0) -> Optional[str]:
    """
    Generate execution_report.pdf inside report_folder.
    Returns the output path, or None on failure.
    """
    if not HAS_REPORTLAB:
        print("  WARNING [STCPDFReport]: reportlab not installed – skipping PDF generation.")
        return None

    report_folder = os.path.abspath(report_folder)
    xml_path = _find_xml(report_folder)
    rf_result = _parse_xml(xml_path) if xml_path else None
    json_map = _load_json_data(report_folder)

    if rf_result is None and not json_map:
        print(f"  WARNING [STCPDFReport]: No result XML and no JSON data found in {report_folder}.")
        return None

    modules = _collect_tests(rf_result, json_map)
    if not modules:
        print(f"  WARNING [STCPDFReport]: No test data found – skipping PDF.")
        return None

    # Derive run timestamp from folder name (dd-MM-yyyy_hh-mm-ss pattern)
    folder_name = os.path.basename(report_folder)
    run_ts = folder_name  # fallback
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})", folder_name)
    if m:
        y, mo, d, h, mi, s = m.groups()
        run_ts = f"{d}-{mo}-{y}  {h}:{mi}:{s}"

    styles = _build_styles()
    pdf_path = os.path.join(report_folder, pdf_name)

    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=A4,
        leftMargin=MARGIN,
        rightMargin=MARGIN,
        topMargin=MARGIN + 0.5 * cm,
        bottomMargin=MARGIN + 0.5 * cm,
        title=f"{title} Execution Report",
        author="STC Automation Framework",
        subject=f"Execution Report – {run_ts}",
    )

    # Calculate total elapsed from test data if not provided
    if total_elapsed_ms <= 0:
        total_elapsed_ms = sum(
            t.get("elapsed_ms", 0) for tests in modules.values() for t in tests
        )

    story: list = []
    story += _build_cover(styles, env, modules, run_ts, title=title,
                          total_elapsed_ms=total_elapsed_ms)
    story += _build_summary(styles, modules)
    for module, tests in modules.items():
        story += _build_module_section(styles, module, tests, report_folder)

    try:
        doc.build(story, onFirstPage=_draw_page_chrome, onLaterPages=_draw_page_chrome)
        print(f"  PDF report generated: {pdf_path}")
        return pdf_path
    except Exception as exc:
        print(f"  ERROR [STCPDFReport]: PDF build failed: {exc}")
        return None


# ─────────────────────────────────────────────────────────────────────────────
#  CLI entry point
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="STC Automation PDF Report Generator")
    parser.add_argument("report_folder", help="Path to the timestamped report folder")
    parser.add_argument("--env", default="dev", help="Environment name (dev/qe/staging/prod)")
    parser.add_argument("--title", default="STC AUTOMATION", help="Report title")
    parser.add_argument("--pdf-name", default="execution_report.pdf", help="Output PDF filename")
    parsed = parser.parse_args()

    result = generate_pdf(parsed.report_folder, env=parsed.env,
                          title=parsed.title, pdf_name=parsed.pdf_name)
    if result:
        print(f"Done: {result}")
    else:
        sys.exit(1)
