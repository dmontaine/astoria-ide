# AI Assistant Guide -- {{PROJECT}}

**Author:** {{AUTHOR}} - **License:** {{LICENSE}} - **Created:** {{DATE}}

This is a **FreeBASIC** project created with the **Astoria IDE**. This file (an
`AGENTS.md`, the cross-tool convention) gives an AI coding assistant the rules
to follow and the task playbooks (skills) for common jobs. Edit it freely as
the project grows.

## Rules

### What this project is

- **Language:** FreeBASIC -- `.bas` (modules), `.bi` (headers), `.frm` (GUI forms, if this is a windowed app).
- **Project manifest:** `{{PROJECT}}.vfp` -- an INI-style file listing every source file (`File=`), with the main file starred (`*File=`), plus build settings and project metadata.
- GUI projects use the **MFF framework** bundled with Astoria (`#include once "mff/Form.bi"`, `Using My.Sys.Forms`). Console projects are plain FreeBASIC.

### Build and run

- **AI agent / MCP (preferred when available):** if the `astoria` MCP server is connected, build and run through its `build` / `run` tools and read `get_errors` -- see the **use-astoria-mcp** skill. The options below are the fallback when MCP isn't connected.
- **Manual:** open `{{PROJECT}}.vfp` in the Astoria IDE and press **F5** (build + run). The IDE handles `.frm` main files, resource (`.rc`) generation, and the framework include path automatically.
- **Command line (console projects):** `fbc -s console <MainFile>.bas`, then run the produced `.exe`.
- **Command line (GUI projects):** needs the framework include path: `<AstoriaDir>\Compiler\fbc64.exe -s gui -i <AstoriaDir>\Controls\Framework <MainFile>.bas`. Two caveats: `fbc` does not accept a `.frm` file as direct input, and the generated `#cmdline "<name>.rc"` line expects an IDE-generated resource file -- **prefer building GUI projects in the IDE**.
- **Errors** are precise: `file.bas(12) error 18: Element not defined, X` -- open that line, fix the root cause, recompile. Fix the FIRST error; later ones often cascade from it.

### FreeBASIC language rules

FreeBASIC is **not** VB.NET, VBA, QBASIC, or C -- do not assume their syntax.

- **Variables:** `Dim As Integer x`, `Dim x As Integer`, or `Var x = 1`. Strings are `String` (ASCII); `WString`/`ZString` are wide/C strings.
- **Procedures:** `Sub`/`Function ... End Sub/Function`; declare in `.bi` headers; pull them in with `#include once "file.bi"`.
- **User types:** `Type Foo ... End Type`, with `Extends` for inheritance and `Declare Virtual` for overridable methods.
- **Memory:** manual for pointers (`New`/`Delete`, `Allocate`/`Deallocate`) -- no garbage collector.
- **Preprocessor:** `#define`, `#include once`, `#if/#endif`, `#macro`.
- **Comments:** `'` (line) or `/' ... '/` (block). **Line continuation:** trailing `_`.
- **Save source as UTF-8 with NO byte-order mark.** FreeBASIC treats a leading BOM as an instruction to make string literals **wide**, so a BOM'd file compiles fine and then prints garbled console output. Astoria strips the BOM on save by design -- if you write a file with your own tools, write it BOM-less too.
- Identifiers are **case-insensitive**; indentation is not significant, but keep it consistent with the surrounding file.
- A local `Dim` is **procedure-scoped**, not block-scoped -- a variable declared inside an `If`/loop is visible for the rest of the `Sub`, so deleting that block can leave later code referencing an undeclared name.
- `IIf(...)` cannot return a `String` -- use an explicit `If/Else` assignment for boolean-to-string logic.
- `Str(a = b)` prints `0`/`-1`, not `"false"`/`"true"` -- a comparison yields an integer. `Str()` of an actual `Boolean` does give `"true"`/`"false"`.
- **Never `ReDim Preserve` an array whose element type owns heap memory** (a UDT holding a `String`/`WString`, or the framework's `UString`). It relocates elements with a shallow copy, so the old element's destructor frees a buffer the survivor still points at -- a double free that crashes later, at the next unrelated touch, not where the fault is. Use a list type, or hold the data as one delimited string.

### Astoria project rules

- **Keep the `.vfp` in sync.** Adding, renaming, or deleting a source file must be mirrored in `{{PROJECT}}.vfp`'s `File=` lines (easiest: do file operations inside the IDE's project Explorer, which maintains the manifest for you). A file not listed there is invisible to the project.
- **Leave the IDE-maintained metadata keys alone** (`Author=`, `License=`, `Description=`, `AIFriendly=`, `AITool=`) -- the IDE round-trips them on every save.
- **`project.astoria`** (project root) is the canonical description file and the marker that identifies this folder as an Astoria project -- it must keep its `AstoriaProject=1` line. It records the creation choices (author, license, description, AI settings) and is what the IDE's **Edit Project Description** reads from (the `.vfp` mirrors some of the same keys). Don't delete or rename it; edit it via **Project menu > Edit Project Description**, or by hand as line-based `Key=Value` (UTF-8).
- **`.frm` files are designer-managed.** The `'#Region "Form"` block (control declarations in the `Type`, layout `With` blocks in the `Constructor`) is generated by Astoria's Form Designer. Edit event-handler bodies freely; make layout/control changes through the Designer when possible. If you must hand-edit the region, keep the `With`-block shape and the `' <ControlName>` comment lines it expects.
- **Do not edit** `Temp/`, produced `.exe` files, or `{{PROJECT}}_Change.log`.

### Editing discipline

- **If the Astoria IDE is running with this project open, edit through the `astoria` MCP server** (`write_file`, `set_active_file_content`) rather than writing to disk behind it. The IDE holds its own copy of each open file; changing it underneath means the IDE prompts to reload on next focus, and if the user declines or the tab is dirty, the two versions compete. Editing over MCP keeps the IDE's copy authoritative.
- Match each file's existing indentation (tabs in generated files) and line endings.
- Keep changes small and compile-checked -- build after each meaningful change.
- Prefer building/running through the Astoria IDE to confirm a change actually works, not just that it compiles.
- Ask before anything destructive or irreversible (deleting files, rewriting history).

## Testing discipline

Three habits, each learned from a real defect that survived a check which looked like it had covered it.

- **Verify by effect, not by return value.** Before trusting a call's result, ask what it returns when it *fails*. If success and failure both return `0`, then `If Foo() = 0` is not a test -- it passes whether or not anything happened. Prove the thing you actually care about: re-read the row, count the lines, check the file exists.
- **Make the assertion as strong as the claim.** "The window opened" is not "the program works" -- a *"DLL not found"* dialog opens a window too. If you claim a feature works, assert on something only a working feature produces.
- **Measure before theorising.** When something behaves unexpectedly, one printed value or log line beats three plausible explanations. A hypothesis formed by reading code is cheap to produce and easy to build on before checking, and a wrong one sends you into the half of the code that was never broken.

When you fix something, re-run the thing that caught it. A fix that has only been compiled has not been tested.

## Skills (task playbooks)

### Build and run the project

1. In the Astoria IDE: open `{{PROJECT}}.vfp`, press **F5**.
2. Console CLI alternative: `fbc -s console <MainFile>.bas`, then run the `.exe` produced next to it.
3. GUI CLI alternative: add `-i <AstoriaDir>\Controls\Framework`; see the Build-and-run rules above for the `.frm`/`.rc` caveats -- the IDE is the reliable path.
4. On failure, read the first `file(line) error N:` message and fix that line first.

### Add a module (.bas / .bi)

1. Create `NewName.bas`. If other files will call into it, also create `NewName.bi` holding the `Declare Sub/Function ...` lines and any shared `Type`s/`Const`s.
2. Implement in the `.bas`; `#include once "NewName.bi"` wherever the declarations are needed.
3. Register the file: add `File=NewName.bas` to `{{PROJECT}}.vfp` (or add the file via the IDE, which does this for you).
4. Compile-check before moving on.

### Add a control and wire an event (GUI projects)

Preferred: use the Astoria Form Designer (drop the control, double-click it to generate the handler). By hand, the MFF pattern is:

1. `#include once "mff/CommandButton.bi"` (or the control's own header) near the other `mff/` includes.
2. In the form's `Type ... Extends Form` block: declare the control and its handler:
   ```
   Declare Sub cmdGo_Click(ByRef Sender As Control)
   Dim As CommandButton cmdGo
   ```
3. In the `Constructor`, configure and wire it:
   ```
   ' cmdGo
   With cmdGo
       .Name = "cmdGo"
       .Text = "Go"
       .SetBounds 10, 10, 90, 28
       .Designer = @This
       .Parent = @This
       .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdGo_Click)
   End With
   ```
4. Implement the handler after the `Type`: `Private Sub <FormType>.cmdGo_Click(ByRef Sender As Control) ... End Sub`.

### Add a new form (GUI projects)

1. Preferred: IDE right-click the project -> Add -> Form (generates and registers it).
2. By hand: copy an existing `.frm`'s shape; rename the `Type`, the shared instance, and every `.Name`/comment consistently; add `File=NewForm.frm` to the `.vfp`.
3. Only the project's **main** form keeps the `#if _MAIN_FILE_ = __FILE__` bootstrap block (`MainForm = True`, `.Show`, `App.Run`) -- a secondary form must not have one.
4. Show it from other code with `NewForm.Show` (modeless) or `NewForm.ShowModal(OwnerForm)` (modal).

### Fix compile errors

- `error 18: Element not defined, X` -- missing `#include once` for the header that declares `X`, or a typo (remember: case-insensitive, so `myVar`/`MyVar` are the same name).
- `error 4: Duplicated definition` -- two declarations collide, possibly only differing by case.
- Linker `undefined reference` -- something was declared but never implemented, or its `.bas` file is missing from the `.vfp`.
- A variable "leaking" between branches -- `Dim` is procedure-scoped; move the `Dim` to the top of the `Sub` or rename.
- Type mismatch on text -- MFF control text properties are `WString`; convert explicitly rather than mixing with `ZString` pointers.
- Always re-read the FIRST reported error before chasing the rest.

---
*Generated by Astoria for Claude Code. Expand with what this project does and how you like to work.*
