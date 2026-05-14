# Numerical Analysis 2026

This repository contains the Quarto source for the Numerical Analysis 2026 book.

## Features

- **Individual Chapter PDFs**: Each chapter in the HTML version of the book has a "Download Chapter PDF" button.
- **Dyslexic Font Toggle**: An accessibility feature in the sidebar to toggle a font tailored for readability (OpenDyslexic).
- **Responsive HTML Design**: A modern, interactive web-based version of the textbook.

## Project Structure

- `_quarto.yml`: Main configuration file.
- `chapter-pdf.lua`: Lua filter that injects the PDF download link into the HTML version.
- `render_chapter_pdfs.sh`: Script that extracts individual chapter PDFs from the full book PDF using `qpdf`, preserving chapter numbers and styling.
- `fonts.css` & `toggle-font.html`: Implementation of the dyslexic font toggle.
- `docs/`: The output directory where the website and all PDFs are generated.

## Rendering and Publishing

### 1. Standard Rendering
To render the entire book (HTML website and the full Book PDF), run:
```bash
quarto render
```
This command automatically triggers `./render_chapter_pdfs.sh` via a `post-render` hook in `_quarto.yml`. This script handles the generation of individual chapter PDFs in the `docs/` folder.

### 2. Selective Chapter PDF Rendering
To update only the individual chapter PDFs without a full site rebuild (requires the full book PDF to already exist in `docs/`):
```bash
./render_chapter_pdfs.sh
```
Extraction is fast, so all chapter PDFs are always regenerated.

### 3. Publishing to GitHub Pages
To render and publish to GitHub Pages:
```bash
quarto publish gh-pages
```

## Technical Requirements

- **Quarto**: Version 1.3 or higher.
- **TeX Live / TinyTex**: Required for PDF generation. Ensure your installation is up to date (`quarto tools update tinytex`).
- **Python/Jupyter**: Used for the computational examples within the book.
- **qpdf**: Required for extracting individual chapter PDFs from the full book PDF (`apt install qpdf` or `brew install qpdf`).
- **pypdf** (Python package): Required by `render_chapter_pdfs.sh` (`pip install pypdf`).
