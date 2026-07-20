'###############################################################################
'#  ListView.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                         #
'###############################################################################

#include once "ListView.bi"
	#include once "win\tmschema.bi"

Namespace My.Sys.Forms
		Private Function ListView.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "allowcolumnreorder": Return @FAllowColumnReorder
			Case "borderselect": Return @FBorderSelect
			Case "checkboxes": Return @FCheckBoxes
			Case "columnheaderhidden": Return @FColumnHeaderHidden
			Case "fullrowselect": Return @FFullRowSelect
			Case "hovertime": Return @FHoverTime
			Case "gridlines": Return @FGridLines
			Case "images": Return Images
			Case "stateimages": Return StateImages
			Case "smallimages": Return SmallImages
			Case "groupheaderimages": Return GroupHeaderImages
			Case "labeltip": Return @FLabelTip
			Case "singleclickactivate": Return @FSingleClickActivate
			Case "sort": Return @FSortStyle
			Case "tabindex": Return @FTabIndex
			Case "hoverselection": Return @FHoverSelection
			Case "view": Return @FView
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ListView.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "allowcolumnreorder": AllowColumnReorder = QBoolean(Value)
				Case "borderselect": BorderSelect = QBoolean(Value)
				Case "checkboxes": CheckBoxes = QBoolean(Value)
				Case "columnheaderhidden": ColumnHeaderHidden = QBoolean(Value)
				Case "fullrowselect": FullRowSelect = QBoolean(Value)
				Case "hovertime": HoverTime = QInteger(Value)
				Case "gridlines": GridLines = QBoolean(Value)
				Case "images": Images = Cast(ImageList Ptr, Value)
				Case "stateimages": StateImages = Cast(ImageList Ptr, Value)
				Case "smallimages": SmallImages = Cast(ImageList Ptr, Value)
				Case "groupheaderimages": GroupHeaderImages = Cast(ImageList Ptr, Value)
				Case "labeltip": LabelTip = QBoolean(Value)
				Case "singleclickactivate": SingleClickActivate = QBoolean(Value)
				Case "sort": Sort = *Cast(SortStyle Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "hoverselection": HoverSelection = QBoolean(Value)
				Case "view": This.View = *Cast(ViewStyle Ptr, Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property ListView.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ListView.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ListView.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ListView.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Function ListViewItem.Index As Integer
		If Parent Then
			Return Cast(ListView Ptr, Parent)->ListItems.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Property ListViewItem.Selected As Boolean
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_STATE
				lvi.iItem = Index
				lvi.iSubItem = 0
				lvi.stateMask = LVIS_SELECTED
				ListView_GetItem(Parent->Handle, @lvi)
				FSelected = (lvi.state And LVIS_SELECTED) = LVIS_SELECTED
			End If
		Return FSelected
	End Property
	
	Private Property ListViewItem.Selected(Value As Boolean)
		FSelected = Value
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_STATE
				lvi.iItem = Index
				ListView_GetItem(Parent->Handle, @lvi)
				If Value Then
					If (lvi.state And LVIS_SELECTED) <> LVIS_SELECTED Then
						lvi.state = lvi.state Or LVIS_SELECTED
						ListView_SetItem(Parent->Handle, @lvi)
					End If
				ElseIf (lvi.state And LVIS_SELECTED) = LVIS_SELECTED Then
					lvi.state = lvi.state And Not LVIS_SELECTED
					ListView_SetItem(Parent->Handle, @lvi)
				End If
			End If
	End Property
	
	Private Sub ListViewItem.SelectItem
			If Parent AndAlso Parent->Handle Then
				Dim lvi As LVITEM
				lvi.iItem = Index
				lvi.iSubItem   = 0
				lvi.state    = LVIS_SELECTED Or LVIS_FOCUSED
				lvi.stateMask = LVIF_STATE
				ListView_SetItem(Parent->Handle, @lvi)
			End If
	End Sub
	
	Private Property ListViewItem.Text(iSubItem As Integer) ByRef As WString
			If Parent AndAlso Parent->Handle Then
				WReAllocate(FText, 1024)
				lvi.mask = LVIF_TEXT
				lvi.iItem = Index
				lvi.iSubItem   = iSubItem
				lvi.pszText    = FText
				lvi.cchTextMax = 1024
				ListView_GetItem(Parent->Handle, @lvi)
				FSubItems.Item(iSubItem) = *FText
				Return FSubItems.Item(iSubItem)
			Else
				If FSubItems.Count > iSubItem Then
					Return FSubItems.Item(iSubItem)
				Else
					Return WStr("")
				End If
			End If
	End Property
	
	
	Private Property ListViewItem.Text(iSubItem As Integer, ByRef Value As WString)
		WLet(FText, Value)
		If Parent Then
			Dim ic As Integer = FSubItems.Count
			Dim cc As Integer = Cast(ListView Ptr, Parent)->Columns.Count
			If ic < cc Then
				For i As Integer = ic + 1 To cc
					FSubItems.Add ""
				Next i
			End If
			If iSubItem < cc Then FSubItems.Item(iSubItem) = Value
				If Parent->Handle Then
					lvi.mask = LVIF_TEXT
					lvi.iItem = Index
					lvi.iSubItem   = iSubItem
					lvi.pszText    = FText
					lvi.cchTextMax = Len(*FText)
					ListView_SetItem(Parent->Handle, @lvi)
				End If
		End If
	End Property
	
	Private Property ListViewItem.State As Integer
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_STATE
				lvi.iItem = Index
				lvi.iSubItem   = 0
				ListView_GetItem(Parent->Handle, @lvi)
				FState = lvi.state
			End If
		Return FState
	End Property
	
	Private Property ListViewItem.State(Value As Integer)
		FState = Value
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_STATE
				lvi.iItem = Index
				lvi.iSubItem   = 0
				lvi.state    = Value
				ListView_SetItem(Parent->Handle, @lvi)
			End If
	End Property
	
	Private Property ListViewItem.Indent As Integer
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_INDENT
				lvi.iItem = Index
				lvi.iSubItem   = 0
				ListView_GetItem(Parent->Handle, @lvi)
				FIndent = lvi.iIndent
			End If
		Return FIndent
	End Property
	
	Private Property ListViewItem.Indent(Value As Integer)
		FIndent = Value
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_INDENT
				lvi.iItem = Index
				lvi.iSubItem   = 0
				lvi.iIndent    = Value
				ListView_SetItem(Parent->Handle, @lvi)
			End If
	End Property
	
	Const LVIS_UNCHECKED = 4096
	Const LVIS_CHECKED = 8192
	Const LVIS_CHECKEDMASK = 12288
	
	Private Property ListViewItem.Checked As Boolean
			If Parent AndAlso Parent->Handle Then
				FChecked = ListView_GetItemState(Parent->Handle, Index, LVIS_CHECKEDMASK) = LVIS_CHECKED
			End If
		Return FChecked
	End Property
	
	Private Property ListViewItem.Checked(Value As Boolean)
		FChecked = Value
			If Parent AndAlso Parent->Handle Then
				lvi.mask = LVIF_STATE
				lvi.iItem = Index
				lvi.stateMask = LVIS_CHECKEDMASK
				If Value Then
					lvi.state = LVIS_CHECKED
				Else
					lvi.state = LVIS_UNCHECKED
				End If
				ListView_SetItem(Parent->Handle, @lvi)
			End If
	End Property
	
	Private Property ListViewItem.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property ListViewItem.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property ListViewItem.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewItem.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
				If Parent AndAlso Parent->Handle Then
					lvi.mask = LVIF_IMAGE
					lvi.iItem = Index
					lvi.iSubItem   = 0
					lvi.iImage     = Value
					ListView_SetItem(Parent->Handle, @lvi)
				End If
		End If
	End Property
	
	Private Property ListViewItem.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewItem.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewItem.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ListViewItem.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewItem.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ListViewItem.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
				If Parent AndAlso Parent->Handle AndAlso Cast(ListView Ptr, Parent)->Images Then
					FImageIndex = Cast(ListView Ptr, Parent)->Images->IndexOf(Value)
					lvi.mask = LVIF_IMAGE
					lvi.iItem = Index
					lvi.iSubItem   = 0
					lvi.iImage     = FImageIndex
					ListView_SetItem(Parent->Handle, @lvi)
				End If
		End If
	End Property
	
	Private Property ListViewItem.SelectedImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ListViewItem.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator ListViewItem.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewItem
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text(0)    = ""
		Hint       = ""
		FImageIndex = -1
		FSelectedImageIndex = -1
		FSmallImageIndex = -1
	End Constructor
	
	Private Destructor ListViewItem
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
		If FImageKey Then _Deallocate( FImageKey)
		If FSelectedImageKey Then _Deallocate( FSelectedImageKey)
		If FSmallImageKey Then _Deallocate( FSmallImageKey)
	End Destructor
	
	Private Sub ListViewColumn.SelectItem
			If Parent AndAlso Parent->Handle Then ListView_SetSelectedColumn(Parent->Handle, Index)
	End Sub
	
	Private Property ListViewColumn.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property ListViewColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_TEXT Or LVCF_SUBITEM
				lvc.iSubItem = Index
				lvc.pszText = FText
				lvc.cchTextMax = Len(*FText)
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			End If
	End Property
	
	Private Property ListViewColumn.Width As Integer
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_WIDTH Or LVCF_SUBITEM
				lvc.iSubItem = Index
				ListView_GetColumn(Parent->Handle, Index, @lvc)
				FWidth = UnScaleX(lvc.cx)
			End If
		Return FWidth
	End Property
	
	Private Property ListViewColumn.Width(Value As Integer)
		FWidth = Value
		Update
	End Property
	
	Private Sub ListViewColumn.Update
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_WIDTH Or LVCF_SUBITEM
				lvc.iSubItem = Index
				lvc.cx = ScaleX(FWidth)
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			End If
	End Sub
	
	Private Property ListViewColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	Private Property ListViewColumn.Format(Value As ColumnFormat)
		FFormat = Value
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_FMT Or LVCF_SUBITEM
				lvc.iSubItem = Index
				lvc.fmt = Value
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			End If
	End Property
	
	Private Property ListViewColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property ListViewColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property ListViewColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewColumn.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ListViewColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewColumn.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property ListViewColumn.Editable(Value As Boolean)
		If Value <> FEditable Then
			FEditable = Value
		End If
	End Property
	
	Private Operator ListViewColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewColumn
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text    = ""
		Hint       = ""
		FImageIndex = -1
	End Constructor
	
	Private Destructor ListViewColumn
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Property ListViewItems.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property ListViewItems.Count(Value As Integer)
	End Property
	
	Private Property ListViewItems.Item(Index As Integer) As ListViewItem Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
		Return 0
	End Property
	
	Private Property ListViewItems.Item(Index As Integer, Value As ListViewItem Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value
		End If
	End Property
	
	
	Private Function ListViewItems.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1) As ListViewItem Ptr
		PItem = _New( ListViewItem)
		Dim i As Integer = Index
		Dim As SortStyle iSortStyle = Cast(ListView Ptr, Parent)->Sort
		If iSortStyle <> SortStyle.ssNone Then
			For i = 0 To FItems.Count - 1
				If iSortStyle = SortStyle.ssSortAscending Then
					If Cast(ListViewItem Ptr, FItems.Item(i))->Text(0) > FCaption Then Exit For
				Else
					If Cast(ListViewItem Ptr, FItems.Item(i))->Text(0) < FCaption Then Exit For
				End If
			Next
			FItems.Insert i, PItem
		ElseIf Index = -1 Then
			FItems.Add PItem
		Else
			FItems.Insert i, PItem
		End If
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State        = State
			.Indent        = Indent
		End With
			lvi.mask = LVIF_TEXT Or LVIF_IMAGE Or LVIF_STATE Or LVIF_INDENT Or LVIF_PARAM
			lvi.pszText  = @FCaption
			lvi.cchTextMax = Len(FCaption)
			lvi.iItem = IIf(Index = -1, FItems.Count - 1, Index)
			lvi.iSubItem = 0
			lvi.iImage   = FImageIndex
			lvi.state   = INDEXTOSTATEIMAGEMASK(State)
			lvi.stateMask = LVIS_STATEIMAGEMASK
			lvi.iIndent   = Indent
			lvi.lParam    = Cast(LPARAM, PItem)
		If Parent Then
				If Parent->Handle Then ListView_InsertItem(Parent->Handle, @lvi)
			PItem->Parent = Parent
			PItem->Text(0) = FCaption
		End If
		Return PItem
	End Function
	
	Private Function ListViewItems.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1) As ListViewItem Ptr
		If Parent AndAlso Cast(ListView Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(ListView Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent, Index)
		Else
			PItem = Add(FCaption, -1, State, Indent, Index)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function ListViewItems.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As ListViewItem Ptr
		Dim As ListViewItem Ptr PItem
			Dim As LVITEM lvi
		PItem = _New( ListViewItem)
		FItems.Insert Index, PItem
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State          = State
			.Indent         = Indent
		End With
			lvi.mask = LVIF_TEXT Or LVIF_IMAGE Or LVIF_STATE Or LVIF_INDENT Or LVIF_PARAM
			lvi.pszText  = @FCaption
			lvi.cchTextMax = Len(FCaption)
			lvi.iItem = Index
			lvi.iImage   = FImageIndex
			lvi.state   = INDEXTOSTATEIMAGEMASK(State)
			lvi.stateMask = LVIS_STATEIMAGEMASK
			lvi.iIndent   = Indent
			lvi.lParam    = Cast(LPARAM, PItem)
			If Parent Then
				PItem->Parent = Parent
				If Parent->Handle Then ListView_InsertItem(Parent->Handle, @lvi)
			End If
		Return PItem
	End Function
	
	Private Sub ListViewItems.Remove(Index As Integer)
		If Count < 1 OrElse Index < 0 OrElse Index > Count - 1 Then Exit Sub
			If Parent AndAlso Parent->Handle Then
				ListView_DeleteItem(Parent->Handle, Index)
			End If
		_Delete(Cast(ListViewItem Ptr, FItems.Items[Index]))
		FItems.Remove Index
	End Sub
	
		Private Function ListViewItems.ListViewCompareFunc(ByVal lParam1 As LPARAM, ByVal lParam2 As LPARAM, ByVal lParamSort As LPARAM) As Long
			Dim As ListViewItem Ptr FirstItem = Cast(ListViewItem Ptr, lParam1), SecondItem = Cast(ListViewItem Ptr, lParam2)
			If FirstItem <> 0 AndAlso SecondItem <> 0 Then
				Select Case FirstItem->Text(0)
				Case Is < SecondItem->Text(0): Return -1
				Case Is > SecondItem->Text(0): Return 1
				Case Else: Return 0
				End Select
			End If
			Return 0
		End Function
	
	Private Sub ListViewItems.Sort
			If Parent AndAlso Parent->Handle Then
				SendMessage Parent->Handle, LVM_SORTITEMS, 0, Cast(WPARAM, @ListViewCompareFunc)
				'ListView_SortItems Parent->Handle, @ListViewCompareFunc, 0
			End If
	End Sub
	
	Private Function ListViewItems.IndexOf(ByRef FItem As ListViewItem Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Function ListViewItems.IndexOf(ByRef Caption As WString) As Integer
		For i As Integer = 0 To Count - 1
			If LCase(QListViewItem(FItems.Items[i]).Text(0)) = LCase(Caption) Then
				Return i
			End If
		Next i
		Return -1
	End Function
	
	Private Function ListViewItems.Contains(ByRef Caption As WString) As Boolean
		Return IndexOf(Caption) <> -1
	End Function
	
	Private Sub ListViewItems.Clear
			If Parent AndAlso Parent->Handle Then SendMessage Parent->Handle, LVM_DELETEALLITEMS, 0, 0
		For i As Integer = Count -1 To 0 Step -1
			_Delete( Cast(ListViewItem Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Operator ListViewItems.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewItems
		This.Clear
	End Constructor
	
	Private Destructor ListViewItems
			This.Clear
	End Destructor
	
	Private Property ListViewColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property ListViewColumns.Count(Value As Integer)
	End Property
	
	Private Property ListViewColumns.Column(Index As Integer) As ListViewColumn Ptr
		Return QListViewColumn(FColumns.Items[Index])
	End Property
	
	Private Property ListViewColumns.Column(Index As Integer, Value As ListViewColumn Ptr)
		'QListViewColumn(FColumns.Items[Index]) = Value
	End Property
	
	
	Private Function ListViewColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False) As ListViewColumn Ptr
		Dim As ListViewColumn Ptr PColumn
		Dim As Integer Index
			Dim As LVCOLUMN lvc
		PColumn = _New( ListViewColumn)
		FColumns.Add PColumn
		Index = FColumns.Count - 1
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index = Index
			.Width     = iWidth
			.Format = Format
			
		End With
			If Parent Then
			lvc.mask      =  LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
			lvc.fmt       =  Format
			lvc.cx		  = Parent->ScaleX(IIf(iWidth = -1, 50, iWidth))
			lvc.iImage   = PColumn->ImageIndex
			lvc.iSubItem = PColumn->Index
			lvc.pszText  = @FCaption
			lvc.cchTextMax = Len(FCaption)
			PColumn->Parent = Parent
				If Parent->Handle Then
					ListView_InsertColumn(Parent->Handle, PColumn->Index, @lvc)
				End If
		End If
		Return PColumn
	End Function
	
	Private Sub ListViewColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer, Format As ColumnFormat = cfLeft)
		Dim As ListViewColumn Ptr PColumn
			Dim As LVCOLUMN lvc
		PColumn = _New( ListViewColumn)
		FColumns.Insert Index, PColumn
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index        = FColumns.Count - 1
			.Width     = iWidth
			.Format = Format
		End With
			lvC.mask      =  LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
			lvC.fmt       =  Format
			lvc.cx        =  0
			lvc.iImage   = PColumn->ImageIndex
			lvc.iSubItem = PColumn->Index
			lvc.pszText  = @FCaption
			lvc.cchTextMax = Len(FCaption)
			If Parent Then
				PColumn->Parent = Parent
				If Parent->Handle Then
					ListView_InsertColumn(Parent->Handle, Index, @lvc)
					ListView_SetColumnWidth(Parent->Handle, Index, ScaleX(iWidth))
				End If
			End If
	End Sub
	
	Private Sub ListViewColumns.Remove(Index As Integer)
		FColumns.Remove Index
			If Parent AndAlso Parent->Handle Then
				SendMessage Parent->Handle, LVM_DELETECOLUMN, Cast(WPARAM, Index), 0
			End If
	End Sub
	
	Private Function ListViewColumns.IndexOf(ByRef FColumn As ListViewColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub ListViewColumns.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QListViewColumn(FColumns.Items[i]))
			Remove i
				If Parent AndAlso Parent->Handle Then
					SendMessage Parent->Handle, LVM_DELETECOLUMN, Cast(WPARAM, i), 0
				End If
		Next i
		FColumns.Clear
	End Sub
	
	Private Operator ListViewColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewColumns
		This.Clear
	End Constructor
	
	Private Destructor ListViewColumns
		This.Clear
	End Destructor
	
	Private Sub ListView.Init()
	End Sub
	
	Private Sub ListView.EnsureVisible(Index As Integer)
			ListView_EnsureVisible(FHandle, Index, True)
	End Sub
	
	Private Property ListView.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property ListView.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
			ChangeStyle LVS_NOCOLUMNHEADER, Value
	End Property
	
	Private Sub ListView.ChangeLVExStyle(iStyle As Integer, Value As Boolean)
			If FHandle Then FLVExStyle = SendMessage(FHandle, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
			If Value Then
				If ((FLVExStyle And iStyle) <> iStyle) Then FLVExStyle = FLVExStyle Or iStyle
			ElseIf ((FLVExStyle And iStyle) = iStyle) Then
				FLVExStyle = FLVExStyle And Not iStyle
			End If
			If FHandle Then SendMessage(FHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, ByVal FLVExStyle)
	End Sub
	
	Private Property ListView.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property ListView.SingleClickActivate(Value As Boolean)
		FSingleClickActivate = Value
			ChangeLVExStyle LVS_EX_ONECLICKACTIVATE, Value
	End Property
	
	Private Property ListView.HoverSelection As Boolean
		Return FHoverSelection
	End Property
	
	Private Property ListView.HoverSelection(Value As Boolean)
		FHoverSelection = Value
			ChangeLVExStyle LVS_EX_TRACKSELECT, Value
	End Property
	
	Private Property ListView.AllowColumnReorder As Boolean
		Return FAllowColumnReorder
	End Property
	
	Private Property ListView.AllowColumnReorder(Value As Boolean)
		FAllowColumnReorder = Value
			ChangeLVExStyle LVS_EX_HEADERDRAGDROP, Value
	End Property
	
	Private Property ListView.BorderSelect As Boolean
		Return FBorderSelect
	End Property
	
	Private Property ListView.BorderSelect(Value As Boolean)
		FBorderSelect = Value
			ChangeLVExStyle LVS_EX_BORDERSELECT, Value
	End Property
	
	Private Property ListView.GridLines As Boolean
		Return FGridLines
	End Property
	
	Private Property ListView.GridLines(Value As Boolean)
		FGridLines = Value
			ChangeLVExStyle LVS_EX_GRIDLINES, Value
	End Property
	
	Private Property ListView.CheckBoxes As Boolean
		Return FCheckBoxes
	End Property
	
	Private Property ListView.CheckBoxes(Value As Boolean)
		FCheckBoxes = Value
			ChangeLVExStyle LVS_EX_CHECKBOXES, Value
	End Property
	
	Private Property ListView.FullRowSelect As Boolean
		Return FFullRowSelect
	End Property
	
	Private Property ListView.FullRowSelect(Value As Boolean)
		FFullRowSelect = Value
			ChangeLVExStyle LVS_EX_FULLROWSELECT, Value
	End Property
	
	Private Property ListView.LabelTip As Boolean
		Return FLabelTip
	End Property
	
	Private Property ListView.LabelTip(Value As Boolean)
		FLabelTip = Value
			ChangeLVExStyle LVS_EX_LABELTIP, Value
	End Property
	
	Private Property ListView.MultiSelect As Boolean
		Return FMultiSelect
	End Property
	
	Private Property ListView.MultiSelect(Value As Boolean)
		FMultiSelect = Value
			ChangeStyle LVS_SINGLESEL, Not Value
	End Property
	
	Private Property ListView.HoverTime As Integer
		Return FHoverTime
	End Property
	
	Private Property ListView.HoverTime(Value As Integer)
		FHoverTime = Value
			If Handle Then Perform(LVM_SETHOVERTIME, 0, Value)
	End Property
	
	Private Property ListView.View As ViewStyle
			If Handle Then
				FView = ListView_GetView(Handle)
			End If
		Return FView
	End Property
	
	Private Property ListView.View(Value As ViewStyle)
		FView = Value
			If Handle Then Perform LVM_SETVIEW, Cast(WPARAM, Cast(DWORD, Value)), 0
	End Property
	
	Private Property ListView.SelectedItem As ListViewItem Ptr
			If Handle Then
				Dim As Integer item = ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
				If item <> -1 Then Return ListItems.Item(item)
			End If
		Return 0
	End Property
	
	Private Property ListView.SelectedItemIndex As Integer
			If Handle Then
				Return ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
			End If
		Return -1
	End Property
	
	Private Property ListView.SelectedItemIndex(Value As Integer)
			If Handle Then
				ListView_SetItemState(Handle, Value, LVIS_FOCUSED Or LVIS_SELECTED, LVNI_SELECTED Or LVNI_FOCUSED)
				ListView_EnsureVisible(Handle, Value, True)
			End If
	End Property
	
	Private Property ListView.SelectedItem(Value As ListViewItem Ptr)
		Value->SelectItem
	End Property
	
	Private Property ListView.SelectedColumn As ListViewColumn Ptr
			If Handle Then
				Return Columns.Column(ListView_GetSelectedColumn(Handle))
			End If
		Return 0
	End Property
	
	Private Property ListView.Sort As SortStyle
		Return FSortStyle
	End Property
	
	Private Property ListView.Sort(Value As SortStyle)
		FSortStyle = Value
			Select Case FSortStyle
			Case SortStyle.ssNone
				ChangeStyle LVS_SORTASCENDING, False
				ChangeStyle LVS_SORTDESCENDING, False
			Case SortStyle.ssSortAscending
				ChangeStyle LVS_SORTDESCENDING, False
				ChangeStyle LVS_SORTASCENDING, True
			Case SortStyle.ssSortDescending
				ChangeStyle LVS_SORTASCENDING, False
				ChangeStyle LVS_SORTDESCENDING, True
			End Select
	End Property
	
	Private Property ListView.SelectedColumn(Value As ListViewColumn Ptr)
			If Handle Then ListView_SetSelectedColumn(Handle, Value->Index)
	End Property
	
	Private Property ListView.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property ListView.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Sub ListView.WndProc(ByRef Message As Message)
	End Sub
	
	
	Private Sub ListView.ProcessMessage(ByRef Message As Message)
		'?message.msg, GetMessageName(message.msg)
			Select Case Message.Msg
			Case WM_PAINT
				Message.Result = 0
			Case CM_DRAWITEM
				Dim lpdis As DRAWITEMSTRUCT Ptr
				Dim As Integer ItemID, State
				lpdis = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				If OnDrawItem Then
					Canvas.SetHandle lpdis->hDC
					OnDrawItem(*Designer, This, lpdis->itemID, lpdis->itemState, lpdis->itemAction, *Cast(My.Sys.Drawing.Rect Ptr, @lpdis->rcItem), Canvas)
					Canvas.UnSetHandle
					Message.Result = True
					Exit Sub
				End If
			Case CM_MEASUREITEM
				Dim As MEASUREITEMSTRUCT Ptr miStruct
				Dim As Integer ItemID
				miStruct = Cast(MEASUREITEMSTRUCT Ptr, Message.lParam)
				ItemID = Cast(Integer, miStruct->itemID)
				'If FOwnerDraw Then miStruct->itemHeight = ScaleY(17)
				If StateImages Then
					miStruct->itemHeight = ScaleY(StateImages->ImageHeight) + 1
				End If
				If OnMeasureItem Then OnMeasureItem(*Designer, This, ItemID, miStruct->itemWidth, miStruct->itemHeight)
			Case WM_DPICHANGED
				Base.ProcessMessage(Message)
				If Images Then Images->SetImageSize Images->ImageWidth, Images->ImageHeight, xdpi, ydpi
				If SmallImages Then SmallImages->SetImageSize SmallImages->ImageWidth, SmallImages->ImageHeight, xdpi, ydpi
				If StateImages Then StateImages->SetImageSize StateImages->ImageWidth, StateImages->ImageHeight, xdpi, ydpi
				If GroupHeaderImages Then GroupHeaderImages->SetImageSize GroupHeaderImages->ImageWidth, GroupHeaderImages->ImageHeight, xdpi, ydpi
				
				If Images AndAlso Images->Handle Then ListView_SetImageList(FHandle, CInt(Images->Handle), LVSIL_NORMAL)
				If SmallImages AndAlso SmallImages->Handle Then ListView_SetImageList(FHandle, CInt(SmallImages->Handle), LVSIL_SMALL)
				If StateImages AndAlso StateImages->Handle Then ListView_SetImageList(FHandle, CInt(StateImages->Handle), LVSIL_STATE)
				If GroupHeaderImages AndAlso GroupHeaderImages->Handle Then ListView_SetImageList(FHandle, CInt(GroupHeaderImages->Handle), LVSIL_GROUPHEADER)
				FItemHeight = 0
				Dim As ..Rect rc
				GetWindowRect(FHandle, @rc)
				Dim As WINDOWPOS wp
				wp.hwnd = FHandle
				wp.cx = rc.Right
				wp.cy = rc.Bottom
				wp.flags = SWP_NOACTIVATE Or SWP_NOMOVE Or SWP_NOOWNERZORDER Or SWP_NOZORDER
				SendMessage(FHandle, WM_WINDOWPOSCHANGED, 0, Cast(LPARAM, @wp))
				For i As Integer = 0 To Columns.Count - 1
					Columns.Column(i)->xdpi = xdpi
					Columns.Column(i)->ydpi = ydpi
					Columns.Column(i)->Update
				Next
				Return
			Case WM_CONTEXTMENU
				If ContextMenu Then
					If ContextMenu->Handle Then
						Dim As ..Point P
						P.X = GET_X_LPARAM(Message.lParam)
						P.Y = GET_Y_LPARAM(Message.lParam)
						ContextMenu->Popup(P.X, P.Y)
					End If
				End If
			Case WM_DESTROY
				If Images Then ListView_SetImageList(FHandle, 0, LVSIL_NORMAL)
				If StateImages Then ListView_SetImageList(FHandle, 0, LVSIL_STATE)
				If SmallImages Then ListView_SetImageList(FHandle, 0, LVSIL_SMALL)
				If GroupHeaderImages Then ListView_SetImageList(FHandle, 0, LVSIL_GROUPHEADER)
			Case WM_SIZE
			Case WM_NOTIFY
				If (Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW) Then
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Message.Result = CDRF_NOTIFYITEMDRAW
						Return
					Case CDDS_ITEMPREPAINT
						'Var info = Cast(SubclassInfo Ptr, dwRefData)
						Message.Result = CDRF_DODEFAULT
						Return
					End Select
				End If
			Case WM_THEMECHANGED
			Case CM_NOTIFY
				Dim lvp As NMLISTVIEW Ptr = Cast(NMLISTVIEW Ptr, Message.lParam)
				Select Case lvp->hdr.code
				Case NM_CLICK: If OnItemClick Then OnItemClick(*Designer, This, lvp->iItem)
				Case NM_DBLCLK: If OnItemDblClick Then OnItemDblClick(*Designer, This, lvp->iItem)
				Case NM_KEYDOWN: 
					Dim As LPNMKEY lpnmk = Cast(LPNMKEY, Message.lParam)
					If OnItemKeyDown Then OnItemKeyDown(*Designer, This, lvp->iItem, lpnmk->nVKey, lpnmk->uFlags And &HFFFF)
				Case NM_CUSTOMDRAW
				Case LVN_ITEMACTIVATE: If lvp->iItem >= 0 AndAlso OnItemActivate Then OnItemActivate(*Designer, This, lvp->iItem)
				Case LVN_BEGINSCROLL: If OnBeginScroll Then OnBeginScroll(*Designer, This)
				Case LVN_ENDSCROLL: If OnEndScroll Then OnEndScroll(*Designer, This)
				Case LVN_ITEMCHANGING:
					Dim bCancel As Boolean
					If lvp->iItem >= 0 AndAlso OnSelectedItemChanging Then OnSelectedItemChanging(*Designer, This, lvp->iItem, bCancel)
					If bCancel Then Message.Result = -1: Exit Sub
				Case LVN_ITEMCHANGED: If ((lvp->uNewState And LVIS_SELECTED) <> 0) AndAlso ( (lvp->uOldState And LVIS_SELECTED) = 0) AndAlso OnSelectedItemChanged Then OnSelectedItemChanged(*Designer, This, lvp->iItem)
					'If ((lvp->uNewState And LVIS_SELECTED) <> 0) And ( (lvp->uOldState And LVIS_SELECTED) = 0) Then
					'' Item was selected
					'End If
					'If ( (lvp->uNewState And LVIS_FOCUSED) = 0) And ( (lvp->uOldState And LVIS_FOCUSED) <> 0) Then
					'' Item lost focus
					'End If
					
				Case HDN_ITEMCHANGED:
				End Select
			Case CM_COMMAND
				Select Case Message.wParam
				Case LVN_ITEMACTIVATE
				Case LVN_KEYDOWN
				Case LVN_ITEMCHANGING
				Case LVN_ITEMCHANGED
				Case LVN_INSERTITEM
				Case LVN_DELETEITEM
				Case LVN_DELETEALLITEMS
				Case LVN_BEGINLABELEDIT
				Case LVN_ENDLABELEDIT
				Case LVN_COLUMNCLICK
				Case LVN_BEGINDRAG
				Case LVN_BEGINRDRAG
				Case LVN_ODCACHEHINT
				Case LVN_ODFINDITEM
				Case LVN_ODSTATECHANGED
				Case LVN_HOTTRACK
				Case LVN_GETDISPINFO
				Case LVN_SETDISPINFO
					'Case LVN_COLUMNDROPDOWN
				Case LVN_GETINFOTIP
					'Case LVN_COLUMNOVERFLOWCLICK
				Case LVN_INCREMENTALSEARCH
				Case LVN_BEGINSCROLL
				Case LVN_ENDSCROLL
					'Case LVN_LINKCLICK
					'Case LVN_GETEMPTYMARKUP
				End Select
				
				'            Dim As TBNOTIFY PTR Tbn
				'            Dim As TBBUTTON TB
				'            Dim As RECT R
				'            Dim As Integer i
				'            Tbn = Cast(TBNOTIFY PTR,Message.lParam)
				'            Select Case Tbn->hdr.Code
				'            Case TBN_DROPDOWN
				'                 If Tbn->iItem <> -1 Then
				'                     SendMessage(Tbn->hdr.hwndFrom,TB_GETRECT,Tbn->iItem,CInt(@R))
				'                     MapWindowPoints(Tbn->hdr.hwndFrom,0,Cast(Point Ptr,@R),2)
				'                     i = SendMessage(Tbn->hdr.hwndFrom,TB_COMMANDTOINDEX,Tbn->iItem,0)
				'                     If SendMessage(Tbn->hdr.hwndFrom,TB_GETBUTTON,i,CInt(@TB)) Then
				'                         TrackPopupMenu(Buttons.Button(i)->DropDownMenu.Handle,0,R.Left,R.Bottom,0,Tbn->hdr.hwndFrom,NULL)
				'                     End If
				'                 End If
				'            End Select
			Case CM_NEEDTEXT
				'            Dim As LPTOOLTIPTEXT TTX
				'            TTX = Cast(LPTOOLTIPTEXT,Message.lParam)
				'            TTX->hInst = GetModuleHandle(NULL)
				'            If TTX->hdr.idFrom Then
				'                Dim As TBButton TB
				'                Dim As Integer Index
				'                Index = Perform(TB_COMMANDTOINDEX,TTX->hdr.idFrom,0)
				'                If Perform(TB_GETBUTTON,Index,CInt(@TB)) Then
				'                   If Buttons.Button(Index)->ShowHint Then
				'                      If Buttons.Button(Index)->Hint <> "" Then
				'                          'Dim As UString s
				'                          's = Buttons.Button(Index).Hint
				'                          TTX->lpszText = @(Buttons.Button(Index)->Hint)
				'                      End If
				'                   End If
				'                End If
				'            End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
		Private Sub ListView.HandleIsDestroyed(ByRef Sender As Control)
		End Sub
		
		Private Sub ListView.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QListView(Sender.Child)
					If .Images Then
						.Images->ParentWindow = @Sender
						If .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
					End If
					If .StateImages Then .StateImages->ParentWindow = @Sender
					If .SmallImages Then .SmallImages->ParentWindow = @Sender
					If .GroupHeaderImages Then .GroupHeaderImages->ParentWindow = @Sender
					If .Images AndAlso .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
					If .StateImages AndAlso .StateImages->Handle Then ListView_SetImageList(.FHandle, CInt(.StateImages->Handle), LVSIL_STATE)
					If .SmallImages AndAlso .SmallImages->Handle Then ListView_SetImageList(.FHandle, CInt(.SmallImages->Handle), LVSIL_SMALL)
					If .GroupHeaderImages AndAlso .GroupHeaderImages->Handle Then ListView_SetImageList(.FHandle, CInt(.GroupHeaderImages->Handle), LVSIL_GROUPHEADER)
					Dim lvStyle As Integer
					lvStyle = SendMessage(.FHandle, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
					lvStyle = lvStyle Or .FLVExStyle
					SendMessage(.FHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, ByVal lvStyle)
					If .HoverTime Then .HoverTime = .FHoverTime
					.View = .FView
					Var TempHandle = .FHandle
					For i As Integer = 0 To .Columns.Count -1
						Dim lvc As LVCOLUMN
						lvc.mask            = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
						lvc.fmt             = .Columns.Column(i)->Format
						lvc.cx              = 0
						lvc.pszText         = @.Columns.Column(i)->Text
						lvc.cchTextMax      = Len(.Columns.Column(i)->Text)
						lvc.iImage          = .Columns.Column(i)->ImageIndex
						lvc.iSubItem        = i
						.FHandle            = 0
						lvc.cx              = .ScaleX(.Columns.Column(i)->Width)
						.FHandle            = TempHandle
						ListView_InsertColumn(.FHandle, i, @lvc)
					Next i
					For i As Integer = 0 To .ListItems.Count - 1
						For j As Integer = 0 To .Columns.Count - 1
							.FHandle = 0
							Dim lvi As LVITEM
							lvi.pszText         = @.ListItems.Item(i)->Text(j)
							lvi.cchTextMax      = Len(.ListItems.Item(i)->Text(j))
							lvi.iItem           = i
							lvi.iSubItem        = j
							If j = 0 Then
								lvi.mask = LVIF_TEXT Or LVIF_IMAGE Or LVIF_STATE Or LVIF_INDENT Or LVIF_PARAM
								lvi.iImage          = .ListItems.Item(i)->ImageIndex
								lvi.state   = INDEXTOSTATEIMAGEMASK(.ListItems.Item(i)->State)
								lvi.stateMask = LVIS_STATEIMAGEMASK
								lvi.iIndent   = .ListItems.Item(i)->Indent
								lvi.lParam   =  Cast(LPARAM, .ListItems.Item(i))
								.FHandle = TempHandle
								ListView_InsertItem(.FHandle, @lvi)
								.FHandle = 0
								If .ListItems.Item(i)->Checked Then
									.FHandle = TempHandle
									Dim lvi As LVITEM
									lvi.mask = LVIF_STATE
									lvi.iItem = i
									lvi.stateMask = LVIS_CHECKEDMASK
									lvi.state = LVIS_CHECKED
									ListView_SetItem(.FHandle, @lvi)
								End If
								.FHandle = TempHandle
							Else
								.FHandle = TempHandle
								lvi.mask = LVIF_TEXT
								ListView_SetItem(.FHandle, @lvi)
							End If
						Next j
					Next i
					.SelectedItemIndex = 0
				End With
			End If
		End Sub
	
	Private Operator ListView.Cast As Control Ptr
		Return @This
	End Operator
	
	
	Private Constructor ListView
		BorderStyle = BorderStyles.bsClient
		ListItems.Parent = @This
		Columns.Parent = @This
		FView = vsDetails
		DoubleBuffered = True
		FEnabled = True
		FGridLines = True
		FFullRowSelect = True
		FVisible = True
		FTabIndex          = -1
		FTabStop = True
		With This
			.Child             = @This
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.RegisterClass "ListView", WC_LISTVIEW
				.ChildProc         = @WndProc
				.ExStyle           = WS_EX_CLIENTEDGE
				.FLVExStyle        = LVS_EX_FULLROWSELECT Or LVS_EX_GridLINES Or LVS_EX_DOUBLEBUFFER
				.Style             = WS_CHILD Or WS_TABSTOP Or WS_VISIBLE Or LVS_REPORT Or LVS_ICON Or LVS_SINGLESEL Or LVS_SHOWSELALWAYS
				WLet(FClassAncestor, WC_LISTVIEW)
			WLet(FClassName, "ListView")
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor ListView
			ListItems.Clear
			UnregisterClass "ListView",GetModuleHandle(NULL)
	End Destructor
End Namespace

