# AstoriaIDE — Threading

This document describes how background work and UI updates are coordinated in the IDE.

## ThreadsEnter / ThreadsLeave — no-ops; they guarantee NOTHING

Defined in `Controls/MyFbFramework/mff/Component.bas` (see the block comment there) and declared in `Component.bi`.

| Platform | `ThreadsEnter` | `ThreadsLeave` |
|----------|--------------|----------------|
| WinAPI (Windows 64-bit IDE) | **empty no-op** | **empty no-op** |

**Contract (resolved 2026-07-12, T-OPUS-1): a `ThreadsEnter … ThreadsLeave` block provides NO synchronization and NO safety. It is a cross-target marker only.** They are a GTK-ism (`gdk_threads_enter/leave`, GTK's global UI lock); Win32 has no equivalent, so on this build they are empty. **They will not be given a real implementation** — a lock here would be *wrong*, not a fix: Win32 controls have thread affinity (a worker touching a control is undefined regardless of any lock), and a process-wide lock held by a worker that then repaints/`SendMessage`s the UI thread deadlocks — this is precisely the DR-3 hang. There are ~69 legacy `ThreadsEnter` blocks in `src/` (worker subs in `BuildService.bas`, `Debug.bas`, `AstoriaIDE.bas`, …); each is a latent unsynchronized race, and MFF itself contains zero uses.

**The rule for any cross-thread UI update: marshal to the UI thread.** Do NOT touch controls (`.Nodes.Add/.Clear`, paint, `.Text=`, `.Enabled=`, `ShowMessages`) directly from a worker. Stage the data on the worker; apply it on the UI thread from a timer/message callback. This is the pattern the debugger converged on across DR-2D / DR-7 / DR-16:

```freebasic
' worker thread — stage only, no control access
gRawLocals = readpipe(...)        ' Debug.bas RefreshDebugPanelsAfterStop
bPanelFillPending = True

' UI thread — apply (TimerProcGDB tick)
FillDebugPanelsOnUI()             ' parses gRaw* into lvLocals/lvGlobals/...
FlushDebugOutputOnUI()            ' Output text / watch edits / panel clears
```

The legacy `ThreadsEnter`-wrapped worker→UI sites are migrated to this marshal pattern opportunistically as bugs surface (the debugger paths are done; compile/find/etc. are not yet — treat any new hang or corruption there as this class).

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
| Debug engine | Debugger | `RunProgramWithDebug`→`run_debug` (`Debug.bas`) | Single worker thread owns the GDB pipe; see `tlockGDB` below |

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

## Rules for UI updates from background threads

1. **Wrap UI calls** in `ThreadsEnter` / `ThreadsLeave` (compile output, Problems list, progress bar, message pane, debug toolbar state).
2. **Protect shared data** with the appropriate `tlock*` mutex when multiple workers can touch the same tab, include list, or GDB pipe.
3. **Do not call blocking UI dialogs** (`MsgBox`, modal `InputBox`) from worker threads without marshaling to the main thread.
4. **Check `FormClosing`** in long-running load threads before touching UI or global lists.
5. **Prefer `ThreadCounter`** for menu-spawned work so handles remain tracked.

When adding new background work, follow an existing neighbor (compile → `CompileProgram`; formatting → `FormatProject`).
