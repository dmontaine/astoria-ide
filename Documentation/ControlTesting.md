# Control Testing

Per-control verification status for every element in the Astoria IDE toolbox.

Listed in toolbox order: group by group (Controls, Containers, Components, Dialogs),
alphabetical within each group, with the Cursor pointer pinned first.

## Columns

- **Name** - toolbox group + control name.
- **Visual** - `Visual` for elements with an on-screen presence (Controls, Containers);
  `Other` for non-visual ones (Components, Dialogs) and the Cursor pointer.
- **Compiled** - **Test 1**: a Windows Application project containing only that one control
  compiles without error.
- **Tested** - **Test 2**: the compiled program opens and closes cleanly.
- **Verified** - **Test 3**: owner visual inspection of the running program.
- **Notes** - anything worth recording about a given test.

Status values: ✅ pass / ❌ fail / `-` not yet run / `n/a` not applicable.

## How these were tested

Each control got its own generated project under `Examples/Controls/<Control>/`: a copy of the
**Windows Application** template (`Main.frm`) containing exactly one instance of that control
and nothing else. Tests 1 and 2 were automated - each project was built **by the IDE itself**
(over the agent pipe, so `.frm` and the generated `.rc` are handled properly), then the
resulting `Main.exe` was launched, checked, and closed.

**Test 2 checks the window title**, not merely that a window exists. The first pass asked only
"is a window up?", which a modal *"DLL not found"* dialog answers just as well as a working
program - and it scored two startup failures as passes as a result. The check now requires the
title to be the expected `<Control> test`, so an error dialog fails. Any control that has to be
force-closed rather than closing on request also fails.

Built binaries are intentionally not committed (see `.gitignore`); the project sources are,
so every test is reproducible by opening its `.vfp` and pressing build.

| Name | Visual | Compiled | Tested | Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Controls-Cursor | Other | n/a | n/a | n/a | Toolbox selection pointer, not a placeable control - no program to build. Appears once, under Controls; it was formerly repeated in all four groups. |
| Controls-Chart | Visual | ✅ | ✅ | ✅ |  |
| Controls-CheckBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-CheckedListBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-ComboBoxEdit | Visual | ✅ | ✅ | ✅ |  |
| Controls-ComboBoxEx | Visual | ✅ | ✅ | ✅ |  |
| Controls-CommandButton | Visual | ✅ | ✅ | ✅ |  |
| Controls-DateTimePicker | Visual | ✅ | ✅ | ✅ |  |
| Controls-Grid | Visual | ✅ | ✅ | ✅ |  |
| Controls-GridData | Visual | ✅ | ✅ | ✅ |  |
| Controls-Header | Visual | ✅ | ✅ | ✅ |  |
| Controls-HotKey | Visual | ✅ | ✅ | ✅ |  |
| Controls-HScrollBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-ImageBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-IPAddress | Visual | ✅ | ✅ | ✅ |  |
| Controls-Label | Visual | ✅ | ✅ | ✅ |  |
| Controls-LinkLabel | Visual | ✅ | ✅ | ✅ |  |
| Controls-ListControl | Visual | ✅ | ✅ | ✅ |  |
| Controls-ListView | Visual | ✅ | ✅ | ✅ |  |
| Controls-MonthCalendar | Visual | ✅ | ✅ | ✅ |  |
| Controls-NumericUpDown | Visual | ✅ | ✅ | ✅ |  |
| Controls-OpenFileControl | Visual | ✅ | ✅ | ✅ |  |
| Controls-PrintPreviewControl | Visual | ✅ | ✅ | ✅ |  |
| Controls-ProgressBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-RadioButton | Visual | ✅ | ✅ | ✅ |  |
| Controls-RichTextBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-ScintillaControl | Visual | ✅ | ✅ | ✅ | Needs Scintilla64.dll / Lexilla64.dll / ScintillaControl64.dll alongside the exe. With them present it opens and closes cleanly - the earlier force-close was a missing-DLL issue, not a control defect. |
| Controls-ScrollBarControl | Visual | ✅ | ✅ | ✅ |  |
| Controls-SearchBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-Splitter | Visual | ✅ | ✅ | ✅ |  |
| Controls-StatusBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-TextBox | Visual | ✅ | ✅ | ✅ |  |
| Controls-ToolBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-ToolPalette | Visual | ✅ | ✅ | ✅ |  |
| Controls-ToolTips | Visual | ✅ | ✅ | ✅ |  |
| Controls-TrackBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-TreeListView | Visual | ✅ | ✅ | ✅ |  |
| Controls-TreeView | Visual | ✅ | ✅ | ✅ |  |
| Controls-UpDown | Visual | ✅ | ✅ | ✅ |  |
| Controls-VScrollBar | Visual | ✅ | ✅ | ✅ |  |
| Controls-WebBrowser | Visual | ✅ | ✅ | - | Was excluded from the toolbox as unbuildable; the framework bug is fixed (see Library fixes) and it now compiles, opens and closes cleanly. **Page rendering and navigation are not exercised by this test.** |
| Containers-Form | Visual | ✅ | ✅ | ✅ |  |
| Containers-GroupBox | Visual | ✅ | ✅ | ✅ |  |
| Containers-HorizontalBox | Visual | ✅ | ✅ | ✅ |  |
| Containers-MsgBoxForm | Visual | ✅ | ✅ | ✅ |  |
| Containers-PagePanel | Visual | ✅ | ✅ | ✅ |  |
| Containers-PageScroller | Visual | ✅ | ✅ | ✅ |  |
| Containers-Panel | Visual | ✅ | ✅ | ✅ |  |
| Containers-Picture | Visual | ✅ | ✅ | ✅ |  |
| Containers-ReBar | Visual | ✅ | ✅ | ✅ |  |
| Containers-ScrollControl | Visual | ✅ | ✅ | ✅ |  |
| Containers-TabControl | Visual | ✅ | ✅ | ✅ |  |
| Containers-TabPage | Visual | ✅ | ✅ | ✅ | **Required a second control**: a TabPage cannot be parented to a Form, so the test program hosts it inside a TabControl. Passes with that parent. |
| Containers-UserControl | Visual | ✅ | ✅ | ✅ |  |
| Containers-VerticalBox | Visual | ✅ | ✅ | ✅ |  |
| Components-CJSON_TYPE | Other | ✅ | ✅ | ✅ |  |
| Components-HTTPConnection | Other | ✅ | ✅ | ✅ |  |
| Components-ImageList | Other | ✅ | ✅ | ✅ |  |
| Components-MainMenu | Other | ✅ | ✅ | ✅ |  |
| Components-MariaDBBox | Other | ✅ | ✅ | ✅ | Needs libmariadb.dll (MariaDB Connector/C) alongside the exe - now supplied in Controls/MariaDBBox/. Library also required a source fix to compile (see Library fixes). DB connectivity not exercised. |
| Components-NotifyIcon | Other | ✅ | ✅ | ✅ |  |
| Components-PopupMenu | Other | ✅ | ✅ | ✅ |  |
| Components-PrintDocument | Other | ✅ | ✅ | ✅ |  |
| Components-Printer | Other | ✅ | ✅ | ✅ |  |
| Components-SQLite3Component | Other | ✅ | ✅ | ✅ | Library did not compile - fixed (see Library fixes). DB connectivity not exercised. |
| Components-TimerComponent | Other | ✅ | ✅ | ✅ |  |
| Dialogs-ColorDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-FolderBrowserDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-FontDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-OpenFileDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-PageSetupDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-PrintDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-PrintPreviewDialog | Other | ✅ | ✅ | ✅ |  |
| Dialogs-SaveFileDialog | Other | ✅ | ✅ | ✅ |  |

**Totals:** 74 elements listed; 73 testable (Cursor excluded).
Tests 1 and 2: **73 of 73 pass**.

## Library fixes made during testing

Two components did not compile at all - the fault was in the bundled libraries, not the IDE.
Both are now fixed, and the same root cause explains every failure:

`FromUtf8()` is declared `FromUtf8(pZString As ZString Ptr) As WString Ptr`, but the callers
were passing a **String** and assigning the returned **pointer** to a `UString`.

- **38 sites** (16 in `MariaDBBox.bas`, 22 in `SQLite3Component.bas`) had:
  `ErrStr = *mysql_error(m_DB)` followed by `ErrStr = FromUtf8(Str(ErrStr))`. That threw the
  API's pointer away, then fed a `String` to a `ZString Ptr` parameter. Rewritten to decode
  straight from the API pointer:
  `ErrStr = WGet(FromUtf8(Cast(ZString Ptr, mysql_error(m_DB))))`.
  - `Cast(ZString Ptr, ...)` drops the `Const` on the API's return type; `FromUtf8` only reads.
  - `WGet()` is null-safe - `FromUtf8` returns 0 for empty input, so a bare `*` would crash.
- **2 sites** had `ot = FromUtf8(rs_Utf8(0))` where `rs_Utf8()` is a `String` array; now
  `ot = WGet(FromUtf8(StrPtr(rs_Utf8(0))))`.

A third fix re-enabled a whole control. `WebBrowser` was hidden from the toolbox because
`WebBrowser.bas` failed to compile: `NewWindowRequestedEventArgs.GetURL()` is declared
`ByRef As WString` but returned the literal `""`, and a byref result cannot reference a
temporary. Returning a `Static As WString * 1` instead fixes it, and the control now builds,
runs and closes cleanly.

Two controls could **not** be recovered and remain excluded: `ListViewEx` and `SearchBar` each
ship a `.bi` whose implementation `.bas` was never included in MyFbFramework, so any project
using one fails with "File not found". That needs an upstream fix, not a local one.

**Known follow-up:** `FromUtf8` allocates its buffer (`WReAllocate`) and no caller frees it,
so each call leaks a small buffer. These are error paths, and this matches the framework's
existing idiom, but a leak-free helper would be a worthwhile cleanup.

**Scope caveat:** these tests prove the libraries *compile* and the components *construct* and
the window opens/closes. They do **not** exercise real database connectivity - that would need
a running MariaDB server and the client/sqlite3 DLLs.

## Runtime DLL dependencies

Two controls are backed by native DLLs, and a built program will **not start** unless those DLLs
sit next to its `.exe` (or on PATH). **The IDE now copies them automatically** on every successful
build, before the program is run - see *Automatic runtime-DLL copying* below.

| Control | Needs | Shipped in |
| --- | --- | --- |
| Controls-ScintillaControl | `Scintilla64.dll`, `Lexilla64.dll`, `ScintillaControl64.dll` | `Controls/ScintillaControl/` |
| Components-MariaDBBox | `libmariadb.dll` | `Controls/MariaDBBox/` (added 2026-07-18, from the MariaDB 12.3 Connector/C) |
| Components-SQLite3Component | *nothing* | statically linked via `libsqlite3_x64.a` - the `sqlite3*.dll` files in `Controls/SQLite3/` are unused by builds |

`libmariadb.dll` was previously missing entirely - the repo shipped only the link-time
`libmariadb.lib` / `libmariadbclient.a` (plus a stray `libmariadb.pdb`), so MariaDBBox linked
successfully and then failed at startup with "libmariadb could not be found". It is LGPL-2.1
(MariaDB Connector/C) and redistributable alongside dynamically-linked software.

### Automatic runtime-DLL copying

A control library declares what its programs need at runtime with a `RuntimeDlls` key in its
`Controls/<Name>/Settings.ini` - the same file the toolbox already reads:

```ini
[setup]
RuntimeDlls=ScintillaControl64.dll,Scintilla64.dll,Lexilla64.dll
```

On every successful build `CopyControlRuntimeDlls` (`src/BuildService.bas`) copies those files
beside the exe, before any Run. A new control library states its own needs by dropping in a
folder; no IDE code changes.

Two design notes:

- **Build time, not drop time.** At the moment a control is dropped on a form the exe's location
  isn't known yet, and drop-time copying would do nothing for a project cloned from git. Copying
  on build gets it right every time, including on a fresh clone.
- **Usage is detected from the sources, not the exe.** A project counts as using a library when
  one of its `.frm`/`.bas`/`.bi` files has an `#include` naming that library's `.bi`. The exe's
  import table can't be used: ScintillaControl loads its DLLs dynamically, so its name never
  appears there. (`cJSON64.dll` shows the opposite trap - the name appears in the exe, yet the
  program runs fine without the file.)

Copying is per library, not per DLL: if a project uses ScintillaControl it gets all three, since
two of them are loaded by the third rather than by the program. Files already present with a
matching size are left alone, so a running program's DLL is never swapped underneath it.

Verified 2026-07-18 by deleting the DLLs from the test projects and rebuilding through the IDE:
ScintillaControl got all 3, MariaDBBox got `libmariadb.dll` only (not its own `MariaDBBox_x64.dll`),
SQLite3Component and Label got none. All then ran and closed gracefully.

## Other findings

- **Containers-TabPage** is the one control that cannot be tested alone: it requires a
  TabControl parent, so its program contains two controls by necessity.
- **Menu** is not a toolbox element - it is the abstract base that `MainMenu` and `PopupMenu`
  extend, and the loader skips it. It is usable from code, but must be declared as
  `My.Sys.Forms.Menu`; the bare name is rejected. An earlier revision of this table listed it
  as a toolbox control in error.
- **Controls-ScintillaControl** and **Components-MariaDBBox** at first appeared to ignore
  `WM_CLOSE` and had to be force-closed. Neither was a control defect: both were missing runtime
  DLLs (see *Runtime DLL dependencies*), so what the harness saw as "a live window" was in fact a
  "DLL not found" error dialog. With the DLLs alongside the exe, each opens its real window and
  closes gracefully.
- The harness's original "is there a live window?" check could not tell a real window from a
  modal error dialog, so a startup failure read as a pass. **Fixed** - Test 2 now matches the
  window title, which would have caught both cases above. See *How these were tested*.

## Revision history

The table above is the result of two passes, not one. What changed after the first:

| Change | Effect |
| --- | --- |
| **Test 2 now matches the window title** | Two results were false passes: a *"DLL not found"* dialog satisfied the old "a window exists" check. Both were re-run and corrected. |
| **MariaDBBox fixed and re-tested** | Was a real failure - `libmariadb.dll` was missing from the repo entirely. Now shipped and passing. |
| **ScintillaControl re-tested** | Was never broken. Its DLLs simply were not beside the exe during the first run; it passes cleanly with them present. |
| **WebBrowser added** | Previously excluded from the toolbox as unbuildable. The framework bug is fixed, and it now has a test project like every other control. |
| **`Components-Menu` row removed** | It was never a toolbox element - `Menu` is an abstract base the loader skips. Listing it was an error in the first pass. |
| **`Controls-Cursor` note** | The Cursor now appears once in the toolbox rather than in all four groups. |
| **cJSON and SQLite3 re-checked** | Both had been assumed DLL-free; re-verified under the stricter test, and both genuinely need nothing. SQLite3 links statically. |
| **Runtime-DLL copying added and verified** | See *Automatic runtime-DLL copying*. Removing the DLLs and rebuilding through the IDE restores exactly the right ones. |

Verified counts are unchanged except for `Controls-WebBrowser`, which is `-` pending owner
inspection - it was added after the review pass.
