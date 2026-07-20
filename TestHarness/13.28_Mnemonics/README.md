# ROADMAP 13.28 part 3 — Alt+C / Alt+G / Alt+R do not open their menus

The harnesses built while investigating this defect on 2026-07-20. **The defect is not solved.**
Eleven hypotheses have been tested and disproved; what follows is what is established, what is
ruled out, and which instruments to reuse so none of it has to be re-derived.

## The defect, stated precisely

In Astoria, `Alt+C`, `Alt+G` and `Alt+R` do nothing at all — **and, crucially, do not ring the
system bell**. Every other letter behaves correctly: a letter with a menu opens it, a letter
without one makes Windows enter menu mode, fail to match, and beep.

The cursed set is **exactly {C, G, R}**, established by a full alphabet sweep. It follows the
**letter, not the menu**: rename `&Code` to `Co&de` and `Alt+D` opens it, while `Alt+C` still
fails — and `Alt+R` stays dead even when no menu uses R at all.

## Ruled out — do not re-investigate without new evidence

| # | Hypothesis | How it died |
| --- | --- | --- |
| 1 | Greyed top-level menus | `GetMenuItemInfo` shows Code/Run/Git enabled |
| 2 | Empty user-tool accelerators | Moving `Tools.ini` aside changes nothing |
| 3 | A background app capturing the keys | Other apps on the same machine receive them |
| 4 | Menu items without popups | All popups exist and have items (28/31/7) |
| 5 | comctl32 tab-label mnemonics | The focused class is MFF's own `TabControl`, not `SysTabControl32` |
| 6 | Dependence on which tabs are open | Failing set identical across documents |
| 7 | The accelerator table | Real table dumped in-process: 65 entries, only `Alt+VK_F4` and `Alt+O` are bare-Alt |
| 8 | The message loop | Every letter reaches all three loop stages with `dispatch=YES` |
| 9 | System-menu collisions (`&Close`, `&Restore`) | `Alt+S`/`Alt+N` collide with `&Size`/`Mi&nimize` and work fine |
| 10 | Menu position | `Alt+D` and `Alt+U` open the very menus that were dead |
| 11 | MFF itself | A minimal MFF app with the same menu opens all three |
| — | Add-ins | None are actually loaded |
| — | Settings / workspace | Same failure on a default `astoria.ini` |

## What is established

- The keystrokes reach the process (`WH_KEYBOARD_LL` sees them; a WinForms app on the same machine
  acts on them).
- `WM_SYSCHAR` reaches Astoria's form with `Handled=0, Result=0`, which falls through to
  `DefWindowProc`.
- `DefWindowProc` then produces **neither** menu activation **nor** `WM_MENUCHAR` — for `Alt+E`,
  which matches nothing, it produces both. **That contradiction is the open question.**

## The instruments

| File | What it does |
| --- | --- |
| `ProbeAltMnemonics.ps1` | Drives `Alt+<letter>` into Astoria and classifies the outcome. **See the warning below.** |
| `ProbeMenuBar.ps1` | Reads the live top-level menu bar: caption, mnemonic, enabled state, popup handle, item count |
| `ProbeSysMenu.ps1` | Reads the window's system menu (`&Restore`, `&Close`, …) |
| `ComputeAccels.ps1` | Reconstructs the accelerator table from live menu captions using MFF's own parsing rules |
| `FocusChain.ps1` | Prints the focused window and its parent chain with Win32 class names |
| `ControlMenuApp.ps1` | A WinForms app with the same mnemonics — a control for "is it the machine?" |
| `ProbeControlApp.ps1` | Drives the control app or the MFF app, with a `WH_KEYBOARD_LL` hook recording what the input stack saw |
| `MffMnemonicTest.bas` | Minimal MFF app: Form + MainMenu + Panel→Panel→TabControl. Build with `Compiler\fbc64.exe MffMnemonicTest.bas -s gui -gen gcc -mt -Wc -O2 -x MffMnemonicTest.exe -i Controls\Framework`, and copy `framework.dll` beside it |

### In-process instrumentation (in the IDE and framework, gated OFF by default)

| Gate | Writes | Records |
| --- | --- | --- |
| `Temp\_astoria_menukeys.on` exists | `Temp\_astoria_menukeys.log` | `WM_SYSKEYDOWN/SYSCHAR/MENUCHAR/INITMENU/INITMENUPOPUP/SC_KEYMENU` at the main form |
| `ASTORIA_LOGSYSCHAR=1` | `%TEMP%\_astoria_syschar.log` | Per-dispatch `Handled`/`Result` in `Control.DefWndProc`/`CallWndProc`/`SuperWndProc` |
| `ASTORIA_LOGSYSCHAR=1` | `%TEMP%\_astoria_loop.log` | Message-loop fate at three stages in `Application.Run` |
| `ASTORIA_LOGSYSCHAR=1` | `%TEMP%\_astoria_accels.log` | The real accelerator table via `CopyAcceleratorTable` |

## Warnings, all of them earned

- **The bell is the diagnostic.** The owner identified the defect signature by *ear*: letters with
  no menu ring the system bell, C/G/R are silent. A single-sample probe cannot tell those apart —
  both look like "no menu" a moment later. `ProbeAltMnemonics.ps1` now polls every 10ms and reports
  three outcomes (`MENU OPENED` / `BELL` / `SWALLOWED`). **That change is written but NOT YET
  VERIFIED — prove it reproduces the bell/no-bell split before trusting a run.**
- **Verify the IDE is still alive after a run.** Probe output looks the same whether the target
  exited early or finished normally.
- **Restore the foreground before every keystroke.** One shortcut that opens a window turns every
  later letter into a false negative.
- **Exclude `O` from alphabet sweeps.** `Alt+O` is a real accelerator and opens a modal dialog that
  disables the main window.
- **Make the instrument prove it can report a positive first.** Two harnesses here reported
  everything dead because they were sending nothing: the x64 `INPUT` struct is 40 bytes, not 32, and
  `[short]` is not a PowerShell type accelerator.
- `vk=&h73` in the accelerator dump renders as `'s'`; it is `VK_F4`, not the letter S.

## Suggested next step

The bisection ladder (add pieces of Astoria to the minimal MFF app until the letters break) reached:
Form+MainMenu ✓, context menus ✓, Panel→Panel→TabControl ✓ — all still working. Step 3 was to be
Astoria's `EditControl`, which was **attempted and abandoned**: despite `EditControl.bi` including
only mff headers, `EditControl.bas` references a long tail of Astoria globals. Pick a different rung
— toolbars, image lists, the status bar, or the worker threads — or find a way to disable parts of
Astoria's startup instead.
