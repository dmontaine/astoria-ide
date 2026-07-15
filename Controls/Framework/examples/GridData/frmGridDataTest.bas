#ifdef __FB_WIN32__
	' #Compile "GridDataTest.rc"
#endif
' #########################################################
' # frmGridDataTest.bas #
' # Authors: Liu ZiQI (2019) #
' #########################################################
' #Define __USE_GTK__
#define GetMN
On Error Goto ErrorQ
#include "vbcompat.bi"
#include once "mff/SysUtils.bi"
#include once "SQLITE3_UTILITY.inc"
#include once "mff/Panel.bi"
#include once "mff/Splitter.bi"

Dim Shared SQLiteDB As sqlite3 Ptr
If SQLiteOpen(SQLiteDB, ExePath & "\Data\Test.db", "") Then
	Print "OPEN SQLiteDB Failure." + Chr(13,10)+SQLiteErrMsg(SQLiteDB)
Else
	Print "Opened SQLiteDB successfully.", ExePath & "\Data\Test.db"
End If
#define _NOT_AUTORUN_FORMS_
#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/Splitter.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CommandButton.bi"
#include once "mff/GroupBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TreeView.bi"

' GRIDDATA
#include once "mff/GridData.bi"
#include once "mff/Picture.bi"
#include once "mff/IniFile.bi"

Using My.Sys.Forms
' Dim Shared As Form frmGridDataTest
' #Region "Form"
	Type frmGridDataTest Extends Form
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Action As Integer)
		Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		
		' GRID DATA
		Declare Static Sub MSHFGridCont_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGridCont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGridCont_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
		Declare Static Sub MSHFGridCont_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		Declare Static Sub MSHFGridCont_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGridCont_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, tGridDCC As HDC)
		#endif
		Declare Static Sub MSHFGridCont_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer,Shift As Integer)
		Declare Static Sub MSHFGridCont_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
		Declare Static Sub MSHFGridCont_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGridCont_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		
		' GRID DATA
		Declare Static Sub MSHFGrid_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGrid_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGrid_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
		Declare Static Sub MSHFGrid_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		Declare Static Sub MSHFGrid_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGrid_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGrid_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGrid_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
		Declare Static Sub MSHFGrid_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGrid_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub Frame_Sql_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As GroupBox)
		Declare Sub Frame_Sql_Click(ByRef Sender As GroupBox)
		Declare Static Sub _cmdRefrshDataBase_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRefrshDataBase_Click(ByRef Sender As Control)
		Declare Function DataBindingCombo(ByRef tControl As ComboBoxEdit, db As sqlite3 Ptr, sSql As ZString Ptr, AddHeader As Boolean = True) As Integer
		Declare Function DataBindingGrid(ByRef tControl As GridData, db As sqlite3 Ptr, sSql As ZString Ptr, AddHeader As Boolean = True) As Integer
		Declare Constructor

		Dim As GroupBox Frame_Sql
		Dim As TreeView TreeView1

		Dim As ComboBoxEdit cboServer
		Dim As CommandButton cmdFindServer
		Dim As CommandButton cmdRefrshDataBase
		Dim As TextBox txtPWD
		Dim As ComboBoxEdit TxtID
		Dim As ComboBoxEdit cboSource
		Dim As RadioButton Option_DB
		Dim As GridData MSHFGrid, MSHFGridCont
		Dim As ImageList imgListGrid1
		
		Dim As Label Label1
		Dim As Label Label2
		Dim As Picture Image_Toolbar
		Dim As Panel Panel1, Panel2
		Dim As Splitter Splitter1, Splitter2
	End Type
	
	Constructor frmGridDataTest
		
		' Form Property
		This.Name = "frmGridDataTest"
		This.Text = "GridDataTest"
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
		This.OnShow = @Form_Show
		This.OnResize = @Form_Resize
		This.MinimizeBox = True
		This.MaximizeBox = True
		This.SetBounds 0, 0, 800, 500
		This.CenterToScreen
		This.Caption = "GridDataTest"
		This.BorderStyle = FormBorderStyle.Sizable 'FixedDialog
		
		TreeView1.Name = "TreeView1"
		TreeView1.Text = "ListView_Offset_Save"
		TreeView1.Align = DockStyle.alLeft
		TreeView1.ExtraMargins.Top = 10
		TreeView1.ExtraMargins.Right = 0
		TreeView1.ExtraMargins.Bottom = 10
		TreeView1.ExtraMargins.Left = 10
		TreeView1.SetBounds 10, 10, 270, 441
		TreeView1.BackColor = -1
		TreeView1.ID = 1001
		TreeView1.Parent = @This
		' Splitter2
		With Splitter2
			.Name = "Splitter2"
			.Text = "Splitter2"
			.SetBounds 290, 0, 10, 461
			.Designer = @This
			.Parent = @This
		End With
		Frame_Sql.Name = "Frame_Sql"
		Frame_Sql.Align = DockStyle.alClient
		Frame_Sql.ExtraMargins.Top = 10
		Frame_Sql.ExtraMargins.Right = 10
		Frame_Sql.ExtraMargins.Bottom = 10
		Frame_Sql.SetBounds 270, 0, 794, 761
		Frame_Sql.Designer = @This
		Frame_Sql.OnClick = @Frame_Sql_Click_
		Frame_Sql.Parent = @This
		
		cboServer.Name = "cboServer"
		cboServer.Text = "YOGA2\SQLEXPRESS"
		cboServer.AddItem "YOGA2\SQLEXPRESS"
		cboServer.AddItem "local"
		cboServer.BackColor = clWhite
		cboServer.SetBounds 16, 16, 94, 21
		cboServer.Parent = @Panel1
		
		cboSource.Name = "cboSource"
		cboSource.Text = "YOGA2\SQLEXPRESS"
		cboSource.AddItem "YOGA2\SQLEXPRESS"
		cboSource.AddItem "local"
		cboSource.BackColor = clWhite
		cboSource.SetBounds 120, 16, 94, 21
		cboSource.Parent = @Panel1
		
		
		cmdFindServer.Name = "cmdFindServer"
		cmdFindServer.Text = "..."
		cmdFindServer.BackColor = clWhite
		cmdFindServer.SetBounds 225, 16, 30, 25
		cmdFindServer.Parent = @Panel1
		
		cmdRefrshDataBase.Name = "cmdRefrshDataBase"
		cmdRefrshDataBase.Text = "Refresh DataBase"
		cmdRefrshDataBase.BackColor = clWhite
		cmdRefrshDataBase.SetBounds 260, 16, 121, 25
		cmdRefrshDataBase.Designer = @This
		cmdRefrshDataBase.OnClick = @_cmdRefrshDataBase_Click
		cmdRefrshDataBase.Parent = @Panel1
		
		txtPWD.Name = "txtPWD"
		txtPWD.Text = "dtquser"
		txtPWD.SetBounds 232, 75, 72, 25
		txtPWD.Parent = @Panel1
		
		TxtID.Name = "TxtID"
		TxtID.Text = "Combo1"
		TxtID.SetBounds 56, 75, 80, 21
		TxtID.Parent = @Panel1
		
		Label1.Name = "Label1"
		Label1.Text = "ID:"
		Label1.SetBounds 24, 75, 22, 22
		Label1.Parent = @Panel1
		
		Label2.Name = "Label2"
		Label2.Text ="Password:"
		Label2.SetBounds 150, 75, 80, 22
		Label2.Parent = @Panel1
		
		Option_DB.Name = "Option_DB"
		Option_DB.Text = "Show DataBase"
		Option_DB.SetBounds 24, 48, 101, 22
		Option_DB.Parent = @Panel1
		
		imgListGrid1.Height=16 'Change the Height of Body
		imgListGrid1.Width=16
		imgListGrid1.Add "Grid", "Grid"
		imgListGrid1.Add "New", "New"
		imgListGrid1.Add "Open", "Open"
		imgListGrid1.Add "Save", "Save"
		
		MSHFGrid.SetBounds 10, 150, 150, 250
		MSHFGrid.StateImages =@imgListGrid1             ' @imgList
		MSHFGrid.SmallImages =@imgListGrid1             '@imgList
		MSHFGrid.RowHeight = 20
		MSHFGrid.Align = DockStyle.alLeft
		MSHFGrid.Parent = @Panel2 ' @This
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.SetBounds 0, 0, 10, 291
			.Designer = @This
			.Parent = @Panel2
		End With
		
		MSHFGridCont.SetBounds 170, 150, 760, 250
		MSHFGridCont.StateImages =@imgListGrid1             ' @imgList
		MSHFGridCont.SmallImages =@imgListGrid1             '@imgList
		MSHFGridCont.RowHeight = 40
		MSHFGridCont.Align = DockStyle.alClient
		MSHFGridCont.Parent = @Panel2 ' @This
		
		
		MSHFGridCont.Init
		Dim As WString Ptr ComboEditItem
		WLet ComboEditItem, "True"+Chr(9)+"False" +Chr(9)+"121313"+Chr(9)+"321232"
		MSHFGridCont.Columns.Add  "NO ", 0, 35, cfCenter, DT_Numeric, False, , , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "1TH", 0, 100, cfLeft, DT_Numeric, False, CT_TextBox, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "2nd", 0, 100, cfRight, DT_Numeric, False, CT_LinkLabel, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "3RD", 0, 100, cfCenter, DT_Numeric, False, CT_Button, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Value", 0, 70, cfCenter, True, False, CT_ComboBoxEdit, *ComboEditItem, SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "5TH", 0, 100, cfCenter, True, False, CT_CheckBox, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "6TH", 0, 100, cfCenter, DT_Numeric, False, CT_ProgressBar, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "7TH", 0, 100, cfCenter, DT_Date, False, CT_DateTimePicker, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "8TH", 0, 100, cfCenter, True, False, CT_TextBox, , SortStyle.ssSortAscending
		
		Dim ItemsCount As Integer
		For ii As Integer  =0 To 30
			MSHFGridCont.ListItems.Add  "1",0,1
			ItemsCount=MSHFGridCont.ListItems.Count - 1
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(0) =Right(Str(ii+1),5)
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(1) =Format(Rnd(1)*10000,"#0.00")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(2) =Format(Rnd(1)*10000,"#0.00")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(3) =Format(Rnd(1)*10000,"#0.00")+WChr(13,10)+"汇总值"
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(4) =IIf( ii Mod 2,"True","False")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(5) =IIf(ii Mod 2,WChr(30),"1234567890"+WChr(13,10)+"汇总值"+WChr(31))
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(6) =Format(Rnd(1)*100,"#0")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(7) =Format(Rnd(1)*10000,"yyyy/mm/dd")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(8) ="汇总值"+Right("00000"+Str(ii),5)+WChr(13,10)+"总汇值FF"+WChr(13,10)+"值汇总"+Right("00000000"+Str(ii),5)
			
		Next
		MSHFGridCont.OnEndScroll = @MSHFGridCont_EndScroll
		MSHFGridCont.OnResize = @MSHFGridCont_Resize
		MSHFGridCont.OnKeyDown = @MSHFGridCont_KeyDown
		#ifdef __USE_WINAPI__
			MSHFGridCont.OnItemClick=@MSHFGridCont_Click
			MSHFGridCont.OnItemDblClick = @MSHFGridCont_DblClick
		#endif
		MSHFGridCont.OnHeadClick=@MSHFGridCont_OnHeadClick
		MSHFGridCont.OnHeadColWidthAdjust=@MSHFGridCont_OnHeadColWidthAdjust
		MSHFGrid.OnEndScroll = @MSHFGrid_EndScroll
		MSHFGrid.OnResize = @MSHFGrid_Resize
		MSHFGrid.OnKeyDown = @MSHFGridCont_KeyDown
		#ifdef __USE_WINAPI__
			MSHFGrid.OnItemClick = @MSHFGrid_Click
		#endif
		MSHFGrid.OnHeadClick=@MSHFGrid_OnHeadClick
		MSHFGrid.OnHeadColWidthAdjust=@MSHFGrid_OnHeadColWidthAdjust
		
		
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		Image_Toolbar.SetBounds 72, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text ="ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		Image_Toolbar.SetBounds 56, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		Image_Toolbar.SetBounds 90, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		Image_Toolbar.SetBounds 32, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 12
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 20
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 140, -80, 464, 110
			.Designer = @This
			.Parent = @Frame_Sql
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 13
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.Align = DockStyle.alClient
			.SetBounds 50, 160, 464, 291
			.Designer = @This
			.Parent = @Frame_Sql
		End With
	End Constructor
	
	Private Sub frmGridDataTest._cmdRefrshDataBase_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmGridDataTest Ptr, Sender.Designer)).cmdRefrshDataBase_Click(Sender)
	End Sub
	
	Private Sub frmGridDataTest.Frame_Sql_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As GroupBox)
		(*Cast(frmGridDataTest Ptr, Sender.Designer)).Frame_Sql_Click(Sender)
	End Sub
	
	Dim Shared fGridDataTest As frmGridDataTest
	
	' #IfnDef _NOT_AUTORUN_FORMS_
	fGridDataTest.Show
	App.Run
	' #EndIf
' #End Region

Private Sub frmGridDataTest.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub
Private Sub frmGridDataTest.Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Action As Integer)
	Print "frmGridDataTest.Form_Close"
	SQLiteClose(SQLiteDB)
	End
End Sub

Private Sub frmGridDataTest.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fGridDataTest.CenterToScreen
	Dim As String sSql="SELECT NAME FROM sqlite_master WHERE type='table' ORDER BY name" 'performs a (short) Table- and Index-Analysis, for better optimized queries
	fGridDataTest.MSHFGrid.Init
	fGridDataTest.MSHFGrid.Columns.Add "NO ", 0, 35, cfCenter, False, False, DT_String, , SortStyle.ssSortAscending
	fGridDataTest.MSHFGrid.Columns.Add "Table" + WChr(13, 10) + "Name", 0, 130, cfLeft, True, False, CT_TextBox, , SortStyle.ssSortAscending
	
End Sub

Private Sub frmGridDataTest.Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
End Sub

Private Sub frmGridDataTest.Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub

Private Sub frmGridDataTest.CommandButton1_Click(ByRef Sender As Control)
	Cast(frmGridDataTest Ptr, Sender.Parent)->CloseForm
End Sub

Private Sub frmGridDataTest.CommandButton2_Click(ByRef Sender As Control)
	Cast(frmGridDataTest Ptr, Sender.Parent)->CloseForm
End Sub
' ########################################################################################
' GRID CODE

Sub frmGridDataTest.MSHFGridCont_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As My.Sys.Drawing.Rect lpRect
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGridCont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		If ColIndex<=0 Then
		End If
		
		Dim As Rect lpRect
		
		#ifndef __USE_GTK__
		#endif
		
	End Sub
#endif

Sub frmGridDataTest.MSHFGridCont_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
End Sub

Sub frmGridDataTest.MSHFGridCont_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
End Sub

Sub frmGridDataTest.MSHFGridCont_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	#ifndef __USE_GTK__
		Dim As Rect lpRect
	#endif
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGridCont_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, tGridDCC As HDC)
		
	End Sub
#endif

Sub frmGridDataTest.MSHFGridCont_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		If Key = VK_RETURN Then
			
		End If
	#endif
	
End Sub

Sub frmGridDataTest.MSHFGridCont_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_RETURN
		Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
		End Select
	#endif
End Sub

Sub frmGridDataTest.MSHFGridCont_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	
End Sub
Sub frmGridDataTest.MSHFGridCont_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer tWidth = Sender.Width - 22
End Sub



' GRID DATA CODE
' ########################################################################################

' #######################################################################################
' GRIDDATA
Sub frmGridDataTest.MSHFGrid_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGrid_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		
	End Sub
#endif

Sub frmGridDataTest.MSHFGrid_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
	Print "ItemActivate Item->Text(1)" + Item->Text(1)
End Sub

Sub frmGridDataTest.MSHFGrid_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
End Sub

Sub frmGridDataTest.MSHFGrid_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	#ifndef __USE_GTK__
		Dim As Rect lpRect
	#endif
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGrid_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		Static As Boolean DataReading
		If ColIndex<=0 Or RowIndex<0  Then Exit Sub
		If DataReading=True Then Exit Sub
		DataReading=True
		Dim As Rect lpRect
		Dim As GridDataItem Ptr Item = fGridDataTest.MSHFGrid.ListItems.Item(RowIndex)
		fGridDataTest.MSHFGridCont.Init
		Dim As String sSql="SELECT * FROM "+Item->Text(ColIndex)+";"
		Dim As Long ItemRows
		If ItemRows<=0 Then
			Print "OPEN DataBase Records Failure."+ Chr(13,10)+ sSql
		Else
		End If
		DataReading=False
		#ifndef __USE_GTK__
		#endif
	End Sub
#endif

Sub frmGridDataTest.MSHFGrid_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		If Key = VK_RETURN Then
			
		End If
	#endif
	
End Sub

Sub frmGridDataTest.MSHFGrid_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_RETURN
		Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
		End Select
	#endif
End Sub

Sub frmGridDataTest.MSHFGrid_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
End Sub
Sub frmGridDataTest.MSHFGrid_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer tWidth = Sender.Width - 22
End Sub



' GRID DATA CODE
' ########################################################################################

Function frmGridDataTest.DataBindingCombo(ByRef tControl As ComboBoxEdit, db As sqlite3 Ptr,sSql As ZString Ptr,AddHeader As Boolean=True) As Integer
' https://www.cnblogs.com/hbtmwangjin/p/7941403.html
	Dim As Integer i,j
	Dim lpTable    As ZString Ptr Ptr ' Pointer to array for given table (from column names)
	Dim nRows      As Long=0         ' Number of rows in result set
	Dim nColumns   As Long=0         ' Number of columns in result set
	Dim lpErrorSz  As ZString Ptr         ' Error message
	Dim iFields    As Long=0         ' Number of fields returned for table
	Dim iRow       As Long=0
	Dim iCol       As Long=0
	Dim iResult    As Long         ' Row count or error code returned by this function

	#ifdef __USE_WINAPI__
		Dim As HCURSOR hCurSave = GetCursor()
		SetCursor(LoadCursor(0, IDC_WAIT))
	#endif
	If sqlite3_get_table(db, sSql, @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then ' Success
		If nRows = 0 OrElse nColumns<1  Then
			sqlite3_free_table lpTable  ' Free char** query result regardless of success
			lpTable=0
			Return  -1
		End If
		If AddHeader Then
		End If
		iFields = ((nRows+1) * nColumns)-1
		For i = nColumns To iFields
			iCol +=1
			If iCol = nColumns Then iCol = 0
			If ((i) Mod nColumns = 0) AndAlso i<iFields Then
				iRow +=1
				tControl.AddItem *lpTable[i]
			End If
		Next
	Else
		iResult = -1
		sqlite3_free_table lpTable  ' Free char** query result regardless of success
		lpTable=0
		Return  -1
	End If
	sqlite3_free_table lpTable  ' Free char** query result regardless of success
	lpTable=0
	Return  nRows
End Function

Function frmGridDataTest.DataBindingGrid(ByRef tControl As GridData, db As sqlite3 Ptr,sSql As ZString Ptr,AddHeader As Boolean=True) As Integer
	' https://www.cnblogs.com/hbtmwangjin/p/7941403.html
	' Get data; returns row count, <=0 on error (see ErrStr)
	' Returns saRecSetZ() 2D array
	' Query result in saRecSetZ(row, col), zero-based
	' Row 0 contains column names
	' Data rows start at index 1
	Dim As Integer i, j, CountPerPage
	#ifdef __USE_WINAPI__
		CountPerPage = ListView_GetCountPerPage(tControl.Handle)
	#endif
	Dim lpTable    As ZString Ptr Ptr ' Pointer to array for given table (from column names)
	Dim nRows      As Long=0         ' Number of rows in result set
	Dim nColumns   As Long=0         ' Number of columns in result set
	Dim lpErrorSz  As ZString Ptr         ' Error message
	Dim iFields    As Long=0         ' Number of fields returned for table
	Dim iRow       As Long=0
	Dim iCol       As Long=0
	Dim iResult    As Long         ' Row count or error code returned by this function

	#ifdef __USE_WINAPI__
		Dim As HCURSOR hCurSave = GetCursor()
		SetCursor(LoadCursor(0, IDC_WAIT))
	#endif
	If sqlite3_get_table(db, sSql, @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then ' Success
		If nRows = 0 OrElse nColumns<1  Then
			sqlite3_free_table lpTable  ' Free char** query result regardless of success
			tControl.Columns.Add "NO", 0, 43,cfCenter,CT_Header,False,CT_Header,,ssSortAscending
			tControl.Columns.Add "  ", 0,130,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
			For i = nRows+1 To CountPerPage
				tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
			Next
			tControl.ListItems.Item(0)->Text(1) = " "
			lpTable=0
			Return  -1
		End If
		If AddHeader Then
			tControl.Columns.Add "NO", 0, 43,cfCenter, CT_Header,False,CT_Header,,ssSortAscending
			For i = 0 To nColumns-1
				tControl.Columns.Add *lpTable[i], 0, 100,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
			Next
		End If
		tControl.ListItems.Add  Str(iRow+1),0,1
		tControl.ListItems.Item(iRow)->Text(0) = Str(iRow+1)
		iFields = ((nRows+1) * nColumns)-1
		For i = nColumns To iFields
			pApp->DoEvents
			tControl.ListItems.Item(iRow)->Text(iCol+1) = *lpTable[i]
			iCol +=1
			If iCol = nColumns Then iCol = 0
			If ((i+1) Mod nColumns = 0) AndAlso i<iFields Then
				iRow +=1
				tControl.ListItems.Add  Str(iRow+1),0,1
				tControl.ListItems.Item(iRow)->Text(0) = Str(iRow+1)
			End If
		Next
		' Marked the last row is BLANKROW
		tControl.ListItems.Item(nRows)->Text(0) = Str(BLANKROW+0.00005)
		If nRows<CountPerPage Then
			For i = nRows+1 To CountPerPage
				tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
			Next
		End If
	Else
		iResult = -1
		sqlite3_free_table lpTable  ' Free char** query result regardless of success
		tControl.Columns.Add " ", 0, 43,cfCenter,CT_Header,True,CT_Header,,ssSortAscending
		tControl.Columns.Add "  ", 0,130,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
		For i = nRows+1 To CountPerPage
			tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
		Next
		tControl.ListItems.Item(0)->Text(1) = " "
		lpTable=0
		Return  -1
	End If
	sqlite3_free_table lpTable  ' Free char** query result regardless of success
	lpTable=0
	Return  nRows
End Function


End
ErrorQ:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in line " & Erl() & " " & _
"in function " & ZGet(Erfn()) & " " & _
"in module " & ZGet(Ermn())

Private Sub frmGridDataTest.Frame_Sql_Click(ByRef Sender As GroupBox)
	
End Sub

Private Sub frmGridDataTest.cmdRefrshDataBase_Click(ByRef Sender As Control)
	
End Sub
