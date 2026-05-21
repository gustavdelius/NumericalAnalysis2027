#!/bin/bash
# Render the full book (frozen chapters skip re-execution) then push only the
# specified chapter's HTML output to the gh-pages branch.
#
# Hashed CSS/JS filenames (e.g. bootstrap-<md5>.min.css) in site_libs/ are
# rewritten back to the hashes already present on gh-pages, so existing CSS
# files need not be updated.
#
# Usage: ./publish_chapter.sh <chapter-stem>
#   e.g. ./publish_chapter.sh ex_exam_solns
#        ./publish_chapter.sh nmODE1

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <chapter-stem>  (e.g. nmODE1, ex_exam_solns)"
    exit 1
fi

STEM="$1"
DOCS="docs"
ROOT="$(pwd)"
WORKTREE="${ROOT}/.gh-pages-publish-tmp"

# Render (freeze:auto means unchanged chapters skip re-execution)
quarto render

# Check the rendered file exists
if [ ! -f "${DOCS}/${STEM}.html" ]; then
    echo "ERROR: ${DOCS}/${STEM}.html not found after render."
    exit 1
fi

# Sync local gh-pages with remote before creating the worktree
git fetch origin gh-pages
git branch -f gh-pages origin/gh-pages

# Set up a temporary worktree pointing at the gh-pages branch
git worktree add "${WORKTREE}" gh-pages

trap 'git worktree remove --force "${WORKTREE}"' EXIT

# Rewrite hashed site_libs URLs in the new HTML back to the hashes that are
# already present on gh-pages, so the existing CSS/JS files remain valid.
python3 - "${DOCS}/${STEM}.html" "${WORKTREE}/${STEM}.html" "${WORKTREE}/${STEM}.html" <<'PYEOF'
import re, sys

new_html  = open(sys.argv[1]).read()
old_html  = open(sys.argv[2]).read()
out_path  = sys.argv[3]

HASH_RE = re.compile(r'(site_libs/[^"\']*?-)([0-9a-f]{32})(\.[^"\']+)')

# Build map: canonical-path-without-hash -> full old path (with old hash)
old_map = {}
for m in HASH_RE.finditer(old_html):
    old_map[m.group(1) + m.group(3)] = m.group(0)

def replace_hash(m):
    key = m.group(1) + m.group(3)
    return old_map.get(key, m.group(0))  # fall back to new hash if not found

patched = HASH_RE.sub(replace_hash, new_html)
open(out_path, 'w').write(patched)
PYEOF

# Copy the companion _files/ directory and chapter PDF if present
if [ -d "${DOCS}/${STEM}_files" ]; then
    cp -r "${DOCS}/${STEM}_files" "${WORKTREE}/"
fi
if [ -f "${DOCS}/${STEM}.pdf" ]; then
    cp "${DOCS}/${STEM}.pdf" "${WORKTREE}/"
fi

# Commit and push from inside the worktree
cd "${WORKTREE}"
git add "${STEM}.html"
[ -d "${STEM}_files" ] && git add "${STEM}_files/"
[ -f "${STEM}.pdf" ] && git add "${STEM}.pdf"
git diff --cached --quiet && { echo "No changes to publish."; exit 0; }
git commit -m "Publish ${STEM}"
git push origin gh-pages
