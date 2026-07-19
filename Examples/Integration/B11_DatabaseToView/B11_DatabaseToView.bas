'' TestPlan.md B11 -- database results into a view.
''
'' A1 proved the SQLite data path in isolation: rows go in, rows come back. This joins that to a
'' display path, which is the only reason anyone uses the database controls in the first place --
'' a query result is worth nothing until it reaches a control the user can see.
''
'' Two subsystems that have each already produced defects meet here: SQLite3Component (whose
'' AddField could never succeed in its obvious form until A1 found it) and ListView (whose image
'' keys silently resolve to -1 in the wrong binding order, per B7).
''
'' The assertions deliberately compare the VIEW against the QUERY, cell by cell, rather than
'' against the values the test happens to remember inserting. A population loop that quietly drops
'' or reorders a row would satisfy "the list has three items" and still be wrong.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b11_result.txt.

'' INCLUDE ORDER MATTERS. The framework must come first. SQLite3Component.bi pulls in windows.bi,
'' and if it does so before the framework has set the Windows version it targets, the later
'' framework include is a no-op and Control.bas fails to compile on WM_POINTERDOWN and friends --
'' declarations that only exist at a high enough _WIN32_WINNT. Putting mff first avoids needing a
'' compiler flag, and matches the order the shipped examples use.
#include once "mff/Form.bi"
#include once "mff/ListView.bi"
#include once "mff/Label.bi"
#include once "mff/TimerComponent.bi"
#include once "SQLite3Component.bi"

Using My.Sys.Forms

Const B11_WATCHDOG_TICKS = 60

Type B11Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As ListView lvRows
	Dim As Label lblStatus
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
End Type

Dim Shared As B11Form Ptr pB11
Dim Shared As String gQuery(Any, Any)     '' the result set, kept so the view can be compared to it
Dim Shared As Long gRows

Sub B11Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b11_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B11Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB11 = 0 Then Exit Sub
	If Got = Want Then
		pB11->Pass += 1
		B11Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB11->Fail += 1
		B11Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Sub B11DbError(ByRef Sender As SQLite3Component, ErrorTxt As String)
	B11Say("   [database error] " & ErrorTxt)
End Sub

Constructor B11Form
	With This
		.Name = "B11Form"
		.Text = "B11 database to view test"
		.Designer = @This
		.SetBounds 0, 0, 640, 400
	End With
	With lblStatus
		.Name = "lblStatus" : .Text = "no query yet"
		.Align = DockStyle.alTop : .Height = 24
		.Designer = @This : .Parent = @This
	End With
	With lvRows
		.Name = "lvRows" : .Align = DockStyle.alClient
		.View = ViewStyle.vsDetails
		.FullRowSelect = True
		.Designer = @This : .Parent = @This
	End With
	lvRows.Columns.Add("Name"), , 220
	lvRows.Columns.Add("Role"), , 220
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

Sub B11Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB11 = 0 Then Exit Sub
	pB11->Ticks += 1
	If pB11->Ticks > B11_WATCHDOG_TICKS Then
		B11Say("watchdog fired at stage " & Str(pB11->Stage))
		B11Say("B11 OVERALL: FAIL")
		End 1
	End If
	If pB11->Ticks < 2 Then Exit Sub

	Select Case pB11->Stage
	Case 0
		'' ---- build a database and query it ------------------------------------------------
		B11Say("-- database --")
		Dim As String dbFile = ExePath & "\b11_test.db"
		If FileExists(dbFile) Then Kill dbFile
		Dim As SQLite3Component db
		db.OnErrorOut = @B11DbError
		B11Check("database opened", Str(db.Open(dbFile)), "true")
		db.CreateTable("staff")
		db.AddField("staff", "name", "TEXT")
		db.AddField("staff", "role", "TEXT")
		db.AddItem("staff", "name = 'Ada',   role = 'Mathematician'")
		db.AddItem("staff", "name = 'Grace', role = 'Rear Admiral'")
		db.AddItem("staff", "name = 'Alan',  role = 'Cryptanalyst'")
		B11Check("rows inserted", Str(db.Count("staff")), "3")

		'' rs is 2D: row 0 holds the column names, rows 1..n the data (see A1).
		gRows = db.Find("staff", "", gQuery(), "name, role", "name")
		B11Check("query returned rows", Str(gRows), "3")
		db.Close

		'' ---- populate the view FROM the query ---------------------------------------------
		For r As Integer = 1 To UBound(gQuery, 1)
			Dim As ListViewItem Ptr it = pB11->lvRows.ListItems.Add(gQuery(r, 0))
			If it Then it->Text(1) = gQuery(r, 1)
		Next
		pB11->lblStatus.Text = Str(gRows) & " row(s) loaded"
		pB11->Stage = 1

	Case 1
		'' ---- compare the VIEW against the QUERY, cell by cell ------------------------------
		B11Say("-- the view against the query --")
		B11Check("view row count matches query", Str(pB11->lvRows.ListItems.Count), Str(gRows))
		For r As Integer = 1 To UBound(gQuery, 1)
			Dim As ListViewItem Ptr it = pB11->lvRows.ListItems.Item(r - 1)
			Dim As UString gotName, gotRole
			If it Then gotName = it->Text(0) : gotRole = it->Text(1)
			B11Check("row " & Str(r) & " name matches query", gotName, gQuery(r, 0))
			B11Check("row " & Str(r) & " role matches query", gotRole, gQuery(r, 1))
		Next
		'' Ordering matters: the query asked for ORDER BY name, so the view must be in that order
		'' rather than insertion order. A populate loop that reordered rows would pass a
		'' count-only check.
		B11Check("first row is alphabetically first", pB11->lvRows.ListItems.Item(0)->Text(0), "Ada")
		B11Check("last row is alphabetically last",   pB11->lvRows.ListItems.Item(2)->Text(0), "Grace")
		B11Check("status label reflects the load", pB11->lblStatus.Text, "3 row(s) loaded")

		B11Say("")
		B11Say("B11 RESULT: " & Str(pB11->Pass) & " passed, " & Str(pB11->Fail) & " failed")
		If pB11->Fail = 0 Then
			B11Say("B11 OVERALL: PASS")
			End 0
		Else
			B11Say("B11 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b11_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B11Form f
pB11 = @f
f.Show
App.Run
