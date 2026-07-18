'' TestPlan.md A1 -- SQLite3Component data path.
''
'' Closes the "database connectivity is unproven beyond compiling" gap in Testing.md by
'' actually moving data: create a database file, create a table, add columns, insert rows,
'' read them back and check the values, update, delete, then close and REOPEN to prove the
'' data reached disk rather than living in a handle.
''
'' Every check prints "PASS <name>" or "FAIL <name>: expected X got Y", and the program ends
'' with a summary line and a non-zero exit code if anything failed, so it can be asserted on
'' from outside without reading prose.

#include once "SQLite3Component.bi"

Dim Shared As Integer gPass, gFail

'' The component reports failures through this event rather than a return code, so without it
'' a broken statement looks identical to an empty table.
Sub OnDbError(ByRef Sender As SQLite3Component, ErrorTxt As String)
	Print "  [component error] " & ErrorTxt
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

Dim As String DbFile = "a1_test.db"
If FileExists(DbFile) Then Kill DbFile

Dim As SQLite3Component db

'' --- open -------------------------------------------------------------------------------
db.OnErrorOut = @OnDbError
Check("open", Str(db.Open(DbFile)), "true")
Check("file created", Str(FileExists(DbFile)), "true")
Print "  sqlite version: " & db.Version()

'' --- schema -----------------------------------------------------------------------------
Print "  CreateTable -> " & Str(db.CreateTable("people")) & "  err=[" & db.ErrMsg() & "]"
'' The plain three-argument call must work. It used to always fail: nNull defaults to 0,
'' which appended NOT NULL, and SQLite refuses to ALTER TABLE ADD a NOT NULL column with no
'' default. Fixed in SQLite3Component.AddField; these are the regression checks.
Check("AddField, natural 3-arg call", Str(db.AddField("people", "name", "TEXT")), "0")
Check("AddField, natural 3-arg call (2)", Str(db.AddField("people", "age", "INTEGER")), "0")
Check("AddField, text default", Str(db.AddField("people", "city", "TEXT", "Unknown")), "0")
Check("AddField, numeric default", Str(db.AddField("people", "score", "INTEGER", "10")), "0")
Check("AddField, default with apostrophe", Str(db.AddField("people", "note", "TEXT", "it's fine")), "0")

'' --- insert -----------------------------------------------------------------------------
Print "  AddItem Ada   -> " & Str(db.AddItem("people", "name = 'Ada', age = 36")) & "  err=[" & db.ErrMsg() & "]"
Print "  AddItem Grace -> " & Str(db.AddItem("people", "name = 'Grace', age = 45")) & "  err=[" & db.ErrMsg() & "]"
Print "  AddItem Alan  -> " & Str(db.AddItem("people", "name = 'Alan', age = 41")) & "  err=[" & db.ErrMsg() & "]"

Check("row count after 3 inserts", Str(db.Count("people")), "3")
Check("text default applied", db.FindOnly("people", "name = 'Ada'", "city"), "Unknown")
Check("numeric default applied", db.FindOnly("people", "name = 'Ada'", "score"), "10")
Check("apostrophe default applied", db.FindOnly("people", "name = 'Ada'", "note"), "it's fine")
Check("conditional count (age > 40)", Str(db.Count("people", "age > 40")), "2")

'' --- read back individual values --------------------------------------------------------
Check("scalar read: Ada's age", db.FindOnly("people", "name = 'Ada'", "age"), "36")
Check("scalar read: Grace's age", db.FindOnly("people", "name = 'Grace'", "age"), "45")
Check("aggregate: SUM(age)", Str(db.Sum("people", "", "age")), "122")

'' --- read a whole result set ------------------------------------------------------------
'' rs is a 2D array: SQLFind does ReDim rs(nRows, nColumns - 1), with row 0 holding the
'' COLUMN NAMES and rows 1..nRows the data. Reading it as a flat 1D array silently yields
'' cells in memory order, which looks like a truncated result set -- worth stating, because
'' that is exactly the mistake this test made on its first run.
Dim As String rs(Any, Any)
Dim As Long n = db.Find("people", "", rs(), "name, age", "name")
Print "  Find returned " & Str(n) & " row(s); rs dims = (" & Str(UBound(rs, 1)) & ", " & Str(UBound(rs, 2)) & ")"
For r As Integer = 0 To UBound(rs, 1)
	Print "    row " & Str(r) & ": [" & rs(r, 0) & "] [" & rs(r, 1) & "]"
Next
Check("Find row count", Str(n), "3")
Check("result header col 0", rs(0, 0), "name")
Check("result header col 1", rs(0, 1), "age")
Check("row 1 ordered by name", rs(1, 0) & "/" & rs(1, 1), "Ada/36")
Check("row 2 ordered by name", rs(2, 0) & "/" & rs(2, 1), "Alan/41")
Check("row 3 ordered by name", rs(3, 0) & "/" & rs(3, 1), "Grace/45")

'' --- update -----------------------------------------------------------------------------
db.Update("people", "name = 'Ada'", "age = 37")
Check("value after update", db.FindOnly("people", "name = 'Ada'", "age"), "37")

'' --- delete -----------------------------------------------------------------------------
db.DeleteItem("people", "name = 'Alan'")
Check("row count after delete", Str(db.Count("people")), "2")

'' --- persistence: close, reopen, re-read ------------------------------------------------
db.Close
Dim As SQLite3Component db2
db2.OnErrorOut = @OnDbError
Check("reopen", Str(db2.Open(DbFile)), "true")
Check("row count survived reopen", Str(db2.Count("people")), "2")
Check("value survived reopen", db2.FindOnly("people", "name = 'Ada'", "age"), "37")
db2.Close

'' --- summary ----------------------------------------------------------------------------
Print
Print "A1 RESULT: " & Str(gPass) & " passed, " & Str(gFail) & " failed"
If gFail > 0 Then
	Print "A1 OVERALL: FAIL"
	End 1
Else
	Print "A1 OVERALL: PASS"
	End 0
End If
