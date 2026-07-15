'###############################################################################
'#  MsgBoxForm.bas                                                             #
'#  Dark-mode-aware replacement for the native MessageBox                     #
'###############################################################################

#include once "MsgBoxForm.bi"

Namespace My.Sys.Forms
	Private Sub MsgBoxForm.HandleButtonClick(Index As Integer)
		This.ModalResult = FButtonResult(Index)
		This.CloseForm
	End Sub

	Private Static Sub MsgBoxForm.Button0Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(MsgBoxForm Ptr, Sender.Designer)).HandleButtonClick(0)
	End Sub

	Private Static Sub MsgBoxForm.Button1Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(MsgBoxForm Ptr, Sender.Designer)).HandleButtonClick(1)
	End Sub

	Private Static Sub MsgBoxForm.Button2Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(MsgBoxForm Ptr, Sender.Designer)).HandleButtonClick(2)
	End Sub

	Private Static Sub MsgBoxForm.FormPaint_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Dim As MsgBoxForm Ptr Me2 = Cast(MsgBoxForm Ptr, Sender.Designer)
		If Me2->FIcon.Handle Then
			Canvas.Draw(Me2->FIconX, Me2->FIconY, Me2->FIcon)
		End If
	End Sub

	Private Function MsgBoxForm.Execute(ByRef MsgStr As WString, ByRef Caption As WString, Icon As MsgBoxIcon, Buttons As MsgBoxButtons, OwnerForm As Form Ptr = 0) As ModalResults
		This.Caption = Caption

		' The window (and its children) needs to exist before its font/HDC can
		' be used to measure the wrapped message text below - Show/ShowModal
		' create it lazily on first display, which is too late for that.
		If This.Handle = 0 Then This.CreateWnd
		If FMessage.Handle = 0 Then FMessage.CreateWnd

		Select Case Icon
		Case mbxIconInfo:     FIcon.Handle = LoadIconW(0, IDI_INFORMATION)
		Case mbxIconWarning:  FIcon.Handle = LoadIconW(0, IDI_WARNING)
		Case mbxIconQuestion: FIcon.Handle = LoadIconW(0, IDI_QUESTION)
		Case mbxIconError:    FIcon.Handle = LoadIconW(0, IDI_ERROR)
		Case Else:            FIcon.Handle = 0
		End Select
		' GetSystemMetrics is already DPI-correct for a DPI-aware process, so
		' the icon itself is drawn at this size directly (Canvas.Draw does not
		' apply the framework's own ScaleX/ScaleY to icons - see Canvas.bas).
		Dim As Integer iconSizeDevice = GetSystemMetrics(SM_CXICON)
		FIcon.Width = iconSizeDevice
		FIcon.Height = iconSizeDevice

		' Everything below except the DT_CALCRECT measurement is in the same
		' unscaled logical units SetBounds already takes everywhere else in
		' this framework (Move applies ScaleX/ScaleY internally) - mixing in
		' ScaleX() here too would double-scale on any non-100% display.
		Dim As Integer iMargin = 20
		Dim As Integer iIconTextGap = 16
		Dim As Integer iContentWidth = 380
		Dim As Integer iIconSizeLogical = UnScaleX(iconSizeDevice)
		Dim As Integer iTextLeft = IIf(FIcon.Handle <> 0, iMargin + iIconSizeLogical + iIconTextGap, iMargin)
		Dim As Integer iTextWidthLogical = iContentWidth - iTextLeft - iMargin

		FIconX = iMargin
		FIconY = iMargin

		Dim As RECT rcCalc
		rcCalc.Right = ScaleX(iTextWidthLogical)
		Dim As HDC hdcMeasure = GetDC(FMessage.Handle)
		Dim As HFONT hPrevFont = SelectObject(hdcMeasure, Cast(HFONT, SendMessage(FMessage.Handle, WM_GETFONT, 0, 0)))
		DrawTextW(hdcMeasure, @MsgStr, -1, @rcCalc, DT_LEFT Or DT_WORDBREAK Or DT_CALCRECT)
		SelectObject(hdcMeasure, hPrevFont)
		ReleaseDC(FMessage.Handle, hdcMeasure)
		Dim As Integer iTextHeightLogical = UnScaleY(rcCalc.Bottom - rcCalc.Top)

		FMessage.WordWraps = True
		FMessage.Text = MsgStr
		FMessage.SetBounds iTextLeft, iMargin, iTextWidthLogical, iTextHeightLogical

		Dim As Integer iContentBottom = iMargin + Max(iTextHeightLogical, iIconSizeLogical)

		Dim As Integer nBtn, iDefaultIdx, iCancelIdx
		Select Case Buttons
		Case mbxOK
			FButton0.Text = ("OK")     : FButtonResult(0) = ModalResults.OK
			nBtn = 1 : iDefaultIdx = 0 : iCancelIdx = 0
		Case mbxOKCancel
			FButton0.Text = ("OK")     : FButtonResult(0) = ModalResults.OK
			FButton1.Text = ("Cancel") : FButtonResult(1) = ModalResults.Cancel
			nBtn = 2 : iDefaultIdx = 0 : iCancelIdx = 1
		Case mbxYesNo
			FButton0.Text = ("Yes") : FButtonResult(0) = ModalResults.Yes
			FButton1.Text = ("No")  : FButtonResult(1) = ModalResults.No
			nBtn = 2 : iDefaultIdx = 0 : iCancelIdx = 1
		Case mbxYesNoCancel
			FButton0.Text = ("Yes")    : FButtonResult(0) = ModalResults.Yes
			FButton1.Text = ("No")     : FButtonResult(1) = ModalResults.No
			FButton2.Text = ("Cancel") : FButtonResult(2) = ModalResults.Cancel
			nBtn = 3 : iDefaultIdx = 0 : iCancelIdx = 2
		End Select

		FButton0.Visible = (nBtn >= 1)
		FButton1.Visible = (nBtn >= 2)
		FButton2.Visible = (nBtn >= 3)

		Dim As Integer iBtnW = 80, iBtnH = 26, iBtnGap = 8
		Dim As Integer iBtnRowY = iContentBottom + iMargin
		Dim As Integer iRightEdge = iContentWidth - iMargin

		If nBtn >= 3 Then
			FButton2.SetBounds iRightEdge - iBtnW, iBtnRowY, iBtnW, iBtnH
			iRightEdge -= (iBtnW + iBtnGap)
		End If
		If nBtn >= 2 Then
			FButton1.SetBounds iRightEdge - iBtnW, iBtnRowY, iBtnW, iBtnH
			iRightEdge -= (iBtnW + iBtnGap)
		End If
		FButton0.SetBounds iRightEdge - iBtnW, iBtnRowY, iBtnW, iBtnH

		Select Case iDefaultIdx
		Case 0: FButton0.Default = True
		Case 1: FButton1.Default = True
		Case 2: FButton2.Default = True
		End Select

		Select Case iCancelIdx
		Case 0: This.CancelButton = @FButton0
		Case 1: This.CancelButton = @FButton1
		Case 2: This.CancelButton = @FButton2
		End Select

		' +40/+16 approximates the FixedDialog title bar and border chrome
		' that SetBounds' outer Width/Height needs to add on top of the
		' client content computed above.
		This.SetBounds This.Left, This.Top, iContentWidth + 16, iBtnRowY + iBtnH + iMargin + 40

		Dim As Integer iResult
		If OwnerForm Then
			iResult = This.ShowModal(*OwnerForm)
		Else
			This.CenterToScreen
			iResult = This.ShowModal()
		End If
		Return Cast(ModalResults, iResult)
	End Function

	Private Constructor MsgBoxForm
		This.Name = "MsgBoxForm"
		This.Designer = @This
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.OnPaint = @FormPaint_

		FMessage.Parent = @This
		FMessage.Designer = @This

		FButton0.Parent = @This
		FButton0.Designer = @This
		FButton0.OnClick = @Button0Click_

		FButton1.Parent = @This
		FButton1.Designer = @This
		FButton1.OnClick = @Button1Click_

		FButton2.Parent = @This
		FButton2.Designer = @This
		FButton2.OnClick = @Button2Click_
	End Constructor

	Private Destructor MsgBoxForm
	End Destructor
End Namespace
