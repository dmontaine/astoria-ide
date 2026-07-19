# Astoria IDE — working on the IDE itself

This file orients an AI assistant working on **Astoria's own source**. It is not the file
that ships to users: `Templates/AI/ClaudeCode/CLAUDE.md` is the template installed into
*projects created with* Astoria, and it describes writing FreeBASIC apps. This one is about
maintaining the IDE.

Astoria is a 64-bit Windows IDE for FreeBASIC, forked from VisualFBEditor, written in
FreeBASIC itself on the MyFbFramework (MFF) GUI library.

## Read these first

| Document | What it is |
| --- | --- |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | The authoritative handoff. Start here: current state, what is in flight, what to do next. |
| [ROADMAP.md](ROADMAP.md) | Enhancement specs and open defects, numbered (`§13.x`). Release blockers are marked. |
| [Documentation/Testing.md](Documentation/Testing.md) | What is proven, and — just as important — what is not. |
| [Documentation/TestPlan.md](Documentation/TestPlan.md) | Named test scenarios with results. **Includes the rule for which documents to update after every test.** |
| [HISTORY.md](HISTORY.md) | Archived session narratives and investigations. |

## Layout

- `src/` — the IDE. `Main.bas` is large and central; `TabWindow.bas` owns open documents and
  the designer bridge; `AstoriaIDE.bas` is the entry point and command dispatch.
- `Controls/Framework/` — the vendored MFF GUI framework (`mff/`). Astoria-specific fixes
  live here and are documented in `Documentation/Controls.md`.
- `Controls/<Name>/` — optional control libraries (SQLite3, MariaDBBox, Scintilla…), each
  declaring its runtime DLLs in its own `Settings.ini`.
- `Templates/` — project and AI templates installed into new user projects.
- `Examples/Integration/` — test fixtures for `Documentation/TestPlan.md`.
- `Settings/astoria.default.ini` — shipped defaults (tracked). `Settings/astoria.ini` is the
  live user file and is **not** tracked.

## Building

```
NOPAUSE=1 SKIP_MFF=1 Compile.bat        # release build: astoria.exe + astoria-mcp.exe
```

- **Close the running IDE first** — linking fails while `astoria.exe` is in use.
- `SKIP_MFF=1` reuses the built framework; `FORCE_MFF=1` rebuilds it.
- A full build takes roughly four minutes. The framework emits a handful of
  `warning 36: Mismatching parameter initializer` lines; those are pre-existing and expected.
- **Check that the build actually ran.** Piping output can mask a failure behind a zero exit
  code from the pipe, and matching file timestamps after a `git pull` look exactly like a
  successful rebuild. Verify the exe is newer than your edit.

## FreeBASIC traps that have actually cost time here

- **UTF-8 BOM makes string literals wide.** A BOM'd source compiles and then prints garbled
  console output. Astoria deliberately normalises files to BOM-less UTF-8 on save, and
  `AgentPipe.bas` downgrades `Utf8BOM` → `Utf8` before agent builds. This is policy, not a
  fidelity bug — it was once "fixed" in the wrong direction and had to be reverted. Do not
  write BOMs.
- **Never `ReDim Preserve` an array whose elements own heap memory** (a UDT holding a
  `String`/`WString`, or MFF's `UString`). It relocates with a shallow copy, so the old
  element's destructor frees a buffer the survivor still points at. The double free surfaces
  at the next unrelated touch, not at the fault. This crashed the IDE in July 2026.
- `IIf(...)` cannot yield a `String`/`WString` — use explicit `If/Else`.
- `Str(a = b)` gives `0`/`-1`, not `"false"`/`"true"`. `Str()` of a real `Boolean` does give
  `"true"`/`"false"`.
- A local `Dim` is **procedure-scoped**, not block-scoped — deleting an `If` block can leave
  later code referencing a name that is no longer declared.
- Identifiers are case-insensitive. Watch for collisions with FB keywords when naming things
  (`Name`, `Step`, `Ok`, `out`, `pos`, `value`, `line`, `msg`, `val` have all bitten).
- Win32 flag tests need hex: `GetKeyState(...) And &h8000`, not `And 8000`. The decimal form
  is truthy by accident for some inputs and zero for others — it was wrong in 19 places.
- P/Invoke and `...W` APIs need `CharSet.Unicode`, or strings truncate at the first NUL.

## Working practices

- **Do not edit a file on disk while the IDE has it open.** The IDE holds its own copy; it
  will prompt to reload on next activation, and a dirty tab means the two versions compete.
  Use the `astoria` MCP server if it is running.
- **Update the reference documents after every test.** `Documentation/TestPlan.md` opens with
  a table of which document to touch when. Test documents stay current because running a test
  forces a visit; reference documents drift because nothing does. `Controls.md` is the one
  most often missed.
- **`DetailedChangelog.md` is generated from commit messages** — write good ones, and
  regenerate rather than hand-editing.
- Commit and push only when asked.

## Testing discipline

- **Verify by effect, not by return value.** Ask what a call returns when it *fails*. A
  database call here returned `0` for both success and failure, and a test asserting `= 0`
  reported a confident PASS that could never have failed.
- **Make the assertion as strong as the claim.** "The window opened" is not "it works" — a
  *"DLL not found"* dialog opens a window too. Two startup failures were once recorded as
  passes for exactly this reason.
- **Measure before theorising.** One printed value beats three plausible explanations. A
  hypothesis formed by reading code is cheap to produce and easy to build on before checking,
  and a wrong one sends you into the half of the code that was never broken.
- **Re-run the thing that caught it.** A fix that has only been compiled has not been tested;
  the two most recent defects in this project were both introduced *by* fixes that read
  correctly.
- Report outcomes plainly. If something is unverified, say so — `Testing.md` is written for
  outside testers and its credibility depends on the gaps being honest.

## Product standard

Astoria's stated rule is that a feature either works or does not ship: a broken menu item or
a control that fails on use costs a newcomer more than a missing feature, because they cannot
tell a broken tool from their own mistake. When there is a choice, take the more robust
option — the goal is *"it just works"*. See
[Documentation/AstoriaIDESignificantChanges.md](Documentation/AstoriaIDESignificantChanges.md).
