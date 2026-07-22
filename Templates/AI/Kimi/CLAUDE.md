# {{PROJECT}}

**Author:** {{AUTHOR}} · **License:** {{LICENSE}} · **Created:** {{DATE}}

This is a **FreeBASIC** project created with the Astoria IDE. This file orients
Claude Code working in this repository. Edit it freely as the project grows —
describe what the program does, its layout, and any rules you want followed.

## What this project is

- **Language:** FreeBASIC — `.bas` (modules), `.bi` (headers), `.frm` (GUI forms
  if this is a windowed app).
- **Project manifest:** `{{PROJECT}}.vfp` — INI-style; lists every source file
  (`File=`), stars the main file (`*File=`), and carries build settings and
  project metadata.
- **How it's normally built:** open the `.vfp` in the **Astoria IDE** and press
  **F5** (build + run). GUI projects use the bundled MFF framework
  (`#include once "mff/Form.bi"`, `Using My.Sys.Forms`). When the `astoria` MCP
  server is connected, build/run it yourself with the `build`/`run` tools instead
  (see **use-astoria-mcp**).

## Skills

Task playbooks live in `.claude/skills/` and load on demand:

- **use-astoria-mcp** — drive the live IDE through the `astoria` MCP server (build, run, read errors, edit files) when it's connected; preferred over manual F5/CLI.
- **build-run** — build and run (via MCP if connected, else IDE F5 or `fbc` CLI with its GUI caveats).
- **fix-compile-errors** — decoding `fbc`'s errors and this stack's common ones.
- **add-module** — new `.bas`/`.bi` pair, registered in the `.vfp`.
- **add-form** — a new `.frm`, the main-form bootstrap rule, Show/ShowModal.
- **add-control-event** — MFF control + event-handler wiring pattern.
- **add-resource** — icons/images/manifests/strings via `.rc`, kept in sync with source + `.vfp`.
- **edit-form-safely** — change a `.frm` without damaging the Designer-managed region.
- **find-framework-control** — locate the right MFF control, its header, properties, events, examples.
- **audit-project-manifest** — check the `.vfp` against the actual source/resource files for stale or missing entries.
- **refactor-freebasic** — rename/move/split code safely (case-insensitive symbols, includes, `.vfp`).
- **debug-freebasic-app** — runtime crashes/hangs/wrong behaviour, breakpoints, GDB, exit codes.
- **winapi-interop** — Win64 API declarations, structs, callbacks, window procs, Unicode, COM.
- **prepare-release** — clean release build, artifact/dependency checks, pre-release checklist.

## FreeBASIC ground rules

FreeBASIC is **not** VB.NET, VBA, QBASIC, or C — do not assume their syntax.

- **Variables:** `Dim As Integer x`, `Dim x As Integer`, or `Var x = 1`. Strings
  are `String` (ASCII); `WString`/`ZString` are wide/C strings.
- **Procedures:** `Sub`/`Function … End Sub/Function`; declare in `.bi` headers;
  pull them in with `#include once "file.bi"`.
- **User types:** `Type Foo … End Type`, with `Extends` for inheritance and
  `Declare Virtual` for overridable methods.
- **Memory:** manual for pointers (`New`/`Delete`, `Allocate`/`Deallocate`) — no
  garbage collector.
- **Preprocessor:** `#define`, `#include once`, `#if/#endif`, `#macro`.
- **Comments:** `'` (line) or `/' … '/` (block). **Line continuation:** trailing
  `_`.
- **Save source as UTF-8 with NO byte-order mark.** This one bites hard and looks
  like a mystery when it does: FreeBASIC treats a leading BOM as an instruction to
  make string literals **wide**, so a BOM'd file compiles fine and then prints
  garbled console output. Astoria strips the BOM when it saves, by design — if you
  write a file with your own tools, write it BOM-less too, or you will reintroduce
  the problem the IDE just removed.
- Identifiers are **case-insensitive**; indentation is not significant, but keep
  it consistent with the surrounding file.
- A local `Dim` is **procedure-scoped**, not block-scoped — a variable declared
  inside an `If`/loop is visible for the rest of the `Sub`, so deleting that block
  can leave later code referencing an undeclared name.
- `IIf(...)` cannot return a `String` — use an explicit `If/Else` assignment.
- `Str(a = b)` prints `0`/`-1`, not `"false"`/`"true"` — a comparison yields an
  integer. `Str()` of an actual `Boolean` does give `"true"`/`"false"`. Mixing
  these up silently inverts assertions in test output.
- **Never `ReDim Preserve` an array whose element type owns heap memory** (a UDT
  holding a `String`/`WString`, or the framework's `UString`). `ReDim Preserve`
  relocates elements with a shallow copy, so the old element's destructor frees a
  buffer the surviving element still points at — a double free that crashes later,
  at the next unrelated touch, not where the fault is. Use a list type, or hold the
  data as one delimited string.

## Astoria project rules

- **Keep the `.vfp` in sync** — adding, renaming, or deleting a source file must
  be mirrored in its `File=` lines (easiest via the IDE's project Explorer). A
  file not listed there is invisible to the project.
- **Leave the IDE-maintained metadata keys alone** (`Author=`, `License=`,
  `Description=`, `AIFriendly=`, `AITool=`) — the IDE round-trips them on save.
- **`project.astoria`** (project root) is the canonical description file and the
  marker that identifies this folder as an Astoria project — it must keep its
  `AstoriaProject=1` line. It records the creation choices (author, license,
  description, AI settings) and is what the IDE's **Edit Project Description**
  reads from (the `.vfp` mirrors some of the same keys). Don't delete or rename
  it; edit it via **Project menu > Edit Project Description**, or by hand as
  line-based `Key=Value` (UTF-8).
- **`.frm` files are designer-managed.** The `'#Region "Form"` block is generated
  by Astoria's Form Designer — edit event-handler bodies freely; prefer the
  Designer for layout/control changes; keep the `With`-block shape and
  `' <ControlName>` comment lines if editing by hand.
- **Do not edit** `Temp/`, produced `.exe` files, or `{{PROJECT}}_Change.log`.

## Editing discipline

- **If the Astoria IDE is running with this project open, edit through the
  `astoria` MCP server** (`write_file`, `set_active_file_content`) rather than
  writing to disk behind it. The IDE holds its own copy of each open file. When you
  change a file underneath it, the next time the user clicks back into the IDE it
  prompts to reload — and if they decline, or an editor buffer is dirty, your change
  and theirs are now competing. Editing over MCP keeps the IDE's copy authoritative
  and avoids the prompt entirely. See **use-astoria-mcp**.
- Match each file's existing indentation (tabs in generated files) and line
  endings.
- Keep changes small and compile-checked. FreeBASIC reports precise errors
  (`file(line) error N: …`) — fix the first one first.
- Prefer building/running through the Astoria IDE to confirm a change actually
  works, not just that it compiles.

## Testing discipline

Three habits, each learned from a real defect that survived a check which looked
like it had covered it.

- **Verify by effect, not by return value.** Before trusting a call's result, ask
  what it returns when it *fails*. If success and failure both return `0`, then
  `If Foo() = 0` is not a test — it passes whether or not anything happened. Prove
  the thing you actually care about: re-read the row, count the lines, check the
  file exists. This is not hypothetical; a database call in this stack returned `0`
  for both, and a test asserting `= 0` reported a confident PASS that could never
  have failed.
- **Make the assertion as strong as the claim.** "The window opened" is not "the
  program works" — a *"DLL not found"* dialog opens a window too. If you claim a
  feature works, assert on something only a working feature produces.
- **Measure before theorising.** When something behaves unexpectedly, one printed
  value or log line beats three plausible explanations. Hypotheses formed by
  reading code are cheap to produce and easy to build on before checking, and a
  wrong one sends you into the half of the code that was never broken. Print the
  state, then decide.

When you fix something, re-run the thing that caught it. A fix that has only been
compiled has not been tested, and the two defects most recently found in this
project were both introduced *by* fixes that read correctly.

## Working with me (Claude Code)

- Ask before anything destructive or irreversible (deleting files, force-pushing,
  etc.).
- Put project-specific context you want me to remember into `resources/` or add
  it to this file.

---
*Starter guide generated by Astoria. Expand it with what this project does and
how you like to work.*
