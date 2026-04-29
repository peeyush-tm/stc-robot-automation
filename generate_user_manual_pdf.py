"""
STC Automation — User Manual PDF Generator
===========================================
Converts documentation/USER_MANUAL.md into a clean, styled PDF.

Usage:
    python generate_user_manual_pdf.py
    python generate_user_manual_pdf.py --output documentation/USER_MANUAL.pdf
    python generate_user_manual_pdf.py --input documentation/USER_MANUAL.md --output my_manual.pdf
"""

from __future__ import annotations

import argparse
import os
import re
import sys

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# ── ReportLab ────────────────────────────────────────────────────────────────
try:
    from reportlab.lib import colors
    from reportlab.lib.enums import TA_CENTER, TA_LEFT
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
    from reportlab.lib.units import cm, mm
    from reportlab.platypus import (
        HRFlowable,
        PageBreak,
        Paragraph,
        SimpleDocTemplate,
        Spacer,
        Table,
        TableStyle,
    )
except ImportError:
    print("ERROR: reportlab is not installed. Run: pip install reportlab")
    sys.exit(1)

# ── Brand colours ─────────────────────────────────────────────────────────────
TEAL       = colors.HexColor("#00838F")
TEAL_LIGHT = colors.HexColor("#E0F4F6")
TEAL_MID   = colors.HexColor("#B2DFE4")
DARK       = colors.HexColor("#1A2B3C")
GREY_BG    = colors.HexColor("#F5F7F9")
GREY_RULE  = colors.HexColor("#D0D7DE")
WHITE      = colors.white
CODE_BG    = colors.HexColor("#F0F3F5")
CODE_FG    = colors.HexColor("#24292E")

PAGE_W, PAGE_H = A4
MARGIN = 2 * cm


# ── Style sheet ──────────────────────────────────────────────────────────────
def build_styles():
    base = getSampleStyleSheet()

    def s(name, **kw):
        return ParagraphStyle(name, **kw)

    return {
        "h1": s("h1", fontName="Helvetica-Bold", fontSize=22, textColor=DARK,
                 spaceAfter=6*mm, spaceBefore=4*mm, leading=28),
        "h2": s("h2", fontName="Helvetica-Bold", fontSize=15, textColor=TEAL,
                 spaceAfter=4*mm, spaceBefore=8*mm, leading=20,
                 borderPad=2, leftIndent=0),
        "h3": s("h3", fontName="Helvetica-Bold", fontSize=12, textColor=DARK,
                 spaceAfter=2*mm, spaceBefore=5*mm, leading=16),
        "body": s("body", fontName="Helvetica", fontSize=9.5, textColor=DARK,
                  spaceAfter=3*mm, leading=14),
        "bullet": s("bullet", fontName="Helvetica", fontSize=9.5, textColor=DARK,
                    spaceAfter=1.5*mm, leading=14, leftIndent=14, bulletIndent=4,
                    bulletText="•"),
        "code": s("code", fontName="Courier", fontSize=8.5, textColor=CODE_FG,
                  backColor=CODE_BG, spaceAfter=3*mm, leading=13,
                  leftIndent=8, rightIndent=8,
                  borderPad=5, borderColor=GREY_RULE, borderWidth=0.5,
                  borderRadius=3),
        "toc": s("toc", fontName="Helvetica", fontSize=9.5, textColor=TEAL,
                 spaceAfter=1.5*mm, leading=14, leftIndent=8),
        "caption": s("caption", fontName="Helvetica-Oblique", fontSize=8,
                     textColor=colors.HexColor("#6B7A8D"), spaceAfter=2*mm),
        "cover_title": s("cover_title", fontName="Helvetica-Bold", fontSize=32,
                          textColor=WHITE, alignment=TA_CENTER, leading=40,
                          spaceAfter=4*mm),
        "cover_sub": s("cover_sub", fontName="Helvetica", fontSize=13,
                        textColor=TEAL_LIGHT, alignment=TA_CENTER, leading=18,
                        spaceAfter=3*mm),
        "cover_meta": s("cover_meta", fontName="Helvetica", fontSize=10,
                         textColor=colors.HexColor("#B0BEC5"), alignment=TA_CENTER,
                         leading=14),
    }


# ── Cover page ────────────────────────────────────────────────────────────────
def cover_page(story, styles):
    from reportlab.platypus import FrameBreak
    story.append(Spacer(1, 3.5*cm))
    # coloured banner
    banner = Table(
        [[Paragraph("STC Automation", styles["cover_title"]),
          Paragraph("User Manual", styles["cover_sub"])]],
        colWidths=[PAGE_W - 2*MARGIN],
        rowHeights=[None],
    )
    banner.setStyle(TableStyle([
        ("BACKGROUND",  (0, 0), (-1, -1), TEAL),
        ("ROUNDEDCORNERS", [6]),
        ("TOPPADDING",  (0, 0), (-1, -1), 18),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 18),
        ("LEFTPADDING",  (0, 0), (-1, -1), 20),
        ("RIGHTPADDING", (0, 0), (-1, -1), 20),
        ("SPAN",        (0, 0), (-1, -1)),
    ]))
    story.append(banner)
    story.append(Spacer(1, 8*mm))

    meta_rows = [
        ("Framework",    "Robot Framework 7.0.1 + SeleniumLibrary 6.3"),
        ("Language",     "Python 3.11"),
        ("Total Tests",  "662 test cases · 23 suites"),
        ("Environments", "QE  ·  SIT"),
        ("Server",       "10.221.86.73  ·  /opt/Automation/STC"),
        ("Maintained by","STC Automation Team — Airlinq"),
        ("Last Updated", "2026-04-29"),
    ]
    cell_style = ParagraphStyle("mc", fontName="Helvetica", fontSize=9.5,
                                 textColor=DARK, leading=14)
    label_style = ParagraphStyle("ml", fontName="Helvetica-Bold", fontSize=9.5,
                                  textColor=TEAL, leading=14)
    table_data = [[Paragraph(k, label_style), Paragraph(v, cell_style)]
                  for k, v in meta_rows]
    meta_tbl = Table(table_data, colWidths=[4.5*cm, PAGE_W - 2*MARGIN - 4.5*cm])
    meta_tbl.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, -1), GREY_BG),
        ("ROWBACKGROUNDS",(0, 0),(-1,-1),[GREY_BG, WHITE]),
        ("TOPPADDING",   (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 5),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("LINEBELOW",    (0, 0), (-1, -2), 0.3, GREY_RULE),
    ]))
    story.append(meta_tbl)
    story.append(PageBreak())


# ── Inline code formatter ─────────────────────────────────────────────────────
def inline_code(text):
    """Wrap `backtick` spans in a monospace font tag."""
    return re.sub(r"`([^`]+)`",
                  r'<font name="Courier" size="8.5" color="#24292E">\1</font>',
                  text)


def escape_xml(text):
    return (text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;"))


def fmt(text):
    """Escape XML then apply inline code and bold/italic markup."""
    text = escape_xml(text)
    text = inline_code(text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"\*(.+?)\*",     r"<i>\1</i>", text)
    return text


# ── Table builder ─────────────────────────────────────────────────────────────
def build_table(header, rows, styles):
    cell_s = ParagraphStyle("tc", fontName="Helvetica",      fontSize=8.5, leading=12, textColor=DARK)
    head_s = ParagraphStyle("th", fontName="Helvetica-Bold", fontSize=8.5, leading=12, textColor=WHITE)

    col_count = len(header)
    usable = PAGE_W - 2 * MARGIN
    col_w = usable / col_count

    def make_row(cells, style):
        return [Paragraph(fmt(c), style) for c in cells]

    data = [make_row(header, head_s)] + [make_row(r, cell_s) for r in rows]

    tbl = Table(data, colWidths=[col_w] * col_count, repeatRows=1)
    tbl.setStyle(TableStyle([
        ("BACKGROUND",    (0, 0), (-1, 0),  TEAL),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [WHITE, GREY_BG]),
        ("GRID",          (0, 0), (-1, -1), 0.3, GREY_RULE),
        ("TOPPADDING",    (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING",   (0, 0), (-1, -1), 6),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 6),
        ("VALIGN",        (0, 0), (-1, -1), "TOP"),
    ]))
    return tbl


# ── Markdown parser → ReportLab story elements ───────────────────────────────
def parse_markdown(md_text, styles):  # noqa: C901
    story = []
    lines = md_text.splitlines()
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # ── blank line
        if not stripped:
            i += 1
            continue

        # ── horizontal rule  ---
        if re.match(r"^-{3,}$", stripped):
            story.append(HRFlowable(width="100%", thickness=0.5,
                                     color=GREY_RULE, spaceAfter=4*mm))
            i += 1
            continue

        # ── headings
        if stripped.startswith("# ") and not stripped.startswith("## "):
            story.append(Paragraph(fmt(stripped[2:]), styles["h1"]))
            story.append(HRFlowable(width="100%", thickness=1.5,
                                     color=TEAL, spaceAfter=4*mm))
            i += 1
            continue
        if stripped.startswith("## "):
            story.append(Spacer(1, 2*mm))
            story.append(Paragraph(fmt(stripped[3:]), styles["h2"]))
            i += 1
            continue
        if stripped.startswith("### "):
            story.append(Paragraph(fmt(stripped[4:]), styles["h3"]))
            i += 1
            continue

        # ── fenced code block  ```
        if stripped.startswith("```"):
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code_lines.append(lines[i].rstrip())
                i += 1
            i += 1  # skip closing ```
            code_text = "\n".join(code_lines)
            # escape for XML but preserve spacing
            safe = (code_text.replace("&", "&amp;")
                              .replace("<", "&lt;")
                              .replace(">", "&gt;")
                              .replace(" ", "&nbsp;")
                              .replace("\n", "<br/>"))
            story.append(Paragraph(safe, styles["code"]))
            continue

        # ── table  | col | col |
        if stripped.startswith("|"):
            header = []
            rows   = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                cells = [c.strip() for c in lines[i].strip().strip("|").split("|")]
                # skip separator rows  |---|---|
                if all(re.match(r"^[-: ]+$", c) for c in cells):
                    i += 1
                    continue
                if not header:
                    header = cells
                else:
                    rows.append(cells)
                i += 1
            if header:
                story.append(build_table(header, rows, styles))
                story.append(Spacer(1, 3*mm))
            continue

        # ── bullet list  - item  or  * item
        if re.match(r"^[-*] ", stripped):
            bullet_text = stripped[2:].strip()
            story.append(Paragraph(fmt(bullet_text), styles["bullet"]))
            i += 1
            continue

        # ── numbered list  1. item
        if re.match(r"^\d+\. ", stripped):
            bullet_text = re.sub(r"^\d+\. ", "", stripped)
            story.append(Paragraph(fmt(bullet_text), styles["bullet"]))
            i += 1
            continue

        # ── blockquote  > text
        if stripped.startswith("> "):
            quote = stripped[2:]
            q_style = ParagraphStyle("bq", fontName="Helvetica-Oblique", fontSize=9,
                                      textColor=colors.HexColor("#555F6D"),
                                      leftIndent=14, borderPadding=(4, 6, 4, 10),
                                      borderColor=TEAL_MID, borderWidth=2,
                                      borderRadius=0, leading=13, spaceAfter=3*mm)
            story.append(Paragraph(fmt(quote), q_style))
            i += 1
            continue

        # ── normal paragraph
        story.append(Paragraph(fmt(stripped), styles["body"]))
        i += 1

    return story


# ── Page template with header/footer ─────────────────────────────────────────
class _PageCanvas:
    def __init__(self, doc_title):
        self._title = doc_title

    def __call__(self, canvas, doc):
        canvas.saveState()
        w, h = A4

        # header bar
        canvas.setFillColor(TEAL)
        canvas.rect(0, h - 1.1*cm, w, 1.1*cm, fill=1, stroke=0)
        canvas.setFont("Helvetica-Bold", 9)
        canvas.setFillColor(WHITE)
        canvas.drawString(MARGIN, h - 0.75*cm, "STC Automation")
        canvas.setFont("Helvetica", 9)
        canvas.drawRightString(w - MARGIN, h - 0.75*cm, self._title)

        # footer
        canvas.setStrokeColor(GREY_RULE)
        canvas.setLineWidth(0.5)
        canvas.line(MARGIN, 1.5*cm, w - MARGIN, 1.5*cm)
        canvas.setFont("Helvetica", 8)
        canvas.setFillColor(colors.HexColor("#6B7A8D"))
        canvas.drawString(MARGIN, 0.9*cm, "Confidential — Airlinq / STC")
        canvas.drawRightString(w - MARGIN, 0.9*cm, f"Page {doc.page}")

        canvas.restoreState()


# ── Main ──────────────────────────────────────────────────────────────────────
def generate(input_md: str, output_pdf: str):
    if not os.path.isfile(input_md):
        print(f"ERROR: Input file not found: {input_md}")
        sys.exit(1)

    with open(input_md, encoding="utf-8") as f:
        md_text = f.read()

    os.makedirs(os.path.dirname(os.path.abspath(output_pdf)), exist_ok=True)

    doc = SimpleDocTemplate(
        output_pdf,
        pagesize=A4,
        leftMargin=MARGIN, rightMargin=MARGIN,
        topMargin=MARGIN + 0.5*cm, bottomMargin=MARGIN + 0.5*cm,
        title="STC Automation — User Manual",
        author="Airlinq STC Automation Team",
    )

    styles = build_styles()
    story  = []

    cover_page(story, styles)
    story += parse_markdown(md_text, styles)

    page_cb = _PageCanvas("User Manual")
    doc.build(story, onFirstPage=page_cb, onLaterPages=page_cb)
    print(f"PDF generated: {output_pdf}")


def main():
    parser = argparse.ArgumentParser(description="Generate User Manual PDF from Markdown")
    parser.add_argument("--input",  default=os.path.join(ROOT_DIR, "documentation", "USER_MANUAL.md"),
                        help="Path to USER_MANUAL.md (default: documentation/USER_MANUAL.md)")
    parser.add_argument("--output", default=os.path.join(ROOT_DIR, "documentation", "USER_MANUAL.pdf"),
                        help="Output PDF path (default: documentation/USER_MANUAL.pdf)")
    args = parser.parse_args()
    generate(args.input, args.output)


if __name__ == "__main__":
    main()
