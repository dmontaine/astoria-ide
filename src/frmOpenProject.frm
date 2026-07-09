	'#Compile -exx "Form1.rc"

'#Region "Form"

	#include once "frmOpenProject.bi"

	

	Constructor frmOpenProject

		With This

			.Name = "frmOpenProject"

			.Text = ("Open Project")

				.Icon.LoadFromResourceID(1)

			.Designer = @This

			.BorderStyle = FormBorderStyle.Sizable

			.OnCreate = @Form_Create_

			.SetBounds 0, 0, 657, 440

			.StartPosition = FormStartPosition.CenterParent

		End With

		' pnlBottom

		With pnlBottom

			.Name = "pnlBottom"

			.Text = ""

			.Align = DockStyle.alBottom

			.TabIndex = 2

			.SetBounds 0, 371, 641, 30

			.Parent = @This

		End With

		' cmdBrowse

		With cmdBrowse

			.Name = "cmdBrowse"

			.Text = ("Browse") & "..."

			.Align = DockStyle.alNone

			.ExtraMargins.Left = 10

			.ExtraMargins.Top = 0

			.ExtraMargins.Bottom = 10

			.TabIndex = 5

			.SetBounds 145, 0, 88, 20

			.Designer = @This

			.OnClick = @cmdBrowse_Click_

			.Parent = @pnlBottom

		End With

		' cmdOpenNew  (leftmost; closes this dialog and opens the New Project window instead)
		With cmdOpenNew
			.Name = "cmdOpenNew"
			.Text = ("Open New Project")
			.Align = DockStyle.alNone
			.TabIndex = 6
			.SetBounds 10, 0, 130, 20
			.Designer = @This
			.OnClick = @cmdOpenNew_Click_
			.Parent = @pnlBottom
		End With

		' cmdCancel

		With cmdCancel

			.Name = "cmdCancel"

			.Text = ("Cancel")

			.Align = DockStyle.alRight

			.ExtraMargins.Bottom = 10

			.ExtraMargins.Top = 0

			.ExtraMargins.Right = 10

			.TabIndex = 4

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

			.TabIndex = 3

			.SetBounds 430, 0, 88, 20

			.Default = True

			.Designer = @This

			.OnClick = @cmdOK_Click_

			.Parent = @pnlBottom

		End With

		' tabOpenProject

		With tabOpenProject

			.Name = "tabOpenProject"

			.Text = "TabControl1"

			.Align = DockStyle.alClient

			.ExtraMargins.Top = 10

			.ExtraMargins.Right = 10

			.ExtraMargins.Left = 10

			.ExtraMargins.Bottom = 10

			.SelectedTabIndex = 0

			.TabIndex = 1

			.SetBounds 10, 10, 621, 361

			.Designer = @This

			.OnSelChange = @tabOpenProject_SelChange_

			.Parent = @This

		End With

		' tpProjects

		With tpProjects

			.Name = "tpProjects"

			.Text = ("Projects")

			.TabIndex = 0

			.UseVisualStyleBackColor = True

			.SetBounds 0, 22, 618, 339

			.Parent = @tabOpenProject

		End With

		' lvProjects

		With lvProjects

			.Name = "lvProjects"

			.Text = "ListView1"

			.View = ViewStyle.vsDetails

			.Align = DockStyle.alClient

			.ExtraMargins.Top = 10

			.ExtraMargins.Right = 10

			.ExtraMargins.Left = 10

			.ExtraMargins.Bottom = 10

			.Images = @imgList

			.SmallImages = @imgList

			.TabIndex = 0

			.SetBounds 10, 10, 598, 319

			.Designer = @This

			.Columns.Add ("File"), , 150

			.Columns.Add ("Path"), , 450

			.OnItemActivate = @lvProjects_ItemActivate_

			.Parent = @tpProjects

		End With

		' tpExamples

		With tpExamples

			.Name = "tpExamples"

			.Text = ("Examples")

			.TabIndex = 1

			.UseVisualStyleBackColor = True

			.SetBounds 0, 22, 618, 339

			.Parent = @tabOpenProject

		End With

		' lvExamples

		With lvExamples

			.Name = "lvExamples"

			.Text = "ListView2"

			.View = ViewStyle.vsDetails

			.Align = DockStyle.alClient

			.ExtraMargins.Top = 10

			.ExtraMargins.Right = 10

			.ExtraMargins.Left = 10

			.ExtraMargins.Bottom = 10

			.Images = @imgList

			.SmallImages = @imgList

			.TabIndex = 0

			.SetBounds 10, 10, 598, 319

			.Designer = @This

			.Columns.Add ("File"), , 150

			.Columns.Add ("Path"), , 450

			.OnItemActivate = @lvExamples_ItemActivate_

			.Parent = @tpExamples

		End With

	End Constructor



'#End Region



Private Sub frmOpenProject.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdOK_Click(Sender)

End Sub

Private Sub frmOpenProject.cmdOK_Click(ByRef Sender As Control)

	SelectedFile = ""

	If tabOpenProject.SelectedTabIndex = 1 Then

		If lvExamples.SelectedItemIndex > -1 Then

			SelectedFile = WinOsPath(ExampleFiles.Item(lvExamples.SelectedItemIndex))

			ModalResult = ModalResults.OK

			Me.CloseForm

		Else

			MsgBox ("Select project!")

			Me.BringToFront

		End If

	Else

		If lvProjects.SelectedItemIndex > -1 Then

			SelectedFile = WinOsPath(ProjectFiles.Item(lvProjects.SelectedItemIndex))

			ModalResult = ModalResults.OK

			Me.CloseForm

		Else

			MsgBox ("Select project!")

			Me.BringToFront

		End If

	End If

End Sub



Private Sub frmOpenProject.cmdBrowse_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdBrowse_Click(Sender)

End Sub

Private Sub frmOpenProject.cmdBrowse_Click(ByRef Sender As Control)

	Dim As FolderBrowserDialog BrowseD

	If tabOpenProject.SelectedTabIndex = 1 Then

		BrowseD.InitialDir = GetFullPath(ExePath & WindowsSlash & "Examples")

	Else

		BrowseD.InitialDir = GetFullPath(*ProjectsPath)

	End If

	If BrowseD.Execute Then

		SelectedFile = FindProjectVfpInFolder(WinOsPath(BrowseD.Directory))

		If SelectedFile = "" Then

			MsgBox ("No project file (.vfp) found in the selected folder."), , mtWarning

			Me.BringToFront

			Exit Sub

		End If

		ModalResult = ModalResults.OK

		Me.CloseForm

	End If

End Sub



Private Sub frmOpenProject.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdCancel_Click(Sender)

End Sub

Private Sub frmOpenProject.cmdCancel_Click(ByRef Sender As Control)

	ModalResult = ModalResults.Cancel

	Me.CloseForm

End Sub

Private Sub frmOpenProject.cmdOpenNew_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdOpenNew_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdOpenNew_Click(ByRef Sender As Control)
	' Close Open Project and signal OpenProject() to bring up the New Project window instead.
	OpenNewRequested = True
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub



Private Sub frmOpenProject.lvProjects_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).lvProjects_ItemActivate(Sender, ItemIndex)

End Sub

Private Sub frmOpenProject.lvProjects_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)

	cmdOK_Click cmdOK

End Sub



Private Sub frmOpenProject.lvExamples_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).lvExamples_ItemActivate(Sender, ItemIndex)

End Sub

Private Sub frmOpenProject.lvExamples_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)

	cmdOK_Click cmdOK

End Sub



Private Sub frmOpenProject.tabOpenProject_SelChange_(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, NewIndex As Integer)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).tabOpenProject_SelChange(Sender, NewIndex)

End Sub

Private Sub frmOpenProject.tabOpenProject_SelChange(ByRef Sender As TabControl, NewIndex As Integer)

	If NewIndex = 1 AndAlso Not ExamplesLoaded Then

		PopulateExamplesList()

		ExamplesLoaded = True

	End If

End Sub



Private Sub frmOpenProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

	(*Cast(frmOpenProject Ptr, Sender.Designer)).Form_Create(Sender)

End Sub

Private Sub frmOpenProject.Form_Create(ByRef Sender As Control)

	ModalResult = ModalResults.Cancel

	SelectedFile = ""

	ExamplesLoaded = False

	lvProjects.ListItems.Clear

	lvExamples.ListItems.Clear

	ProjectFiles.Clear

	ExampleFiles.Clear

	tabOpenProject.SelectedTabIndex = 0

	PopulateProjectsList()

End Sub



Private Sub frmOpenProject.FillListView(ByRef lv As ListView, ByRef files As WStringList)

	lv.ListItems.Clear

	For i As Integer = 0 To files.Count - 1

		Dim As WString * MAX_PATH fullPath = files.Item(i)

		lv.ListItems.Add GetFileName(fullPath), GetIconName(fullPath)

		lv.ListItems.Item(lv.ListItems.Count - 1)->Text(1) = fullPath

	Next

End Sub



Private Sub frmOpenProject.ScanFolderSubdirsForVfp(ByVal root As UString, ByRef files As WStringList)

	root = OsPathForDir(root)

	If root = "" OrElse Not FolderExistsU(root) Then Return

	Dim As WString * MAX_PATH scanPattern = OsPathForDir(root) & WindowsSlash & "*"

	Dim As WStringList subdirs

	Dim As UInteger Attr

	Dim As WString * MAX_PATH entry = Dir(scanPattern, fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)

	While entry <> ""

		If (Attr And fbDirectory) <> 0 Then

			If entry <> "." AndAlso entry <> ".." Then subdirs.Add entry

		End If

		entry = Dir(Attr)

	Wend

	For i As Integer = 0 To subdirs.Count - 1

		Dim As UString subFolder = root & WindowsSlash & subdirs.Item(i)

		Dim As UString vfpPath = FindProjectVfpInFolder(subFolder)

		If vfpPath <> "" Then files.Add vfpPath

	Next

End Sub



Private Sub frmOpenProject.PopulateProjectsList()

	ProjectFiles.Clear

	Dim As WString * MAX_PATH projectsPathSetting = Trim(*ProjectsPath, Any !" \t" + Chr(10) + Chr(13))

	If projectsPathSetting = "" Then projectsPathSetting = "./Projects"

	Dim As UString projectsRoot = GetFullPathU(projectsPathSetting)

	ScanFolderSubdirsForVfp projectsRoot, ProjectFiles

	ProjectFiles.Sort

	FillListView lvProjects, ProjectFiles

End Sub



Private Sub frmOpenProject.PopulateExamplesList()

	ExampleFiles.Clear

	Dim As UString examplesRoot = CanonicalWinPath(ExePath & WindowsSlash & "Examples")

	If examplesRoot = "" OrElse Not FolderExistsU(examplesRoot) Then

		FillListView lvExamples, ExampleFiles

		Return

	End If

	Dim As WString * MAX_PATH scanPattern = OsPathForDir(examplesRoot) & WindowsSlash & "*"

	Dim As WStringList topLevelDirs

	Dim As UInteger Attr

	Dim As WString * MAX_PATH entry = Dir(scanPattern, fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)

	While entry <> ""

		If (Attr And fbDirectory) <> 0 Then

			If entry <> "." AndAlso entry <> ".." Then topLevelDirs.Add entry

		End If

		entry = Dir(Attr)

	Wend

	For i As Integer = 0 To topLevelDirs.Count - 1

		Dim As UString subFolder = examplesRoot & WindowsSlash & topLevelDirs.Item(i)

		Dim As UString vfpPath = FindProjectVfpInFolder(subFolder)

		If vfpPath <> "" Then

			ExampleFiles.Add vfpPath

		Else

			ScanFolderSubdirsForVfp subFolder, ExampleFiles

		End If

	Next

	ExampleFiles.Sort

	FillListView lvExamples, ExampleFiles

End Sub

