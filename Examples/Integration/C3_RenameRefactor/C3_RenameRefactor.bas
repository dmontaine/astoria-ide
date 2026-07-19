'' TestPlan.md C3 -- the rename refactoring's line rewriter.
''
'' C3 failed because renaming a control in the designer updated the four places that DESCRIBE it
'' (its Dim, comment, With block and .Name) but nothing that REFERENCES it, so the project stopped
'' building with "Variable not declared, Label1". ROADMAP 13.17, required for 1.0.
''
'' The fix adds an identifier-aware sweep over the rest of the file. This tests that sweep directly,
'' against `src/RenameRefactor.bi`, which is the actual shipping code and not a copy.
''
'' What matters here is not that it renames -- that is easy -- but everything it must NOT rename.
'' A rename refactor that is too eager silently corrupts working code, which is far worse than the
'' defect it replaces: the build error C3 started with at least told you where to look. So most of
'' these cases assert that a line is left ALONE.
''
'' SELF-CONTAINED AND SELF-EXITING. Exit code is non-zero if any assertion failed.

#include once "RenameRefactor.bi"

Dim Shared As Integer gPass, gFail

Sub Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If Got = Want Then
		gPass += 1
		Print "PASS " & CheckName
	Else
		gFail += 1
		Print "FAIL " & CheckName
		Print "       expected [" & Want & "]"
		Print "            got [" & Got & "]"
	End If
End Sub

'' Shorthand: rename Label1 -> lblGreeting in one line.
Function R(ByRef s As String) As String
	Return RenameIdentifierInLine(s, "Label1", "lblGreeting")
End Function

Print "-- the reference that C3 actually failed on --"
Check("member access is renamed", _
	R("	Label1.Text = ""Hello, "" & TextBox1.Text"), _
	"	lblGreeting.Text = ""Hello, "" & TextBox1.Text")

Print ""
Print "-- what must NOT be touched --"

'' The handler keeps its name by design (ROADMAP 13.17): renaming it would break anything calling
'' it by name. Whole-identifier matching gives this for free -- Label1_Click is one token.
Check("the event handler name is left alone", _
	R("Private Sub frmMain.Label1_Click(ByRef Sender As Control)"), _
	"Private Sub frmMain.Label1_Click(ByRef Sender As Control)")

Check("a longer identifier with the same prefix is left alone", _
	R("	Label10.Text = ""ten"""), _
	"	Label10.Text = ""ten""")

Check("a longer identifier with the same suffix is left alone", _
	R("	MyLabel1.Text = ""mine"""), _
	"	MyLabel1.Text = ""mine""")

'' Text inside strings is user data. A caption that happens to read "Label1" must survive, and so
'' must the .Name assignment the designer owns and rewrites itself.
Check("text inside a string literal is left alone", _
	R("	.Text = ""Label1 says hello"""), _
	"	.Text = ""Label1 says hello""")

Check("the designer's own .Name string is left alone", _
	R("		.Name = ""Label1"""), _
	"		.Name = ""Label1""")

Check("comment text is left alone", _
	R("	' Label1 is the greeting label"), _
	"	' Label1 is the greeting label")

Check("a trailing comment is left alone while code before it is renamed", _
	R("	Label1.Text = """" ' reset Label1 here"), _
	"	lblGreeting.Text = """" ' reset Label1 here")

Print ""
Print "-- the shapes a form file actually contains --"

Check("the Dim line", _
	R("	Dim As Label Label1"), _
	"	Dim As Label lblGreeting")

Check("a With block", _
	R("	With Label1"), _
	"	With lblGreeting")

Check("an address-of reference", _
	R("		.Parent = @Label1"), _
	"		.Parent = @lblGreeting")

Check("a reference used as a bare argument", _
	R("	SomeHelper(Label1)"), _
	"	SomeHelper(lblGreeting)")

Check("several references on one line", _
	R("	Label1.Top = Label1.Top + Label1.Height"), _
	"	lblGreeting.Top = lblGreeting.Top + lblGreeting.Height")

Check("matching is case-insensitive, as FreeBASIC is", _
	R("	LABEL1.Text = ""shout"""), _
	"	lblGreeting.Text = ""shout""")

Print ""
Print "-- edges --"

Check("a line with no occurrence is returned unchanged", _
	R("	TextBox1.Text = ""nothing to do here"""), _
	"	TextBox1.Text = ""nothing to do here""")

Check("an empty line survives", R(""), "")

'' A doubled "" inside a literal. The scanner treats it as a closing quote immediately followed by
'' an opening one, which lands on the same result: the whole span is still copied verbatim.
Check("an escaped quote inside a string does not break the scan", _
	R("	.Text = ""say """"Label1"""" loudly"" : Label1.Top = 0"), _
	"	.Text = ""say """"Label1"""" loudly"" : lblGreeting.Top = 0")

Check("an unterminated string does not run past the end of the line", _
	R("	.Text = ""Label1"), _
	"	.Text = ""Label1")

Print ""
Print "C3 RESULT: " & Str(gPass) & " passed, " & Str(gFail) & " failed"
If gFail = 0 Then
	Print "C3 OVERALL: PASS"
	End 0
Else
	Print "C3 OVERALL: FAIL"
	End 1
End If
