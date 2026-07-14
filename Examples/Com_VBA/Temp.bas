'################################################################################
'#  Com_HtmlFile.frm                                                            #
'#  This file is an examples of MyFBFramework.                                  #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################

'A FreeBasic module that generates including files (not dependent on libraries) on the fly can be used to write  the code normally according to the COM and VBA syntax. Before compiling the code
'Click On COMWrapperBuilder in the Menu "Settings" To automatically generate a reference header FILE that calls Com. Add "#include once 'Com_xxx.bi" in the code including area.

'A FreeBasic module that generates an including file on the fly (not dependent on libraries), for calling COM; you can write the code normally according to COM and VBA syntax. Before compiling the code,
'click COMWrapperBuilder in the "Settings" menu to automatically generate a reference header file that calls COM. Add "#include once "Com_xxx.bi"" in the code-including area.


'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "Com_Msxml2.bi"
	#include once "Com_HTMLFILE.bi"
	#include once "Com_Excel.bi"
	#include once "Com_Word.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub cmdJson_Click(ByRef Sender As Control)
		Declare Sub cmdJson2_Click(ByRef Sender As Control)
		Declare Sub cmdShow2_Click(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub cmdExcel_Click(ByRef Sender As Control)
		Declare Sub cmdWord_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdJson, cmdExcel, cmdJson2, cmdJson3, cmdShow2, cmdWord
		Dim As TextBox TextBox1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.SetBounds 0, 0, 350, 300
		End With
		' cmdJson
		With cmdJson
			.Name = "cmdJson"
			.Text = "Json"
			.TabIndex = 0
			.SetBounds 10, 10, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson_Click)
			.Parent = @This
		End With
		' cmdExcel
		With cmdExcel
			.Name = "cmdExcel"
			.Text = "Excel"
			.TabIndex = 1
			.ControlIndex = 0
			.SetBounds 204, 14, 60, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExcel_Click)
			.Parent = @This
		End With
		' cmdJson2
		With cmdJson2
			.Name = "cmdJson2"
			.Text = "cmdJson"
			.TabIndex = 2
			.ControlIndex = 1
			.SetBounds 13, 43, 60, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdJson3
		With cmdJson3
			.Name = "cmdJson3"
			.Text = "HtmlFile"
			.TabIndex = 3
			.ControlIndex = 2
			.Caption = "HtmlFile"
			.SetBounds 76, 10, 48, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson2_Click)
			.Parent = @This
		End With
		' cmdShow2
		With cmdShow2
			.Name = "cmdShow2"
			.Text = "ShowForm2"
			.TabIndex = 4
			.ControlIndex = 3
			.SetBounds 130, 10, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdShow2_Click)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 4
			.ControlIndex = 4
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 10, 70, 320, 180
			.Designer = @This
			.Parent = @This
		End With
		' cmdWord
		With cmdWord
			.Name = "cmdWord"
			.Text = "Word"
			.TabIndex = 6
			.ControlIndex = 1
			.Caption = "Word"
			.SetBounds 272, 15, 60, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdWord_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Sub Form1Type.cmdJson_Click(ByRef Sender As Control)
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE") '2323
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	oWindow.execScript("var d=new Date() ; t=d.getTime()")
	Dim As String t = oWindow. eval( "t")
	Print "from 1970/01/01 time has passed " & t & "mi11iseconds"
	Print "-------------------------------------------------------"
	
	Dim json As String = "{'a':1,'b':[2,3]}"
	oWindow.execScript("var js=" & json)
	Print oWindow.eval("js['b'] [1]")
End Sub

Private Sub Form1Type.cmdJson2_Click(ByRef Sender As Control)
	'https://cloud.tencent.com/developer/ask/sof/359206
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE") '2323
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	Dim As Object_Msxml2 oHttp = CreateObject("Msxml2.XMLHTTP")
	oHttp.Open "GET", "https://www.marketscreener.com/COLUMBIA-SPORTSWEAR-COMPA-8859/company/", False
	oHttp.send
	Dim As String strHtml = oHttp.responseText ' get the data
	'Window.clipboardData.SetData "text", strHtml 'write to clipboard
	'Dim As Object_Msxml2 oName = oDom.getElementsByTagName("table")
	'Print oName(0).innerHTML
	'oWindow.execScript "var js= " & strHtml  ' rewrite as an object-creation statement
	'Dim As vbVariant kuwo = oWindow.js ' get the parsed object
	TextBox1.Text = strHtml  'kuwo.view
End Sub
#include once "Com_HtmlFile2.frm"
Private Sub Form1Type.cmdShow2_Click(ByRef Sender As Control)
	Form2.Show
End Sub

Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	
End Sub

Private Sub Form1Type.cmdExcel_Click(ByRef Sender As Control)
	
	Dim As Object_Excel xlApp = CreateObject("Excel.Application")
	xlApp.Workbooks.Open(ExePath & "\com_Excel.xlsx") 'open the existing Excel workbook file
	xlApp.Visible = True
	Dim As Object_Excel CellValue 
	Dim As Object_Excel xlSheet = xlApp.Worksheets(2)
	Dim As Object_Excel xlSheet1 = xlApp.Worksheets(1)
	'Dim xlSheet As vbVariant = xlApp.ActiveSheet
	xlSheet1.Range("A1").Value = "Sheet115.3434353535" 'assign value to cell A1
	xlSheet1.Range("A2").Value = 8.676843553454353453453454 'assign value to cell A2
	xlSheet1.Range("A3").Value = 16.3243243242344 'assign value to cell A3
	xlSheet1.Range("A4").Value = 7.322434324234 'assign value to cell A4

	xlApp.Range("B1").Value = 2.121213124324324 'assign value to cell B1
	xlApp.Range("B2").Value = 3.23131231243 'assign value to cell B2
	xlApp.Range("B3").Value = 4.324234234324 'assign value to cell B3
	xlApp.Range("B4").Value = 5.324324324324324324 'assign value to cell B4

	'uppercase to lowercase
	With xlSheet.Range("A1") 'let's operate from the TopLeft-cell
		Dim SArr(0 To 2) As String = {"Hello", "COM-calls", "from FB"}
		'Dim SArr(1 To 2) As String = {{"11111", "22222", "33333"}, {"44444", "55555", "66666"}}
		For iRow As Integer = 0 To UBound(SArr, iRow)
			For iCol As Integer = 0 To UBound(SArr, iRow)
				xlSheet.Range("A1").Offset(0, iCol).Value = SArr(iCol)
			Next
		Next
		CellValue = xlApp.Range("B5").Value & Chr(13)  & Chr(10) & xlApp.Range("B6").Value '.Offset(6, 0).Value '<- should return "COM-calls"
		Print CellValue
		'CellValue = .Resize("3", "3").Value
		'Print CellValue
	End With '<- at this point, the above instantiated A1-Range-Object will be destroyed implicitly
	MsgBox Str(CellValue) '... now show the CellValue we have retrieved (should contain "COM-calls") ...
	xlApp.Save(ExePath & "\com_Excel_bak.xlsx")  'save the existing Excel workbook file
	xlSheet.Parent.Saved = True 'let's suppress the "Save Document" Dialogue ...
	xlSheet.Clear '... and destroy the Sheet-Object with the appropriate vbVariant.Method ...
	Sleep(1000)
	xlApp.Quit
End Sub

Private Sub Form1Type.cmdWord_Click(ByRef Sender As Control)
' create the Word application's COM object
Dim As Object_Word wordApp = CreateObject("Word.Application")
' set visibility
wordApp.Visible = True
Dim As Object_Word doc
' create a new document
doc = wordApp.Documents.ADD

' enter text into the document
doc.Content.Text = "Hello from FreeBASIC!"
MsgBox "Save the file and quit?"
' save and close the document (path must be specified here)
doc.SaveAs(ExePath & "\example.docx")
doc.Close()
' quit the Word application
wordApp.Quit()

End Sub
