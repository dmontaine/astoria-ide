' Radar window inspector
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmRadar.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/TextBox.bi"
	
	#include once "win/winuser.bi"
	#include once "win/wingdi.bi"
	
	Using My.Sys.Forms
	
	Type frmRadarType Extends Form
		mhWnd As HWND = 0 'current control handle
		phWnd As HWND = 0 'previous control handle
		
		Declare Sub HighlighthWnd(hWnd As HWND)
		
		Declare Sub ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As ImageBox ImageBox1, ImageBox2
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4, TextBox5
	End Type
	
	Constructor frmRadarType
		'Form1
		With This
			.Name = "frmRadar"
			.Text = "Radar32"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __FB_64BIT__
				.Caption = "Radar64"
			#else
				.Caption = "Radar32"
			#endif
			.Size = Type<My.Sys.Drawing.Size>(340, 170)
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = True
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.SetBounds 0, 0, 350, 370
		End With
		'ImageBox1
		With ImageBox1
			.Name = "ImageBox1"
			.Text = "ImageBox1"
			.BorderStyle = BorderStyles.bsNone
			.Hint = "Drag me to a control"
			.BackColor = 8421504
			.SetBounds 10, 10, 40, 40
			.Designer = @This
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @ImageBox1_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @ImageBox1_MouseMove)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @ImageBox1_MouseUp)
			.Parent = @This
		End With
		'TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Hint = "Handle"
			.SetBounds 60, 10, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = ""
			.TabIndex = 1
			.Hint = "Mouse position"
			.SetBounds 200, 10, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = ""
			.TabIndex = 2
			.Hint = "Window RECT"
			.SetBounds 60, 40, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = ""
			.TabIndex = 3
			.Hint = "Class name"
			.SetBounds 200, 40, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox5
		With TextBox5
			.Name = "TextBox5"
			.Text = ""
			.TabIndex = 4
			.Hint = "Window text"
			.Multiline = True
			.ID = 1214
			.ScrollBars = ScrollBarsType.Vertical
			.SetBounds 10, 70, 320, 60
			.Designer = @This
			.Parent = @This
		End With
		' ImageBox2
		With ImageBox2
			.Name = "ImageBox2"
			.Text = "ImageBox2"
			.BackColor = 12632256
			.SetBounds 10, 140, 320, 190
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmRadar As frmRadarType
	
	#if _MAIN_FILE_ = __FILE__
		frmRadar.MainForm = True
		frmRadar.Show
		App.Run
	#endif
'#End Region

'Get control position and size
Private Function ObjectRect2Str(hWnd As HWND) As String
	Dim lRT As Rect
	GetWindowRect(hWnd, @lRT)
	Return lRT.Left & ", " & lRT.Right & ", " & lRT.Top & ", " & lRT.Bottom
End Function

'Control screenshot
Private Sub ObjectScreenShot(hWndObj As HWND, hWndImg As HWND)
	Dim hDC As HDC
	hDC = GetWindowDC(hWndImg)
	PrintWindow(hWndObj, hDC, PW_CLIENTONLY)
	ReleaseDC(hWndImg, hDC)
End Sub

'Control highlight
Private Sub ObjectHighlight(hWnd As HWND, mColor As Long)
	Dim lhDC As HDC
	Dim lPen As HPEN
	Dim lRT As Rect

	'Get control rectangle
	GetWindowRect(hWnd, @lRT)
	'Get control DC
	lhDC = GetWindowDC(hWnd)

	SetROP2 lhDC, R2_NOT                             'Set DC color, for use when removing later

	'Create pen
	lPen = CreatePen(0, 5 * GetSystemMetrics(SM_CXBORDER), &Hff000000 + mColor)

	'Highlight control border
	SaveDC(lhDC)                                     'Save pen and brush
	SelectObject(lhDC, lPen)                         'Set new pen
	SelectObject(lhDC, GetStockObject(NULL_BRUSH))   'Set null brush, background unchanged

	'Draw control border
	Rectangle lhDC, 0, 0, lRT.Right - lRT.Left, lRT.Bottom - lRT.Top

	'Restore DC
	RestoreDC(lhDC, -1)                              '-1 restores previous content

	'Release
	ReleaseDC hWnd, lhDC
	DeleteObject lPen
End Sub

Private Sub frmRadarType.HighlighthWnd(hWnd As HWND)
	If phWnd <> 0 Then
		'Restore previous control
		ObjectHighlight(phWnd, RGB(&h80, &h80, &h80))
	End If
	If hWnd <> 0 Then
		'Highlight current control
		ObjectHighlight(hWnd, RGB(&h80, &h80, &h80))
	End If
	
	'If phWnd = hWnd Then
	'	phWnd = 0
	'Else
		phWnd = hWnd
	'End If
End Sub

Private Sub frmRadarType.ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	SetCapture(ImageBox1.Handle)
	ImageBox1.BackColor = &h0000ff
	ImageBox1_MouseMove(Sender, MouseButton, x, y, Shift)
End Sub

Private Sub frmRadarType.ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If GetCapture() = 0 Then Exit Sub
	Dim hWnd As HWND = 0
	Dim p As tagPOINT
	Dim s As WString Ptr
	Dim l As Long = 255
	
	'Get mouse coordinates
	GetCursorPos(@p)
	TextBox2.Text = p.x & ", " & p.y

	'Get control handle at coordinates
	hWnd = WindowFromPoint(p)

	'Exit if the control hasn't changed
	If hWnd = mhWnd Or hWnd = 0 Then Exit Sub

	'Highlight the control
	HighlighthWnd(hWnd)

	'Display control handle
	TextBox1.Text = hWnd & " (&H" &  Hex(hWnd) & ")"
	'Display control position and size
	TextBox3.Text = ObjectRect2Str(hWnd)

	'Display control class name
	s = CAllocate(l * 2 + 2)
	GetClassName(hWnd, s, l)
	TextBox4.Text = *s

	'Display control text
	l = GetWindowTextLength(hWnd) + 1
	s = Reallocate(s, l * 2 + 2)
	GetWindowText(hWnd, s, l)
	TextBox5.Text = *s
	Deallocate(s)

	'Display control screenshot
	ObjectScreenShot(hWnd, ImageBox2.Handle)
	
	mhWnd = hWnd
End Sub

Private Sub frmRadarType.ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If GetCapture() = 0 Then Exit Sub
	HighlighthWnd(0)
	ImageBox1.BackColor = &h808080
	ReleaseCapture()
	'InvalidateRect(0, 0, True)
End Sub
