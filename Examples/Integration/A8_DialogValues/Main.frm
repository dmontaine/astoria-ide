'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#cmdline "Main.rc"
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Dialogs.bi"
	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Sub Dialog_Click(ByRef Sender As Control)
		Declare Sub RecordResult(ByRef TestName As String, ByVal Passed As Boolean, ByRef Detail As WString)
		Dim As CommandButton cmdOpen, cmdSave, cmdColor, cmdFont
		Dim As Label lblInstructions, lblStatus, lblPreview
		Dim As OpenFileDialog dlgOpen
		Dim As SaveFileDialog dlgSave
		Dim As ColorDialog dlgColor
		Dim As FontDialog dlgFont
		Dim As Integer CompletedCount
	End Type

	Constructor MainType
		With This
			.Name = "Main" : .Text = "TestPlan A8 - Dialog Return Values"
			.Designer = @This : .SetBounds 0, 0, 680, 350
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblInstructions
			.Name = "lblInstructions"
			.Text = "Complete each dialog. Open: choose open-target.txt. Save: keep A8-selected.txt. Color: choose a non-black color. Font: change family, size, or style."
			.SetBounds 18, 18, 630, 44 : .Parent = @This
		End With
		With cmdOpen
			.Name = "cmdOpen" : .Text = "1. Open File..." : .SetBounds 18, 76, 145, 34 : .Designer = @This : .Parent = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Dialog_Click)
		End With
		With cmdSave
			.Name = "cmdSave" : .Text = "2. Save File..." : .SetBounds 178, 76, 145, 34 : .Designer = @This : .Parent = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Dialog_Click)
		End With
		With cmdColor
			.Name = "cmdColor" : .Text = "3. Color..." : .SetBounds 338, 76, 145, 34 : .Designer = @This : .Parent = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Dialog_Click)
		End With
		With cmdFont
			.Name = "cmdFont" : .Text = "4. Font..." : .SetBounds 498, 76, 145, 34 : .Designer = @This : .Parent = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Dialog_Click)
		End With
		With lblPreview
			.Name = "lblPreview" : .Text = "Selected color and font preview"
			.SetBounds 18, 132, 625, 72 : .BackColor = 0 : .ForeColor = &HFFFFFF : .Parent = @This
		End With
		With lblStatus
			.Name = "lblStatus" : .Text = "Results: 0/4 completed" : .SetBounds 18, 220, 625, 70 : .Parent = @This
		End With
		With dlgOpen
			.Name = "dlgOpen" : .Caption = "A8 Open File - select open-target.txt"
			.InitialDir = ExePath : .FileName = ExePath & "\open-target.txt" : .Filter = "Text files|*.txt|All files|*.*|"
			.Designer = @This : .Parent = @This
		End With
		With dlgSave
			.Name = "dlgSave" : .Caption = "A8 Save File - keep A8-selected.txt"
			.InitialDir = ExePath : .FileName = ExePath & "\A8-selected.txt"
			.Filter = "Text files|*.txt|All files|*.*|" : .DefaultExt = "txt"
			.Designer = @This : .Parent = @This
		End With
		dlgColor.Designer = @This : dlgColor.Parent = @This
		dlgColor.Caption = "A8 Color - choose any non-black color" : dlgColor.Color = 0
		dlgFont.Designer = @This : dlgFont.Parent = @This
		dlgFont.Font.Name = "Arial" : dlgFont.Font.Size = 10
	End Constructor

	Dim Shared Main As MainType
	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True : Main.Show : App.Run
	#endif
'#End Region

Private Sub MainType.RecordResult(ByRef TestName As String, ByVal Passed As Boolean, ByRef Detail As WString)
	Dim As Integer fn = FreeFile
	Open ExePath & "\A8-results.txt" For Append As #fn
	Print #fn, TestName & "=" & IIf(Passed, "PASS", "FAIL") & " | " & Detail
	Close #fn
	CompletedCount += 1
	lblStatus.Text = "Results: " & CompletedCount & "/4 completed" & Chr(13, 10) & TestName & ": " & IIf(Passed, "PASS", "FAIL") & " - " & Detail
	If CompletedCount = 4 Then lblStatus.Text &= Chr(13, 10) & "A8 complete. Close this window."
End Sub

Private Sub MainType.Dialog_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdOpen"
		If dlgOpen.Execute Then
			Dim As Boolean openOk = (Right(LCase(dlgOpen.FileName), Len("open-target.txt")) = "open-target.txt")
			RecordResult "OpenFile", openOk, dlgOpen.FileName
		Else
			RecordResult "OpenFile", False, "cancelled"
		End If
	Case "cmdSave"
		If dlgSave.Execute Then
			Dim As Boolean saveOk = (Right(LCase(dlgSave.FileName), Len("a8-selected.txt")) = "a8-selected.txt")
			RecordResult "SaveFile", saveOk, dlgSave.FileName
		Else
			RecordResult "SaveFile", False, "cancelled"
		End If
	Case "cmdColor"
		If dlgColor.Execute Then
			lblPreview.BackColor = dlgColor.Color
			RecordResult "Color", (dlgColor.Color <> 0), "Color=" & Str(dlgColor.Color)
		Else
			RecordResult "Color", False, "cancelled"
		End If
	Case "cmdFont"
		If dlgFont.Execute Then
			lblPreview.Font.Name = dlgFont.Font.Name : lblPreview.Font.Size = dlgFont.Font.Size
			lblPreview.Font.Bold = dlgFont.Font.Bold : lblPreview.Font.Italic = dlgFont.Font.Italic
			Dim As Boolean fontOk = (CBool(LCase(dlgFont.Font.Name) <> "arial") OrElse CBool(dlgFont.Font.Size <> 10) OrElse CBool(dlgFont.Font.Bold) OrElse CBool(dlgFont.Font.Italic))
			RecordResult "Font", fontOk, dlgFont.Font.Name & " " & Str(dlgFont.Font.Size) & "pt bold=" & Str(dlgFont.Font.Bold) & " italic=" & Str(dlgFont.Font.Italic)
		Else
			RecordResult "Font", False, "cancelled"
		End If
	End Select
End Sub
