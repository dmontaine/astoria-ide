'################################################################################
'#  SearchBox.bas                                                               #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2024)                                          #
'################################################################################

#include once "SearchBox.bi"

Namespace My.Sys.Forms
		Private Function SearchBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function SearchBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property SearchBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property SearchBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property SearchBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property SearchBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub SearchBox.WndProc(ByRef message As Message)
		End Sub
		
		Private Sub SearchBox.MoveIcons
			Dim rcClient As Rect
			GetClientRect(FHandle, @rcClient)
			imgSearch.SetBounds 1, Fix(UnScaleY(rcClient.Bottom) - 16) / 2, 16, 17
			imgClear.SetBounds UnScaleY(rcClient.Right) - 16, (UnScaleY(rcClient.Bottom) - 16) / 2, 16, 16
		End Sub
	
	Private Sub SearchBox.ProcessMessage(ByRef message As Message)
			Select Case message.Msg
			Case WM_SIZE
				MoveIcons
			Case CM_COMMAND
				Select Case message.wParamHi
				Case EN_CHANGE
					imgClear.Visible = Text <> ""
				End Select
			End Select
		Base.ProcessMessage(message)
	End Sub
	
		Sub SearchBox.imgSearch_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
			Dim hPen As HPEN
			Dim As ..Rect R
			GetClientRect Sender.Handle, @R
			FillRect(Canvas.Handle, @R, Brush.Handle)
			Dim As HBRUSH PrevBrush = SelectObject(Canvas.Handle, GetStockObject(NULL_BRUSH))
			If FDarkMode Then
				hPen = CreatePen(PS_SOLID, 2, BGR(61, 61, 118))
			Else
				hPen = CreatePen(PS_SOLID, 2, BGR(171, 171, 227))
			End If
			SelectObject(Canvas.Handle, hPen)
			Ellipse(Canvas.Handle, 0, 1, ScaleX(13), ScaleY(14))
			DeleteObject(hPen)
			If FDarkMode Then
				hPen = CreatePen(PS_SOLID, 1, BGR(89, 94, 95))
			Else
				hPen = CreatePen(PS_SOLID, 1, BGR(95, 95, 95))
			End If
			SelectObject(Canvas.Handle, hPen)
			Ellipse(Canvas.Handle, 0, 1, ScaleX(13), ScaleY(14))
			DeleteObject(hPen)
			If FDarkMode Then
				hPen = CreatePen(PS_SOLID, 2, BGR(89, 94, 95))
			Else
				hPen = CreatePen(PS_SOLID, 2, BGR(95, 95, 95))
			End If
			SelectObject(Canvas.Handle, hPen)
			MoveToEx(Canvas.Handle, ScaleX(10), ScaleY(11), NULL)
			LineTo(Canvas.Handle, ScaleX(16), ScaleY(17))
			MoveToEx(Canvas.Handle, ScaleX(10), ScaleY(11), NULL)
			LineTo(Canvas.Handle, ScaleX(16), ScaleY(17))
			SelectObject(Canvas.Handle, PrevBrush)
			DeleteObject(hPen)
		End Sub
		
		Sub SearchBox.imgClear_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
			Dim hPen As HPEN
			Dim As ..Rect R
			GetClientRect Sender.Handle, @R
			FillRect(Canvas.Handle, @R, Brush.Handle)
			If FDarkMode Then
				hPen = CreatePen(PS_SOLID, 2, BGR(89, 94, 95))
			Else
				hPen = CreatePen(PS_SOLID, 2, BGR(95, 95, 95))
			End If
			SelectObject(Canvas.Handle, hPen)
			MoveToEx(Canvas.Handle, ScaleX(4), ScaleY(4), NULL)
			LineTo(Canvas.Handle, ScaleX(12), ScaleY(12))
			MoveToEx(Canvas.Handle, ScaleX(12), ScaleY(4), NULL)
			LineTo(Canvas.Handle, ScaleX(4), ScaleY(12))
			DeleteObject(hPen)
		End Sub
		
		Sub SearchBox.imgClear_Click(ByRef Sender As Control)
			Text = ""
		End Sub
		
		Private Sub SearchBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QSearchBox(Sender.Child)
						If .FMaxLength = 0 Then
							.Perform(EM_LIMITTEXT, -1, 0)
						Else
							.Perform(EM_LIMITTEXT, .FMaxLength, 0)
						End If
						If .ReadOnly Then .Perform(EM_SETREADONLY, True, 0)
						If .FMasked Then .Masked = True
						If .FSelStart <> 0 OrElse .FSelEnd <> 0 Then .SetSel .FSelStart, .FSelEnd
						If .FLeftMargin <> 0 Then
							SendMessage(.FHandle, EM_SETMARGINS, EC_LEFTMARGIN, MAKELPARAM(.ScaleX(.FLeftMargin), .ScaleX(.FRightMargin)))
						End If
						If .FRightMargin <> 0 Then
							SendMessage(.FHandle, EM_SETMARGINS, EC_RIGHTMARGIN, MAKELPARAM(.ScaleX(.FLeftMargin), .ScaleX(.FRightMargin)))
						End If
						.MoveIcons
				End With
			End If
		End Sub
	
	Private Operator SearchBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor SearchBox
		With This
				RegisterClass "SearchBox", "Edit"
				OnHandleIsAllocated = @HandleIsAllocated
				ChildProc = @WndProc
				WLet(FClassAncestor, "Edit")
				FLeftMargin = 20
				FRightMargin = 20
				imgSearch.DoubleBuffered = True
				imgSearch.Designer = @This
				imgSearch.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @imgSearch_Paint)
				imgSearch.Parent = @This
				imgClear.DoubleBuffered = True
				imgClear.Designer = @This
				imgClear.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @imgClear_Paint)
				imgClear.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @imgClear_Click)
				imgClear.Visible = False
				imgClear.Parent = @This
			FHideSelection    = False
			FTabIndex          = -1
			FTabStop           = True
			WLet(FClassName, "SearchBox")
			Child       = @This
			Width       = 121
			Height      = ScaleY(Font.Size / 72 * 96 + 6) '21
		End With
	End Constructor
	
	Private Destructor SearchBox
			DestroyWindow FHandle
	End Destructor
End Namespace

