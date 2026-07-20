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
| 12 | A hidden/duplicate menu-bar item claiming C, G, R | Full menu bar dumped live: 11 items, no duplicate C/G/R, all three enabled with populated popups |
| — | Add-ins | None are actually loaded |
| — | Settings / workspace | Same failure on a default `astoria.ini` |

### Hypothesis 12 in full (2026-07-20, later)

The idea was that Windows matches the **first** menu-bar item carrying a mnemonic, so a second,
non-visible item claiming C/G/R would match first and then do nothing — producing *silence* rather
than a bell, because a match suppresses `WM_MENUCHAR`. That fits the observed signature exactly, and
`ProbeMenuBar.ps1`'s own comments describe the mechanism. It is nonetheless **wrong**. The live dump:

```
  [ 0] "&File"        Alt+F  enabled   popup items=24
  [ 1] "&View"        Alt+V  enabled   popup items=16
  [ 2] "&Project"     Alt+P  enabled   popup items=16
  [ 3] "&Code"        Alt+C  enabled   popup items=28
  [ 4] "Code/Form"    (none) enabled   popup items=9
  [ 5] "&Form"        Alt+F  DISABLED  popup items=22
  [ 6] "&Run"         Alt+R  enabled   popup items=31
  [ 7] "&Git"         Alt+G  enabled   popup items=7
  [ 8] "&Tools"       Alt+T  enabled   popup items=9
  [ 9] "&Window"      Alt+W  enabled   popup items=2
  [10] "&Help"        Alt+H  enabled   popup items=7
```

Each of C, G and R is claimed exactly once, by an enabled item with a populated popup. No
owner-drawn item, no command item without a popup, no empty popup. Position does not explain it
either: failing indices are 3, 6, 7 while 0, 1, 2, 8, 9, 10 work — no contiguous region.

**Two unrelated findings from the same dump, for 13.35 rather than 13.28:** `&Form` at [5] is a
genuine duplicate `Alt+F` (harmless only because `&File` at [0] matches first), and `Code/Form` at
[4] is the one top-level menu with no mnemonic at all. Worth checking whether `ValidateHotKeys`
covers menu-bar-to-menu-bar collisions or only accelerator-to-menu.

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

## The user-mode debugger approach is a dead end — do not repeat it

**A `cdb` trace of `user32` cannot see menu mnemonic handling at all.** This was tried on
2026-07-20 and the run is void: it failed its own positive control.

`SysCharTrace.cdb` + `RunSysCharTrace.ps1` armed non-stopping breakpoints on `USER32!MessageBeep`,
`NtUserCalcMenuBar`, `NtUserEndMenu`, `NtUserHiliteMenuItem` and `NtUserTrackPopupMenuEx`, then sent
`Alt+E` (control — must beep), `Alt+C`, `Alt+G`, `Alt+R` and `Alt+F` (control — must open File).
All five breakpoints resolved to real addresses and the target survived the sweep. Result:

| Breakpoint | Hits across all five letters |
| --- | --- |
| `MessageBeep` | **0** |
| `TrackPopupMenuEx` | 0 |
| `HiliteMenuItem` | 0 |
| `EndMenu` | 1 |
| `CalcMenuBar` | 44 (layout noise, unrelated to keystrokes) |

**`Alt+E` produced no beep and `Alt+F` produced no menu signal.** Both controls failed, so the
silence for C/G/R means nothing. The correct reading is *instrument blind*, not *no beep*.

The reason is structural: the `user32!*Menu*` exports are the **API entry points applications call**,
not the code that services a keystroke. Menu-mode handling — including the mnemonic match and the
no-match bell — runs in `win32kfull.sys` on the far side of the syscall boundary. Nothing in the
app's own address space is on that path. Checking which side of the syscall a function lives on,
*before* building a trace around it, would have caught this in a minute.

The scripts are kept because they are correct instruments for a different question (they do work,
they are just pointed at the wrong layer), and because the negative is worth preserving.

## Tooling now installed (2026-07-20)

| What | Where |
| --- | --- |
| Debugging Tools for Windows (`cdb.exe`, `kd.exe`, `symchk.exe`, `dbh.exe`) | `C:\Program Files (x86)\Windows Kits\10\Debuggers\x64` |
| Symbol cache | `C:\Symbols`, `_NT_SYMBOL_PATH` set at user scope |

Installed from the Windows 11 SDK 22621 bootstrapper with
`/features OptionId.WindowsDesktopDebuggers` — debuggers only, not the multi-GB SDK. winget's only
Windows SDK packages are 2018/2019-era and were not used.

## Kernel symbols are verified usable — the premise is checked this time

`win32kfull.sys` public symbols download clean and **name the exact functions this defect needs**:

| Symbol | Offset |
| --- | --- |
| `win32kfull!xxxMNFindChar` | `0x12e9020` — the mnemonic matcher |
| `win32kfull!xxxMNKeyFilter` | `0x12e9168` |
| `win32kfull!xxxMNChar` | `0x12b8c04` |
| `win32kfull!xxxMNLoop` | `0x1154260` |
| `win32kfull!xxxSysCommand` | `0x12b0304` — upstream, handles `SC_KEYMENU` |
| `win32kfull!xxxHandleMenuMessages` | `0x1041970` |

44 `xxxMN*` functions in total, all named, PDB matched to this build
(`{46D01474-8B6F-4F73-16B6-D630CC02A539}`). Cached at
`C:\Symbols\win32kfull.pdb\46D014748B6F4F7316B6D630CC02A5391\win32kfull.pdb`.

Trace the chain, not just the matcher: if `Alt+C` never reaches `xxxMNFindChar`, the divergence is
upstream in `xxxSysCommand` / `xxxMNKeyFilter` and that is where to look next.

## Suggested next step

### 0. The free test, before anything else — DOES IT REPRODUCE ON THE OTHER COMPUTER?

**Not yet done, and it is worth more than any instrument here.** Three keystrokes in Astoria on the
second machine:

- **Works there, fails here** → the defect is **machine-local**. Nothing in Astoria's source is the
  cause, twelve hypotheses have been aimed at the wrong target, and the answer is in this machine's
  configuration — a filter driver, an IME, something with a global claim on those letters. The
  kernel trace becomes unnecessary.
- **Fails on both** → it is in Astoria or the framework, machine state is ruled out for free, and
  the kernel trace is worth its setup cost.

Either answer is progress and it costs nothing. Do this first.

### 1. Kernel debugging (only if it fails on both)

Two machines are available. **This machine (the one this session ran on) is the intended TARGET** —
it reproduces the defect and can run Astoria. The second machine is the HOST and needs none of the
setup below.

**Prerequisites, all verified on the target 2026-07-20 — no firmware change or reboot risk remains:**

| Check | Result |
| --- | --- |
| BitLocker | **Off on both machines**, both on local accounts. The recovery-lockout risk that normally gates kernel debugging does not apply. |
| Secure Boot | **Already off.** `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\State\UEFISecureBootEnabled = 0`. No firmware trip needed. (This value is readable without elevation; `Confirm-SecureBootUEFI` is not.) |
| Debug-capable NIC | **Realtek PCIe GbE, `busparams=2.0.0`** — reported supported by `kdnet.exe`. |
| USB alternative | Intel USB 3.20 xHC, `busparams=0.20.0` — would need an A/A debug cable. |
| Hypervisor | `kdnet.exe` reports KDNET is supported in guest VMs, if a VM target is ever preferred. |

**The one thing missing is an ethernet cable.** The Realtek port reports *"Not plugged in"*, and the
machine is currently on Wi-Fi only (MediaTek MT7922 — **not** in `kdnet.exe`'s supported list, so
Wi-Fi will not work for this). Plug both machines into the same switch or router before starting.

Target identity at time of writing: hostname `ACE`, `10.0.0.2` via Wi-Fi, gateway `10.0.0.1`. The
wired interface will get its own address once connected — use that one.

Target setup (elevated), then reboot:

```
bcdedit /dbgsettings                          REM check current state first
bcdedit /dbgsettings net hostip:<HOST-IP> port:50000
bcdedit /debug on
```

`hostip` is the **other** machine's address, not this one's. `/dbgsettings net` prints a
**connection key** — record it, the host needs it to connect. `kdnet.exe <HOST-IP> 50000` will do
the same configuration and print the key, if that is preferred to `bcdedit`.

Host:

```
kd -k net:port=50000,key=<KEY-FROM-TARGET>
```

Then break on the chain, not just the matcher:

```
bp win32kfull!xxxSysCommand
bp win32kfull!xxxMNKeyFilter
bp win32kfull!xxxMNFindChar
```

Send `Alt+E` (control, must reach the matcher and fail to match) and `Alt+C` on the target, and
compare. **The target halts completely at every break, including the mouse** — that is normal, but
it means the keystroke must be sent by hand or by a script that runs before the break.

### 2. The bisection ladder (needs no Windows internals at all)

Its large advantage over everything above: it depends on nothing being right about Windows, only on
the failure reproducing. Reached Form+MainMenu ✓, context menus ✓, Panel→Panel→TabControl ✓ — all
still working. Step 3 was to be Astoria's `EditControl`, which was **attempted and abandoned**:
despite `EditControl.bi` including only mff headers, `EditControl.bas` references a long tail of
Astoria globals. Pick a different rung — toolbars, image lists, the status bar, or the worker
threads — or find a way to disable parts of Astoria's startup instead.
