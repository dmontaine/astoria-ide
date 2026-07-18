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
- **git-workflow** — commit/push a git-backed project; the remote lives in `project.astoria` (IDE Project menu > Git Commit/Push, or git CLI over SSH).
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
- Identifiers are **case-insensitive**; indentation is not significant, but keep
  it consistent with the surrounding file.
- A local `Dim` is **procedure-scoped**, not block-scoped — a variable declared
  inside an `If`/loop is visible for the rest of the `Sub`, so deleting that block
  can leave later code referencing an undeclared name.
- `IIf(...)` cannot return a `String` — use an explicit `If/Else` assignment.

## Astoria project rules

- **Keep the `.vfp` in sync** — adding, renaming, or deleting a source file must
  be mirrored in its `File=` lines (easiest via the IDE's project Explorer). A
  file not listed there is invisible to the project.
- **Leave the IDE-maintained metadata keys alone** (`Author=`, `License=`,
  `Description=`, `UseGit=`, `GitProvider=`, `GitUserName=`, `GitEmail=`,
  `GitURL=`, `AIFriendly=`, `AITool=`) — the IDE round-trips them on save.
- **`project.astoria`** (project root) is the canonical description file and the
  marker that identifies this folder as an Astoria project — it must keep its
  `AstoriaProject=1` line. It records the creation choices (author, license,
  description, Git provider/username/email/remote URL, AI settings) and is what
  the IDE's **Edit Project Description** and **Git Commit/Push** features read
  from (the `.vfp` mirrors some of the same keys). Don't delete or rename it;
  edit it via **Project menu > Edit Project Description**, or by hand as
  line-based `Key=Value` (UTF-8). See the **git-workflow** skill.
- **`.frm` files are designer-managed.** The `'#Region "Form"` block is generated
  by Astoria's Form Designer — edit event-handler bodies freely; prefer the
  Designer for layout/control changes; keep the `With`-block shape and
  `' <ControlName>` comment lines if editing by hand.
- **Do not edit** `Temp/`, produced `.exe` files, or `{{PROJECT}}_Change.log`.

## Editing discipline

- Match each file's existing indentation (tabs in generated files) and line
  endings.
- Keep changes small and compile-checked. FreeBASIC reports precise errors
  (`file(line) error N: …`) — fix the first one first.
- Prefer building/running through the Astoria IDE to confirm a change actually
  works, not just that it compiles.

## Working with me (Claude Code)

- Ask before anything destructive or irreversible (deleting files, force-pushing,
  etc.).
- Commit only when asked; write clear, scoped commit messages; never force-push.
  If this project is git-backed, its remote lives in `project.astoria` and a
  `.gitignore`/`.gitattributes` pair is already provided — commit/push via
  **Project > Git Commit/Push** or the git CLI over SSH (see **git-workflow**).
- Put project-specific context you want me to remember into `resources/` or add
  it to this file.

---
*Starter guide generated by Astoria. Expand it with what this project does and
how you like to work.*
