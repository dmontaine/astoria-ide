# AstoriaIDE — Threading

This document describes how background work and UI updates are coordinated in the IDE.

## ThreadsEnter / ThreadsLeave

Defined in `Controls/MyFbFramework/mff/Component.bas` and declared in `Component.bi`.

| Platform | `ThreadsEnter` | `ThreadsLeave` |
|----------|--------------|----------------|
| WinAPI (Windows 64-bit IDE) | (no-op) | (no-op) |

**Purpose:** Worker threads that update controls or call `ShowMessages` wrap those calls in `ThreadsEnter()` / `ThreadsLeave()` for API consistency with the framework.

**Usage pattern** (throughout `Main.bas`, `VisualFBEditor.bas`, `TabWindow.bas`):

```freebasic
ThreadsEnter()
ShowMessages(...)
lvProblems.ListItems.Add ...
ThreadsLeave()
```

On pure WinAPI builds these calls are effectively no-ops, but the pattern is kept for a single code path across targets.

## Worker thread spawning

Menu and toolbar actions do not run heavy work on the UI thread. They call:

```freebasic
ThreadCounter(ThreadCreate_(@WorkerSub, optionalParam))
```

- `ThreadCreate_` — MFF wrapper around `ThreadCreate` (see `Component.bas`).
- `ThreadCounter` — appends the thread handle to the shared `Threads` list (`Main.bas`) for lifecycle tracking.
- `ClearThreadsWindow` — clears the debugger **Threads** panel UI (`VisualFBEditor.bas`); unrelated to `ThreadCounter`.

### Operations that run on worker threads

| Area | Entry point | Worker sub | Notes |
|------|-------------|------------|-------|
| Compile | Build menu | `CompileProgram`, `CompileAll`, `SyntaxCheck`, `MakeExecute`, … | All call `Compile()` in `Main.bas` |
| Format | Edit menu | `FormatProject` (`TabWindow.bas`) | Project-wide beautify/unformat |
| Find/Replace | Search dialogs | `FindSub`, `ReplaceSub` | Search in files |
| Help | F1 / help menu | `RunHelp` | Fetches help content |
| Command prompt | Tools | `RunCmd` | Spawns external shell |
| Run / Debug | Run menu | `CompileAndRun`, `StartDebugging`, `StartDebuggingWithCompile`, `RunProgram` | Compile and/or launch debuggee |
| IntelliSense | Tab open / edit | `LoadFunctionsSub`, `LoadOnlyFilePath`, … | Background include parsing |
| Debug engine | Debugger | `start_pgm`, `attach_debuggee` (`Debug.bas`) | Separate from menu worker pattern |

GDB integrated debugger additionally uses `tlockGDB` and timer callbacks (`TimerProcGDB`).

## Mutex handles (`tlock*`)

Declared in `Main.bi`, created at startup in `Main.bas`:

| Mutex | Role |
|-------|------|
| `tlock` | Serializes IntelliSense load counter / status bar updates (`StartOfLoadFunctions` / `EndOfLoadFunctions`) |
| `tlockSave` | Protects tab save/load and project file writes (`TabWindow.bas`, `LoadFunctions` paths in `Main.bas`) |
| `tlockToDo` | Find-in-files / To-Do list updates (`frmFind.frm`) |
| `tlockGDB` | GDB debugger I/O and command queue (`Main.bas`, `Debug.bas`) |
| `tlockSuggestions` | Per-tab autocomplete / suggestion rebuild (`TabWindow.bas`) |

## Debug `blocker` mutex

Separate from `tlock*`, defined at the top of `Debug.bas`:

```freebasic
Dim Shared As Any Ptr blocker
blocker = MutexCreate
```

Used in the integrated IDE debugger event loop to serialize debuggee stop/resume handling between the debug thread and the timer-driven UI thread. Typical pattern:

1. `MutexLock blocker` before processing a debug event.
2. `MutexUnlock blocker` when the event is handled or when waiting on `CondWait(condid, blocker)` for the next event.

This prevents two threads from advancing the debuggee or updating breakpoint state concurrently.

## Rules for UI updates from background threads

1. **Wrap UI calls** in `ThreadsEnter` / `ThreadsLeave` (compile output, Problems list, progress bar, message pane, debug toolbar state).
2. **Protect shared data** with the appropriate `tlock*` mutex when multiple workers can touch the same tab, include list, or GDB pipe.
3. **Do not call blocking UI dialogs** (`MsgBox`, modal `InputBox`) from worker threads without marshaling to the main thread.
4. **Check `FormClosing`** in long-running load threads before touching UI or global lists.
5. **Prefer `ThreadCounter`** for menu-spawned work so handles remain tracked.

When adding new background work, follow an existing neighbor (compile → `CompileProgram`; formatting → `FormatProject`).
