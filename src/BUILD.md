# Visual FB Editor — Build Pipeline

How the IDE compiles user projects and how the IDE itself is built.

## IDE self-build (`Compile.bat`)

Root `Compile.bat` is a **two-step** Win64-only build using the bundled compiler at `Compiler\fbc64.exe`:

1. **MyFbFramework** — `cd Controls\MyFbFramework\mff`, build `mff64.dll` with `fbc64`.
2. **Visual FB Editor** — `cd src`, build `VisualFBEditor64.exe` with `fbc64`, linking `VisualFBEditor.rc` and `-i ..\Controls\MyFbFramework`.

Linux, GTK, and 32-bit IDE builds are not supported in this fork.

Close a running IDE before overwriting `VisualFBEditor64.exe` (file lock on Windows). Use `-x ../VisualFBEditor64_buildtest.exe` for a side-by-side test build.

## Dev leak audits (`MEMCHECK` / `FILENUMCHECK`)

`VisualFBEditor.bas` defines these guards at the top of the entry file (before `#include once "Main.bi"`). **Shipped default: both off** (`MEMCHECK 0`, `FILENUMCHECK 0`).

To audit memory or file-handle leaks locally:

1. Open `src/VisualFBEditor.bas` and uncomment one or both lines:
   ```bas
   '#define MEMCHECK 1
   '#define FILENUMCHECK 1
   ```
2. Rebuild with `Compile.bat` (or `fbc64` from `src/`).
3. Run the IDE, exercise the areas under test, then exit — `MEMCHECK` reports unfreed allocations to stderr; `FILENUMCHECK` reports mismatched `FreeFile`/`Close` use.
4. Re-comment (or remove) the defines before shipping a release build.

Alternate: pass compile defines without editing the source:

```bat
fbc64 -d MEMCHECK=1 -d FILENUMCHECK=1 VisualFBEditor.bas ...
```

MyFbFramework (`mff.bi`) also defaults `MEMCHECK` to `0` when undefined; the IDE entry file sets the value used for the full link.

Manual equivalent from `src/`:

```bat
fbc64 VisualFBEditor.bas -s gui -gen gcc -Wc -O2 -x ../VisualFBEditor64.exe VisualFBEditor.rc -i "..\Controls\MyFbFramework" -v
```

## Bundled compiler

The IDE ships with a single FreeBASIC compiler at `{ExePath}\Compiler\fbc64.exe`. Path constants in `Main.bi`:

| Constant | Value |
|----------|-------|
| `BUNDLED_COMPILER_FOLDER` | `Compiler` |
| `BUNDLED_COMPILER_EXE` | `fbc64.exe` |

Runtime helpers: `GetBundledCompilerFolder()`, `GetBundledCompilerExe()`, `SetBundledCompilerPath()`.

## Compiler command-line flags

Default `fbc` switches are stored in `Settings/VisualFBEditor64.ini` under `[Parameters]`:

| Key | Default | Purpose |
|-----|---------|---------|
| `Compiler64Arguments` | `-b {S} -exx` | Flags prepended to every compile via `GetFirstCompileLine()` |

Edit these in **Project → Parameters** (Compile group, Command line field). The **+** button opens the compiler options picker.

## `Compile()` pipeline (`Main.bas`)

High-level flow for **Build → Compile** (and syntax check, make, run-with-debug, etc.):

```
GetMainFile / project node
    → GetBundledCompilerExe() (or project custom CompilerPath)
    → GetFirstCompileLine() → Compiler64Arguments + project flags
    → build fbcCommand (main file, modules, -i paths, build config)
    → WLet(PipeCommand, """" & FbcExe & """ " & fbcCommand)
    → spawn compiler, read stdout/stderr
    → SplitError + lvProblems + ShowMessages
```

### `PipeCommand` and process spawn

| Target | Mechanism |
|--------|-----------|
| **WinAPI** | `CreatePipe` + `CreateProcess(PipeCommand, …)` — reads child stdout/stderr via `ReadFile` |

`PipeApplicationName` is typically `NULL`; the full command line is in `PipeCommand` (quoted `fbc64.exe` path + arguments).

Alternate `PipeCommand` sources:

- **make** — `MakeToolPath1` / `MakeToolPath2` with `FBC:=` and `XFLAG:=`.
- **Android** — project `BatchCompilationFileName` (`gradlew`, custom batch).
- **WebAssembly** — multi-step `CompileCommands` (`emcc` after `fbc`).

Working directory is set with `ChDir` to the main file folder (or project / makefile location).

## Problems panel — error parsing

Compiler output lines are classified in `Compile()`:

1. **Progress / noise** — prefix matched against `TmpStrKey` (`compiling`, `linking`, `FreeBASIC`, …) → status messages only.
2. **Diagnostics** — `SplitError(line, ErrFileName, ErrTitle, iLine)` returns severity flag:
   - `2` = Error → `NumberErr`
   - `1` = Warning → `NumberWarning`
   - `0` = Info
3. **Problems list** — `lvProblems.ListItems.Add` with icon column (Warning/Error/Info), line number, and file path (relative paths resolved against main file folder).

After compile, `tpProblems->Caption` reflects error/warning counts; double-click navigates via existing Problems handlers.

## Related files

| File | Role |
|------|------|
| `Main.bas` | `Compile`, `GetBundledCompilerExe`, `LoadSettings`, Problems UI |
| `Main.bi` | Bundled compiler constants, shared paths, declarations |
| `frmParameters.frm` | `Compiler64Arguments` editor (Parameters dialog) |
| `VisualFBEditor.bas` | Menu → `ThreadCreate_` → compile/format/debug workers |
| `TabWindow.bas` | `FormatProject`, `GetFirstCompileLine`, per-tab build helpers |
| `Settings/VisualFBEditor64.ini` | `Compiler64Arguments` and other tool settings |
| `Compile.bat` | Release build of framework + IDE |
