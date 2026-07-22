'###############################################################################
'#  ProjectDescription.bas -- see ProjectDescription.bi for the contract.      #
'#  Depends on PathUtils (FileExistsU / EnsureDirectoryExists / WinOsPath) and  #
'#  the framework's UString/WStringList.                                        #
'###############################################################################

Function ProjectDescriptionPath(ByRef ProjectFolder As UString) As UString
	Return WinOsPath(ProjectFolder & "/" & ASTORIA_DESC_FILENAME)
End Function

'' Description carries real newlines in memory; store them as the literal "\n"
'' placeholder so the file stays strictly line-based (matches the .vfp keys).
Private Function DescEncodeNewlines(ByRef s As UString) As UString
	Dim As UString r = s
	r = Replace(r, Chr(13) & Chr(10), "\n")
	r = Replace(r, Chr(10), "\n")
	r = Replace(r, Chr(13), "\n")
	Return r
End Function

Private Function DescDecodeNewlines(ByRef s As UString) As UString
	Return Replace(s, "\n", Chr(13) & Chr(10))
End Function

Function WriteProjectDescription(ByRef ProjectFolder As UString, ByRef d As ProjectDescriptionData) As Boolean
	EnsureDirectoryExists(ProjectFolder)
	Dim As UString path = ProjectDescriptionPath(ProjectFolder)
	Dim As Integer fn = FreeFile
	If Open(path For Output Encoding "utf-8" As #fn) <> 0 Then Return False
	Print #fn, "# Astoria Project Description -- do not delete."
	Print #fn, "# Records the choices made when this project was created with the Astoria IDE."
	Print #fn, "# Edit via the Project menu > Edit Project Description."
	Print #fn, "AstoriaProject=1"
	Print #fn, "ProjectName=" & d.ProjectName
	Print #fn, "Template=" & d.Template
	Print #fn, "Author=" & d.Author
	Print #fn, "License=" & d.License
	Print #fn, "Description=" & DescEncodeNewlines(d.Description)
	Print #fn, "AIFriendly=" & IIf(d.AIFriendly, "true", "false")
	Print #fn, "AITool=" & d.AITool
	Print #fn, "Created=" & d.Created
	Close #fn
	Return True
End Function

Function ReadProjectDescription(ByRef ProjectFolder As UString, ByRef d As ProjectDescriptionData) As Boolean
	Dim As UString path = ProjectDescriptionPath(ProjectFolder)
	If Not FileExistsU(path) Then Return False
	Dim As Integer fn = FreeFile
	'' Written UTF-8; fall back to a plain read so a BOM-less/other-encoded file
	'' still parses (same defensive pattern as the .vfp reader).
	Dim As Integer res = Open(path For Input Encoding "utf-8" As #fn)
	If res <> 0 Then res = Open(path For Input As #fn)
	If res <> 0 Then Return False
	Dim As Boolean hasMarker = False
	Dim As WString * 4096 lineBuf
	Do Until EOF(fn)
		Line Input #fn, lineBuf
		Dim As UString ln = lineBuf
		If Left(ln, 1) = "#" OrElse Trim(ln) = "" Then Continue Do
		Dim As Integer eq = InStr(ln, "=")
		If eq = 0 Then Continue Do
		Dim As UString key = Trim(Left(ln, eq - 1))
		Dim As UString valStr = Mid(ln, eq + 1)
		Select Case key
		Case "AstoriaProject": If Trim(valStr) = "1" Then hasMarker = True
		Case "ProjectName":    d.ProjectName = valStr
		Case "Template":       d.Template = valStr
		Case "Author":         d.Author = valStr
		Case "License":        d.License = valStr
		Case "Description":    d.Description = DescDecodeNewlines(valStr)
		Case "AIFriendly":     d.AIFriendly = (LCase(Trim(valStr)) = "true")
		Case "AITool":         d.AITool = valStr
		Case "Created":        d.Created = valStr
		End Select
	Loop
	Close #fn
	Return hasMarker
End Function

Function IsAstoriaProject(ByRef ProjectFolder As UString) As Boolean
	Dim As ProjectDescriptionData d
	Return ReadProjectDescription(ProjectFolder, d)
End Function
