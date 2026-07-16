---
name: freebasic-project
description: Rules and task playbooks for building, running, and safely editing this FreeBASIC project ({{PROJECT}}). Trigger when working on any .bas/.bi/.frm file, compiling, running, or adding files, controls, or forms.
---

# FreeBASIC project — {{PROJECT}}

**Author:** {{AUTHOR}} · **License:** {{LICENSE}} · **Created:** {{DATE}}

FreeBASIC project created with the **Astoria IDE**. See `AGENTS.md` for the full guide; this file is the working summary.

## Rules

FreeBASIC is not VB.NET, VBA, QBASIC, or C — do not assume their syntax.

- Variables: `Dim As Integer x` / `Var x = 1`; strings are `String`, `WString`, `ZString`.
- Procedures: `Sub`/`Function … End`; declare in `.bi`; `#include once "file.bi"`.
- Types: `Type … End Type`, `Extends`, `Declare Virtual`. Manual memory for pointers.
- Comments `'` or `/' … '/`; continuation trailing `_`; identifiers case-insensitive.
- `Dim` is **procedure-scoped**, not block-scoped. `IIf(...)` cannot return a `String`.
- `{{PROJECT}}.vfp` is the manifest: every source file is a `File=` line, main file starred (`*File=`). Mirror any file add/rename/delete there; leave the IDE-maintained metadata keys (`Author=` … `AITool=`) alone.
- `.frm` files are Form-Designer-managed: edit handler bodies freely; keep the `With`-block shape and `' <ControlName>` comment lines if hand-editing.
- Do not edit `Temp/`, produced `.exe` files, or `{{PROJECT}}_Change.log`.
- Keep changes small and compile-checked; match existing indentation/line endings.

## Build and run

1. Preferred: open `{{PROJECT}}.vfp` in the Astoria IDE, press **F5** (handles `.frm` mains, `.rc` generation, include paths).
2. Console CLI: `fbc -s console <MainFile>.bas`, then run the `.exe`.
3. GUI CLI: `<AstoriaDir>\Compiler\fbc64.exe -s gui -i <AstoriaDir>\Controls\Framework <MainFile>.bas` — `fbc` rejects `.frm` input and the `#cmdline "<name>.rc"` needs the IDE-generated resource, so prefer the IDE.
4. Errors are `file(line) error N: message` — fix the FIRST one first.

## Add a module

1. Create `NewName.bas` (+ `NewName.bi` with `Declare` lines / shared `Type`s if other files call in); `#include once "NewName.bi"` where needed.
2. Register: add `File=NewName.bas` to `{{PROJECT}}.vfp` (or add via the IDE Explorer).

## Add a control + event (GUI)

Preferred: Astoria Form Designer (drop control, double-click for handler). By hand:
1. `#include once "mff/CommandButton.bi"` (or the control's header).
2. In the form `Type`: `Declare Sub cmdGo_Click(ByRef Sender As Control)` and `Dim As CommandButton cmdGo`.
3. In the `Constructor`:
   ```
   ' cmdGo
   With cmdGo
       .Name = "cmdGo" : .Text = "Go"
       .SetBounds 10, 10, 90, 28
       .Designer = @This : .Parent = @This
       .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdGo_Click)
   End With
   ```
4. Implement `Private Sub <FormType>.cmdGo_Click(ByRef Sender As Control) … End Sub` after the `Type`.

## Add a form (GUI)

1. Preferred: IDE right-click project → Add → Form. By hand: copy an existing `.frm`'s shape, rename Type/instance/`.Name`s consistently, add `File=NewForm.frm` to the `.vfp`.
2. Only the MAIN form keeps the `#if _MAIN_FILE_ = __FILE__` bootstrap (`MainForm = True`, `.Show`, `App.Run`).
3. Show with `NewForm.Show` (modeless) or `NewForm.ShowModal(OwnerForm)` (modal).

## Fix compile errors

- `error 18: Element not defined, X` → missing `#include once` or typo (case-insensitive names).
- `error 4: Duplicated definition` → collision, possibly case-only.
- Linker `undefined reference` → declared but unimplemented, or `.bas` missing from the `.vfp`.
- `error 24: Invalid data types` on `IIf` → rewrite as `If/Else`.
- Unexpected variable visibility → `Dim` is procedure-scoped.

> Expand this file with what the project does and how you like to work.
