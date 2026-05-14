#!/bin/bash
# Extract individual chapter PDFs from the full book PDF using qpdf.
# This preserves chapter numbers, styling, and cross-references exactly as
# they appear in the full book.
OUTPUT_DIR="${QUARTO_PROJECT_OUTPUT_DIR:-docs}"

python3 << 'PYEOF'
import os
import sys
import subprocess
import yaml
import pypdf

OUTPUT_DIR = os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "docs")
BOOK_PDF = os.path.join(OUTPUT_DIR, "Numerical-Analysis.pdf")

if not os.path.exists(BOOK_PDF):
    print(f"ERROR: Full book PDF not found at {BOOK_PDF}", file=sys.stderr)
    sys.exit(1)

# Read chapter/appendix order from _quarto.yml
with open("_quarto.yml") as f:
    config = yaml.safe_load(f)

chapters = config.get("book", {}).get("chapters", [])
appendices = config.get("book", {}).get("appendices", [])

# Read PDF and its outline
reader = pypdf.PdfReader(BOOK_PDF)
total_pages = len(reader.pages)

def flatten_top_level(outline):
    """Walk the top-level outline, collecting (title, start_page_1indexed, children_list)."""
    entries = []
    i = 0
    while i < len(outline):
        item = outline[i]
        if isinstance(item, list):
            i += 1
            continue
        page_num = reader.get_destination_page_number(item) + 1  # 1-indexed
        children = []
        if i + 1 < len(outline) and isinstance(outline[i + 1], list):
            children = outline[i + 1]
        entries.append((item.title, page_num, children))
        i += 1
    return entries

def with_end_pages(entries, fallback_end):
    """Add end_page to each entry: start of next entry minus 1, or fallback_end."""
    result = []
    for idx, (title, start, children) in enumerate(entries):
        end = entries[idx + 1][1] - 1 if idx + 1 < len(entries) else fallback_end
        result.append((title, start, end, children))
    return result

top_entries = flatten_top_level(reader.outline)
top_ranges = with_end_pages(top_entries, total_pages)

# Separate chapters from the Appendices block
chapter_ranges = []   # (title, start, end)
appendix_ranges = []  # (title, start, end)

for title, start, end, children in top_ranges:
    if title == "Appendices":
        # Children are the individual appendices
        child_entries = flatten_top_level(children)
        child_ranges = with_end_pages(child_entries, total_pages)
        appendix_ranges = [(t, s, e) for t, s, e, _ in child_ranges]
    else:
        chapter_ranges.append((title, start, end))

def extract(qmd, start_page, end_page):
    """Extract pages [start_page, end_page] (1-indexed, inclusive) from the full PDF."""
    stem = os.path.splitext(qmd)[0]
    out_pdf = os.path.join(OUTPUT_DIR, stem + ".pdf")
    print(f"Extracting {qmd} -> {out_pdf} (pages {start_page}-{end_page})...")
    subprocess.run(
        ["qpdf", BOOK_PDF,
         "--pages", BOOK_PDF, f"{start_page}-{end_page}", "--",
         out_pdf],
        check=True
    )

# Match chapters list to chapter_ranges by position
if len(chapters) != len(chapter_ranges):
    print(
        f"WARNING: {len(chapters)} chapters in _quarto.yml but "
        f"{len(chapter_ranges)} top-level PDF bookmarks. "
        "Extraction may be misaligned.",
        file=sys.stderr
    )

for qmd, (title, start, end) in zip(chapters, chapter_ranges):
    extract(qmd, start, end)

# Match appendices list to appendix_ranges by position
if len(appendices) != len(appendix_ranges):
    print(
        f"WARNING: {len(appendices)} appendices in _quarto.yml but "
        f"{len(appendix_ranges)} appendix PDF bookmarks. "
        "Extraction may be misaligned.",
        file=sys.stderr
    )

for qmd, (title, start, end) in zip(appendices, appendix_ranges):
    extract(qmd, start, end)

print("Done.")
PYEOF
