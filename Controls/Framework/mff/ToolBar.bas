'###############################################################################
'#  ToolBar.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TToolBar.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "ToolBar.bi"

Namespace My.Sys.Forms
		Private Function ToolButton.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "buttonindex": FButtonIndex = ButtonIndex: Return @FButtonIndex
			Case "caption": Return FCaption
			Case "checked": Return @FChecked
			Case "commandid": Return @FCommandID
			Case "dropdownmenu": Return @DropDownMenu
			Case "enabled": Return @FEnabled
			Case "hint": Return FHint
			Case "imageindex": Return @FImageIndex
			Case "imagekey": Return FImageKey
			Case "left": FButtonLeft = This.Left: Return @FButtonLeft
			Case "top": FButtonTop = This.Top: Return @FButtonTop
			Case "name": Return FName
			Case "showhint": Return @FShowHint
			Case "state": Return @FState
			Case "style": Return @FStyle
			Case "tag": Return This.Tag
			Case "visible": Return @FVisible
			Case "width": FButtonWidth = This.Width: Return @FButtonWidth
			Case "height": FButtonHeight = This.Height: Return @FButtonHeight
			Case "parent": Return Ctrl
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ToolButton.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case "parent": This.Parent = Value
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "buttonindex": This.ButtonIndex = QInteger(Value)
				Case "caption": This.Caption = QWString(Value)
				Case "checked": This.Checked = QBoolean(Value)
				Case "commandid": This.CommandID = QInteger(Value)
				Case "enabled": This.Enabled = QBoolean(Value)
				Case "hint": This.Hint = QWString(Value)
				Case "imageindex": This.ImageIndex = QInteger(Value)
				Case "imagekey": This.ImageKey = QWString(Value)
				Case "left": This.Left = QInteger(Value)
				Case "top": This.Top = QInteger(Value)
				Case "name": This.Name = QWString(Value)
				Case "showhint": This.ShowHint = QBoolean(Value)
				Case "state": This.State = *Cast(ToolButtonState Ptr, Value)
				Case "style": This.Style = *Cast(ToolButtonStyle Ptr, Value)
				Case "tag": This.Tag = Value
				Case "parent": This.Parent = Value
				Case "visible": This.Visible = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
		Private Function ToolBar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutosize
			Case "caption": Return FText.vptr
			Case "flat": Return @FFlat
			Case "list": Return @FList
			Case "wrapable": Return @FWrapable
			Case "transparency": Return @FTransparent
			Case "disabledimageslist": Return DisabledImagesList
			Case "hotimageslist": Return HotImagesList
			Case "imageslist": Return ImagesList
			Case "divider": Return @FDivider
			Case "bitmapwidth": FBitmapWidth = This.BitmapWidth: Return @FBitmapWidth
			Case "bitmapheight": FBitmapHeight = This.BitmapHeight: Return @FBitmapHeight
			Case "buttonwidth": FButtonWidth = This.ButtonWidth: Return @FButtonWidth
			Case "buttonheight": FButtonHeight = This.ButtonHeight: Return @FButtonHeight
			Case "buttonscount": FButtonsCount = Buttons.Count: Return @FButtonsCount
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ToolBar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value)
				Case "bitmapwidth": This.BitmapWidth = QInteger(Value)
				Case "bitmapheight": This.BitmapHeight = QInteger(Value)
				Case "buttonwidth": This.ButtonWidth = QInteger(Value)
				Case "buttonheight": This.ButtonHeight = QInteger(Value)
				Case "caption": This.Caption = QWString(Value)
				Case "flat": This.Flat = QBoolean(Value)
				Case "list": This.List = QBoolean(Value)
				Case "disabledimageslist": This.DisabledImagesList = Value
				Case "hotimageslist": This.HotImagesList = Value
				Case "imageslist": This.ImagesList = Value
				Case "divider": This.Divider = QBoolean(Value)
				Case "transparency": This.Transparency = QBoolean(Value)
				Case "wrapable": This.Wrapable = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Sub ToolBar.GetDropDownMenuItems
		FPopupMenuItems.Clear
		For j As Integer = 0 To Buttons.Count - 1
			For i As Integer = 0 To Buttons.Item(j)->DropDownMenu.Count -1
				EnumPopupMenuItems *Buttons.Item(j)->DropDownMenu.Item(i)
			Next i
		Next j
	End Sub
	
	Private Property ToolButton.ButtonIndex As Integer
		If Ctrl Then
			Return Cast(ToolBar Ptr, Ctrl)->Buttons.IndexOf(@This)
		Else
			Return -1
		End If
	End Property
	
	Private Sub ToolButtons.ChangeIndex(Btn As ToolButton Ptr, Index As Integer)
		FButtons.ChangeIndex Btn, Index
	End Sub
	
	Private Property ToolButton.ButtonIndex(Value As Integer)
		If Ctrl Then
			Cast(ToolBar Ptr, Ctrl)->Buttons.ChangeIndex @This, Value
		End If
	End Property
		
	Private Function ToolButton.ToString ByRef As WString
		Return This.Name
	End Function
	
	Private Property ToolButton.Caption ByRef As WString
		Return *FCaption
	End Property
	
	Private Property ToolButton.Caption(ByRef Value As WString)
		Dim As Integer i
		If  FCaption = 0 OrElse Value <> *FCaption Then
			WLet(FCaption, Value)
				Dim As TBBUTTON TB
				If Ctrl Then
					With QControl(Ctrl)
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_GETBUTTON, i, CInt(@TB))
						If *FCaption <> "" Then
							TB.iString = CInt(FCaption)
						Else
							TB.iString = 0
						End If
						SendMessage(.Handle, TB_INSERTBUTTON, i, CInt(@TB))
						SendMessage(.Handle, TB_DELETEBUTTON, i + 1, 0)
					End With
				End If
		End If
	End Property
	
	Private Property ToolButton.Child As Control Ptr
		Return FChild
	End Property
	
	Private Property ToolButton.Child(Value As Control Ptr)
		FChild = Value
			If Ctrl Then
				If Value->Parent <> Ctrl Then Value->Parent = Ctrl
				If Ctrl->Handle AndAlso Value->Handle Then
					Dim As Rect R
					Var i = SendMessage(Ctrl->Handle, TB_COMMANDTOINDEX, FCommandID, 0)
					SendMessage(Ctrl->Handle, TB_GETITEMRECT, i, CInt(@R))
					MoveWindow Value->Handle, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, True
					'Value->SetBounds UnScaleX(R.Left), UnScaleY(R.Top), UnScaleX(R.Right - R.Left), UnScaleY(R.Bottom - R.Top)
				End If 
			End If
	End Property
	
	Private Property ToolButton.Name ByRef As WString
		Return WGet(FName)
	End Property
	
	Private Property ToolButton.Name(ByRef Value As WString)
		WLet(FName, Value)
		DropDownMenu.Name = *FName & ".DropDownMenu"
	End Property

	Private Property ToolButton.Parent As Control Ptr
		Return Ctrl
	End Property
	
	Private Property ToolButton.Parent(Value As Control Ptr)
		If Ctrl <> 0 AndAlso Ctrl <> Value Then
			Dim As Integer Index = Cast(ToolBar Ptr, Ctrl)->Buttons.IndexOf(@This)
			If Index > -1 Then Cast(ToolBar Ptr, Ctrl)->Buttons.Remove Index
		End If
		Ctrl = Value
		Cast(ToolBar Ptr, Ctrl)->Buttons.Add @This
	End Property

	Private Property ToolButton.Hint ByRef As WString
		Return *FHint
	End Property
	
	Private Property ToolButton.Hint(ByRef Value As WString)
		FHint = _Reallocate(FHint, (Len(Value) + 1) * SizeOf(WString))
		*FHint = Value
	End Property
	
	Private Property ToolButton.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property ToolButton.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Property ToolButton.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ToolButton.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Ctrl Then
				With QControl(Ctrl)
						SendMessage(.Handle, TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ToolButton.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ToolButton.ImageKey(ByRef Value As WString)
		WLet(FImageKey, Value)
			If Ctrl AndAlso QToolBar(Ctrl).ImagesList Then
				ImageIndex = Cast(ToolBar Ptr, Ctrl)->ImagesList->IndexOf(Value)
			End If
	End Property
	
	Private Property ToolButton.Style As ToolButtonStyle
		Return FStyle
	End Property
	
	Private Property ToolButton.Style(Value As ToolButtonStyle)
		If Value <> FStyle Then
			FStyle = Value
				If Ctrl AndAlso Ctrl->Handle Then
					Dim As TBBUTTONINFO info
					info.cbSize = SizeOf(info)
					info.dwMask = TBIF_STYLE
					info.idCommand = FCommandID
					info.fsStyle = Value
					SendMessage(Ctrl->Handle, TB_SETBUTTONINFO, FCommandID, Cast(LPARAM, @info))
				End If
			'If Ctrl AndAlso Ctrl->Handle Then QControl(Ctrl).RecreateWnd
		End If
	End Property
	
	Private Property ToolButton.State As ToolButtonState
			If Ctrl AndAlso Ctrl->Handle Then
				Dim As TBBUTTONINFO info
				info.cbSize = SizeOf(info)
				info.dwMask = TBIF_STATE
				info.idCommand = FCommandID
				SendMessage(Ctrl->Handle, TB_GETBUTTONINFO, FCommandID, Cast(LPARAM, @info))
				FState = info.fsState
			End If
		Return FState
	End Property
	
	Private Property ToolButton.State(Value As ToolButtonState)
		If Value <> FState Then
			FState = Value
				If Ctrl AndAlso Ctrl->Handle Then
					Dim As TBBUTTONINFO info
					info.cbSize = SizeOf(info)
					info.dwMask = TBIF_STATE
					info.idCommand = FCommandID
					info.fsState = Value
					SendMessage(Ctrl->Handle, TB_SETBUTTONINFO, FCommandID, Cast(LPARAM, @info))
				End If
			'If Ctrl Then QControl(Ctrl).RecreateWnd
		End If
	End Property
	
	Private Property ToolButton.CommandID As Integer
		Return FCommandID
	End Property
	
	Private Property ToolButton.CommandID(Value As Integer)
		Dim As Integer i
		If Value <> FCommandID Then
			FCommandID = Value
			If Ctrl Then
				With QControl(Ctrl)
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_SETCMDID, i, FCommandID)
				End With
			End If
		End If
	End Property
	
	Private Property ToolButton.Left As Integer
			Dim As ..Rect R
			Dim As Integer i
			If Ctrl Then
				With QControl(Ctrl)
					If .Handle Then
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_GETITEMRECT, i, CInt(@R))
						FButtonLeft = R.Left
					End If
				End With
			End If
		Return FButtonLeft
	End Property
	
	Private Property ToolButton.Left(Value As Integer)
	End Property
	
	Private Property ToolButton.Top As Integer
		Dim As Integer i
		If Ctrl Then
			With QControl(Ctrl)
					Dim As ..Rect R
					If .Handle Then
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_GETITEMRECT, i, CInt(@R))
						FButtonTop = R.Top
					End If
			End With
		End If
		Return FButtonTop
	End Property
	
	Private Property ToolButton.Top(Value As Integer)
	End Property
	
	Private Property ToolButton.Width As Integer
			Dim As Integer i
			If Ctrl Then
				With QControl(Ctrl)
					Dim As ..Rect R
					If .Handle Then
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_GETITEMRECT, i, CInt(@R))
						FButtonWidth = UnScaleX(R.Right - R.Left)
					End If
				End With
			End If
		Return FButtonWidth
	End Property
	
	Private Property ToolButton.Width(Value As Integer)
		FButtonWidth = Value
			If Ctrl AndAlso Ctrl->Handle Then
				Var i = SendMessage(Ctrl->Handle, TB_COMMANDTOINDEX, FCommandID, 0)
				Dim As TBBUTTONINFO tbbi
				tbbi.cbSize = SizeOf(tbbi)
				tbbi.dwMask = TBIF_SIZE Or TBIF_BYINDEX
				tbbi.cx = ScaleX(Value)
				SendMessage(Ctrl->Handle, TB_SETBUTTONINFO, i, Cast(LPARAM, @tbbi))
				If FChild Then 
					FChild->Width = Value
					Dim As Rect R
					SendMessage(Ctrl->Handle, TB_GETITEMRECT, i, CInt(@R))
					MoveWindow FChild->Handle, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, True
				End If
			End If
	End Property
	
	Private Sub ToolButton.Update()
			If Ctrl AndAlso Ctrl->Handle Then
				Var i = SendMessage(Ctrl->Handle, TB_COMMANDTOINDEX, FCommandID, 0)
				If *FCaption <> "" Then
					Dim As TBBUTTON TB
					SendMessage(Ctrl->Handle, TB_GETBUTTON, i, CInt(@TB))
					TB.iString = CInt(FCaption)
					SendMessage(Ctrl->Handle, TB_INSERTBUTTON, i, CInt(@TB))
					SendMessage(Ctrl->Handle, TB_DELETEBUTTON, i + 1, 0)
				End If
				Dim As TBBUTTONINFO tbbi
				tbbi.cbSize = SizeOf(tbbi)
				tbbi.dwMask = TBIF_SIZE Or TBIF_BYINDEX
				tbbi.cx = ScaleX(FButtonWidth)
				SendMessage(Ctrl->Handle, TB_SETBUTTONINFO, i, Cast(LPARAM, @tbbi))
				If FChild Then
					FChild->Width = FButtonWidth
					Dim As Rect R
					SendMessage(Ctrl->Handle, TB_GETITEMRECT, i, CInt(@R))
					MoveWindow FChild->Handle, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, True
				End If
			End If
	End Sub
	
	Private Property ToolButton.Height As Integer
			Dim As ..Rect R
			Dim As Integer i
			If Ctrl Then
				With QControl(Ctrl)
					If .Handle Then
						i = SendMessage(.Handle, TB_COMMANDTOINDEX, FCommandID, 0)
						SendMessage(.Handle, TB_GETITEMRECT,i,CInt(@R))
						FButtonHeight = UnScaleY(R.Bottom - R.Top)
					End If
				End With
			End If
		Return FButtonHeight
	End Property
	
	Private Property ToolButton.Height(Value As Integer)
	End Property
	
	Private Property ToolButton.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ToolButton.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Ctrl Then
				With QControl(Ctrl)
'						Dim As TBBUTTONINFO info
'						info.cbSize = SizeOf(info)
'						info.dwMask = TBIF_STATE
'						info.idCommand = FCommandID
'						SendMessage(Ctrl->Handle, TB_GETBUTTONINFO, FCommandID, Cast(LParam, @info))
'						info.cbSize = SizeOf(info)
'						info.dwMask = TBIF_STATE
'						info.idCommand = FCommandID
'						If Not Value Then
'							If ((info.fsState And tstHidden) <> tstHidden) Then info.fsState = info.fsState Or tstHidden
'						ElseIf ((info.fsState And tstHidden) = tstHidden) Then
'							info.fsState = info.fsState And Not tstHidden
'						End If
'						SendMessage(Ctrl->Handle, TB_SETBUTTONINFO, FCommandID, Cast(LParam, @info))
						SendMessage(.Handle, TB_HIDEBUTTON, FCommandID, MAKELONG(Not FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ToolButton.Enabled As Boolean
		Return FEnabled
	End Property
	
	Private Property ToolButton.Enabled(Value As Boolean)
		'If Value <> FEnabled Then
			FEnabled = Value
			If Ctrl Then
				With QControl(Ctrl)
						SendMessage(.Handle, TB_ENABLEBUTTON, FCommandID, MAKELONG(FEnabled, 0))
						SendMessage(.Handle, TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex,0))
				End With
			End If
		'End If
	End Property
	
	Private Property ToolButton.Expand As Boolean
		Return FExpand
	End Property
	
	Private Property ToolButton.Expand(Value As Boolean)
		FExpand = Value
	End Property
	
	Private Property ToolButton.Checked As Boolean
		If Ctrl Then
			With QControl(Ctrl)
					FChecked = SendMessage(.Handle, TB_ISBUTTONCHECKED, FCommandID, 0)
			End With
		End If
		Return FChecked
	End Property
	
	Private Property ToolButton.Checked(Value As Boolean)
		'If Value <> Checked Then
		FChecked = Value
		If Ctrl Then
			With QControl(Ctrl)
					If .Handle Then
						SendMessage(.Handle, TB_CHECKBUTTON, FCommandID, MAKELONG(FChecked, 0))
						If OnClick Then OnClick(*Designer, This)
					End If
			End With
		End If
		If CInt(Value) AndAlso CInt((FState And tstChecked) <> tstChecked) Then
			FState = FState Or tstChecked
		End If
		'End If
	End Property
	
	Private Operator ToolButton.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolButton
		WLet(FName, "")
		WLet(FImageKey, "")
		WLet(FClassName, "ToolButton")
		FStyle      = tbsButton
		FEnabled    = 1
		FVisible    = 1
		FState      = tstEnabled
		WLet(FCaption, "")
		WLet(FHint, "")
		FShowHint   = False
		FImageIndex = -1
	End Constructor
	
	Private Destructor ToolButton
			If DropDownMenu.Handle Then DestroyMenu DropDownMenu.Handle
		WDeAllocate(FHint)
		WDeAllocate(FCaption)
		WDeAllocate(FImageKey)
		WDeAllocate(FName)
	End Destructor
	
	Private Property ToolButtons.Count As Integer
		Return FButtons.Count
	End Property
	
	Private Property ToolButtons.Count(Value As Integer)
	End Property
	
	Private Property ToolButtons.Item(Index As Integer) As ToolButton Ptr
		Return Cast(ToolButton Ptr, FButtons.Items[Index])
	End Property
	
	Private Property ToolButtons.Item(ByRef Key As WString) As ToolButton Ptr
		If IndexOf(Key) <> -1 Then Return Cast(ToolButton Ptr, FButtons.Items[IndexOf(Key)])
		Return 0
	End Property
	
	Private Property ToolButtons.Item(Index As Integer, Value As ToolButton Ptr)
		'QToolButton(FButtons.Items[Index]) = Value
	End Property
	
	
	Private Function ToolButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, FImageIndex As Integer = -1, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
		PButton = _New( ToolButton)
		PButton->FDynamic = True
		FButtons.Add PButton
		With *PButton
			.Style          = FStyle
			.State        = FState
			.ImageIndex     = FImageIndex
			.Hint           = FHint
			.ShowHint       = FShowHint
			.Name         = FKey
			.Caption        = FCaption
			.CommandID      = 10 + FButtons.Count
			.OnClick        = FClick
		End With
		PButton->Ctrl = Parent
			Dim As TBBUTTON TB
			TB.fsState   = FState
			TB.fsStyle   = FStyle
			TB.iBitmap   = PButton->ImageIndex
			TB.idCommand = PButton->CommandID
			If FCaption <> "" Then
				TB.iString = CInt(@FCaption)
			Else
				TB.iString = 0
			End If
			TB.dwData = Cast(DWORD_PTR,@PButton->DropDownMenu)
			If Parent Then
				If Index <> -1 Then
					SendMessage(Parent->Handle, TB_INSERTBUTTON, Index, CInt(@TB))
				Else
					SendMessage(Parent->Handle, TB_ADDBUTTONS, 1, CInt(@TB))
				End If
			End If
		Return PButton
	End Function
	
	Private Function ToolButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, ByRef ImageKey As WString, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
		If Parent AndAlso Cast(ToolBar Ptr, Parent)->ImagesList Then
			With *Cast(ToolBar Ptr, Parent)->ImagesList
				PButton = Add(FStyle, .IndexOf(ImageKey), Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
			End With
		Else
			PButton = Add(FStyle, -1, Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
		End If
		If PButton Then PButton->ImageKey         = ImageKey
		Return PButton
	End Function

	Private Function ToolButtons.Add(PButton As ToolButton Ptr, Index As Integer = -1) As ToolButton Ptr
		FButtons.Add PButton
		With *PButton
			.CommandID      = 10 + FButtons.Count
		End With
		PButton->Ctrl = Parent
			Dim As TBBUTTON TB
			TB.fsState   = PButton->State
			TB.fsStyle   = PButton->Style
			TB.iBitmap   = PButton->ImageIndex
			TB.idCommand = PButton->CommandID
			If PButton->Caption <> "" Then
				TB.iString = CInt(@PButton->Caption)
			Else
				TB.iString = 0
			End If
			TB.dwData = Cast(DWORD_PTR, @PButton->DropDownMenu)
			If Parent Then
				If Index <> -1 Then
					SendMessage(Parent->Handle, TB_INSERTBUTTON, Index, CInt(@TB))
				Else
					SendMessage(Parent->Handle, TB_ADDBUTTONS, 1, CInt(@TB))
				End If
			End If
		Return PButton
	End Function
	
	Private Sub ToolButtons.Remove(Index As Integer)
		FButtons.Remove Index
		If Parent Then
				SendMessage(Parent->Handle, TB_DELETEBUTTON,Index,0)
		End If
	End Sub
	
	Private Function ToolButtons.IndexOf(ByRef FButton As ToolButton Ptr) As Integer
		Return FButtons.IndexOf(FButton)
	End Function
	
	Private Function ToolButtons.IndexOf(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QToolButton(FButtons.Items[i]).Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Sub ToolButtons.Clear
		For i As Integer = Count - 1 To 0 Step -1
			If QToolButton(FButtons.Items[i]).FDynamic Then _Delete( @QToolButton(FButtons.Items[i]))
		Next i
		FButtons.Clear
	End Sub
	
	Private Operator ToolButtons.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolButtons
		This.Clear
	End Constructor
	
	Private Destructor ToolButtons
		This.Clear
	End Destructor
	
	Private Property ToolBar.AutoSize As Boolean
			FAutosize = StyleExists(TBSTYLE_AUTOSIZE)
		Return FAutosize
	End Property
	
	Private Property ToolBar.AutoSize(Value As Boolean)
		FAutosize = Value
			ChangeStyle TBSTYLE_AUTOSIZE, Value
			If FHandle Then If FAutosize Then Perform(TB_AUTOSIZE, 0, 0)
	End Property
	
	Private Property ToolBar.Flat As Boolean
			FFlat = StyleExists(TBSTYLE_FLAT)
		Return FFlat
	End Property
	
	Private Property ToolBar.Flat(Value As Boolean)
		FFlat = Value
			ChangeStyle TBSTYLE_FLAT, Value
	End Property
	
	Private Property ToolBar.List As Boolean
			FList = StyleExists(TBSTYLE_LIST)
		Return FList
	End Property
	
	Private Property ToolBar.List(Value As Boolean)
		FList = Value
			ChangeStyle TBSTYLE_LIST, Value
	End Property
	
	
	Private Property ToolBar.Divider As Boolean
			FDivider = Not StyleExists(CCS_NODIVIDER)
		Return FDivider
	End Property
	
	Private Property ToolBar.Divider(Value As Boolean)
		FDivider = Value
			ChangeStyle CCS_NODIVIDER, Not Value
	End Property
	
	Private Property ToolBar.Transparency As Boolean
			FTransparent = StyleExists(TBSTYLE_TRANSPARENT)
		Return FTransparent
	End Property
	
	Private Property ToolBar.Transparency(Value As Boolean)
		FTransparent = Value
			ChangeStyle TBSTYLE_TRANSPARENT, Value
	End Property
	
	Private Property ToolBar.BitmapWidth As Integer
		Return FBitmapWidth
	End Property
	
	Private Property ToolBar.BitmapWidth(Value As Integer)
		FBitmapWidth = Value
			If Handle Then Perform(TB_SETBITMAPSIZE, 0, MAKELONG(FBitmapWidth, FBitmapHeight))
	End Property
	
	Private Property ToolBar.BitmapHeight As Integer
		Return FBitmapHeight
	End Property
	
	Private Property ToolBar.BitmapHeight(Value As Integer)
		FBitmapHeight = Value
			If Handle Then Perform(TB_SETBITMAPSIZE, 0, MAKELONG(FBitmapWidth, FBitmapHeight))
	End Property
	
	Private Property ToolBar.ButtonWidth As Integer
			If Handle Then
				Var Size = Perform(TB_GETBUTTONSIZE, 0, 0)
				FButtonWidth = UnScaleX(LoWord(Size))
			End If
		Return FButtonWidth
	End Property
	
	Private Property ToolBar.ButtonWidth(Value As Integer)
		FButtonWidth = Value
			If Handle Then Perform(TB_SETBUTTONSIZE,0,MAKELONG(FButtonWidth,FButtonHeight))
	End Property
	
	Private Property ToolBar.ButtonHeight As Integer
			If Handle Then
				Var Size = Perform(TB_GETBUTTONSIZE, 0, 0)
				FButtonHeight = UnScaleY(HiWord(Size))
			End If
		Return FButtonHeight
	End Property
	
	Private Property ToolBar.ButtonHeight(Value As Integer)
		FButtonHeight = Value
			If Handle Then Perform(TB_SETBUTTONSIZE,0,MAKELONG(FButtonWidth,FButtonHeight))
	End Property
	
	Private Property ToolBar.Wrapable As Boolean
			FWrapable = StyleExists(TBSTYLE_WRAPABLE)
		Return FWrapable
	End Property
	
	Private Property ToolBar.Wrapable(Value As Boolean)
		FWrapable = Value
			ChangeStyle TBSTYLE_WRAPABLE, Value
	End Property
	
	Private Property ToolBar.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property ToolBar.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Sub ToolBar.WndProc(ByRef Message As Message)
	End Sub
	
		Private Sub ToolBar.SetDark(Value As Boolean)
			Base.SetDark Value
			If Value Then
				SetWindowTheme(FHandle, "DarkMode_InfoPaneToolbar", nullptr) ' "DarkMode", "DarkMode_InfoPaneToolbar", "DarkMode_BBComposited", "DarkMode_InactiveBBComposited", "DarkMode_MaxBBComposited", "DarkMode_MaxInactiveBBComposited"
				Brush.Handle = hbrBkgnd
				Dim As HWND hwndTT = Cast(HWND, SendMessage(FHandle, TB_GETTOOLTIPS, 0, 0))
				SetWindowTheme(hwndTT, "DarkMode_Explorer", nullptr)
				'SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
			Else
				Dim As HWND hwndTT = Cast(HWND, SendMessage(FHandle, TB_GETTOOLTIPS, 0, 0))
				SetWindowTheme(hwndTT, NULL, NULL)
			End If
			'SendMessage FHandle, WM_THEMECHANGED, 0, 0
		End Sub
		
		Private Sub ToolBar.SetButtonSizes()
			Dim As ..Rect R
			GetWindowRect Handle, @R
			If AutoSize Then
				FHeight = R.Bottom - R.Top
			End If
			Dim As Integer ExpandCount, ButtonsWidth, SpaceWidth
			For i As Integer = 0 To Buttons.Count - 1
				If Buttons.Item(i)->Expand Then
					ExpandCount += 1
				Else
					ButtonsWidth += Buttons.Item(i)->Width
				End If
			Next
			If ExpandCount > 0 Then
				SpaceWidth = UnScaleX(R.Right - R.Left) - ButtonsWidth
				For i As Integer = 0 To Buttons.Count - 1
					If Buttons.Item(i)->Expand Then
						Buttons.Item(i)->Width = SpaceWidth / ExpandCount
					End If
				Next
			End If
		End Sub
	
	Private Sub ToolBar.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PAINT
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					If Not FDarkMode Then
						SetDark True
'						FDarkMode = True
'						SetWindowTheme(FHandle, "DarkMode_InfoPaneToolbar", nullptr) ' "DarkMode", "DarkMode_InfoPaneToolbar", "DarkMode_BBComposited", "DarkMode_InactiveBBComposited", "DarkMode_MaxBBComposited", "DarkMode_MaxInactiveBBComposited"
'						Brush.Handle = hbrBkgnd
'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
					End If
				End If
				Message.Result = 0
			Case WM_SIZE
				SetButtonSizes()
			Case WM_DPICHANGED
				Base.ProcessMessage(Message)
				Perform(TB_SETBITMAPSIZE, 0, MAKELONG(ScaleX(FBitmapWidth), ScaleY(FBitmapHeight)))
				If ImagesList Then ImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If HotImagesList Then HotImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If DisabledImagesList Then DisabledImagesList->SetImageSize FBitmapWidth, FBitmapHeight, xdpi, ydpi
				If ImagesList AndAlso ImagesList->Handle Then Perform(TB_SETIMAGELIST, 0, CInt(ImagesList->Handle))
				If HotImagesList AndAlso HotImagesList->Handle Then Perform(TB_SETHOTIMAGELIST, 0, CInt(HotImagesList->Handle))
				If DisabledImagesList AndAlso DisabledImagesList->Handle Then Perform(TB_SETDISABLEDIMAGELIST, 0, CInt(DisabledImagesList->Handle))
				If ImagesList AndAlso ImagesList->Handle Then SendMessage(FHandle, TB_SETIMAGELIST, 0, CInt(ImagesList->Handle))
				For i As Integer = 0 To Buttons.Count - 1
					Buttons.Item(i)->xdpi = xdpi
					Buttons.Item(i)->ydpi = ydpi
					Buttons.Item(i)->Update
				Next
				Dim As ..Size sz
				SendMessage FHandle, TB_GETIDEALSIZE, False, Cast(LPARAM, @sz)
				sz.cx = 10000
				sz.cy = ScaleY(FHeight)
				SendMessage FHandle, TB_GETIDEALSIZE, 1, Cast(LPARAM, @sz)
				SetBounds FLeft, FTop, FWidth, UnScaleY(sz.cy)
				If Parent Then Parent->RequestAlign
				Return
			Case WM_COMMAND
				GetDropDownMenuItems
				For i As Integer = 0 To FPopupMenuItems.Count -1
					If QMenuItem(FPopupMenuItems.Items[i]).Command = Message.wParamLo Then
						If QMenuItem(FPopupMenuItems.Items[i]).OnClick Then QMenuItem(FPopupMenuItems.Items[i]).OnClick(*QMenuItem(FPopupMenuItems.Items[i]).Designer, QMenuItem(FPopupMenuItems.Items[i]))
						Exit For
					End If
				Next i
			Case WM_DESTROY
				If ImagesList Then Perform(TB_SETIMAGELIST, 0, 0)
				If HotImagesList Then Perform(TB_SETHOTIMAGELIST, 0, 0)
				If DisabledImagesList Then Perform(TB_SETDISABLEDIMAGELIST, 0, 0)
			Case CM_COMMAND
				Dim As Integer Index
				Dim As TBBUTTON TB
				If Message.wParam <> 0 Then
					Index = Perform(TB_COMMANDTOINDEX, Message.wParam, 0)
					If Perform(TB_GETBUTTON, Index, CInt(@TB)) Then
						If Buttons.Item(Index)->OnClick Then (Buttons.Item(Index))->OnClick(*Buttons.Item(Index)->Designer, *Buttons.Item(Index))
						If OnButtonClick Then OnButtonClick(*Designer, This, *Buttons.Item(Index))
					End If
				End If
			Case CM_NOTIFY
				Dim As TBNOTIFY Ptr Tbn
				Dim As TBBUTTON TB
				Dim As ..Rect R
				Dim As Integer i
				Tbn = Cast(TBNOTIFY Ptr,Message.lParam)
				Select Case Tbn->hdr.code
				Case TBN_DROPDOWN
					If Tbn->iItem <> -1 Then
						SendMessage(Tbn->hdr.hwndFrom, TB_GETRECT, Tbn->iItem, CInt(@R))
						MapWindowPoints(Tbn->hdr.hwndFrom, 0, Cast(..Point Ptr, @R), 2)
						i = SendMessage(Tbn->hdr.hwndFrom, TB_COMMANDTOINDEX, Tbn->iItem, 0)
						If SendMessage(Tbn->hdr.hwndFrom, TB_GETBUTTON, i, CInt(@TB)) Then
							bDropdownIndex = i
							TrackPopupMenu(Buttons.Item(i)->DropDownMenu.Handle, 0, R.Left, R.Bottom, 0, Tbn->hdr.hwndFrom, NULL)
							bDropdownIndex = -1
						End If
					End If
				Case NM_CUSTOMDRAW
					If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
						Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
						Select Case nmcd->dwDrawStage
						Case CDDS_PREPAINT
							FillRect nmcd->hdc, @nmcd->rc, hbrBkgnd
							Message.Result = CDRF_NOTIFYPOSTPAINT
							Return
						Case CDDS_POSTPAINT
							Dim As HPEN SeparatorPen = CreatePen(PS_SOLID, 1, darkHlBkColor) 'BGR(48, 48, 48))
							Dim As HPEN DropDownPen = CreatePen(PS_SOLID, 1, BGR(215, 215, 215))
							Dim As HPEN HotItemPen = CreatePen(PS_SOLID, 1, IIf(bDropdownIndex = -1, BGR(33, 33, 33), BGR(13, 13, 13)))
							Dim As HPEN PrevPen = SelectObject(nmcd->hdc, SeparatorPen)
							Dim As HBRUSH HotItemBrush = CreateSolidBrush(IIf(bDropdownIndex = -1, BGR(67, 67, 67), BGR(33, 33, 33)))
							Dim As HBRUSH PrevBrush = SelectObject(nmcd->hdc, HotItemBrush)
							Dim As Integer iHotItem, iLeft, iTop, iWidth, iDropDownWidth, iDropDownHeight
							Dim As ..Rect rc, rcOffset
							iHotItem = SendMessage(FHandle, TB_GETHOTITEM, 0, 0)
							For i As Integer = 0 To Buttons.Count - 1
								If Buttons.Item(i)->Style = ToolButtonStyle.tbsSeparator Then
									SendMessage(FHandle, TB_GETITEMRECT, i, Cast(LPARAM, @rc))
									FillRect nmcd->hdc, @rc, hbrBkgnd
									If rc.Left <> 0 Then
										SelectObject(nmcd->hdc, SeparatorPen)
										MoveToEx nmcd->hdc, rc.Left + ScaleX(3), ScaleY(2), 0
										LineTo nmcd->hdc, rc.Left + ScaleX(3), rc.Bottom - rc.Top - ScaleY(3)
									End If
								ElseIf Buttons.Item(i)->Style = ToolButtonStyle.tbsDropDown Then
									SendMessage(FHandle, TB_GETITEMRECT, i, Cast(LPARAM, @rc))
									rcOffset.Right = rc.Right
									rcOffset.Top = rc.Top
									rcOffset.Left = rc.Right - ScaleX(16)
									rcOffset.Bottom = rc.Bottom
									FillRect nmcd->hdc, @rcOffset, hbrBkgnd
									If i = iHotItem OrElse i = bDropdownIndex Then
										rcOffset.Left = rc.Right - ScaleX(16)
										rcOffset.Bottom = rc.Bottom - ScaleY(1)
										SelectObject(nmcd->hdc, HotItemPen)
										Rectangle nmcd->hdc, rcOffset.Left, rcOffset.Top, rcOffset.Right, rcOffset.Bottom
									End If
									SelectObject(nmcd->hdc, DropDownPen)
									iWidth = ScaleX(15)
									iDropDownWidth = ScaleX(7)
									If iDropDownWidth Mod 2 = 0 Then iDropDownWidth += 1
									iDropDownHeight = Fix(iDropDownWidth / 2) + 1
									iLeft = rc.Right - iWidth + Fix((iWidth - iDropDownWidth) / 2)
									iTop = rc.Top + Fix((rc.Bottom - rc.Top - iDropDownHeight) / 2)
									For j As Integer = 0 To iDropDownHeight - 1
										MoveToEx nmcd->hdc, iLeft + j, iTop + j, 0
										LineTo nmcd->hdc, iLeft + iDropDownWidth - j, iTop + j
									Next j
								End If
							Next i
							SelectObject(nmcd->hdc, PrevPen)
							SelectObject(nmcd->hdc, PrevBrush)
							DeleteObject SeparatorPen
							DeleteObject DropDownPen
							DeleteObject HotItemPen
							DeleteObject HotItemBrush
							Message.Result = CDRF_DODEFAULT
							Return
						End Select
					End If
				End Select
			Case CM_NEEDTEXT
				Dim As LPTOOLTIPTEXT TTX
				TTX = Cast(LPTOOLTIPTEXT, Message.lParam)
				TTX->hinst = GetModuleHandle(NULL)
				If TTX->hdr.idFrom Then
					Dim As TBBUTTON TB
					Dim As Integer Index
					Index = Perform(TB_COMMANDTOINDEX,TTX->hdr.idFrom,0)
					If Perform(TB_GETBUTTON,Index,CInt(@TB)) Then
						If Buttons.Item(Index)->ShowHint Then
							If Buttons.Item(Index)->Hint <> "" Then
								'Dim As UString s
								's = Buttons.Button(Index).Hint
								TTX->lpszText = @(Buttons.Item(Index)->Hint)
							End If
						End If
					End If
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ToolBar.HandleIsDestroyed(ByRef Sender As Control)
	End Sub
	
	Private Sub ToolBar.HandleIsAllocated(ByRef Sender As Control)
		If Sender.Child Then
			With QToolBar(Sender.Child)
					If .ImagesList Then .ImagesList->ParentWindow = @Sender: If .ImagesList->Handle Then .Perform(TB_SETIMAGELIST,0,CInt(.ImagesList->Handle))
					If .HotImagesList Then .HotImagesList->ParentWindow = @Sender: If .HotImagesList->Handle Then .Perform(TB_SETHOTIMAGELIST, 0, CInt(.HotImagesList->Handle))
					If .DisabledImagesList Then .DisabledImagesList->ParentWindow = @Sender: If .DisabledImagesList->Handle Then .Perform(TB_SETDISABLEDIMAGELIST,0,CInt(.DisabledImagesList->Handle))
					.Perform(TB_BUTTONSTRUCTSIZE, SizeOf(TBBUTTON), 0)
					.Perform(TB_SETEXTENDEDSTYLE, 0, .Perform(TB_GETEXTENDEDSTYLE, 0, 0) Or TBSTYLE_EX_DRAWDDARROWS)
					.Perform(TB_SETBUTTONSIZE, 0, MAKELONG(.ScaleX(.FButtonWidth), .ScaleY(.FButtonHeight)))
					If .ScaleX(.FBitmapWidth) <> 16 AndAlso .ScaleY(.FBitmapHeight) <> 16 Then .Perform(TB_SETBITMAPSIZE, 0, MAKELONG(.ScaleX(.FBitmapWidth), .ScaleY(.FBitmapHeight)))
					Var FHandle = .FHandle
					For i As Integer = 0 To .Buttons.Count - 1
						.FHandle = 0
						.Buttons.Item(i)->xdpi = .xdpi
						.Buttons.Item(i)->ydpi = .ydpi
						Dim As TBBUTTON TB
						'Dim As WString Ptr s = .Buttons.Button(i)->Caption
						TB.fsState   = .Buttons.Item(i)->State
						TB.fsStyle   = .Buttons.Item(i)->Style
						If .Buttons.Item(i)->ImageIndex = -1 AndAlso .ImagesList <> 0 AndAlso .Buttons.Item(i)->ImageKey <> "" Then
							.Buttons.Item(i)->ImageIndex = .ImagesList->IndexOf(.Buttons.Item(i)->ImageKey)
						End If
						TB.iBitmap   = .Buttons.Item(i)->ImageIndex
						TB.idCommand = .Buttons.Item(i)->CommandID
						If .Buttons.Item(i)->Caption <> "" Then
							TB.iString   = CInt(@.Buttons.Item(i)->Caption)
						Else
							TB.iString   = 0
						End If
						TB.dwData    = Cast(DWORD_PTR, @.Buttons.Item(i)->DropDownMenu)
						SendMessage(FHandle, TB_ADDBUTTONS, 1, CInt(@TB))
						Var iWidth = .Buttons.Item(i)->Width
						.FHandle = FHandle
						If iWidth > 0 Then
							.Buttons.Item(i)->Width = iWidth
						End If
						If Not .Buttons.Item(i)->Visible Then .Perform(TB_HIDEBUTTON, .Buttons.Item(i)->CommandID, MAKELONG(True, 0))
						If .Buttons.Item(i)->Visible AndAlso .Buttons.Item(i)->Child <> 0 Then .Buttons.Item(i)->Child = .Buttons.Item(i)->Child
					Next i
					If .AutoSize Then .Perform(TB_AUTOSIZE, 0, 0)
					.SetButtonSizes()
'				If .DesignMode Then
'					.Buttons.Add
'				End If
			End With
		End If
	End Sub
	
	Private Operator ToolBar.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Constructor ToolBar
		With This
				AFlat(0)        = 0
				AFlat(1)        = TBSTYLE_FLAT
				ADivider(0)     = CCS_NODIVIDER
				ADivider(1)     = 0
				AAutosize(0)    = 0
				AAutosize(1)    = TBSTYLE_AUTOSIZE
				AList(0)        = 0
				AList(1)        = TBSTYLE_LIST
				AState(0)       = TBSTATE_INDETERMINATE
				AState(1)       = TBSTATE_ENABLED
				AState(2)       = TBSTATE_HIDDEN
				AState(3)       = TBSTATE_CHECKED
				AState(4)       = TBSTATE_PRESSED
				AState(5)       = TBSTATE_WRAP
				AWrap(0)        = 0
				AWrap(1)        = TBSTYLE_WRAPABLE
				ATransparent(0) = 0
				ATransparent(1) = TBSTYLE_TRANSPARENT
			FTransparent    = 1
			FAutosize       = 1
			FButtonWidth    = 16
			FButtonHeight   = 16
			FBitmapWidth    = 16
			FBitmapHeight   = 16
			Buttons.Parent  = This
			FEnabled = True
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.ChildProc         = @WndProc
				.ExStyle           = 0
				.Style             = WS_CHILD Or TBSTYLE_TOOLTIPS Or CCS_NOPARENTALIGN Or CCS_NOMOVEY Or AList(FList) Or AAutosize(_Abs(FAutosize)) Or AFlat(_Abs(FFlat)) Or ADivider(_Abs(FDivider)) Or AWrap(_Abs(FWrapable)) Or ATransparent(_Abs(FTransparent))
				.RegisterClass "ToolBar", "ToolBarWindow32"
			.Child             = @This
			WLet(FClassName, "ToolBar")
			WLet(FClassAncestor, "ToolBarWindow32")
				.Width             = 121
					.Height            = 26
			'.Font              = @Font
			'.Cursor            = @Cursor
		End With
		'Dim As GtkSettings Ptr settings = gtk_settings_get_default()
		'g_object_set(settings, "gtk-icon-sizes", "gtk-toolbar=24,24", NULL)
	End Constructor
	
	Private Destructor ToolBar
		Buttons.Clear
			'UnregisterClass "ToolBar", GetmoduleHandle(NULL)
	End Destructor
End Namespace

	' ToolBarAddButtonWithImageIndex/Key deliberately not restored here: FStyle's type
	' (Private Enum ToolButtonStyle) hits an unresolved FreeBASIC "Illegal specification"
	' error when used as an Alias/Export parameter at this scope. Not used anywhere in
	' the IDE itself (only exported for external dynamic callers) so deferred rather
	' than blocking the Designer fix.

	Sub ToolBarRemoveButton Alias "ToolBarRemoveButton" (tb As My.Sys.Forms.ToolBar Ptr, Index As Integer) Export
		tb->Buttons.Remove Index
	End Sub

	Function ToolBarButtonByIndex Alias "ToolBarButtonByIndex" (tb As My.Sys.Forms.ToolBar Ptr, Index As Integer) As My.Sys.Forms.ToolButton Ptr Export
		Return tb->Buttons.Item(Index)
	End Function

	Function ToolBarIndexOfButton Alias "ToolBarIndexOfButton"(tb As My.Sys.Forms.ToolBar Ptr, Btn As My.Sys.Forms.ToolButton Ptr) As Integer Export
		Return tb->Buttons.IndexOf(Btn)
	End Function


