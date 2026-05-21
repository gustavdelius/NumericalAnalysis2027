# Numerical Analysis 2027

This repository contains the Quarto source for the Numerical Analysis 2027 book.

## Features

- **Individual Chapter PDFs**: Each chapter in the HTML version of the book has a "Download Chapter PDF" button.
- **Dyslexic Font Toggle**: An accessibility feature in the sidebar to toggle a font tailored for readability (OpenDyslexic).
- **Responsive HTML Design**: A modern, interactive web-based version of the textbook.

## Project Structure

- `_quarto.yml`: Main configuration file.
- `chapter-pdf.lua`: Lua filter that injects the PDF download link into the HTML version.
- `render_chapter_pdfs.sh`: Script that extracts individual chapter PDFs from the full book PDF using `qpdf`, preserving chapter numbers and styling.
- `publish_chapter.sh`: Script that renders the book and pushes a single chapter to the `gh-pages` branch.
- `fonts.css` & `toggle-font.html`: Implementation of the dyslexic font toggle.
- `docs/`: The output directory where the website and all PDFs are generated.

## Rendering and Publishing

### 1. Standard Rendering
To render the entire book (HTML website and the full Book PDF), run:
```bash
quarto render
```
This command automatically triggers `./render_chapter_pdfs.sh` via a `post-render` hook in `_quarto.yml`. This script handles the generation of individual chapter PDFs in the `docs/` folder.

### 2. Publishing to GitHub Pages
To render and publish to GitHub Pages:
```bash
quarto publish gh-pages
```

### 3. Publishing a Single Chapter

Because all pages share book navigation, Quarto always rebuilds the full site — `quarto render <file>.qmd` still triggers a full render. However, with `freeze: auto` set in `_quarto.yml`, code cells in unchanged chapters are not re-executed, so a full render is fast after a text-only fix.

To render and then publish changes to **only one chapter** to GitHub Pages:

```bash
./publish_chapter.sh ex_exam_solns
```

The script runs `quarto render` (skipping re-execution of frozen chapters), then uses a temporary git worktree to copy just `<chapter>.html` (and its companion `<chapter>_files/` directory, if present) and `<chapter>.pdf` to the `gh-pages` branch and pushes.

**Note:** This does *not* update the full book PDF. If the PDF also needs updating, run a full `quarto publish gh-pages` afterwards.


## Technical Requirements

- **Quarto**: Version 1.3 or higher.
- **TeX Live / TinyTex**: Required for PDF generation. Ensure your installation is up to date (`quarto tools update tinytex`).
- **Python/Jupyter**: Used for the computational examples within the book.
- **qpdf**: Required for extracting individual chapter PDFs from the full book PDF (`apt install qpdf` or `brew install qpdf`).
- **pypdf** (Python package): Required by `render_chapter_pdfs.sh` (`pip install pypdf`).
