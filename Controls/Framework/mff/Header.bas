'###############################################################################
'#  Header.bi                                                                  #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   THeader.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Modified by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                      #
'###############################################################################

#include once "Header.bi"

Namespace My.Sys.Forms
	'HeaderSection
	
	Private Property HeaderSection.Style As HeaderSectionStyle
		Return FStyle
	End Property
	
	Private Property HeaderSection.Style(Value As HeaderSectionStyle)
		If Value <> FStyle Then
			FStyle = Value
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Property HeaderSection.Caption ByRef As WString
		Return WGet(FCaption)
	End Property
	
	Private Property HeaderSection.Caption(ByRef Value As WString)
		WLet(FCaption, Value)
		QHeader(HeaderControl).UpdateItems
	End Property
	
	Private Property HeaderSection.Alignment As Integer
		Return FAlignment
	End Property
	
	Private Property HeaderSection.Alignment(Value As Integer)
		If Value <> FAlignment Then
			FAlignment = Value
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Property HeaderSection.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property HeaderSection.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Property HeaderSection.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property HeaderSection.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
			If HeaderControl AndAlso HeaderControl->Images Then FImageIndex = HeaderControl->Images->IndexOf(*FImageKey)
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Property HeaderSection.Resizable As Boolean
		Return FResizable
	End Property
	
	Private Property HeaderSection.Resizable(Value As Boolean)
		If Value <> FResizable Then
			FResizable = Value
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Property HeaderSection.Width As Integer
		Return FWidth
	End Property
	
	Private Property HeaderSection.Width(Value As Integer)
		If Value <> FWidth Then
			FWidth = Value
			QHeader(HeaderControl).UpdateItems
		End If
	End Property
	
	Private Operator HeaderSection.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor HeaderSection
			AFmt(0)         = HDF_LEFT
			AFmt(1)         = HDF_CENTER
			AFmt(2)         = HDF_RIGHT
			AFmt(3)         = HDF_RTLREADING
		WLet(FCaption, "")
		FImageIndex     = -1
		FAlignment      = 0
		FWidth          = 50
	End Constructor
	
	Private Destructor HeaderSection
	End Destructor
	
	'Header
		Private Function Header.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "dragreorder": Return @FDragReorder
			Case "fulldrag": Return @FFullDrag
			Case "hottrack": Return @FHotTrack
			Case "sectioncount": FSectionCount = SectionCount: Return @FSectionCount
			Case "style": Return @FStyle
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Header.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "dragreorder": If Value <> 0 Then This.DragReorder = QBoolean(Value)
			Case "fulldrag": If Value <> 0 Then This.FullDrag = QBoolean(Value)
			Case "hottrack": If Value <> 0 Then This.HotTrack = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(HeaderStyle Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property Header.Style As HeaderStyle
		Return FStyle
	End Property
	
	Private Property Header.Style(Value As HeaderStyle)
		If FStyle <> Value Then
			FStyle = Value
				ChangeStyle HDS_BUTTONS, Not Value
				'Base.Style = WS_CHILD Or AStyle(Abs_(FStyle)) Or AFullDrag(Abs_(FFullDrag)) Or AHotTrack(Abs_(FHotTrack)) Or ADragReorder(Abs_(FDragReorder))
		End If
	End Property
	
	Private Property Header.HotTrack As Boolean
		Return FHotTrack
	End Property
	
	Private Property Header.HotTrack(Value As Boolean)
		If FHotTrack <> Value Then
			FHotTrack = Value
				ChangeStyle HDS_HOTTRACK, Value
				'Base.Style = WS_CHILD Or AStyle(Abs_(FStyle)) Or AFullDrag(Abs_(FFullDrag)) Or AHotTrack(Abs_(FHotTrack)) Or ADragReorder(Abs_(FDragReorder))
		End If
	End Property
	
	Private Property Header.FullDrag As Boolean
		Return FFullDrag
	End Property
	
	Private Property Header.FullDrag(Value As Boolean)
		If FFullDrag <> Value Then
			FFullDrag = Value
				ChangeStyle HDS_FULLDRAG, Value
				'Base.Style = WS_CHILD Or AStyle(Abs_(FStyle)) Or AFullDrag(Abs_(FFullDrag)) Or AHotTrack(Abs_(FHotTrack)) Or ADragReorder(Abs_(FDragReorder))
		End If
	End Property
	
	Private Property Header.DragReorder As Boolean
		Return FDragReorder
	End Property
	
	Private Property Header.DragReorder(Value As Boolean)
		If FDragReorder <> Value Then
			DragReorder = Value
				ChangeStyle HDS_DRAGDROP, Value
				'Base.Style = WS_CHILD Or AStyle(Abs_(FStyle)) Or AFullDrag(Abs_(FFullDrag)) Or AHotTrack(Abs_(FHotTrack)) Or ADragReorder(Abs_(FDragReorder))
		End If
	End Property
	
	Private Property Header.Resizable As Boolean
		Return FResizable
	End Property
	
	Private Property Header.Resizable(Value As Boolean)
		If FResizable <> Value Then
			FResizable = Value
				'Const HDS_NOSIZING = &h800
		End If
	End Property
	
	Private Property Header.SectionCount As Integer
		FSectionCount = FSections.Count
		Return FSectionCount
	End Property
	
	Private Property Header.SectionCount(Value As Integer)
		FSectionCount = FSections.Count
	End Property
	
	Private Property Header.Section(Index As Integer) As HeaderSection Ptr
		If Index >= 0 And Index <= SectionCount -1 Then
			Return QHeaderSection(FSections.Items[Index])
		End If
		Return NULL
	End Property
	
	Private Property Header.Section(Index As Integer, Value As HeaderSection Ptr)
		If Index >= 0 And Index <= SectionCount -1 Then
			FSections.Items[Index] = Value
		End If
	End Property
	
	Private Property Header.Captions(Index As Integer) ByRef As WString
		If Index >= 0 And Index <= SectionCount -1 Then
			Return QHeaderSection(FSections.Items[Index]).Caption
		Else
			Return WStr("")
		End If
	End Property
	
	Private Property Header.Captions(Index As Integer, ByRef Value As WString)
		If Index >= 0 And Index <= SectionCount -1 Then
			QHeaderSection(FSections.Items[Index]).Caption = Value
		End If
	End Property
	
	Private Property Header.Widths(Index As Integer) As Integer
		If Index >= 0 And Index <= SectionCount -1 Then
			Return QHeaderSection(FSections.Items[Index]).Width
		Else
			Return 0
		End If
	End Property
	
	Private Property Header.Widths(Index As Integer, Value As Integer)
		If Index >= 0 And Index <= SectionCount -1 Then
			QHeaderSection(FSections.Items[Index]).Width = Value
		End If
	End Property
	
	Private Property Header.Alignments(Index As Integer) As Integer
		If Index >= 0 And Index <= SectionCount -1 Then
			Return QHeaderSection(FSections.Items[Index]).Alignment
		Else
			Return 0
		End If
	End Property
	
	Private Property Header.Alignments(Index As Integer, Value As Integer)
		If Index >= 0 And Index <= SectionCount -1 Then
			QHeaderSection(FSections.Items[Index]).Alignment = Value
		End If
	End Property
	
	Private Property Header.ImageIndexes(Index As Integer) As Integer
		If Index >= 0 And Index <= SectionCount -1 Then
			Return QHeaderSection(FSections.Items[Index]).ImageIndex
		Else
			Return -1
		End If
	End Property
	
	Private Property Header.ImageIndexes(Index As Integer, Value As Integer)
		If Index >= 0 And Index <= SectionCount -1 Then
			QHeaderSection(FSections.Items[Index]).ImageIndex = Value
		End If
	End Property
	
	Private Sub Header.UpdateItems
			Dim As HDITEM HI
			For i As Integer = SectionCount -1 To 0 Step -1
				Perform(HDM_DELETEITEM, i, 0)
			Next i
			For i As Integer = 0 To SectionCount - 1
				HI.mask       = HDI_FORMAT Or HDI_WIDTH Or HDI_LPARAM Or HDI_TEXT
				HI.pszText    = @QHeaderSection(FSections.Items[I]).Caption
				HI.cchTextMax = Len(QHeaderSection(FSections.Items[I]).Caption)
				HI.cxy        = QHeaderSection(FSections.Items[I]).Width
				HI.fmt        = AFmt(QHeaderSection(FSections.Items[I]).Alignment)
				HI.iImage     = QHeaderSection(FSections.Items[I]).ImageIndex
				If HI.iImage <> -1 Then
					HI.mask = HI.mask Or HDI_IMAGE
					HI.fmt = HI.fmt Or HDF_IMAGE
				End If
				If QHeaderSection(FSections.Items[I]).Style > 0 Then
					HI.fmt = HI.fmt Or HDF_OWNERDRAW
				Else
					HI.fmt = HI.fmt Or HDF_STRING
				End If
				If FResizable AndAlso Not QHeaderSection(FSections.Items[I]).Resizable Then
				End If
				HI.hbm        = NULL
				HI.lParam     = Cast(LParam, FSections.Items[I])
				Perform(HDM_INSERTITEM, i, CInt(@HI))
			Next i
	End Sub
	
		Private Sub Header.HandleIsAllocated(ByRef Sender As Control)
			Dim As HDITEM HI
			If Sender.Child Then
				With QHeader(Sender.Child)
					If .Images Then 
						.Images->ParentWindow = @Sender
						SendMessage(.Handle, HDM_SETIMAGELIST, 0, Cast(LPARAM, .Images->Handle))
					End If
					For i As Integer = 0 To .SectionCount - 1
						HI.mask       = HDI_FORMAT Or HDI_WIDTH Or HDI_LPARAM Or HDI_TEXT
						HI.pszText    = @QHeaderSection(.FSections.Items[I]).Caption
						HI.cchTextMax = Len(QHeaderSection(.FSections.Items[I]).Caption)
						HI.cxy        = QHeaderSection(.FSections.Items[I]).Width
						HI.fmt        = .AFmt(QHeaderSection(.FSections.Items[I]).Alignment)
						HI.iImage     = QHeaderSection(.FSections.Items[I]).ImageIndex
						If HI.iImage <> -1 Then
							HI.mask = HI.mask Or HDI_IMAGE
							HI.fmt = HI.fmt Or HDF_IMAGE
						End If
						If QHeaderSection(.FSections.Items[I]).Style > 0 Then
							HI.fmt = HI.fmt Or HDF_OWNERDRAW
						Else
							HI.fmt = HI.fmt Or HDF_STRING
						End If
						HI.hbm        = NULL
						HI.lParam     = Cast(LParam, .FSections.Items[I])
						.Perform(HDM_INSERTITEM, i, CInt(@HI))
					Next i
				End With
			End If
		End Sub
		
		Private Sub Header.WndProc(ByRef Message As Message)
			If Message.Sender Then
			End If
		End Sub
	
	Private Function Header.EnumMenuItems(Item As MenuItem, ByRef List As List) As Boolean
		For i As Integer = 0 To Item.Count -1
			List.Add Item.Item(i)
			EnumMenuItems *Item.Item(i), List
		Next i
		Return True
	End Function
	
	Private Sub Header.Init()
	End Sub
	
	Private Sub Header.ProcessMessage(ByRef Message As Message)
			Static As Boolean IsMenuItem
			Select Case Message.Msg
			Case WM_RBUTTONDOWN
				'PopupMenu.Window = FHandle
				'PopupMenu.Popup(Message.lParamLo, Message.lParamHi)
			Case CM_NOTIFY
				Dim As HD_NOTIFY Ptr HDN
				Dim As Integer ItemIndex, MouseButton
				HDN = Cast(HD_NOTIFY Ptr, Message.lParam)
				ItemIndex   = HDN->iItem
				MouseButton = HDN->iButton
				Select Case HDN->hdr.code
				Case HDN_BEGINTRACK
					If OnBeginTrack Then OnBeginTrack(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]))
				Case HDN_ENDTRACK
					If OnEndTrack Then OnEndTrack(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]))
				Case HDN_DIVIDERDBLCLICK
					If OnDividerDblClick Then OnDividerDblClick(*Designer, This, ItemIndex, MouseButton)
				Case HDN_ITEMCHANGED
					Dim As HD_ITEM Ptr HI
					HI = Cast(HD_ITEM Ptr,HDN->pitem)
					QHeaderSection(FSections.Items[ItemIndex]).Width = HI->cxy
					If OnChange Then OnChange(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]))
				Case HDN_ITEMCHANGING
					Dim As HD_ITEM Ptr HI
					HI = Cast(HD_ITEM Ptr,HDN->pitem)
					Dim bCancel As Boolean
					If OnChanging Then OnChanging(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]), bCancel)
					If bCancel Then Message.Result = -1: Exit Sub Else QHeaderSection(FSections.Items[ItemIndex]).Width = HI->cxy
				Case HDN_ITEMCLICK
					If OnSectionClick Then OnSectionClick(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]), ItemIndex, MouseButton)
				Case HDN_ITEMDBLCLICK
					If OnSectionDblClick Then OnSectionDblClick(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]), ItemIndex, MouseButton)
				Case HDN_TRACK
					If OnTrack Then OnTrack(*Designer, This, QHeaderSection(FSections.Items[ItemIndex]))
				End Select
			Case CM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr Dis
				Dis = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				Dim As My.Sys.Drawing.Rect R = *Cast(My.Sys.Drawing.Rect Ptr, @Dis->rcItem)
				Dim As Integer Index = Dis->itemID, State = Dis->itemState
				If OnDrawSection Then OnDrawSection(*Designer, This, QHeaderSection(FSections.Items[Index]), R, State And ODS_SELECTED <> 0)
			Case WM_MENUSELECT
				IsMenuItem = True
			Case WM_COMMAND
				Static As List List
				Dim As MenuItem Ptr Item
				If IsMenuItem Then
					List.Clear
					For i As Integer = 0 To ContextMenu->Count -1
						EnumMenuItems(*ContextMenu->Item(i), List)
					Next i
					For i As Integer = 0 To List.Count - 1
						If QMenuItem(List.Items[i]).Command = Message.wParamLo Then
							If QMenuItem(List.Items[i]).OnClick Then QMenuItem(List.Items[i]).OnClick(*QMenuItem(List.Items[i]).Designer, QMenuItem(List.Items[i]))
							Exit For
						End If
					Next i
					IsMenuItem = False
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	Private Function Header.AddSection(ByRef FCaption As WString = "", FImageIndex As Integer = -1, FWidth As Integer = -1, FAlignment As Integer = 0, bResizable As Boolean = True) As HeaderSection Ptr
		Dim As HeaderSection Ptr PSection
		PSection = _New( HeaderSection)
		FSections.Add PSection
		With *PSection
			.HeaderControl = @This
			.Caption       = FCaption
			.ImageIndex    = FImageIndex
			.Alignment     = FAlignment
			.Width         = FWidth
		End With
		
			Dim As HDITEM HI
			With HI
				.mask       = HDI_FORMAT Or HDI_WIDTH Or HDI_LPARAM Or HDI_TEXT
				.pszText    = @FCaption
				.cchTextMax = Len(FCaption)
				.cxy        = PSection->Width
				.fmt        = AFmt(Abs_(PSection->Alignment))
				.iImage     = FImageIndex
				If .iImage <> -1 Then
					.mask = .mask Or HDI_IMAGE
					.fmt  = .fmt Or HDF_IMAGE
				End If
				If PSection->Style > 0 Then
					.fmt = .fmt Or HDF_OWNERDRAW
				Else
					.fmt = .fmt Or HDF_STRING
				End If
				If FResizable AndAlso Not bResizable Then
				End If
				.hbm        = NULL
				.lParam     = Cast(LParam, PSection)
			End With
			If Handle Then Perform(HDM_INSERTITEM, SectionCount - 1, CInt(@HI))
		Return PSection
	End Function
	
	Private Function Header.AddSection(ByRef FCaption As WString = "", ByRef FImageKey As WString, FWidth As Integer = -1, FAlignment As Integer = 0, bResizable As Boolean = True) As HeaderSection Ptr
		Dim As HeaderSection Ptr PSection
		If Images Then
			PSection = This.AddSection(FCaption, Images->IndexOf(FImageKey), FWidth, FAlignment, bResizable)
		Else
			PSection = This.AddSection(FCaption, -1, FWidth, FAlignment, bResizable)
		End If
		If PSection Then PSection->ImageKey         = FImageKey
		Return PSection
	End Function
	
	Private Sub Header.AddSections cdecl(FCount As Integer, ...)
		Dim As HeaderSection Ptr PSection
		'Dim As Any Ptr Arg
		Dim args As Cva_List
		'Arg = va_first()
		Cva_Start(args, FCount)
		For i As Integer = 0 To FCount - 1
			PSection = _New( HeaderSection)
			With *PSection
				.HeaderControl = @This
				'.Caption       = *va_arg(Arg, WString Ptr)
				.Caption       = *Cva_Arg(args, WString Ptr)
			End With
			FSections.Add PSection
				Dim As HDITEM HI
				With HI
					.mask       = HDI_FORMAT Or HDI_LPARAM Or HDI_TEXT Or HDI_WIDTH
					.pszText    = @PSection->Caption
					.cchTextMax = Len(PSection->Caption)
					.cxy        = PSection->Width
					.fmt        = AFmt(Abs_(PSection->Alignment))
					.iImage     = PSection->ImageIndex
					If .iImage <> -1 Then
						.mask = .mask Or HDI_IMAGE
						.fmt  = .fmt Or HDF_IMAGE
					End If
					If PSection->Style Then
						.fmt = .fmt Or HDF_OWNERDRAW
					Else
						.fmt = .fmt Or HDF_STRING
					End If
					.hbm        = NULL
					.lParam     = Cast(LParam,PSection)
				End With
				If Handle Then Perform(HDM_INSERTITEM, SectionCount - 1, CInt(@HI))
			'Arg = va_next(Arg, WString Ptr)
		Next i
		Cva_End(args)
	End Sub
	
	Private Sub Header.RemoveSection(Index As Integer)
		If Index >= 0 And Index <= SectionCount - 1 Then
				If FHandle Then Perform(HDM_DELETEITEM, Index, 0)
			FSections.Remove Index
		End If
	End Sub
	
	Private Operator Header.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor Header
'			AStyle(0)       = HDS_BUTTONS
'			AStyle(1)       = 0
'			AFullDrag(0)    = 0
'			AFullDrag(1)    = HDS_FULLDRAG
'			AHotTrack(0)    = 0
'			AHotTrack(1)    = HDS_HOTTRACK
'			ADragReorder(0) = 0
'			ADragReorder(1) = HDS_DRAGDROP
			AFmt(0)         = HDF_LEFT
			AFmt(1)         = HDF_CENTER
			AFmt(2)         = HDF_RIGHT
			AFmt(3)         = HDF_RTLREADING
		FFullDrag       = True
		FDragReorder    = True
		FHotTrack       = True
		FResizable      = True
		With This
			.Child             = @This
				.RegisterClass "Header", WC_HEADER
				.ChildProc         = @WndProc
				.ExStyle           = 0
				'Base.Style             = WS_CHILD Or AStyle(Abs_(FStyle)) Or AFullDrag(Abs_(FFullDrag)) Or AHotTrack(Abs_(FHotTrack)) Or ADragReorder(Abs_(FDragReorder))
				Base.Style             = WS_CHILD Or HDS_BUTTONS Or HDS_FULLDRAG Or HDS_DRAGDROP ' Or HDS_HOTTRACK
				.DoubleBuffered = True
				.BackColor             = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
				WLet(FClassAncestor, WC_HEADER)
			WLet(FClassName, "Header")
			.Width             = 150
			.Height            = 24
			.Align             = DockStyle.alTop
		End With
	End Constructor
	
	Private Destructor Header
		FSections.Clear
	End Destructor
End Namespace

