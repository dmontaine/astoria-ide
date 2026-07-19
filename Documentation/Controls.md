# Controls Reference

Every element in the Astoria toolbox: what it is for, what is distinctive about using it, and
anything worth a warning.

**Where this comes from.** Purposes and member lists are extracted from the MyFbFramework help
file (`MyFbFramework.chm`), which is the upstream authority for the framework controls. Five
controls are add-ons that the framework help does not cover - `ScintillaControl`, `MsgBoxForm`,
`CJSON_TYPE`, `MariaDBBox` and `SQLite3Component` - and their entries are written from their
headers and from testing. Warnings come from the per-control testing recorded in
[ControlTesting.md](ControlTesting.md).

**Reading an entry.** *Key members* lists only what each control adds on top of the ~124
properties, methods and events every `Control` already has (`Text`, `Enabled`, `Visible`,
`Align`, `Anchor`, `OnClick`, and so on). It is a guide to what makes the control distinct, not
a complete API - the framework help has the full list.

**Platform.** Astoria targets Windows, so upstream's cross-platform annotations have been
stripped - every control listed here is available to you. If you consult the MyFbFramework help
directly you will see notes like *(Windows, Linux, Web)*; those describe the framework's own
reach, not Astoria's.

**Changes Astoria has made** to a control are called out in its entry under *Changed in
Astoria*, and summarised in [Changes made in Astoria](#changes-made-in-astoria) at the end.

A control being listed here means it compiles and its window opens and closes. It does **not**
mean every feature is exercised - see the scope caveats in ControlTesting.md.

## Contents

- **Controls** (40): [Chart](#chart), [CheckBox](#checkbox), [CheckedListBox](#checkedlistbox), [ComboBoxEdit](#comboboxedit), [ComboBoxEx](#comboboxex), [CommandButton](#commandbutton), [DateTimePicker](#datetimepicker), [Grid](#grid), [GridData](#griddata), [Header](#header), [HotKey](#hotkey), [HScrollBar](#hscrollbar), [ImageBox](#imagebox), [IPAddress](#ipaddress), [Label](#label), [LinkLabel](#linklabel), [ListControl](#listcontrol), [ListView](#listview), [MonthCalendar](#monthcalendar), [NumericUpDown](#numericupdown), [OpenFileControl](#openfilecontrol), [PrintPreviewControl](#printpreviewcontrol), [ProgressBar](#progressbar), [RadioButton](#radiobutton), [RichTextBox](#richtextbox), [ScintillaControl](#scintillacontrol), [ScrollBarControl](#scrollbarcontrol), [SearchBox](#searchbox), [Splitter](#splitter), [StatusBar](#statusbar), [TextBox](#textbox), [ToolBar](#toolbar), [ToolPalette](#toolpalette), [ToolTips](#tooltips), [TrackBar](#trackbar), [TreeListView](#treelistview), [TreeView](#treeview), [UpDown](#updown), [VScrollBar](#vscrollbar), [WebBrowser](#webbrowser)
- **Containers** (14): [Form](#form), [GroupBox](#groupbox), [HorizontalBox](#horizontalbox), [MsgBoxForm](#msgboxform), [PagePanel](#pagepanel), [PageScroller](#pagescroller), [Panel](#panel), [Picture](#picture), [ReBar](#rebar), [ScrollControl](#scrollcontrol), [TabControl](#tabcontrol), [TabPage](#tabpage), [UserControl](#usercontrol), [VerticalBox](#verticalbox)
- **Components** (11): [CJSON_TYPE](#cjson_type), [HTTPConnection](#httpconnection), [ImageList](#imagelist), [MainMenu](#mainmenu), [MariaDBBox](#mariadbbox), [NotifyIcon](#notifyicon), [PopupMenu](#popupmenu), [PrintDocument](#printdocument), [Printer](#printer), [SQLite3Component](#sqlite3component), [TimerComponent](#timercomponent)
- **Dialogs** (8): [ColorDialog](#colordialog), [FolderBrowserDialog](#folderbrowserdialog), [FontDialog](#fontdialog), [OpenFileDialog](#openfiledialog), [PageSetupDialog](#pagesetupdialog), [PrintDialog](#printdialog), [PrintPreviewDialog](#printpreviewdialog), [SaveFileDialog](#savefiledialog)

---

## Controls

Visual controls: they draw themselves and are placed directly on a form or container.

### Chart

The Chart control is a chart object that exposes events.

**Key properties:** `AxisMax`, `AxisMin`, `BackColorOpacity`, `Border`, `BorderColor`, `BorderRound`, `ChartOrientation`, `ChartStyle`, `Count`, `DonutWidth`, `FillGradient`, `FillOpacity`, `ItemColor`, `LabelsAlignment`, `LabelsFormat`, `LabelsFormats`, `LabelsPosition`, `LabelsVisible`, `LegendAlign`, `LegendVisible`, `LinesColor`, `LinesCurve`, `LinesWidth`, `Rotation`, `SeparatorLine`, `SeparatorLineColor`, `SeparatorLineWidth`, `Special`, `Title`, `TitleFont`, `TitleForeColor`, `ToolTipsFormat`, `VerticalLines`

**Key methods:** `AddAxisItems`, `AddItem`, `AddSerie`, `AxisItemsCount`, `Clear`, `GetCenterPie`, `GetWindowsDPI`, `Refresh`, `RGBtoARGB`, `SeriesCount`, `SumSerieValues`, `UpdateSerie`, `Wait`

**Key events:** `OnItemClick`

### CheckBox

Displays an V when selected; the V disappears when the CheckBox is cleared.

**Key properties:** `Alignment`, `Caption`, `Checked`, `TabIndex`, `TabStop`

### CheckedListBox

Displays a ListBox in which a check box is displayed to the left of each item.

**Key properties:** `Checked`, `Ctl3D`, `HorizontalScrollBar`, `IntegralHeight`, `Item`, `ItemCount`, `ItemData`, `ItemHeight`, `ItemIndex`, `Items`, `MultiColumn`, `RadioCheck`, `SelCount`, `Selected`, `SelectionMode`, `SelItems`, `Sort`, `Style`, `TabIndex`, `TabStop`, `TopIndex`, `VerticalScrollBar`

**Key methods:** `AddItem`, `Clear`, `IndexOfData`, `InsertItem`, `LoadFromFile`, `NewIndex`, `RemoveItem`, `SaveToFile`, `SelectAll`, `UnSelectAll`

**Key events:** `OnChange`, `OnDrawItem`, `OnMeasureItem`

### ComboBoxEdit

Combines the features of a TextBox and a ListControl.

**Key properties:** `DropDownCount`, `IntegralHeight`, `Item`, `ItemCount`, `ItemData`, `ItemHeight`, `ItemIndex`, `Items`, `SelColor`, `Sort`, `Style`, `TabIndex`, `TabStop`

**Key methods:** `AddItem`, `Clear`, `Contains`, `CopyToClipboard`, `CutToClipboard`, `IndexOfData`, `InsertItem`, `LoadFromFile`, `NewIndex`, `PasteFromClipboard`, `RemoveItem`, `SaveToFile`, `SelectAll`, `ShowDropDown`, `Undo`

**Key events:** `OnActivate`, `OnChange`, `OnCloseUp`, `OnDrawItem`, `OnDropDown`, `OnMeasureItem`, `OnSelectCanceled`, `OnSelected`

> [!WARNING]
> `ComboBoxEdit`, `ComboBoxEx` and `ListControl` overlap. `ComboBoxEdit` is the editable combo; `ComboBoxEx` adds images to the list.

### ComboBoxEx

ComboBoxEx controls are combo box controls that provide native support for item images.

**Key properties:** `DropDownCount`, `ImagesList`, `IntegralHeight`, `Item`, `ItemCount`, `ItemData`, `ItemHeight`, `ItemIndex`, `Items`, `ListStore`, `SelColor`, `Sort`, `Style`, `TabIndex`, `TabStop`

**Key methods:** `AddItem`, `Clear`, `Contains`, `CopyToClipboard`, `CutToClipboard`, `IndexOfData`, `InsertItem`, `LoadFromFile`, `NewIndex`, `PasteFromClipboard`, `RemoveItem`, `SaveToFile`, `SelectAll`, `SetDark`, `ShowDropDown`, `Undo`

**Key events:** `OnActivate`, `OnChange`, `OnCloseUp`, `OnDrawItem`, `OnDropDown`, `OnMeasureItem`, `OnSelectCanceled`, `OnSelected`

### CommandButton

Looks like a push button and is used to begin, interrupt, or end a process.

**Key properties:** `Cancel`, `Caption`, `Default`, `Graphic`, `Style`, `TabIndex`, `TabStop`

**Key events:** `OnDraw`

### DateTimePicker

Lets the user pick a date and time, and displays it in a format you specify.

**Key properties:** `AutoNextPart`, `CalendarRightAlign`, `Checked`, `CustomFormat`, `DateFormat`, `SelectedDate`, `SelectedDateTime`, `SelectedTime`, `ShowNone`, `ShowUpDown`, `TabIndex`, `TabStop`, `TimePicker`

**Key events:** `OnDateTimeChanged`

### Grid

Defines a flexible grid area that consists of columns and rows.

**Key properties:** `AllowColumnReorder`, `AllowEdit`, `ColorEditBack`, `ColorEditFore`, `ColorLine`, `ColorSelected`, `ColumnHeaderHidden`, `Columns`, `DataArrayPtr`, `FixCols`, `FullRowSelect`, `GridLines`, `GroupHeaderImages`, `HoverSelection`, `Images`, `OwnerData`, `Rows`, `SelectedColumn`, `SelectedColumnIndex`, `SelectedImages`, `SelectedRow`, `SelectedRowIndex`, `SingleClickActivate`, `SmallImages`, `SortIndex`, `SortOrder`, `StateImages`, `TabIndex`, `TabStop`

**Key methods:** `Cells`, `Clear`, `EnsureVisible`, `LoadFromFile`, `SaveToFile`

**Key events:** `OnBeginScroll`, `OnCacheHint`, `OnCellEdited`, `OnColumnClick`, `OnEndScroll`, `OnGetDispInfo`, `OnRowActivate`, `OnRowClick`, `OnRowDblClick`, `OnRowKeyDown`, `OnSelectedRowChanged`, `OnSelectedRowChanging`

> [!WARNING]
> `Grid` and `GridData` are different controls. `Grid` is the general-purpose cell grid; `GridData` is the data-bound variant. Check which one your example refers to.

### GridData

Advanced grid control supporting hierarchical data and multiple selection modes.

**Key properties:** `AllowEdit`, `ColumnHeaderHidden`, `Columns`, `ColumnTypes`, `GroupHeaderImages`, `HandleHeader`, `Images`, `ListItems`, `RowHeight`, `RowHeightHeader`, `SelectedColumn`, `SelectedItem`, `SelectedItemIndex`, `ShowHoverBar`, `ShowSelection`, `SingleClickActivate`, `SmallImages`, `Sort`, `StateImages`, `TreeSelection`, `TreeStore`, `View`

**Key methods:** `CollapseAll`, `EnsureVisible`, `ExpandAll`, `Init`, `Refresh`, `SetFont`, `SetFontHeader`, `SetGridLines`

**Key events:** `OnBeginScroll`, `OnCellEdited`, `OnCellEditing`, `OnEndScroll`, `OnHeadClick`, `OnHeadColWidthAdjust`, `OnItemActivate`, `OnItemClick`, `OnItemDblClick`, `OnItemExpanding`, `OnItemKeyDown`, `OnSelectedItemChanged`

> [!WARNING]
> The data-bound counterpart to `Grid`. Check which of the two an example refers to.

### Header

A header control is a window that is usually positioned above columns of text or numbers.

**Key properties:** `Alignments`, `Captions`, `DragReorder`, `FullDrag`, `HotTrack`, `ImageIndexes`, `Images`, `Resizable`, `Section`, `SectionCount`, `Style`, `Widths`

**Key methods:** `AddSection`, `AddSections`, `RemoveSection`, `UpdateItems`

**Key events:** `OnBeginTrack`, `OnChange`, `OnChanging`, `OnDividerDblClick`, `OnDrawSection`, `OnEndTrack`, `OnSectionClick`, `OnSectionDblClick`, `OnTrack`

### HotKey

A hot key control is a window that enables the user to enter a combination of keystrokes to be used as a hot key.

**Key properties:** `TabIndex`, `TabStop`

**Key events:** `OnChange`

### HScrollBar

Provides a horizontal scroll bar for easy navigation through long lists of items.

**Key properties:** `ArrowChangeSize`, `MaxValue`, `MinValue`, `PageSize`, `Position`, `TabIndex`, `TabStop`

### ImageBox

Displays a graphic.

**Key properties:** `CenterImage`, `Graphic`, `RealSizeImage`, `Style`

**Key events:** `OnDraw`

### IPAddress

An Internet Protocol (IP) address control allows the user to enter an IP address in an easily understood format.

**Key properties:** `TabIndex`, `TabStop`

**Key methods:** `Clear`

**Key events:** `OnChange`, `OnFieldChanged`

### Label

Displays text that a user can't change directly.

**Key properties:** `Alignment`, `Border`, `Caption`, `CenterImage`, `Graphic`, `RealSizeImage`, `Style`, `TabIndex`, `TabStop`, `Transparent`, `WordWraps`

**Key events:** `OnDraw`

### LinkLabel

Represents a label control that can display hyperlinks.

**Key properties:** `TabIndex`, `TabStop`

**Key events:** `OnLinkClicked`

### ListControl

Displays a list of items from which the user can select one or more.

**Key properties:** `Ctl3D`, `HorizontalScrollBar`, `IntegralHeight`, `Item`, `ItemCount`, `ItemData`, `ItemHeight`, `ItemIndex`, `Items`, `MultiColumn`, `SelCount`, `Selected`, `SelectionMode`, `SelItems`, `Sort`, `Style`, `TabIndex`, `TabStop`, `TopIndex`, `VerticalScrollBar`

**Key methods:** `AddItem`, `Clear`, `IndexOfData`, `InsertItem`, `LoadFromFile`, `NewIndex`, `RemoveItem`, `SaveToFile`, `SelectAll`, `UnSelectAll`

**Key events:** `OnChange`, `OnDrawItem`, `OnMeasureItem`

### ListView

Represents a control that displays a list of data items.

**Key properties:** `AllowColumnReorder`, `BorderSelect`, `CheckBoxes`, `ColumnHeaderHidden`, `Columns`, `FullRowSelect`, `GridLines`, `GroupHeaderImages`, `HoverSelection`, `Images`, `LabelTip`, `ListItems`, `MultiSelect`, `SelectedColumn`, `SelectedItem`, `SelectedItemIndex`, `SingleClickActivate`, `SmallImages`, `Sort`, `StateImages`, `TabIndex`, `TabStop`, `View`

**Key methods:** `EnsureVisible`, `Init`

**Key events:** `OnBeginScroll`, `OnCellEdited`, `OnDrawItem`, `OnEndScroll`, `OnItemActivate`, `OnItemClick`, `OnItemDblClick`, `OnItemKeyDown`, `OnMeasureItem`, `OnSelectedItemChanged`, `OnSelectedItemChanging`

### MonthCalendar

A control that enables the user to select a date using a visual monthly calendar display.

**Key properties:** `SelectedDate`, `ShortDayNames`, `TabIndex`, `TabStop`, `TodayCircle`, `TodaySelector`, `TrailingDates`, `WeekNumbers`

**Key events:** `OnSelect`, `OnSelectionChanged`

### NumericUpDown

Allows numeric input via textbox with increment/decrement buttons and value constraints.

**Key properties:** `ArrowKeys`, `DecimalPlaces`, `Increment`, `MaxValue`, `MinValue`, `Position`, `Style`, `TabIndex`, `TabStop`, `Thousands`, `UpDownWidth`, `Wrap`

**Key methods:** `SelectAll`

**Key events:** `OnChange`

### OpenFileControl

Embeds a file selection interface directly within forms, supporting multi-select and dynamic filtering.

**Key properties:** `DefaultExt`, `FileName`, `FileNames`, `FileTitle`, `Filter`, `FilterIndex`, `InitialDir`, `MultiSelect`, `Options`, `TabIndex`, `TabStop`

**Key events:** `OnFileActivate`, `OnFolderChange`, `OnSelectionChange`, `OnTypeChange`

### PrintPreviewControl

Displays document pages with zoom/scroll capabilities and print layout visualization.

**Key properties:** `CurrentPage`, `Document`, `Orientation`, `PageLength`, `PageSize`, `PageWidth`, `TabIndex`, `TabStop`, `Zoom`

**Key events:** `OnCurrentPageChanged`, `OnZoom`

### ProgressBar

A progress bar is a window that an application can use to indicate the progress of a lengthy operation.

**Key properties:** `Marquee`, `MaxValue`, `MinValue`, `Orientation`, `Position`, `Smooth`, `StepValue`

**Key methods:** `SetMarquee`, `StepBy`, `StepIt`, `StopMarquee`

### RadioButton

Displays an option that can be turned on or off.

**Key properties:** `Alignment`, `Caption`, `Checked`, `TabIndex`, `TabStop`

### RichTextBox

The RichTextBox control enables you to display or edit flow content including paragraphs, images, tables, and more.

**Key properties:** `Alignment`, `CaretPos`, `CharCase`, `Ctl3D`, `EditStyle`, `HideSelection`, `LeftMargin`, `Lines`, `MaskChar`, `Masked`, `MaxLength`, `Modified`, `Multiline`, `NumbersOnly`, `OEMConvert`, `ReadOnly`, `RightMargin`, `ScrollBars`, `SelAlignment`, `SelBackColor`, `SelBold`, `SelBullet`, `SelCharOffset`, `SelCharSet`, `SelColor`, `SelEnd`, `SelFontName`, `SelFontSize`, `SelHangingIndent`, `SelIndent`, `SelItalic`, `SelLength`, `SelProtected`, `SelRightIndent`, `SelStart`, `SelStrikeout`, `SelTabCount`, `SelTabs`, `SelText`, `SelUnderline`, `TabIndex`, `TabStop`, `TextRTF`, `TopLine`, `WantReturn`, `WantTab`, `WordWraps`, `Zoom`

**Key methods:** `AddImage`, `AddImageFromFile`, `AddLine`, `BottomLine`, `CanRedo`, `CanUndo`, `Clear`, `ClearUndo`, `CopyToClipboard`, `CutToClipboard`, `Find`, `FindNext`, `FindPrev`, `GetCharIndexFromLine`, `GetCharIndexFromPos`, `GetLineFromCharIndex`, `GetLineLength`, `GetSel`, `GetTextRange`, `InputFilter`, `InsertLine`, `LinesCount`, `LoadFromFile`, `PasteFromClipboard`, `Redo`, `RemoveLine`, `SaveToFile`, `ScrollToCaret`, `ScrollToEnd`, `ScrollToLine`, `SelectAll`, `SelPrint`, `SetSel`, `Undo`

**Key events:** `OnActivate`, `OnChange`, `OnCopy`, `OnCut`, `OnPaste`, `OnProtectChange`, `OnSelChange`, `OnUpdate`

### ScintillaControl

Wraps the Scintilla editing component - the same engine behind the Astoria code editor - giving you a full programmer's text editor with syntax highlighting, folding, margins and multiple selections.

*Changed in Astoria.* No source change, but its three DLLs are now copied beside your exe automatically on build; previously a program using it built cleanly and then failed to start.

**Key properties:** `Bold`, `CaretLineBackAlpha`, `CaretLineBackColor`, `CharSet`, `CodePage`, `DarkMode`, `EOLMode`, `FindCount`, `FindData`, `FindIndex`, `FindLength`, `FindLines`, `FindPoses`, `FontName`, `FontSize`, `IndentSize`, `IndicatorSel`, `Italic`, `Length`, `LineCount`, `LineData`, `LineEnd`, `LineLength`, `LineStart`, `LineText`, `MarginWidth`, `Pos`, `PosX`, `PosY`, `SelAlpha`, `SelEnd`, `SelLayer`, `SelLength`, `SelStart`, `SelText`, `SelTxtData`, `TabIndents`, `TabIndex`, `TabStop`, `TabWidth`, `TxtData`, `Underline`, `UseTabs`, `ViewCaretLine`, `ViewEOL`, `ViewFold`, `ViewLineNo`, `ViewWhiteSpace`, `WordWrap`, `Zoom`

**Key methods:** `Clear`, `Copy`, `Cut`, `Find`, `GetPosX`, `GetPosY`, `GotoLine`, `IndexFind`, `IndicatorClear`, `IndicatorSet`, `MarginColor`, `Paste`, `Redo`, `ReplaceAll`, `SelColor`, `SelectAll`, `Undo`

**Key events:** `OnModify`, `OnUpdate`

> [!WARNING]
> Needs `ScintillaControl64.dll`, `Scintilla64.dll` and `Lexilla64.dll` beside the built `.exe`. The IDE copies these automatically on build; if you deploy by hand, copy them too.

> [!WARNING]
> Third-party (CM.Wang), distributed as freeware "use at your own risk" - it is not covered by the framework's licence or its support.

### ScrollBarControl

Provides a horizontal and a vertical scroll bar for easy navigation through long lists of items.

**Key properties:** `ArrowChangeSize`, `MaxValue`, `MinValue`, `PageSize`, `Position`, `Style`, `TabIndex`, `TabStop`

### SearchBox

The SearchBar is a control made to have a search entry.

**Key properties:** `Alignment`, `CaretPos`, `CharCase`, `Ctl3D`, `HideSelection`, `LeftMargin`, `Lines`, `MaskChar`, `Masked`, `MaxLength`, `Modified`, `Multiline`, `NumbersOnly`, `OEMConvert`, `ReadOnly`, `RightMargin`, `ScrollBars`, `SelEnd`, `SelLength`, `SelStart`, `SelText`, `TabIndex`, `TabStop`, `TopLine`, `WantReturn`, `WantTab`, `WordWraps`

**Key methods:** `AddLine`, `CanUndo`, `Clear`, `ClearUndo`, `CopyToClipboard`, `CutToClipboard`, `GetCharIndexFromLine`, `GetLineFromCharIndex`, `GetLineLength`, `GetSel`, `InputFilter`, `InsertLine`, `LinesCount`, `LoadFromFile`, `PasteFromClipboard`, `RemoveLine`, `SaveToFile`, `ScrollToCaret`, `ScrollToEnd`, `ScrollToLine`, `SelectAll`, `SetSel`, `Undo`

**Key events:** `OnActivate`, `OnChange`, `OnCopy`, `OnCut`, `OnPaste`, `OnUpdate`

### Splitter

Represents a splitter control that enables the user to resize docked controls.

**Key properties:** `bCursor`, `MinExtra`

**Key events:** `OnMoved`, `OnMoving`

> [!WARNING]
> Resizes *docked* controls, so the controls either side need their `Align` set. A splitter between two free-floating controls will not do anything useful.

### StatusBar

A status bar is a horizontal window at the bottom of a parent window in which an application can display various kinds of status information.

**Key properties:** `Count`, `Panel`, `Panels`, `SimplePanel`, `SimpleText`, `SizeGrip`

**Key methods:** `ChangePanelIndex`, `Clear`, `UpdatePanels`

**Key events:** `OnPanelClick`, `OnPanelDblClick`

### TextBox

Displays information entered at design time by the user, or in code at run time.

**Key properties:** `Alignment`, `CaretPos`, `CharCase`, `Ctl3D`, `HideSelection`, `LeftMargin`, `Lines`, `MaskChar`, `Masked`, `MaxLength`, `Modified`, `Multiline`, `NumbersOnly`, `OEMConvert`, `ReadOnly`, `RightMargin`, `ScrollBars`, `SelEnd`, `SelLength`, `SelStart`, `SelText`, `TabIndex`, `TabStop`, `TopLine`, `WantReturn`, `WantTab`, `WordWraps`

**Key methods:** `AddLine`, `CanUndo`, `Clear`, `ClearUndo`, `CopyToClipboard`, `CutToClipboard`, `GetCharIndexFromLine`, `GetLineFromCharIndex`, `GetLineLength`, `GetSel`, `InputFilter`, `InsertLine`, `LinesCount`, `LoadFromFile`, `PasteFromClipboard`, `RemoveLine`, `SaveToFile`, `ScrollToCaret`, `ScrollToEnd`, `ScrollToLine`, `SelectAll`, `SetSel`, `Undo`

**Key events:** `OnActivate`, `OnChange`, `OnCopy`, `OnCut`, `OnPaste`, `OnUpdate`

### ToolBar

A toolbar is a control that contains one or more buttons.

**Key properties:** `BitmapHeight`, `BitmapWidth`, `ButtonHeight`, `Buttons`, `ButtonWidth`, `Caption`, `DisabledImagesList`, `Divider`, `Flat`, `HotImagesList`, `ImagesList`, `List`, `Transparency`, `Wrapable`

**Key methods:** `ChangeButtonIndex`

**Key events:** `OnButtonClick`

### ToolPalette

A tool palette with categories.

**Key properties:** `BitmapHeight`, `BitmapWidth`, `ButtonHeight`, `ButtonWidth`, `DisabledImagesList`, `Divider`, `Flat`, `Groups`, `HotImagesList`, `ImagesList`, `List`, `Style`, `Transparency`, `Wrapable`

**Key events:** `OnButtonActivate`, `OnButtonClick`

### ToolTips

Represents a small rectangular pop-up window that displays a brief description of a control's purpose when the user rests the pointer on the control.

**Key events:** `OnLinkClicked`

### TrackBar

A trackbar is a window that contains a slider (sometimes called a thumb) in a channel, and optional tick marks.

**Key properties:** `Frequency`, `LineSize`, `MaxValue`, `MinValue`, `PageSize`, `Position`, `SelEnd`, `SelStart`, `SliderVisible`, `Style`, `TabIndex`, `TabStop`, `ThumbLength`, `TickMark`, `TickStyle`

**Key methods:** `AddTickMark`, `ClearTickMarks`

**Key events:** `OnChange`

### TreeListView

Combines the features of a `TreeView` and a `ListView`.

**Key properties:** `ColumnHeaderHidden`, `Columns`, `ColumnTypes`, `EditLabels`, `GridLines`, `Images`, `MultiSelect`, `Nodes`, `OwnerData`, `OwnerDraw`, `SelectedColumn`, `SelectedItem`, `SelectedItemIndex`, `SingleClickActivate`, `SortColumn`, `SortOrder`, `StateImages`, `TabIndex`, `TabStop`, `TreeSelection`, `TreeStore`

**Key methods:** `CollapseAll`, `EnsureVisible`, `ExpandAll`, `GetItemByVisibleIndex`, `Init`, `Sort`

**Key events:** `OnBeginScroll`, `OnCacheHint`, `OnCellEdited`, `OnCellEditing`, `OnDrawItem`, `OnEndScroll`, `OnGetDisplayInfo`, `OnItemActivate`, `OnItemClick`, `OnItemDblClick`, `OnItemExpanding`, `OnItemKeyDown`, `OnMeasureItem`, `OnSelectedItemChanged`

### TreeView

Represents a control that displays hierarchical data in a tree structure that has items that can expand and collapse.

**Key properties:** `EditLabels`, `HideSelection`, `Images`, `Nodes`, `SelectedImages`, `SelectedNode`, `Sorted`, `TabIndex`, `TabStop`

**Key methods:** `CollapseAll`, `DraggedNode`, `ExpandAll`

**Key events:** `OnAfterLabelEdit`, `OnBeforeLabelEdit`, `OnNodeActivate`, `OnNodeClick`, `OnNodeCollapsed`, `OnNodeCollapsing`, `OnNodeDblClick`, `OnNodeExpanded`, `OnNodeExpanding`, `OnSelChanged`, `OnSelChanging`

### UpDown

An up-down control is a pair of arrow buttons that the user can click to increment or decrement a value, such as a scroll position or a number displayed in a companion control (called a buddy window).

**Key properties:** `Alignment`, `ArrowKeys`, `Associate`, `Increment`, `MaxValue`, `MinValue`, `Position`, `Style`, `TabIndex`, `TabStop`, `Thousands`, `Wrap`

**Key events:** `OnChanging`

### VScrollBar

Provides a vertical scroll bar.

**Key properties:** `ArrowChangeSize`, `MaxValue`, `MinValue`, `PageSize`, `Position`, `TabIndex`, `TabStop`

### WebBrowser

Enables the user to navigate Web pages inside your form.

*Changed in Astoria.* Twice, and the second change matters more. First it was returned to the toolbox: it had been hidden because the framework would not compile with it (`NewWindowRequestedEventArgs.GetURL()` is declared `ByRef As WString` but returned the literal `""`, and a byref result cannot reference a temporary). Testing then showed it still could not render **anything** — it hosted the retired Internet Explorer engine through ATL `AtlAxWin`, whose host window was created with empty text, so no control was instantiated and `Navigate` crashed the program. It now hosts **WebView2** (Edge/Chromium) by default.

**Key properties:** `ScriptResult`, `TabIndex`, `TabStop`

**Key methods:** `ExecuteScript`, `GetBody`, `GetURL`, `GoBack`, `GoForward`, `Navigate`, `Refresh`, `SetBody`, `State`, `Stop`

**Key events:** `OnNewWindowRequested`

> [!WARNING]
> Needs `WebView2Loader.dll` beside the built `.exe`. The IDE copies it automatically on build, but a hand-deployed program needs it too.

> [!WARNING]
> Requires the **WebView2 runtime** on the machine that runs your program. It ships with Edge on Windows 10 and 11, so it is present on essentially all current systems - but it is a dependency of anything you distribute.

---

## Containers

Controls that host other controls. Set a child's `.Parent` to one of these.

### Form

A window or dialog box that makes up part of an application's user interface.

**Key properties:** `ActiveControl`, `CancelButton`, `Caption`, `ControlBox`, `DefaultButton`, `FormStyle`, `Graphic`, `Icon`, `KeyPreview`, `MainForm`, `MaximizeBox`, `Menu`, `MinimizeBox`, `ModalResult`, `Opacity`, `Owner`, `ShowInTaskbar`, `StartPosition`, `Transparent`, `TransparentColor`, `WindowState`

**Key methods:** `CenterToParent`, `CenterToScreen`, `CloseForm`, `Maximize`, `Minimize`, `ShowModal`

**Key events:** `OnActivate`, `OnActivateApp`, `OnActiveControlChange`, `OnClose`, `OnDeActivate`, `OnDeActivateApp`, `OnHide`, `OnShow`

### GroupBox

Provides an identifiable grouping for controls.

**Key properties:** `Caption`, `ParentColor`, `TabIndex`, `TabStop`

### HorizontalBox

The Horizontal Box lays out its child controls horizontally and will not wrap onto a new line in any circumstances

**Key properties:** `Spacing`, `TabIndex`, `TabStop`

### MsgBoxForm

The framework's own message-box window, used by `MsgBox`. A dark-mode-aware replacement for the native Windows `MessageBox`, built from a Form, Labels and CommandButtons so it follows the application's theme.

> [!WARNING]
> Not documented in the framework help - it is an Astoria addition. Normally you use `MsgBox` rather than placing this form yourself.

### PagePanel

Used to group collections of controls.

**Key properties:** `Graphic`, `SelectedPanel`, `SelectedPanelIndex`, `TabIndex`, `TabStop`, `Transparent`

**Key events:** `OnSelChange`, `OnSelChanging`

### PageScroller

The PageScroller control is used to scroll a panel along with the components placed on it.

**Key properties:** `ArrowChangeSize`, `AutoScroll`, `ChildDragDrop`, `Position`, `Style`, `TabIndex`, `TabStop`

### Panel

Used to group collections of controls.

**Key properties:** `BevelInner`, `BevelOuter`, `BevelWidth`, `BorderWidth`, `Graphic`, `TabIndex`, `TabStop`, `Transparent`

### Picture

Displays a graphic from a bitmap, icon or metafile.

**Key properties:** `CenterImage`, `Graphic`, `RealSizeImage`, `StretchImage`, `Style`, `TabIndex`, `TabStop`, `Transparent`

**Key events:** `OnDraw`

### ReBar

A Rebar control acts as a container for child windows. It can contain one or more bands, and each band can have any combination of a gripper bar, a bitmap, a text label, and one child window.

**Key properties:** `Bands`, `ImageBacking`, `ImageList`

**Key methods:** `RowCount`, `UpdateReBar`

**Key events:** `OnHeightChange`, `OnPopup`

### ScrollControl

Defines a class that support auto-scrolling behavior.

**Key properties:** `TabIndex`, `TabStop`

**Key methods:** `RecalculateScrollBars`

### TabControl

Represents a control that contains multiple items that share the same space on the screen.

**Key properties:** `Detachable`, `FlatButtons`, `GroupName`, `Images`, `Multiline`, `Reorderable`, `SelectedTab`, `SelectedTabIndex`, `Tab`, `TabCount`, `TabIndex`, `TabPosition`, `Tabs`, `TabStop`, `TabStyle`

**Key methods:** `AddTab`, `Clear`, `DeleteTab`, `IndexOfTab`, `InsertTab`, `ItemHeight`, `ItemLeft`, `ItemTop`, `ItemWidth`, `ReorderTab`

**Key events:** `OnSelChange`, `OnSelChanging`, `OnTabAdded`, `OnTabRemoved`, `OnTabReordered`

### TabPage

Represents a single tab page in a TabControl.

*Changed in Astoria.* The TabControl parent requirement was found during testing - it is the only control that cannot be tested, or used, on its own.

**Key properties:** `BevelInner`, `BevelOuter`, `BevelWidth`, `BorderWidth`, `Caption`, `Graphic`, `ImageIndex`, `ImageKey`, `Index`, `Object`, `TabIndex`, `TabStop`, `Transparent`, `UseVisualStyleBackColor`

**Key methods:** `HandleIsAllocated`, `IsSelected`, `SelectTab`

**Key events:** `OnDeSelected`, `OnSelected`

> [!WARNING]
> **Cannot be parented to a Form.** A TabPage only works inside a `TabControl`; give it `.Parent = @yourTabControl`. It is the one control that cannot be used on its own.

### UserControl

Provides an empty control that can be used to create other controls. A Control authored in VisualFBEditor.

### VerticalBox

The Vertical Box lays out its child controls verically and will not wrap onto a new line in any circumstances

**Key properties:** `Spacing`, `TabIndex`, `TabStop`

---

## Components

Non-visual components. They appear in the designer tray rather than on the form, and have no on-screen presence at run time.

### CJSON_TYPE

A wrapper over the cJSON library for parsing and generating JSON: read a document into a tree of nodes, walk or edit it, and serialise it back to text.

> [!WARNING]
> Not documented in the framework help. `cJSON64.dll` appears in the built exe's strings but is **not** required at runtime - programs using it run with no DLL alongside.

### HTTPConnection

Provides a class for sending HTTP requests and receiving HTTP responses from a resource identified by a URI.

**Key properties:** `Abort`, `Host`, `Port`, `Timeout`

**Key methods:** `CallMethod`

**Key events:** `OnComplete`, `OnReceive`

### ImageList

An image list is a collection of images of the same size, each of which can be referred to by its index.

**Key properties:** `Count`, `DrawingStyle`, `GrowCount`, `ImageHeight`, `ImageType`, `ImageWidth`, `InitialCount`, `Items`, `MaskColor`, `ParentWindow`

**Key methods:** `AddFromFile`, `AddMasked`, `Clear`, `Draw`, `GetBitmap`, `GetCursor`, `GetIcon`, `GetMask`, `SetImageSize`

**Key events:** `OnChange`

### MainMenu

Represents the menu structure of a form.

**Key properties:** `Color`, `ColorizeEntire`, `Count`, `DisplayIcons`, `ImagesList`, `Item`, `ParentWindow`, `Style`, `Widget`

**Key methods:** `ChangeIndex`, `Clear`, `Find`, `Insert`, `ProcessMessages`

**Key events:** `OnActivate`

> [!WARNING]
> Attach to a Form's menu, not placed visually. `MainMenu` and `PopupMenu` both extend the abstract `Menu` type, which is deliberately absent from the toolbox.

### MariaDBBox

A client component for MariaDB and MySQL servers - connect, run queries, and read result sets. It talks to a database server over the network; it does not embed one.

*Changed in Astoria.* 16 call sites passed a `String` to `FromUtf8(pZString As ZString Ptr)` and assigned the returned pointer to a `UString`, so the library did not compile at all. They now decode straight from the API pointer. Astoria also ships `libmariadb.dll`, which the library needed but never included, and copies it beside your exe on build.

**Key methods:** `AddField`, `AddItem`, `AddItemUtf`, `Close`, `Count`, `CountUtf`, `CreateIndex`, `CreateIndexUtf`, `CreateTable`, `CreateTableUtf`, `DeleteItem`, `DeleteItemUtf`, `ErrMsg`, `Exec`, `Find`, `FindByte`, `FindByteUtf`, `FindOne`, `FindOneByte`, `FindOneByteUtf`, `FindOneUtf`, `FindOnly`, `FindOnlyUtf`, `FindUtf`, `GetMySQLPtr`, `INIGetKey`, `INISetKey`, `Insert`, `InsertUtf`, `MaxID`, `MaxIDUtf`, `Open`, `SetKey`, `SQLFind`, `SQLFindOne`, `Sum`, `SumUtf`, `TransactionBegin`, `TransactionEnd`, `TransactionRollback`, `UpdateByte`, `UpdateByteUtf`, `UpdateText`, `UpdateTextUtf`, `UpdateUtf`, `Vacuum`, `Version`

**Key events:** `OnErrorOut`, `OnSQLString`

> [!WARNING]
> Needs `libmariadb.dll` beside the built `.exe` (copied automatically on build).

> [!WARNING]
> Requires a reachable MariaDB/MySQL **server**; the control is only a client.

> [!WARNING]
> Only construction and compilation are verified - **no test has exercised a real connection or query**. Treat the data path as unproven.

### NotifyIcon

Specifies a component that creates an icon in the notification area.

**Key properties:** `BalloonTipIcon`, `BalloonTipIconType`, `BalloonTipText`, `BalloonTipTitle`, `Icon`

**Key methods:** `ShowBalloonTip`

**Key events:** `OnBalloonTipClicked`, `OnBalloonTipClosed`, `OnBalloonTipShown`

### PopupMenu

Represents a context menu.

**Key properties:** `Color`, `ColorizeEntire`, `Count`, `DisplayIcons`, `ImagesList`, `Item`, `ParentMenuItem`, `ParentWindow`, `Style`, `Widget`

**Key methods:** `ChangeIndex`, `Clear`, `Find`, `Insert`, `Popup`, `ProcessMessages`

**Key events:** `OnActivate`, `OnDropDown`, `OnPopup`

> [!WARNING]
> Shown on demand (typically from a right-click) rather than placed visually.

### PrintDocument

Defines a reusable object that sends output to a printer.

**Key properties:** `DocumentName`, `Pages`, `PrinterSettings`

**Key methods:** `Print`

**Key events:** `OnPrintPage`

### Printer

Enables you to communicate with a system printer (initially the default printer).

**Key properties:** `ColorMode`, `Copies`, `DriveVersion`, `DuplexMode`, `FontSize`, `FromPage`, `Marginbottom`, `MarginLeft`, `MarginRight`, `MarginTop`, `MaxCopies`, `MaxPaperHeight`, `MaxPaperWidth`, `Orientation`, `Page`, `PageLength`, `PageSize`, `PageWidth`, `PaperSizes`, `PortName`, `PrintableHeight`, `PrintableWidth`, `Quality`, `Scale`, `ScaleFactorX`, `ScaleFactorY`, `Title`, `ToPage`

**Key methods:** `CalcPageSize`, `ChoosePrinter`, `DefaultPrinter`, `EndDoc`, `EndDPage`, `GetCharSize`, `GetLines`, `GetPageSize`, `NewFont`, `NewPage`, `reportError`, `StartDoc`, `StartPage`

### SQLite3Component

An SQLite3 database component. SQLite is a file-backed embedded engine, so this needs no server - you open a `.db` file directly.

*Changed in Astoria.* Same defect as MariaDBBox at 22 call sites, plus 2 that needed `StrPtr()`. The library did not compile before this.

**Key methods:** `AddField`, `AddItem`, `AddItemUtf`, `Close`, `Count`, `CountUtf`, `CreateIndex`, `CreateIndexUtf`, `CreateTable`, `CreateTableUtf`, `DeleteItem`, `DeleteItemUtf`, `ErrMsg`, `Exec`, `Find`, `FindByte`, `FindByteUtf`, `FindOne`, `FindOneByte`, `FindOneByteUtf`, `FindOneUtf`, `FindOnly`, `FindOnlyUtf`, `FindUtf`, `GetSQLitePtr`, `INIGetKey`, `INISetKey`, `Insert`, `InsertUtf`, `MaxID`, `MaxIDUtf`, `MemOpen`, `MemSave`, `Open`, `SetKey`, `SQLFind`, `SQLFindOne`, `Sum`, `SumUtf`, `TransactionBegin`, `TransactionEnd`, `TransactionRollback`, `UpdateByte`, `UpdateByteUtf`, `UpdateText`, `UpdateTextUtf`, `UpdateUtf`, `Vacuum`, `Version`

**Key events:** `OnErrorOut`, `OnSQLString`

> [!WARNING]
> Links SQLite statically, so it needs no DLL. The `sqlite3*.dll` files in `Controls/SQLite3/` are left over and unused by builds - do not ship them.

> [!WARNING]
> Only construction and compilation are verified - **no test has exercised a real database file**. Treat the data path as unproven.

### TimerComponent

A control which can execute code at regular intervals by causing a Timer event.

**Key properties:** `Interval`

**Key events:** `OnTimer`

---

## Dialogs

Standard system dialogs. Non-visual at design time; you call `.ShowDialog` (or equivalent) to display them.

### ColorDialog

Represents a common dialog box that displays available colors along with controls that enable the user to define custom colors.

**Key properties:** `Caption`, `Center`, `Color`, `Colors`, `Style`

**Key methods:** `Execute`

### FolderBrowserDialog

Prompts the user to select a folder.

**Key properties:** `Caption`, `Center`, `Directory`, `InitialDir`, `Title`

**Key methods:** `Execute`

### FontDialog

Prompts the user to choose a font from among those installed on the local computer.

**Key properties:** `MaxFontSize`, `MinFontSize`

**Key methods:** `Execute`

### OpenFileDialog

Displays a standard dialog box that prompts the user to open a file.

**Key properties:** `Caption`, `Center`, `DefaultExt`, `FileName`, `FileNames`, `FileTitle`, `Filter`, `FilterIndex`, `InitialDir`, `MultiSelect`, `Options`

**Key methods:** `Execute`

**Key events:** `OnFolderChange`, `OnSelectionChange`, `OnTypeChange`

### PageSetupDialog

Enables users to change page-related print settings, including margins and paper orientation.

**Key properties:** `BottomMargin`, `Caption`, `LeftMargin`, `Metric`, `MinBottomMargin`, `MinLeftMargin`, `MinRightMargin`, `MinTopMargin`, `Orientation`, `PaperHeight`, `PaperSize`, `PaperWidth`, `PrinterName`, `RightMargin`, `TopMargin`

**Key methods:** `Execute`

### PrintDialog

Lets users select a printer and choose which sections of the document to print from an application.

**Key properties:** `AllowToFile`, `AllowToNetwork`, `Caption`, `FromPage`, `HelpFile`, `PrinterName`, `SetupDialog`, `ShowHelpButton`, `ToPage`, `xSetupDialog`

**Key methods:** `Execute`

### PrintPreviewDialog

Represents the raw preview part of print previewing from an application.

**Key properties:** `Caption`, `Document`

**Key methods:** `Execute`

### SaveFileDialog

Prompts the user to select a location for saving a file.

**Key properties:** `Caption`, `Center`, `Color`, `DefaultExt`, `FileName`, `Filter`, `FilterIndex`, `InitialDir`, `Options`

**Key methods:** `Execute`

**Key events:** `OnFolderChange`, `OnSelectionChange`, `OnTypeChange`

---

## Not in the toolbox

Three framework types look like controls but are deliberately absent.

| Type | Why |
| --- | --- |
| `Menu` | An abstract base, not a placeable control. `MainMenu` and `PopupMenu` extend it and are both in the toolbox. Declaring one directly needs the qualified name `My.Sys.Forms.Menu`. |
| `ListViewEx` | Hidden because it cannot be built: the header includes `ListViewEx.bas`, which MyFbFramework never shipped. Not fixable without an upstream implementation. |
| `SearchBar` | Same - `SearchBar.bas` is missing. Note `SearchBox` is a different, working control and is in the toolbox. |

`FileListBox` is also worth knowing about: despite the name it is **not** a visual control but a
helper that enumerates files in a directory. See [FrameworkFeatures.md](FrameworkFeatures.md).

---

## Changes made in Astoria

Astoria has modified the bundled control libraries. Everything below is a change from what
upstream ships, so it is worth knowing if you compare against the original framework or its
documentation.

| Control | Change |
| --- | --- |
| WebBrowser | **Re-enabled, then rebuilt on WebView2.** It was hidden as unbuildable (a `ByRef As WString` returning a literal); fixing that revealed it could not render at all, because it hosted the retired IE engine via ATL and crashed on `Navigate`. Now hosts WebView2 by default. Rendering and navigation both verified (TestPlan A4/A5). |
| MariaDBBox | **Made to compile** (16 `FromUtf8` call sites), and `libmariadb.dll` - missing from the library entirely - is now shipped and copied beside your exe. |
| SQLite3Component | **Made to compile** (22 `FromUtf8` call sites, plus 2 needing `StrPtr()`). |
| ScintillaControl | Its three DLLs are now copied beside your exe on build. |
| ListViewEx, SearchBar | **Kept hidden.** Each ships a `.bi` whose implementation `.bas` was never included upstream, so neither can be built. Needs an upstream fix. |
| Toolbox: Cursor | Shown **once**, under Controls, rather than repeated in all four groups. |

Beyond the controls, the build now copies any control library's declared runtime DLLs beside
the program it builds, so a program using ScintillaControl or MariaDBBox starts on a machine
other than the one that compiled it. See ControlTesting.md for how a library declares these.

---

## Acknowledgements

Astoria stands on **MyFbFramework** and **VisualFBEditor**, and essentially every control
documented here is their work rather than ours. Our contribution has been to test them, fix a
handful of build errors, and write this reference - the design, the implementation and the
original documentation are theirs.

With thanks to:

- **Xusinboy Bekchanov** - author of MyFbFramework and VisualFBEditor, and the primary hand
  behind nearly every control in this document.
- **Liu XiaLin** - co-author across a large part of the framework.
- **Nastase Eodor** - co-author of much of the control and drawing code.
- **Aloberoger** - contributor to several controls.

MyFbFramework is published under the LGPL / modified LGPL. The upstream projects:

- MyFbFramework - <https://github.com/XusinboyBekchanov/MyFbFramework>
- VisualFBEditor - <https://github.com/XusinboyBekchanov/VisualFBEditor>

The descriptions and member lists in this document are drawn from their documentation.
Bundled add-ons carry their own credits: ScintillaControl (CM.Wang, over Scintilla),
SQLite3Component (Yongfang Software Development Team), cJSON (Dave Gamble and contributors),
and MariaDBBox (Xusinboy Bekchanov, over the MariaDB Connector/C).
