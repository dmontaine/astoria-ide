#!/usr/bin/env python3
"""Strip dead __USE_GTK__ / Linux preprocessor branches for Win64-only IDE build."""

from __future__ import annotations

import re
import sys
from pathlib import Path

# Win64 Windows IDE: GTK/Linux paths are never compiled.
DEFINED = {
    "__FB_WIN32__": True,
    "__FB_64BIT__": True,
    "__USE_GTK__": False,
    "__USE_GTK3__": False,
    "__FB_LINUX__": False,
    "__USE_WINAPI__": True,
}

DIRECTIVE_RE = re.compile(
    r"^\s*#(?P<kind>ifdef|ifndef|if|elseif|else|endif)\b(?P<rest>.*)$",
    re.IGNORECASE,
)
DEFINED_RE = re.compile(r"defined\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", re.IGNORECASE)


def eval_condition(expr: str) -> bool:
    expr = expr.strip()
    if not expr:
        return False
    expr = DEFINED_RE.sub(
        lambda m: "True" if DEFINED.get(m.group(1), False) else "False", expr
    )
    expr = re.sub(r"\bAndAlso\b", " and ", expr, flags=re.IGNORECASE)
    expr = re.sub(r"\bOrElse\b", " or ", expr, flags=re.IGNORECASE)
    expr = re.sub(r"\bNot\b", " not ", expr, flags=re.IGNORECASE)
    expr = expr.replace("&&", " and ").replace("||", " or ")
    try:
        return bool(eval(expr, {"__builtins__": {}}, {}))
    except Exception:
        return False


class Frame:
    __slots__ = ("parent_active", "branch_active", "taken", "has_else")

    def __init__(self, parent_active: bool, branch_active: bool, taken: bool):
        self.parent_active = parent_active
        self.branch_active = branch_active
        self.taken = taken
        self.has_else = False


def strip_file(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    stack: list[Frame] = []

    def active() -> bool:
        return all(f.branch_active for f in stack)

    for line in lines:
        m = DIRECTIVE_RE.match(line.rstrip("\r\n"))
        if not m:
            if active():
                out.append(line)
            continue

        kind = m.group("kind").lower()
        rest = m.group("rest").strip()

        if kind == "ifdef":
            sym = rest.split()[0] if rest else ""
            cond = DEFINED.get(sym, False)
            parent = active()
            stack.append(Frame(parent, parent and cond, cond))
        elif kind == "ifndef":
            sym = rest.split()[0] if rest else ""
            cond = not DEFINED.get(sym, False)
            parent = active()
            stack.append(Frame(parent, parent and cond, cond))
        elif kind == "if":
            cond = eval_condition(rest)
            parent = active()
            stack.append(Frame(parent, parent and cond, cond))
        elif kind == "elseif":
            if not stack:
                if active():
                    out.append(line)
                continue
            frame = stack[-1]
            if not frame.parent_active:
                frame.branch_active = False
                frame.taken = True
            elif frame.taken:
                frame.branch_active = False
            else:
                cond = eval_condition(rest)
                frame.branch_active = True
                frame.taken = cond
        elif kind == "else":
            if not stack:
                if active():
                    out.append(line)
                continue
            frame = stack[-1]
            frame.has_else = True
            if not frame.parent_active:
                frame.branch_active = False
            elif frame.taken:
                frame.branch_active = False
            else:
                frame.branch_active = True
                frame.taken = True
        elif kind == "endif":
            if stack:
                stack.pop()
            # Drop bare #endif lines (never emit preprocessor directives we resolved)
        else:
            if active():
                out.append(line)

    return "".join(out)


def process_path(path: Path) -> bool:
    original = path.read_text(encoding="utf-8", errors="replace")
    updated = strip_file(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8", newline="")
        return True
    return False


def main(argv: list[str]) -> int:
    roots = [Path(p) for p in argv[1:]] if len(argv) > 1 else []
    if not roots:
        print("Usage: strip_gtk_preprocessor.py <root>...", file=sys.stderr)
        return 2

    exts = {".bas", ".bi", ".frm"}
    changed = 0
    scanned = 0
    for root in roots:
        for path in root.rglob("*"):
            if path.suffix.lower() in exts and path.is_file():
                scanned += 1
                if process_path(path):
                    changed += 1
                    print(f"updated: {path}")
    print(f"Scanned {scanned} files, updated {changed}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
