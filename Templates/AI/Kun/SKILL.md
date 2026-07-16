---
name: freebasic-project
description: Build, run, and safely edit this FreeBASIC project ({{PROJECT}}). Trigger when working on any .bas/.bi/.frm file, or when compiling or running the program.
---

# FreeBASIC project — {{PROJECT}}

**Author:** {{AUTHOR}} · **License:** {{LICENSE}} · **Created:** {{DATE}}

This project is written in **FreeBASIC** and was created with the Astoria IDE.

## Build / run
- In the Astoria IDE: open the `.vfp` project and press **F5** (build) / Run.
- Command line: `fbc {{PROJECT}}.bas` (add `-s console` or `-s gui`), then run the executable.

## FreeBASIC ground rules
FreeBASIC is not VB.NET, VBA, QBASIC, or C — do not assume their syntax.
- Variables: `Dim As Integer x` / `Var x = 1`; strings are `String`, `WString`, `ZString`.
- Procedures: `Sub`/`Function … End`; declare in `.bi`; `#include once "file.bi"`.
- User types: `Type … End Type`, `Extends`, `Declare Virtual`.
- Manual memory for pointers (`New`/`Delete`, `Allocate`/`Deallocate`).
- Comments `'` or `/' … '/`; line continuation trailing `_`; identifiers case-insensitive.
- A local `Dim` is procedure-scoped, not block-scoped.

## Editing discipline
- Match existing indentation and line endings; keep changes small and compile-checked.
- Read FreeBASIC's precise `file(line) error N: …` messages and fix the root cause.

> Starter scaffold. Expand with what the project does and how you like to work.
