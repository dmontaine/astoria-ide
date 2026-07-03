'################################################################################
'#  ReBar.bi                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "ReBar.bi"

Namespace My.Sys.Forms
	Private Sub ReBarBand.ChangeStyle(iStyle As Integer, Value As Boolean)
		If Value Then
			If ((FStyle And iStyle) <> iStyle) Then FStyle = FStyle Or iStyle
		ElseIf ((FStyle And iStyle) = iStyle) Then
			FStyle = FStyle And Not iStyle
		End If
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.cbSize = SizeOf(REBARBANDINFO)
				rbBand.fMask = RBBIM_STYLE
				rbBand.fStyle = FStyle
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Sub
	
	Private Property ReBarBand.Break As Boolean
		Return FBreak
	End Property
	
	Private Property ReBarBand.Break(Value As Boolean)
		FBreak = Value
			ChangeStyle RBBS_BREAK, Value
	End Property
	
	Private Property ReBarBand.ChildEdge As Boolean
		Return FChildEdge
	End Property
	
	Private Property ReBarBand.ChildEdge(Value As Boolean)
		FChildEdge = Value
			ChangeStyle RBBS_CHILDEDGE, Value
	End Property
	
	Private Property ReBarBand.Caption ByRef As WString
		Return WGet(FCaption)
	End Property
	
	Private Property ReBarBand.Caption(ByRef Value As WString)
		WLet(FCaption, Value)
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.cbSize = SizeOf(REBARBANDINFO)
				rbBand.fMask = RBBIM_TEXT
				rbBand.lpText = FCaption
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.Child As Control Ptr
		Return FChild
	End Property
	
	Private Property ReBarBand.Child(Value As Control Ptr)
		FChild = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				Dim As ..Rect rct
				rbBand.fMask = RBBIM_CHILD Or RBBIM_CHILDSIZE Or RBBIM_SIZE Or RBBIM_IDEALSIZE
				rbBand.hwndChild = Value->Handle                                        ' (RBBIM_CHILD flag)
				GetWindowRect(Value->Handle, @rct)
				rbBand.cxMinChild = rct.Right - rct.Left                                ' Minimum width of band (RBBIM_CHILDSIZE flag)
				rbBand.cyMinChild = rct.Bottom - rct.Top                                ' Minimum height of band (RBBIM_CHILDSIZE flag)
				rbBand.cx = rct.Right - rct.Left                                        ' Length of the band (RBBIM_SIZE flag)
				rbBand.cxIdeal = rct.Right - rct.Left
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.FixedBitmap As Boolean
		Return FFixedBitmap
	End Property
	
	Private Property ReBarBand.FixedBitmap(Value As Boolean)
		FFixedBitmap = Value
			ChangeStyle RBBS_FIXEDBMP, Value
	End Property
	
	Private Property ReBarBand.FixedSize As Boolean
		Return FFixedSize
	End Property
	
	Private Property ReBarBand.FixedSize(Value As Boolean)
		FFixedSize = Value
			ChangeStyle RBBS_FIXEDSIZE, Value
	End Property
	
	Private Property ReBarBand.GripperStyle As GripperStyles
		Return FGripperStyle
	End Property
	
	Private Property ReBarBand.GripperStyle(Value As GripperStyles)
		FGripperStyle = Value
			ChangeStyle RBBS_GRIPPERALWAYS, False
			ChangeStyle RBBS_NOGRIPPER, False
			Select Case Value
			Case Auto
			Case GripperAlways: ChangeStyle RBBS_GRIPPERALWAYS, True
			Case NoGripper: ChangeStyle RBBS_NOGRIPPER, True
			End Select
	End Property
	
	Private Property ReBarBand.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ReBarBand.ImageIndex(Value As Integer)
		FImageIndex = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				If FImageIndex > -1 AndAlso Parent->ImageList <> 0 AndAlso Parent->ImageList->Count > 0 Then
					Dim As REBARBANDINFO rbBand
					rbBand.cbSize = SizeOf(REBARBANDINFO)
					rbBand.fMask Or = RBBIM_IMAGE
					rbBand.iImage = FImageIndex
					SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
				End If
			End If
	End Property
	
	Private Property ReBarBand.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ReBarBand.ImageKey(ByRef Value As WString)
		WLet(FImageKey, Value)
		If Parent AndAlso Parent->ImageList Then
			ImageIndex = Parent->ImageList->IndexOf(*FImageKey)
		End If
	End Property
	
	Private Property ReBarBand.MinWidth As Integer
		Return FMinWidth
	End Property
	
	Private Property ReBarBand.MinWidth(Value As Integer)
		FMinWidth = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_CHILDSIZE
				rbBand.cxMinChild = FMinWidth                                ' Minimum width of band (RBBIM_CHILDSIZE flag)
				rbBand.cyMinChild = FMinHeight                               ' Minimum height of band (RBBIM_CHILDSIZE flag)
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.MinHeight As Integer
		Return FMinHeight
	End Property
	
	Private Property ReBarBand.MinHeight(Value As Integer)
		FMinHeight = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_CHILDSIZE
				rbBand.cxMinChild = FMinWidth                                ' Minimum width of band (RBBIM_CHILDSIZE flag)
				rbBand.cyMinChild = FMinHeight                               ' Minimum height of band (RBBIM_CHILDSIZE flag)
				rbBand.cyChild = FHeight
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.Left As Integer
			Dim rc As My.Sys.Drawing.Rect
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then 
				SendMessage(Parent->Handle, RB_GETRECT, Index, Cast(LPARAM, @rc))
				FLeft = rc.Left
			End If
		Return FLeft
	End Property
	
	Private Property ReBarBand.Left(Value As Integer)
		FLeft = Value
	End Property
	
	Private Property ReBarBand.Top As Integer
			Dim rc As My.Sys.Drawing.Rect
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then 
				SendMessage(Parent->Handle, RB_GETRECT, Index, Cast(LPARAM, @rc))
				FLeft = rc.Top
			End If
		Return FTop
	End Property
	
	Private Property ReBarBand.Top(Value As Integer)
		FTop = Value
	End Property
	
	Private Property ReBarBand.Height As Integer
			Dim rc As My.Sys.Drawing.Rect
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then 
				SendMessage(Parent->Handle, RB_GETRECT, Index, Cast(LPARAM, @rc))
				FHeight = rc.Bottom - rc.Top
			End If
		Return FHeight
	End Property
	
	Private Property ReBarBand.Height(Value As Integer)
		FHeight = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_CHILDSIZE
				rbBand.cxMinChild = FMinWidth                                ' Minimum width of band (RBBIM_CHILDSIZE flag)
				rbBand.cyMinChild = FMinHeight                               ' Minimum height of band (RBBIM_CHILDSIZE flag)
				rbBand.cyChild = FHeight
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.Width As Integer
			Dim rc As My.Sys.Drawing.Rect
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then 
				SendMessage(Parent->Handle, RB_GETRECT, Index, Cast(LPARAM, @rc))
				FWidth = rc.Right - rc.Left
			End If
		Return FWidth
	End Property
	
	Private Property ReBarBand.Width(Value As Integer)
		FWidth = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_SIZE
				rbBand.cx = FWidth
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.IdealWidth As Integer
		Return FIdealWidth
	End Property
	
	Private Property ReBarBand.IdealWidth(Value As Integer)
		FIdealWidth = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_IDEALSIZE
				rbBand.cxIdeal = FIdealWidth
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.RequestedWidth As Integer
		Return FRequestedWidth
	End Property
	
	Private Property ReBarBand.RequestedWidth(Value As Integer)
		FRequestedWidth = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				rbBand.fMask = RBBIM_SIZE
				rbBand.cx = FRequestedWidth
				SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
			End If
	End Property
	
	Private Property ReBarBand.TopAlign As Boolean
		Return FTopAlign
	End Property
	
	Private Property ReBarBand.TopAlign(Value As Boolean)
		FTopAlign = Value
			ChangeStyle RBBS_TOPALIGN, Value
	End Property
	
	Private Property ReBarBand.TitleVisible As Boolean
		Return FTitleVisible
	End Property
	
	Private Property ReBarBand.TitleVisible(Value As Boolean)
		FTitleVisible = Value
			ChangeStyle RBBS_HIDETITLE, Not Value
	End Property
	
	Private Property ReBarBand.UseChevron As Boolean
		Return FTitleVisible
	End Property
	
	Private Property ReBarBand.UseChevron(Value As Boolean)
		FTitleVisible = Value
			ChangeStyle RBBS_USECHEVRON, Value
	End Property
	
	Private Property ReBarBand.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ReBarBand.Visible(Value As Boolean)
		FVisible = Value
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then SendMessage(Parent->Handle, RB_SHOWBAND, Index, Value)
	End Property
	
	Private Property ReBarBand.Index As Integer
		If Parent Then Return Parent->Bands.IndexOf(@This)
		Return -1
	End Property
	
	Private Property ReBarBand.Index(Value As Integer)
		If Value >= 0 AndAlso Value <= Parent->Bands.Count - 1 Then
			Dim As Integer OldIndex = Index
			If OldIndex < 0 OrElse Value = OldIndex Then Exit Property
			Parent->Bands.Move(OldIndex, Value)
		End If
	End Property
	
	Private Sub ReBarBandCollection.Move(OldIndex As Integer, Value As Integer)
		Dim As Any Ptr Band = FItems.Item(OldIndex)
		FItems.Remove OldIndex
		FItems.Insert Value, Band
			SendMessage Parent->Handle, RB_MOVEBAND, OldIndex, Value
	End Sub
	
	Private Sub ReBarBand.Maximize()
			If Parent AndAlso Parent->Handle Then
				SendMessage Parent->Handle, RB_MAXIMIZEBAND, Index, 0
			End If
	End Sub
	
	Private Sub ReBarBand.Minimize()
			If Parent AndAlso Parent->Handle Then
				SendMessage Parent->Handle, RB_MINIMIZEBAND, Index, 0
			End If
	End Sub
	
	Private Sub ReBarBand.Update(Create As Boolean = False)
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then
				Dim As REBARBANDINFO rbBand
				Dim As ..Rect rct
				rbBand.cbSize = SizeOf(REBARBANDINFO)
				rbBand.fMask = RBBIM_STYLE Or RBBIM_CHILD Or RBBIM_CHILDSIZE Or RBBIM_SIZE Or RBBIM_IDEALSIZE
				If (FImageIndex > -1) AndAlso Parent->ImageList AndAlso (Parent->ImageList->Count > 0) Then
					rbBand.fMask Or= RBBIM_IMAGE
					rbBand.iImage = FImageIndex
				End If
				If WGet(FCaption) <> "" Then
					rbBand.fMask Or= RBBIM_TEXT
					rbBand.lpText = FCaption
				End If
				rbBand.fStyle = FStyle                                          ' (RBBIM_STYLE flag)
				If FChild Then
					rbBand.hwndChild = FChild->Handle                           ' (RBBIM_CHILD flag)
				End If
				'If Create Then
					GetWindowRect(FChild->Handle, @rct)
					FMinWidth = rct.Right - rct.Left
					FMinHeight = rct.Bottom - rct.Top
					FWidth = rct.Right - rct.Left
					FHeight = rct.Bottom - rct.Top
					If *FChild Is ToolBar Then
						Dim As ..Size sz
						SendMessage FChild->Handle, TB_GETIDEALSIZE, False, Cast(LPARAM, @sz)
						FIdealWidth = sz.cx
						FMinWidth = sz.cx
						FWidth = sz.cx
						sz.cx = 10000
						sz.cy = FHeight
						SendMessage FChild->Handle, TB_GETIDEALSIZE, 1, Cast(LPARAM, @sz)
						FMinHeight = sz.cy
						FHeight = sz.cy
					Else
						FIdealWidth = rct.Right - rct.Left
					End If
				'End If
				rbBand.cxMinChild = FMinWidth                                   ' Minimum width of band (RBBIM_CHILDSIZE flag)
				rbBand.cyMinChild = FMinHeight + 2                              ' Minimum height of band (RBBIM_CHILDSIZE flag)
				rbBand.cx = FWidth                                              ' Length of the band (RBBIM_SIZE flag)
				rbBand.cyChild = FHeight + 2                                    ' Height of the band (RBBIM_SIZE flag)
				rbBand.cxIdeal = FIdealWidth
				If Create Then
					'SendMessage(Parent->Handle, RB_INSERTBAND, Index, Cast(LPARAM, @rbBand))
					SendMessage(Parent->Handle, RB_INSERTBAND, -1, Cast(LPARAM, @rbBand))
					If Not FBreak Then Maximize
				Else
					SendMessage(Parent->Handle, RB_SETBANDINFO, Index, Cast(LPARAM, @rbBand))
					If Not FBreak Then Maximize
				End If
			End If
	End Sub
	
	Private Function ReBarBand.GetRect() As My.Sys.Drawing.Rect
		Dim rc As My.Sys.Drawing.Rect
			If Parent AndAlso Parent->Handle AndAlso Index <> - 1 Then SendMessage(Parent->Handle, RB_GETRECT, Index, Cast(LPARAM, @rc))
		Return rc
	End Function
	
	Private Constructor ReBarBand
		FVisible = True
	End Constructor
	
	Private Destructor ReBarBand
		WDeAllocate(FCaption)
		WDeAllocate(FImageKey)
	End Destructor
	
	Private Function ReBarBandCollection.Count As Integer
		Return FItems.Count
	End Function
	
	Private Property ReBarBandCollection.Item(Index As Integer) As ReBarBand Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Item(Index)
		Else
			Print "Not found item by index" & Index
			Return 0
		End If
	End Property
	
	Private Property ReBarBandCollection.Item(Index As Integer, Value As ReBarBand Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Item(Index) = Value
		Else
			Print "Not found item by index" & Index
		End If
	End Property
	
	Private Function ReBarBandCollection.Add(Value As Control Ptr, ByRef Caption As WString = "", ImageIndex As Integer = 0, Index As Integer = -1) As ReBarBand Ptr
		Dim As ReBarBand Ptr pBand = _New(ReBarBand)
		pBand->Caption = Caption
		pBand->Child = Value
		pBand->ImageIndex = ImageIndex
		pBand->ChildEdge = True
		pBand->GripperStyle = GripperStyles.GripperAlways
		pBand->UseChevron = True
		pBand->Parent = Parent
			If Parent AndAlso Parent->Handle Then
				Dim As REBARBANDINFO rbBand
				Dim As ..Rect rct
				
				rbBand.cbSize = SizeOf(REBARBANDINFO)
				rbBand.fMask = RBBIM_STYLE Or RBBIM_CHILD Or RBBIM_CHILDSIZE Or RBBIM_SIZE Or RBBIM_IDEALSIZE
				If (ImageIndex > -1) AndAlso Parent->ImageList AndAlso (Parent->ImageList->Count > 0) Then
					rbBand.fMask Or= RBBIM_IMAGE
					rbBand.iImage = ImageIndex
				End If
				If Caption <> "" Then
					rbBand.fMask Or= RBBIM_TEXT
					rbBand.lpText = @Caption
				End If
				rbBand.fStyle = RBBS_CHILDEDGE Or RBBS_GRIPPERALWAYS 'Or RBBS_USECHEVRON          ' (RBBIM_STYLE flag)
				
				rbBand.hwndChild = Value->Handle                                       ' (RBBIM_CHILD flag)
				If rbBand.hwndChild Then
					GetWindowRect(Value->Handle, @rct)
					rbBand.cxMinChild = rct.Right - rct.Left                        ' Minimum width of band (RBBIM_CHILDSIZE flag)
					rbBand.cyMinChild = rct.Bottom - rct.Top                        ' Minimum height of band (RBBIM_CHILDSIZE flag)
					rbBand.cx = rct.Right - rct.Left                                ' Length of the band (RBBIM_SIZE flag)
					If *Value Is ToolBar Then
						Dim As ..Size sz
						SendMessage Value->Handle, TB_GETIDEALSIZE, False, Cast(LPARAM, @sz)
						rbBand.cxIdeal = sz.cx
						rbBand.cxMinChild = sz.cx
						rbBand.cx = sz.cx
						sz.cx = 10000
						sz.cy = rbBand.cyChild
						SendMessage Value->Handle, TB_GETIDEALSIZE, 1, Cast(LPARAM, @sz)
						rbBand.cyMinChild = sz.cy
						rbBand.cyChild = sz.cy
					Else
						rbBand.cxIdeal = rct.Right - rct.Left
					End If
					pBand->MinWidth = rbBand.cxMinChild
					pBand->MinHeight = rbBand.cyMinChild
					pBand->Width = rbBand.cx
				End If
				SendMessage(Parent->Handle, RB_INSERTBAND, Index, Cast(LPARAM, @rbBand))
			End If
		FItems.Add pBand
		Return pBand
	End Function
	
	Private Function ReBarBandCollection.Add(Value As Control Ptr, ByRef Caption As WString = "", ByRef ImageKey As WString, Index As Integer = -1) As ReBarBand Ptr
		Dim As ReBarBand Ptr pBand
		If Parent AndAlso Parent->ImageList Then
			pBand = Add(Value, Caption, Parent->ImageList->IndexOf(ImageKey), Index)
		Else
			pBand = Add(Value, Caption, -1, Index)
		End If
		If pBand Then pBand->ImageKey = ImageKey
		Return pBand
	End Function
	
	Private Sub ReBarBandCollection.Remove(Index As Integer)
			If Parent AndAlso Parent->Handle Then SendMessage Parent->Handle, RB_DELETEBAND, Index, 0
		_Delete(Cast(ReBarBand Ptr, FItems.Item(Index)))
		FItems.Remove Index
	End Sub
	
	Private Sub ReBarBandCollection.Clear
		For Index As Integer = 0 To FItems.Count - 1
				If Parent AndAlso Parent->Handle Then SendMessage Parent->Handle, RB_DELETEBAND, Index, 0
			_Delete(Cast(ReBarBand Ptr, FItems.Item(Index)))
		Next Index
		FItems.Clear
	End Sub
	
	Private Function ReBarBandCollection.IndexOf(Value As ReBarBand Ptr) As Integer
		Return FItems.IndexOf(Value)
	End Function
	
	Private Function ReBarBandCollection.IndexOf(Value As Control Ptr) As Integer
		For Index As Integer = 0 To FItems.Count - 1
			If Cast(ReBarBand Ptr, FItems.Item(Index))->Child = Value Then Return Index
			Return FItems.IndexOf(Value)
		Next Index
		Return -1
	End Function
	
	Private Function ReBarBandCollection.Contains(Value As ReBarBand Ptr) As Boolean
		Return IndexOf(Value) <> -1
	End Function
	
	Private Function ReBarBandCollection.Contains(Value As Control Ptr) As Boolean
		Return IndexOf(Value) <> -1
	End Function
	
	Private Constructor ReBarBandCollection
		
	End Constructor
	
	Private Destructor ReBarBandCollection
		This.Clear
	End Destructor
	
		Private Function ReBar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutoSize
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ReBar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value) 
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property ReBar.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property ReBar.AutoSize(Value As Boolean)
		FAutoSize = Value
			ChangeStyle RBS_AUTOSIZE, Value
	End Property
	
	Private Sub ReBar.UpdateReBar()
			If ImageList AndAlso ImageList->Count Then
				Dim As REBARINFO inf
				inf.cbSize = SizeOf(REBARINFO)
				inf.fMask = RBIM_IMAGELIST
				inf.himl = ImageList->Handle
				SendMessage(Handle, RB_SETBARINFO, 0, Cast(LPARAM, @inf))
			End If
	End Sub
	
	Private Function ReBar.RowCount() As Integer
			If FHandle Then FRowCount = SendMessage(FHandle, RB_GETROWCOUNT, 0, 0)
		Return FRowCount
	End Function
	
	Private Sub ReBar.Add(Ctrl As Control Ptr, Index As Integer = -1)
		Base.Add(Ctrl, Index)
		Bands.Add Ctrl
	End Sub
	
		Private Sub ReBar.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QReBar(Sender.Child)
					If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso .FDefaultBackColor = .FBackColor Then
						'SetWindowTheme(.FHandle, "DarkModeNavbar", nullptr)
						.Brush.Handle = hbrBkgnd
						SendMessageW(.FHandle, WM_THEMECHANGED, 0, 0)
						SendMessage(.FHandle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, darkTextColor))
						SendMessage(.FHandle, RB_SETBKCOLOR, 0, Cast(LPARAM, darkBkColor))
						Dim As COLORSCHEME csch
						csch.dwSize = SizeOf(COLORSCHEME)
						csch.clrBtnShadow = darkBkColor
						csch.clrBtnHighlight = darkHlBkColor
						SendMessage(.FHandle, RB_SETCOLORSCHEME, 0, Cast(LPARAM, @csch))
						.FDarkMode = True
					End If
					.UpdateReBar()
					For i As Integer = 0 To .Bands.Count - 1
						'.Bands.Item(i)->Child = .Bands.Item(i)->Child
						.Bands.Item(i)->Update True
					Next
				End With
			End If
		End Sub
		
		Private Sub ReBar.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub ReBar.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_WINDOWPOSCHANGING
				If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
					Brush.Handle = hbrBkgnd
					SendMessage(FHandle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, darkTextColor))
					SendMessage(FHandle, RB_SETBKCOLOR, 0, Cast(LPARAM, darkBkColor))
					Dim As COLORSCHEME csch
					csch.dwSize = SizeOf(COLORSCHEME)
					csch.clrBtnShadow = darkBkColor
					csch.clrBtnHighlight = darkHlBkColor
					SendMessage(FHandle, RB_SETCOLORSCHEME, 0, Cast(LPARAM, @csch))
					SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
					Repaint
				End If
			Case WM_DPICHANGED
				Base.ProcessMessage(Message)
				For i As Integer = 0 To Bands.Count - 1
					'Bands.Item(i)->Child = Bands.Item(i)->Child
					Bands.Item(i)->Update
					Bands.Item(i)->Visible = Bands.Item(i)->Visible
				Next
				SetBounds FLeft, FTop, FWidth, FHeight
				Return
			Case WM_ERASEBKGND
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					
				End If
			Case WM_PAINT
				'If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
				'	If Not FDarkMode Then
				'		If Not FDarkMode Then
				'			FDarkMode = True
				'			'SetWindowTheme(FHandle, "DarkModeNavbar", nullptr)
				'			Brush.Handle = hbrBkgnd
				'			SendMessage(FHandle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, darkTextColor))
				'			SendMessage(FHandle, RB_SETBKCOLOR, 0, Cast(LPARAM, darkBkColor))
				'			Dim As COLORSCHEME csch
				'			csch.dwSize = SizeOf(COLORSCHEME)
				'			csch.clrBtnShadow = darkBkColor
				'			csch.clrBtnHighlight = darkHlBkColor
				'			SendMessage(FHandle, RB_SETCOLORSCHEME, 0, Cast(LPARAM, @csch))
				'			SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
				'			Repaint
				'		End If
				'	End If
				'End If
				'Dim As HDC Dc, memDC
				'Dim As HBITMAP Bmp
				'Dim As PAINTSTRUCT Ps
				'Dim As ..Rect R
				'Canvas.HandleSetted = True
				'Dc = BeginPaint(Handle, @Ps)
				'FillRect Dc, @Ps.rcPaint, Brush.Handle
				'Canvas.Handle = Dc
				'Dim As HPEN GripperPen = CreatePen(PS_SOLID, 1, darkBkColor)
				'Dim As HPEN GripperPen1 = CreatePen(PS_SOLID, 1, darkHlBkColor)
				'Dim As HPEN PrevPen = SelectObject(Dc, GripperPen)
				'Dim rc As My.Sys.Drawing.Rect
				'For i As Integer = 0 To Bands.Count - 1
				'	SendMessage(FHandle, RB_GETRECT, i, Cast(LPARAM, @rc))
				'	SelectObject(Dc, GripperPen1)
				'	MoveToEx Dc, rc.Left + 2, rc.Top + 2, 0
				'	LineTo Dc, rc.Left + 2, rc.Bottom - 3
				'	SelectObject(Dc, GripperPen1)
				'	MoveToEx Dc, rc.Left + 3, rc.Top + 2, 0
				'	LineTo Dc, rc.Left + 3, rc.Bottom - 3
				'Next i
				'SelectObject(Dc, PrevPen)
				'DeleteObject GripperPen
				'DeleteObject GripperPen1
				'If OnPaint Then OnPaint(This, Canvas)
				'EndPaint Handle, @Ps
				'Message.Result = -1
				'Canvas.HandleSetted = False
				'Return
			Case WM_COMMAND
				Message.Result = -1
			Case WM_SIZE
				If This.Parent Then This.Parent->RequestAlign , , , @This
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC,Message.wParam)
				' SetBKMode Dc, TRANSPARENT
				' SetTextColor Dc,Font.Color
				' SetBKColor Dc,base.Color
				' SetBKMode Dc,OPAQUE
				SendMessage(Handle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, This.Font.Color))
				SendMessage(Handle, RB_SETBKCOLOR, 0, Cast(LPARAM, FBackColor))
			Case CM_NOTIFY
				Dim ptnmRebar As NMREBAR Ptr            ' information about a notification message
				ptnmRebar = Cast(NMREBAR Ptr,  Message.lParam)
				Select Case ptnmRebar->hdr.code
				Case RBN_HEIGHTCHANGE
					If OnHeightChange Then OnHeightChange(*Designer, This)
				Case NM_CUSTOMDRAW
					If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
						If Not FReBarDarkMode Then
							FDarkMode = True
							FReBarDarkMode = True
							'SetWindowTheme(FHandle, "DarkModeNavbar", nullptr)
							Brush.Handle = hbrBkgnd
							SendMessage(FHandle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, darkTextColor))
							SendMessage(FHandle, RB_SETBKCOLOR, 0, Cast(LPARAM, darkBkColor))
							Dim As COLORSCHEME csch
							csch.dwSize = SizeOf(COLORSCHEME)
							csch.clrBtnShadow = darkBkColor
							csch.clrBtnHighlight = darkHlBkColor
							SendMessage(FHandle, RB_SETCOLORSCHEME, 0, Cast(LPARAM, @csch))
							SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
							If This.Parent Then This.Parent->RequestAlign , , , @This
							Repaint
						End If
						Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
						Select Case nmcd->dwDrawStage
						Case CDDS_PREPAINT
							'FillRect nmcd->hdc, @nmcd->rc, hbrBkgnd
							Message.Result = CDRF_NOTIFYPOSTPAINT Or CDRF_NOTIFYPOSTERASE
							Return
						Case CDDS_POSTPAINT
							Dim As HPEN GripperPen = CreatePen(PS_SOLID, 1, darkBkColor)
							Dim As HPEN GripperPen1 = CreatePen(PS_SOLID, 1, darkBkColor)
							Dim As HPEN PrevPen = SelectObject(nmcd->hdc, GripperPen)
							'FillRect nmcd->hdc, @nmcd->rc, hbrBkgnd
							Dim rc As My.Sys.Drawing.Rect
							For i As Integer = 0 To Bands.Count - 1
								SendMessage(FHandle, RB_GETRECT, i, Cast(LPARAM, @rc))
								SelectObject(nmcd->hdc, GripperPen1)
								MoveToEx nmcd->hdc, rc.Left + 2, rc.Top + 2, 0
								LineTo nmcd->hdc, rc.Left + 2, rc.Bottom - 3
								SelectObject(nmcd->hdc, GripperPen1)
								MoveToEx nmcd->hdc, rc.Left + 3, rc.Top + 2, 0
								LineTo nmcd->hdc, rc.Left + 3, rc.Bottom - 3
							Next i
							SelectObject(nmcd->hdc, PrevPen)
							DeleteObject GripperPen
							DeleteObject GripperPen1
							Message.Result = CDRF_DODEFAULT
							Return
						End Select
					Else
						If FReBarDarkMode Then
							FDarkMode = False
							FReBarDarkMode = False
							If FBackColor = -1 Then
								Brush.Handle = 0
							Else
								Brush.Color = FBackColor
							End If
							SendMessage(Handle, RB_SETTEXTCOLOR, 0, Cast(LPARAM, This.Font.Color))
							SendMessage(Handle, RB_SETBKCOLOR, 0, Cast(LPARAM, FBackColor))
							Dim As COLORSCHEME csch
							csch.dwSize = SizeOf(COLORSCHEME)
							csch.clrBtnShadow = FBackColor
							csch.clrBtnHighlight = FBackColor
							SendMessage(FHandle, RB_SETCOLORSCHEME, 0, Cast(LPARAM, @csch))
							SetWindowTheme(FHandle, NULL, NULL)
							If This.Parent Then This.Parent->RequestAlign , , , @This
						End If
					End If
				End Select
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator ReBar.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor ReBar
			Dim ticc As INITCOMMONCONTROLSEX     ' specifies common control classes to register
			ticc.dwSize = SizeOf(ticc)
			ticc.dwICC  = ICC_COOL_CLASSES Or ICC_BAR_CLASSES
			INITCOMMONCONTROLSEX @ticc
		Bands.Parent = @This
		With This
			WLet(FClassName, "ReBar")
			WLet(FClassAncestor, "ReBarWindow32")
				.RegisterClass "ReBar", "ReBarWindow32"
				.Style        = WS_CHILD Or RBS_VARHEIGHT Or CCS_NODIVIDER Or RBS_BANDBORDERS
				.ExStyle      = 0
				.ChildProc    = @WndProc
				.DoubleBuffered = True
				.OnHandleIsAllocated = @HandleIsAllocated
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
			.Width        = 100
			.Height       = 25
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor ReBar
			UnregisterClass "ReBar", GetModuleHandle(NULL)
	End Destructor
End Namespace

