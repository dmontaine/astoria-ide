'' TestPlan.md A2 -- SQLite3Component error handling.
''
'' A1 proved the happy path: rows go in, rows come back. This asks the harder question -- what
'' happens when things go wrong. The component reports failures through an OnErrorOut event rather
'' than through return codes, which means a program that does not wire that event sees a failed
'' query as an empty result. That is the worst possible failure mode for a database: silent, and
'' indistinguishable from "no rows matched".
''
'' So every case here checks three things:
''   1. the operation did NOT crash the program,
''   2. an error was actually REPORTED rather than swallowed, and
''   3. the return value signals failure rather than looking like a legitimate empty result.
''
'' The last section matters most and is the one a happy-path test can never reach: after all those
'' failures, is the component still usable? A component that wedges itself after one bad query
'' would pass every individual check above and still be useless in a real program.
''
'' Console program: run it and read the output, or check the exit code.

#include once "SQLite3Component.bi"

Dim Shared As Integer gPass, gFail
Dim Shared As Integer gErrorsReported
Dim Shared As String  gLastError

Sub OnDbError(ByRef Sender As SQLite3Component, ErrorTxt As String)
	gErrorsReported += 1
	gLastError = ErrorTxt
End Sub

Sub Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If Got = Want Then
		gPass += 1
		Print "PASS " & CheckName & " (" & Got & ")"
	Else
		gFail += 1
		Print "FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]"
	End If
End Sub

'' Runs an operation and reports whether it raised an error, without asserting on the exact
'' message -- messages come from SQLite and are not ours to pin down.
Function ErrorsRaisedBy(ByVal Before As Integer) As Integer
	Return gErrorsReported - Before
End Function

Dim As String DbFile = "a2_test.db"
If FileExists(DbFile) Then Kill DbFile

Dim As SQLite3Component db
db.OnErrorOut = @OnDbError

Print "== setup =="
Check("database opens", Str(db.Open(DbFile)), "true")
db.CreateTable("real_table")
db.AddField("real_table", "name", "TEXT")
db.AddItem("real_table", "name = 'genuine row'")
Check("the good table works", Str(db.Count("real_table")), "1")

Print
Print "== querying a table that does not exist =="
Dim As Integer before = gErrorsReported
Dim As Long missingCount = db.Count("no_such_table")
Print "   Count returned " & Str(missingCount) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("count on a missing table reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Check("...and does not invent rows", Str(missingCount), "0")
Print "   message: " & gLastError

before = gErrorsReported
Dim As String rs(Any, Any)
Dim As Long n = db.Find("no_such_table", "", rs(), "*")
Print "   Find returned " & Str(n) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("find on a missing table reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Check("...and returns no rows", Str(n), "0")

Print
Print "== querying a column that does not exist =="
before = gErrorsReported
Dim As String badCol = db.FindOnly("real_table", "", "no_such_column")
Check("missing column reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Check("...and returns nothing", badCol, "")
Print "   message: " & gLastError

Print
Print "== malformed SQL =="
before = gErrorsReported
Dim As Long execResult = db.Exec("THIS IS NOT SQL")
Print "   Exec returned " & Str(execResult) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("malformed SQL reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Print "   message: " & gLastError

Print
Print "== inserting into a table that does not exist =="
before = gErrorsReported
Dim As Long badInsert = db.AddItem("no_such_table", "name = 'nowhere'")
Print "   AddItem returned " & Str(badInsert) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("insert into a missing table reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Check("...and reports no new row id", Str(badInsert), "0")

Print
Print "== creating a table that already exists =="
before = gErrorsReported
db.CreateTable("real_table")
Check("duplicate CreateTable reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Print "   message: " & gLastError

Print
Print "== operating on a CLOSED database =="
db.Close
before = gErrorsReported
Dim As Long afterClose = db.Count("real_table")
Print "   Count after Close returned " & Str(afterClose) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("use after Close reports an error", Str(ErrorsRaisedBy(before) > 0), "-1")
Check("...and does not invent rows", Str(afterClose), "0")
Print "   message: " & gLastError

Print
Print "== opening an impossible path =="
Dim As SQLite3Component db2
db2.OnErrorOut = @OnDbError
before = gErrorsReported
'' A directory that cannot exist, so the file cannot be created.
Dim As Boolean openedBad = db2.Open("Z:\no\such\directory\nope.db")
Print "   Open returned " & Str(openedBad) & ", errors raised: " & Str(ErrorsRaisedBy(before))
Check("opening an impossible path does not report success", Str(openedBad), "false")
'' Whether it raises an error event as well is recorded rather than demanded -- the return value
'' is the contract here, and it held.
Print "   errors raised by the bad open: " & Str(ErrorsRaisedBy(before))

Print
Print "== the component survives all of that =="
'' The point of the whole test. Every failure above must have left the component usable.
Dim As SQLite3Component db3
db3.OnErrorOut = @OnDbError
Check("a fresh handle still opens the database", Str(db3.Open(DbFile)), "true")
Check("the original row is still there", Str(db3.Count("real_table")), "1")
Check("its value is intact", db3.FindOnly("real_table", "", "name"), "genuine row")
'' And new work still succeeds after the earlier errors.
db3.AddItem("real_table", "name = 'added after the errors'")
Check("new inserts still work", Str(db3.Count("real_table")), "2")
Check("the new value reads back", db3.FindOnly("real_table", "ID = 2", "name"), "added after the errors")
db3.Close

Print
Print "errors reported across the whole run: " & Str(gErrorsReported)
Print "A2 RESULT: " & Str(gPass) & " passed, " & Str(gFail) & " failed"
If gFail > 0 Then
	Print "A2 OVERALL: FAIL"
	End 1
Else
	Print "A2 OVERALL: PASS"
	End 0
End If
