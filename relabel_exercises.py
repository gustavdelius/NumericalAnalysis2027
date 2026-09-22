#!/usr/bin/env python3
"""
Rename the internal exercise labels so that they agree with the exercise
numbers that Quarto displays.

Quarto numbers exercises consecutively within each chapter, e.g. the 13th
exercise in chapter 5 is "Exercise 5.13", and in appendices with the
appendix letter, e.g. "Exercise C.4". This script gives that exercise the
label `exr-5.13` (or `exr-C.4`) and updates all cross-references
`@exr-...` accordingly. Exercises in the unnumbered introduction get the
labels `exr-intro-1`, `exr-intro-2`, ... Exercises inside HTML comments
(commented out) are not numbered by Quarto and are left unchanged.

The chapter order is read from `_quarto.yml`. Run the script from the
root of the repository after adding, removing or reordering exercises:

    python3 relabel_exercises.py            # rewrite the .qmd files
    python3 relabel_exercises.py --dry-run  # only print the renames

The script is idempotent: running it twice makes no further changes.
"""

import re
import sys
from pathlib import Path

# An exercise label or reference: `exr-` followed by characters allowed in
# a Quarto cross-reference. Internal punctuation is allowed but trailing
# punctuation (as in "see @exr-3.13.") is not part of the label.
LABEL = r"exr-[A-Za-z0-9_]+(?:[.\-:][A-Za-z0-9_]+)*"
DEFINITION = re.compile(r"(::: *\{[^}\n]*#)(" + LABEL + r")")
REFERENCE = re.compile(r"(?<=@)(" + LABEL + r")")
COMMENT = re.compile(r"<!--.*?-->", re.S)


def outside_comments(pattern, text):
    """
    Find the matches of `pattern` in `text` that are not inside an HTML
    comment. Commented-out exercises are not numbered by Quarto, so they
    are left alone.

    Parameters:
        pattern (re.Pattern): Compiled regular expression
        text (str): Text to search

    Returns:
        list: The match objects outside of comments
    """
    comments = [m.span() for m in COMMENT.finditer(text)]
    return [m for m in pattern.finditer(text)
            if not any(a <= m.start() < b for a, b in comments)]


def substitute(pattern, text, replacement):
    """
    Like pattern.sub(replacement, text) but leaving HTML comments alone.

    Parameters:
        pattern (re.Pattern): Compiled regular expression
        text (str): Text in which to substitute
        replacement (function): Maps a match object to its replacement

    Returns:
        str: The text with the substitutions made
    """
    pieces, last = [], 0
    for m in outside_comments(pattern, text):
        pieces.append(text[last:m.start()])
        pieces.append(replacement(m))
        last = m.end()
    pieces.append(text[last:])
    return "".join(pieces)


def chapter_files(quarto_yml):
    """
    Read the list of chapter and appendix files from _quarto.yml

    Parameters:
        quarto_yml (Path): Path to the _quarto.yml file

    Returns:
        chapters (list): The .qmd files listed under `chapters:`
        appendices (list): The .qmd files listed under `appendices:`
    """
    chapters, appendices, current = [], [], None
    for line in quarto_yml.read_text().splitlines():
        stripped = line.strip()
        if stripped == "chapters:":
            current = chapters
        elif stripped == "appendices:":
            current = appendices
        elif current is not None and stripped.startswith("- "):
            current.append(stripped[2:].strip())
        elif current is not None and stripped and not stripped.startswith("#"):
            current = None
    return chapters, appendices


def is_unnumbered(text):
    """Return True if the first heading of the chapter is {.unnumbered}."""
    for line in text.splitlines():
        if line.startswith("# "):
            return ".unnumbered" in line or "{-}" in line
    return False


def main(dry_run=False):
    root = Path(__file__).resolve().parent
    chapters, appendices = chapter_files(root / "_quarto.yml")

    # Work out the new label for every exercise definition, file by file.
    # Labels are only unique per file here because the same old label
    # may (by mistake) be used in two chapters.
    texts, renames = {}, {}
    number = 0
    files = [(f, None) for f in chapters] + \
            [(f, chr(ord("A") + i)) for i, f in enumerate(appendices)]
    for name, letter in files:
        text = (root / name).read_text()
        texts[name] = text
        if letter is None and is_unnumbered(text):
            prefix = "exr-intro-"
        elif letter is None:
            number += 1
            prefix = f"exr-{number}."
        else:
            prefix = f"exr-{letter}."
        renames[name] = {}
        for i, match in enumerate(outside_comments(DEFINITION, text), start=1):
            old = match.group(2)
            if old in renames[name]:
                sys.exit(f"{name}: label {old} is defined twice")
            renames[name][old] = f"{prefix}{i}"

    # A reference to a label defined in the same file refers to that
    # definition; otherwise it must refer to a unique definition elsewhere.
    global_renames = {}
    for name in renames:
        for old, new in renames[name].items():
            global_renames.setdefault(old, set()).add(new)

    def new_label(name, old):
        if old in renames[name]:
            return renames[name][old]
        targets = global_renames.get(old)
        if targets is None:
            print(f"warning: {name}: reference to undefined label {old}")
            return old
        if len(targets) > 1:
            sys.exit(f"{name}: ambiguous reference to {old}")
        return next(iter(targets))

    changed = 0
    for name, text in texts.items():
        new_text = substitute(
            DEFINITION, text,
            lambda m: m.group(1) + renames[name][m.group(2)])
        new_text = substitute(REFERENCE, new_text,
                              lambda m: new_label(name, m.group(1)))
        for old, new in renames[name].items():
            if old != new:
                changed += 1
                print(f"{name}: {old} -> {new}")
        if new_text != text and not dry_run:
            (root / name).write_text(new_text)

    # The other .qmd files (not chapters) may also reference exercises.
    for path in sorted(root.glob("*.qmd")):
        if path.name in texts:
            continue
        text = path.read_text()
        new_text = substitute(
            REFERENCE, text,
            lambda m: next(iter(global_renames.get(m.group(1),
                                                   {m.group(1)}))))
        if new_text != text and not dry_run:
            path.write_text(new_text)

    print(f"{changed} labels {'would be ' if dry_run else ''}renamed")


if __name__ == "__main__":
    main(dry_run="--dry-run" in sys.argv[1:])
