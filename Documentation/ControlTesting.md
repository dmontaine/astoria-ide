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
resulting `Main.exe` was launched, checked for a live window, and closed.

Built binaries are intentionally not committed (see `.gitignore`); the project sources are,
so every test is reproducible by opening its `.vfp` and pressing build.

| Name | Visual | Compiled | Tested | Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Controls-Cursor | Other | n/a | n/a | n/a | Toolbox selection pointer, not a placeable control - no program to build. |
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
| Components-Menu | Other | ✅ | ✅ | ✅ | Requires the fully-qualified type name `My.Sys.Forms.Menu`; the bare `Menu` is rejected by the compiler. MainMenu/PopupMenu work unqualified. |
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

**Known follow-up:** `FromUtf8` allocates its buffer (`WReAllocate`) and no caller frees it,
so each call leaks a small buffer. These are error paths, and this matches the framework's
existing idiom, but a leak-free helper would be a worthwhile cleanup.

**Scope caveat:** these tests prove the libraries *compile* and the components *construct* and
the window opens/closes. They do **not** exercise real database connectivity - that would need
a running MariaDB server and the client/sqlite3 DLLs.

## Runtime DLL dependencies

Two controls are backed by native DLLs, and a built program will **not start** unless those DLLs
sit next to its `.exe` (or on PATH). This is a deployment gap worth noting: the IDE does not
currently copy a control library's DLLs alongside the programs a user builds.

| Control | Needs | Shipped in |
| --- | --- | --- |
| Controls-ScintillaControl | `Scintilla64.dll`, `Lexilla64.dll`, `ScintillaControl64.dll` | `Controls/ScintillaControl/` |
| Components-MariaDBBox | `libmariadb.dll` | `Controls/MariaDBBox/` (added 2026-07-18, from the MariaDB 12.3 Connector/C) |
| Components-SQLite3Component | *nothing* | statically linked via `libsqlite3_x64.a` - the `sqlite3*.dll` files in `Controls/SQLite3/` are unused by builds |

`libmariadb.dll` was previously missing entirely - the repo shipped only the link-time
`libmariadb.lib` / `libmariadbclient.a` (plus a stray `libmariadb.pdb`), so MariaDBBox linked
successfully and then failed at startup with "libmariadb could not be found". It is LGPL-2.1
(MariaDB Connector/C) and redistributable alongside dynamically-linked software.

## Other findings

- **Containers-TabPage** is the one control that cannot be tested alone: it requires a
  TabControl parent, so its program contains two controls by necessity.
- **Components-Menu** must be declared as `My.Sys.Forms.Menu`; the bare name is rejected.
- **Controls-ScintillaControl** and **Components-MariaDBBox** at first appeared to ignore
  `WM_CLOSE` and had to be force-closed. Neither was a control defect: both were missing runtime
  DLLs (see *Runtime DLL dependencies*), so what the harness saw as "a live window" was in fact a
  "DLL not found" error dialog. With the DLLs alongside the exe, each opens its real window and
  closes gracefully.
- The harness's "is there a live window?" check cannot tell a real window from a modal error
  dialog, so a startup failure can read as a pass. Worth tightening if these tests are ever
  re-run in bulk - checking the window title against the expected one would have caught both.
