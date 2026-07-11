	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmTemplates.bi"
	
	Constructor frmTemplates
		' frmTemplates
		With This
			.Name = "frmTemplates"
			.Text = ("New") & "..."
				.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.Sizable
			.OnClose = @Form_Close_
			.OnCreate = @_Form_Create
			.SetBounds 0, 0, 657, 440
			.StartPosition = FormStartPosition.CenterParent
		End With
		' TabControl1
		With TabControl1
			.Name = "TabControl1"
			.Text = "TabControl1"
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SelectedTabIndex = 2
			.TabIndex = 0
			.SetBounds 10, 10, 621, 351
			.Designer = @This
			.OnSelChange = @TabControl1_SelChange_
			.Parent = @This
		End With
		' tpNew
		With tpNew
			.Name = "tpNew"
			.TabIndex = 1
			.SetBounds 0, 22, 618, 329
			.Text = ("New")
			.UseVisualStyleBackColor = True
			.Parent = @TabControl1
		End With
		' tvTemplates
		With tvTemplates
			.Name = "tvTemplates"
			.Text = "TreeView1"
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 10
			.TabIndex = 2
			.ExtraMargins.Right = 10
			.SetBounds 0, 10, 120, 315
			.Designer = @This
			.OnSelChanged = @tvTemplates_SelChanged_
			.Parent = @tpNew
		End With
		' lvTemplates
		With lvTemplates
			.Name = "lvTemplates"
			.Text = "ListView1"
			.View = ViewStyle.vsIcon
			.Images = @imgList32
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 10
			.TabIndex = 3
			.SetBounds 126, 10, 490, 314
			.Designer = @This
			.Columns.Add ("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnSelectedItemChanged = @lvTemplates_SelectedItemChanged_
			.Parent = @tpNew
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.TabIndex = 18
			.SetBounds 527, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlBottom
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 16
			.SetBounds 430, 0, 88, 20
				.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' tpExisting
		With tpExisting
			.Name = "tpExisting"
			.Text = ("Existing")
			.TabIndex = 4
			.UseVisualStyleBackColor = True
			.SetBounds 2, 22, 615, 326
			.Parent = @TabControl1
		End With
		' tpRecent
		With tpRecent
			.Name = "tpRecent"
			.Text = ("Recent")
			.TabIndex = 6
			.UseVisualStyleBackColor = True
			.SetBounds 0, 22, 618, 329
			.Parent = @TabControl1
		End With
		' lvRecent
		With lvRecent
			.Name = "lvRecent"
			.Text = "ListView1"
			.TabIndex = 8
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 10
			.Images = @imgList
			.SmallImages = @imgList
			.SetBounds 126, 10, 491, 313
			.Parent = @tpRecent
			.Columns.Add ("File"), , 150
			.Designer = @This
			.OnItemActivate = @lvRecent_ItemActivate_
			.Columns.Add ("Path"), , 300
		End With
		' OpenFileControl1
		With OpenFileControl1
			.Name = "OpenFileControl1"
			.Text = "OpenFileControl1"
			.Align = DockStyle.alClient
			.TabIndex = 5
			.SetBounds 0, 0, 615, 326
			.Designer = @This
			.InitialDir = GetFullPath(*ProjectsPath)
			.Filter = ("FreeBasic Files") & " (*.vfs, *.vfp, *.bas, *.frm, *.bi, *.inc, *.rc)|*.vfs;*.vfp;*.bas;*.frm;*.bi;*.inc;*.rc|" & ("AstoriaIDE Project Group") & " (*.vfs)|*.vfs|" & ("AstoriaIDE Project") & " (*.vfp)|*.vfp|" & ("FreeBasic Module") & " (*.bas)|*.bas|" & ("FreeBasic Form Module") & " (*.frm)|*.frm|" & ("FreeBasic Include File") & " (*.bi)|*.bi|" & ("Other Include File") & " (*.inc)|*.inc|" & ("Resource File") & " (*.rc)|*.rc|" & ("All Files") & "|*.*|"
			.OnFileActivate = @OpenFileControl1_FileActivate_
			.Parent = @tpExisting
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = "Panel1"
			.TabIndex = 9
			.Align = DockStyle.alBottom
			.SetBounds 0, 371, 641, 30
			.Parent = @This
		End With
		' tvRecent
		With tvRecent
			.Name = "tvRecent"
			.Text = "tvRecent"
			.TabIndex = 7
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 10
			.HideSelection = False
			.ExtraMargins.Right = 10
			.SetBounds 0, 10, 120, 313
			.Parent = @tpRecent
			.Nodes.Add ("Folders")
			.Nodes.Add ("Projects")
			.Nodes.Add ("Files")
			.Designer = @This
			.OnSelChanged = @tvRecent_SelChanged_
		End With
		' pnlSaveLocation
		With pnlSaveLocation
			.Name = "pnlSaveLocation"
			.Text = "Panel1"
			.TabIndex = 15
			.SetBounds 10, -1, 410, 30
			.Visible = False
			.Parent = @pnlBottom
		End With
		' lblSaveLocation
		With lblSaveLocation
			.Name = "lblSaveLocation"
			.Text = ("Save location:")
			.TabIndex = 17
			.Caption = ("Save location:")
			.SetBounds 10, 3, 110, 20
			.Parent = @pnlSaveLocation
		End With
		' txtSaveLocation
		With txtSaveLocation
			.Name = "txtSaveLocation"
			.Text = "./Projects/Project1"
			.TabIndex = 19
			.SetBounds 120, 1, 204, 20
			.Parent = @pnlSaveLocation
		End With
		' cmdSaveLocation
		With cmdSaveLocation
			.Name = "cmdSaveLocation"
			.Text = "..."
			.TabIndex = 20
			.Caption = "..."
			.SetBounds 325, 0, 30, 22
			.Designer = @This
			.OnClick = @cmdSaveLocation_Click_
			.Parent = @pnlSaveLocation
		End With
		' pnlRecent
		With pnlRecent
			.Name = "pnlRecent"
			.Text = "Panel1"
			.TabIndex = 10
			.SetBounds 10, 0, 420, 30
			.Designer = @This
			.Parent = @pnlBottom
		End With
		' cmdAdd
		With cmdAdd
			.Name = "cmdAdd"
			.Text = ("Add")
			.TabIndex = 11
			.Align = DockStyle.alLeft
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.Caption = ("Add")
			.SetBounds 0, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdAdd_Click_
			.Parent = @pnlRecent
		End With
		' cmdChange
		With cmdChange
			.Name = "cmdChange"
			.Text = ("Chan&ge")
			.TabIndex = 12
			.Align = DockStyle.alLeft
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 100, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdChange_Click_
			.Parent = @pnlRecent
		End With
		' cmdRemove
		With cmdRemove
			.Name = "cmdRemove"
			.Text = ("&Remove")
			.TabIndex = 13
			.Align = DockStyle.alLeft
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 198, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdRemove_Click_
			.Parent = @pnlRecent
		End With
		' cmdClear
		With cmdClear
			.Name = "cmdClear"
			.Text = ("&Clear")
			.TabIndex = 14
			.Align = DockStyle.alLeft
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 296, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdClear_Click_
			.Parent = @pnlRecent
		End With
	End Constructor
	
	Private Sub frmTemplates._Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmTemplates Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmTemplates.cmdAdd_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmTemplates Ptr, Sender.Designer)).cmdAdd_Click(Sender)
	End Sub
	
	Private Sub frmTemplates.cmdChange_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmTemplates Ptr, Sender.Designer)).cmdChange_Click(Sender)
	End Sub
	
	Private Sub frmTemplates.cmdRemove_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmTemplates Ptr, Sender.Designer)).cmdRemove_Click(Sender)
	End Sub
	
	Private Sub frmTemplates.cmdClear_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmTemplates Ptr, Sender.Designer)).cmdClear_Click(Sender)
	End Sub
	
	Private Sub frmTemplates.TabControl1_SelChange_(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, NewIndex As Integer)
		(*Cast(frmTemplates Ptr, Sender.Designer)).TabControl1_SelChange(Sender, NewIndex)
	End Sub

	Dim Shared fTemplates As frmTemplates
	pfTemplates = @fTemplates
'#End Region

Private Sub frmTemplates.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmTemplates Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmTemplates.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmTemplates.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmTemplates Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmTemplates.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	SelectedFile = ""
	Select Case TabControl1.SelectedTabIndex
	Case 0
		If lvTemplates.SelectedItemIndex > -1 Then
			If pnlSaveLocation.Visible Then
				If FolderExists(GetFullPath(txtSaveLocation.Text)) Then
					MsgBox ("Selected folder exists, change the project folder!")
					Me.BringToFront
				ElseIf Not FolderExists(GetFolderName(GetFullPath(txtSaveLocation.Text), False)) Then
					MsgBox ("Parent folder not exists, change the parent folder!")
					Me.BringToFront
				Else
					SelectedTemplate = ExePath & WindowsSlash & "Templates" & WindowsSlash & Templates.Item(lvTemplates.SelectedItemIndex)
					Dim As UString TemplateFolderName = ..Left(SelectedTemplate, Len(SelectedTemplate) - 4)
					SelectedFolder = GetFullPath(txtSaveLocation.Text)
					FolderCopy TemplateFolderName, SelectedFolder
					Dim As WString * MAX_PATH SrcPath, DestPath
					SrcPath = SelectedFolder & WindowsSlash & GetFileName(SelectedTemplate)
					DestPath = SelectedFolder & WindowsSlash & GetFileName(SelectedFolder) & ".vfp"
						MoveFile @SrcPath, @DestPath
					ModalResult = ModalResults.OK
					Me.CloseForm
				End If
			Else
				SelectedTemplate = ExePath & WindowsSlash & "Templates" & WindowsSlash & Templates.Item(lvTemplates.SelectedItemIndex)
				ModalResult = ModalResults.OK
				Me.CloseForm
			End If
		Else
			MsgBox ("Select template!")
			Me.BringToFront
		End If
	Case 1
		If OpenFileControl1.FileName <> "" Then
			SelectedFile = OpenFileControl1.FileName
			ModalResult = ModalResults.OK
			Me.CloseForm
		Else
			MsgBox ("Select file!")
			Me.BringToFront
		End If
	Case 2
		If lvRecent.SelectedItemIndex > -1 Then
			SelectedFile = GetFullPath(lvRecent.ListItems.Item(lvRecent.SelectedItemIndex)->Text(1))
			ModalResult = ModalResults.OK
			Me.CloseForm
		Else
			MsgBox ("Select recent file!")
			Me.BringToFront
		End If
	End Select
	If RecentChanged Then
		SaveMRU
	End If
End Sub

Private Sub frmTemplates.tvTemplates_SelChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	(*Cast(frmTemplates Ptr, Sender.Designer)).tvTemplates_SelChanged(Sender, Item)
End Sub
Private Sub frmTemplates.tvTemplates_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	If FormClosing Then Exit Sub
	lvTemplates.ListItems.Clear
	Templates.Clear
	Dim As String f, TemplateName, ImageName
	If Item.Name = "Projects" Then
		f = Dir(ExePath & "/Templates/Projects/*.vfp")
		While f <> ""
			TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			ImageName = "App" +..Left(TemplateName, IfNegative(InStr(TemplateName, " ") - 1, Len(TemplateName)))
			'Debug.Print " ImageName= " & ImageName & " " & imgList32.IndexOf(ImageName) 
			If imgList32.IndexOf(ImageName) < 0 Then ImageName = "AppGUI"
			lvTemplates.ListItems.Add (TemplateName), ImageName
			If FileExists(ExePath & "/Templates/Projects/" & TemplateName & "/" & f) Then
				Templates.Add "Projects" & WindowsSlash & f, lvTemplates.ListItems.Item(lvTemplates.ListItems.Count - 1)
			Else
				Templates.Add "Projects" & WindowsSlash & f
			End If
			f = Dir()
		Wend
	Else
		Dim As String IconName
		f = Dir(ExePath & "/Templates/Files/*")
		While f <> ""
			TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			If EndsWith(LCase(f), ".frm") Then
				IconName = "Form32"
			ElseIf f = "User Control.bas" Then
				IconName = "UserControl32"
			ElseIf EndsWith(LCase(f), ".bas") Then
				IconName = "Module32"
			ElseIf EndsWith(LCase(f), ".rc") Then
				IconName = "Resource32"
			ElseIf EndsWith(LCase(f), ".xml") Then
				IconName = "Manifest32"
			Else
				IconName = "File32"
			End If
			If imgList32.IndexOf(IconName) < 0 Then IconName = "AppGUI"
			lvTemplates.ListItems.Add (TemplateName), IconName
			Templates.Add "Files" & WindowsSlash & f
			f = Dir()
		Wend
	End If
End Sub

Private Sub frmTemplates.lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmTemplates Ptr, Sender.Designer)).lvTemplates_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub


Private Sub frmTemplates.Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	(*Cast(frmTemplates Ptr, Sender.Designer)).Form_Show(Sender)
End Sub
Private Sub frmTemplates.Form_Show(ByRef Sender As Form)
	Select Case DialogMode
	Case 0
		SendMessage(TabControl1.Handle, TCM_SETITEMSIZE, 0, MAKELONG(0, 22))
		tvTemplates.Visible = True
		tvRecent.Visible = True
	Case 1
		TabControl1.SelectedTabIndex = 0
		SendMessage(TabControl1.Handle, TCM_SETITEMSIZE, 0, 0)
		tvTemplates.Visible = False
		tvTemplates.SelectedNode = tvTemplates.Nodes.Item(0)
		tvTemplates_SelChanged tvTemplates, *tvTemplates.SelectedNode
	Case 2, 3
		TabControl1.SelectedTabIndex = 2
		SendMessage(TabControl1.Handle, TCM_SETITEMSIZE, 0, 0)
		tvRecent.Visible = False
		tvRecent.SelectedNode = tvRecent.Nodes.Item(2)
		tvRecent_SelChanged tvRecent, *tvRecent.SelectedNode
	End Select
	pnlRecent.Visible = True
End Sub

Private Sub frmTemplates.Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	(*Cast(frmTemplates Ptr, Sender.Designer)).Form_Close(Sender, Action)
End Sub
Private Sub frmTemplates.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	OnlyFiles = False
End Sub

Private Sub frmTemplates.tvRecent_SelChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	(*Cast(frmTemplates Ptr, Sender.Designer)).tvRecent_SelChanged(Sender, Item)
End Sub
Private Sub frmTemplates.tvRecent_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	Dim As WStringList Ptr MRUList
	lvRecent.ListItems.Clear
	Select Case Item.Index
	Case 0: MRUList = @MRUFolders
	Case 1: MRUList = @MRUProjects
	Case 2: MRUList = @MRUFiles
	Case Else: Exit Sub
	End Select
	Dim sTmp As WString * 1024
	For i As Integer = 0 To MRUList->Count - 1
		sTmp = MRUList->Item(i)
		lvRecent.ListItems.Add GetFileName(sTmp), GetIconName(sTmp)
		lvRecent.ListItems.Item(i)->Text(1) = sTmp
	Next
End Sub

Private Sub frmTemplates.lvRecent_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmTemplates Ptr, Sender.Designer)).lvRecent_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.OpenFileControl1_FileActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl)
	(*Cast(frmTemplates Ptr, Sender.Designer)).OpenFileControl1_FileActivate(Sender)
End Sub
Private Sub frmTemplates.OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.TabControl1_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
	'If  NewIndex = 1 Then 
		'OpenFileControl1.SetBounds TabControl1.Left, TabControl1.Top, TabControl1.Width, TabControl1.Height
		'TabControl1.RequestAlign
	'End If 
	pnlSaveLocation.Visible = lvTemplates.SelectedItemIndex >= 0 AndAlso Templates.Object(lvTemplates.SelectedItemIndex) > 0 AndAlso TabControl1.SelectedTabIndex = 0
	pnlRecent.Visible = TabControl1.SelectedTabIndex = 2
End Sub

Private Sub frmTemplates.cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmTemplates Ptr, Sender.Designer)).cmdSaveLocation_Click(Sender)
End Sub
Private Sub frmTemplates.cmdSaveLocation_Click(ByRef Sender As Control)
	Dim BrowseD As FolderBrowserDialog
	BrowseD.InitialDir = GetFullPath(Replace(GetFolderName(txtSaveLocation.Text), UnixSlash, WindowsSlash))
	If BrowseD.Execute Then
		txtSaveLocation.Text = BrowseD.Directory & WindowsSlash & Mid(txtSaveLocation.Text, InStrRev(Replace(txtSaveLocation.Text, UnixSlash, WindowsSlash), WindowsSlash) + 1)
	End If
End Sub

Private Sub frmTemplates.lvTemplates_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmTemplates Ptr, Sender.Designer)).lvTemplates_SelectedItemChanged(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvTemplates_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If lvTemplates.SelectedItemIndex > -1 Then
		pnlSaveLocation.Visible = Templates.Object(lvTemplates.SelectedItemIndex) > 0
	End If
End Sub

Private Sub frmTemplates.cmdClear_Click(ByRef Sender As Control)
	Dim NodeIdx As Integer = -1
	If tvRecent.SelectedNode <> 0 Then NodeIdx = tvRecent.SelectedNode->Index
	If NodeIdx = 0 Then
		MRUFolders.Clear
	ElseIf NodeIdx = 1 Then
		MRUProjects.Clear
	ElseIf NodeIdx = 2 Then
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	End If
	lvRecent.ListItems.Clear
	RecentChanged = True
End Sub

Private Sub frmTemplates.cmdRemove_Click(ByRef Sender As Control)
	Var Idx = lvRecent.SelectedItemIndex
	Dim NodeIdx As Integer = -1
	If tvRecent.SelectedNode <> 0 Then NodeIdx = tvRecent.SelectedNode->Index
	If Idx <> -1 Then
		If NodeIdx = 0 Then
			MRUFolders.Remove Idx
		ElseIf NodeIdx = 1 Then
			MRUProjects.Remove Idx
		ElseIf NodeIdx = 2 Then
			miRecentFiles->Remove miRecentFiles->Item(Idx)
			MRUFiles.Remove Idx
		End If
		lvRecent.ListItems.Remove Idx
		RecentChanged = True
	End If
End Sub

Private Sub frmTemplates.cmdChange_Click(ByRef Sender As Control)
	Var Idx = lvRecent.SelectedItemIndex
	Dim NodeIdx As Integer = -1
	If tvRecent.SelectedNode <> 0 Then NodeIdx = tvRecent.SelectedNode->Index
	If Idx <> -1 Then
		pfPath->WithoutVersion = True
		pfPath->WithoutCommandLine = True
		If NodeIdx = 0 Then
			pfPath->ChooseFolder = True
		End If
		pfPath->txtPath.Text = lvRecent.SelectedItem->Text(1)
		Dim As UString Path
		'' T16 smoke-test finding: read the snapshot field (frmPath.bi), not txtPath.Text
		'' directly -- see frmTools.frm's cmdAdd_Click for the full explanation.
		If pfPath->ShowModal(Me) = ModalResults.OK Then
			Path = pfPath->txtPathText
		Else
			Exit Sub
		End If
		If StartsWith(Path, "." & WindowsSlash) Then Path = Mid(Path, 3)
		If NodeIdx = 0 Then
			MRUFolders.Item(Idx) = Path
		ElseIf NodeIdx = 1 Then
			MRUProjects.Item(Idx) = Path
		ElseIf NodeIdx = 2 Then
			miRecentFiles->Item(Idx)->Caption = Path
			MRUFiles.Item(Idx) = Path
		End If
		lvRecent.ListItems.Item(Idx)->Text(0) = GetFileName(Path)
		lvRecent.ListItems.Item(Idx)->Text(1) = Path
		lvRecent.ListItems.Item(Idx)->ImageKey = GetIconName(Path)
		RecentChanged = True
	End If
End Sub

Private Sub frmTemplates.cmdAdd_Click(ByRef Sender As Control)
	Dim NodeIdx As Integer = -1
	If tvRecent.SelectedNode <> 0 Then NodeIdx = tvRecent.SelectedNode->Index
	pfPath->WithoutVersion = True
	pfPath->WithoutCommandLine = True
	If NodeIdx = 1 Then
		pfPath->ChooseFolder = True
	End If
	pfPath->txtPath.Text = ""
	Dim As UString Path
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		Path = pfPath->txtPathText
	Else
		Exit Sub
	End If
	If StartsWith(Path, "." & WindowsSlash) Then Path = Mid(Path, 3)
	If NodeIdx = 0 Then
		MRUFolders.Insert 0, Path
	ElseIf NodeIdx = 1 Then
		MRUProjects.Insert 0, Path
	ElseIf NodeIdx = 2 Then
		miRecentFiles->Add Path, "", , @mClickMRU, , 0
		MRUFiles.Insert 0, Path
	End If
	Var Item = lvRecent.ListItems.Add(GetFileName(Path), GetIconName(Path), , , 0)
	Item->Text(1) = Path
	RecentChanged = True
End Sub

Private Sub frmTemplates.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	tvTemplates.Nodes.Clear
	If OnlyFiles = False Then
		tvTemplates.Nodes.Add ("Projects"), "Projects"
	End If
	tvTemplates.Nodes.Add ("Files"), "Files"
	tvTemplates_SelChanged tvTemplates, *tvTemplates.Nodes.Item(0)
	tvRecent_SelChanged tvRecent, *tvRecent.Nodes.Item(0)
	RecentChanged = False
	TabControl1.SelectedTabIndex = 0
	'This.Width = This.Width + 1
	Var n = 0
	Dim As String ProjectName = "Project"
	Dim NewName As String
	Do
		n = n + 1
		NewName = ProjectName & Str(n)
	Loop While FolderExists(*ProjectsPath & WindowsSlash & NewName)
	txtSaveLocation.Text = Replace(*ProjectsPath, UnixSlash, WindowsSlash) & WindowsSlash & NewName
End Sub

