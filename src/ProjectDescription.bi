'###############################################################################
'#  ProjectDescription.bi                                                      #
'#                                                                             #
'#  Every project created with the Astoria IDE gets a `project.astoria` file   #
'#  in its folder recording the choices made at creation. It is:               #
'#    - the marker that identifies a folder as an Astoria project (the clone    #
'#      flow refuses git repos that are neither empty nor Astoria projects);    #
'#    - what Project menu > Edit Project Description opens;                      #
'#    - where the Git Commit/Push menu options read the remote from.            #
'#                                                                             #
'#  Format: UTF-8, one Key=Value per line, `#` comment lines, a required        #
'#  `AstoriaProject=1` marker. Multi-line Description is stored with a literal  #
'#  "\n" placeholder (same convention as the .vfp keys), since the file is      #
'#  line-based.                                                                 #
'###############################################################################
#pragma once

Const ASTORIA_DESC_FILENAME = "project.astoria"

Enum ProjectCreateMode
	pcmLocalProject      '' created from a local template, no git
	pcmExistingGit       '' cloned from / backed by an existing remote git repo
End Enum

'' The creation choices captured in project.astoria. Text fields are UString so
'' non-ASCII names/authors round-trip. Description keeps its real newlines here;
'' the writer/reader handle the "\n" placeholder at the file boundary.
Type ProjectDescriptionData
	Mode         As ProjectCreateMode
	ProjectName  As UString
	Template     As UString
	Author       As UString
	License      As UString
	Description  As UString
	GitProvider  As UString
	GitUserName  As UString
	GitEmail     As UString
	GitURL       As UString
	AIFriendly   As Boolean
	AITool       As UString
	Created      As UString    '' yyyy-mm-dd
End Type

'' Full path to a project's description file (ProjectFolder is the project's folder).
Declare Function ProjectDescriptionPath(ByRef ProjectFolder As UString) As UString

'' Write project.astoria into ProjectFolder. Returns False on open failure.
Declare Function WriteProjectDescription(ByRef ProjectFolder As UString, ByRef d As ProjectDescriptionData) As Boolean

'' Read project.astoria from ProjectFolder into d. Returns False if the file is
'' missing or lacks the AstoriaProject marker (d is left at defaults then).
Declare Function ReadProjectDescription(ByRef ProjectFolder As UString, ByRef d As ProjectDescriptionData) As Boolean

'' Whether ProjectFolder holds a valid Astoria project.astoria (the load-gate check).
Declare Function IsAstoriaProject(ByRef ProjectFolder As UString) As Boolean

'' Whether a folder is "empty" for clone-classification purposes: no entries other
'' than . / .. / .git (a freshly cloned empty repo). Used to decide empty-repo vs
'' foreign-repo in the Use Existing Git flow.
Declare Function FolderIsEffectivelyEmpty(ByRef Folder As UString) As Boolean

'' Defined in Main.bas (they need IDE state / helpers there), declared here so the Edit
'' Project Description dialog -- included before them -- can call them.
'' Stamp Templates/AI/<toolFolder>/ into destFolder with token substitution.
Declare Sub StampAiTemplateInto(ByRef destFolder As UString, ByRef toolFolder As UString, ByRef projectName As String, ByRef author As String, ByRef license As String, ByRef description As String)
'' Rewrite a .vfp's Author/License/Description/AIFriendly/AITool keys to match d.
Declare Sub UpdateVfpMetadataKeys(ByRef vfpPath As UString, ByRef d As ProjectDescriptionData)

#include once "ProjectDescription.bas"
