'' TestPlan.md A3 -- MariaDBBox against a real MariaDB server.
''
'' The last unproven data path. A1 did this for SQLite3Component and found two real defects; this
'' is the same exercise for the client-server driver, which is a harder case: the data leaves the
'' process entirely, so "did it persist" means "did it reach another program", not "did it reach a
'' file". Closing the connection and reconnecting is what proves that.
''
'' Credentials come from the environment, never from this file:
''
''   MARIADB_TEST_HOST      default 127.0.0.1
''   MARIADB_TEST_PORT      default 3306
''   MARIADB_TEST_USER      default astoria_test
''   MARIADB_TEST_DB        default astoria_test
''   MARIADB_TEST_PASSWORD  required -- no default, the test refuses to guess
''
'' Run setup_astoria_test.sql once as root to create the database and user.
''
'' FOUR DEFECTS were found by the first run of this test and have since been FIXED in
'' Controls/MariaDBBox/MariaDBBox.bas (ROADMAP 13.20). The checks that recorded them are now
'' regression assertions, marked REGRESSION 1-4 below. All four came from this component being a
'' copy of SQLite3Component that was evidently never run against a server:
''
''   1. CreateTable emitted SQLite's AUTOINCREMENT -- it could never create a table.
''   2. AddField never quoted a text default -- "DEFAULT hello" read as a column reference.
''   3. AddField silently made columns NOT NULL while REPORTING SUCCESS.
''   4. Insert returned 0 whether it succeeded or failed.
''
'' Defects 3 and 4 are the reason this file asserts the way it does. Neither is visible in a return
'' code, and the first version of this test trusted return codes for both -- printing a green
'' "PASS insert first row (0)" for an assertion that would have passed identically had every insert
'' silently failed. So: schema questions are answered by information_schema, and effects are checked
'' independently of what a call claims about itself.
''
'' SELF-CONTAINED AND SELF-EXITING. Exit code is non-zero if any assertion failed.

#include once "MariaDBBox.bi"

Dim Shared As Integer gPass, gFail

Sub OnDbError(ByRef Sender As MariaDBBox, ErrorTxt As String)
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

'' --- connection details, from the environment -------------------------------------------
Dim As String EnvHost = Environ("MARIADB_TEST_HOST")
Dim As String EnvPort = Environ("MARIADB_TEST_PORT")
Dim As String EnvUser = Environ("MARIADB_TEST_USER")
Dim As String EnvDb   = Environ("MARIADB_TEST_DB")
Dim As String EnvPass = Environ("MARIADB_TEST_PASSWORD")

If EnvHost = "" Then EnvHost = "127.0.0.1"
If EnvPort = "" Then EnvPort = "3306"
If EnvUser = "" Then EnvUser = "astoria_test"
If EnvDb   = "" Then EnvDb   = "astoria_test"

'' No default password. A blank one would silently attempt an anonymous login and report a
'' confusing connection failure instead of the real problem, which is an unset variable.
If EnvPass = "" Then
	Print "A3 SKIPPED: MARIADB_TEST_PASSWORD is not set."
	Print "  Run setup_astoria_test.sql once, then: set MARIADB_TEST_PASSWORD=<the password>"
	End 2
End If

Print "-- connecting to " & EnvUser & "@" & EnvHost & ":" & EnvPort & "/" & EnvDb & " --"

Dim As MariaDBBox db
db.OnErrorOut = @OnDbError

Dim As ZString * 256 zHost = EnvHost

'' --- open ---------------------------------------------------------------------------------
Check("open", Str(db.Open(EnvDb, EnvUser, EnvPass, @zHost, CULng(ValInt(EnvPort)))), "true")

If db.GetMySQLPtr() = 0 Then
	Print ""
	Print "A3 OVERALL: FAIL -- could not connect, nothing downstream could be tested."
	End 1
End If

Print "  client/server version: " & db.Version()

'' --- schema -------------------------------------------------------------------------------
'' Start from a known state; a leftover table from a previous run would make every count wrong.
db.Exec("DROP TABLE IF EXISTS people")

'' REGRESSION 1 -- CreateTable emitted SQLite's AUTOINCREMENT, a syntax error on MariaDB, so it
'' could never create a table at all. Fixed to AUTO_INCREMENT.
Check("CreateTable succeeds", Str(db.CreateTable("people")), "0")
Check("the table really exists", Str(db.Count("people")), "0")

'' REGRESSION 2 -- a text default was escaped but never quoted, emitting DEFAULT hello, which
'' MariaDB read as a column reference. Same defect and same fix as the SQLite twin.
Check("AddField with a text default succeeds", _
	Str(db.AddField("people", "note", "VARCHAR(64)", "hello")), "0")

'' A numeric default must still go in UNQUOTED -- the fix distinguishes literals from text rather
'' than quoting everything, and quoting a number would change the column's meaning.
Check("AddField with a numeric default succeeds", _
	Str(db.AddField("people", "score", "INTEGER", "7")), "0")

'' DEFECT 3 -- nNull defaults to 0, which appends NOT NULL with no default value. SQLite refuses
'' this outright; MariaDB accepts it outside strict mode by inventing an implicit default, which
'' is worse: the call succeeds and the column silently does not mean what the caller asked for.
'' Recorded either way, because the outcome depends on the server's sql_mode.
'' REGRESSION 3 -- the return code proves nothing here, which is what made this the nastiest of the
'' four and what the first version of this test got wrong. The call SUCCEEDED either way; only the
'' resulting schema showed that the column had been made NOT NULL behind the caller's back. So the
'' assertion has to ask the server what it actually built.
Check("AddField(3-arg) succeeds", Str(db.AddField("people", "name", "VARCHAR(64)")), "0")

Dim As String nullable()
db.SQLFindOne("SELECT IS_NULLABLE FROM information_schema.COLUMNS " & _
	"WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='people' AND COLUMN_NAME='name'", nullable())
Dim As String nameNullable = ""
If UBound(nullable) >= 0 Then nameNullable = nullable(0)

'' A caller writing AddField(t, "name", "VARCHAR(64)") is asking for a plain column, and must get
'' one. This is the check that would have caught the defect the return code hid.
Check("...and the column is nullable, as asked", nameNullable, "YES")

'' NOT NULL must still be honoured when a default exists -- the fix suppresses it only where the
'' statement would otherwise be meaningless, so this must not have broken the deliberate case.
Check("AddField with a default is still NOT NULL", _
	Str(db.AddField("people", "rank_", "INTEGER", "5")), "0")
Dim As String nullable2()
db.SQLFindOne("SELECT IS_NULLABLE FROM information_schema.COLUMNS " & _
	"WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='people' AND COLUMN_NAME='rank_'", nullable2())
If UBound(nullable2) >= 0 Then Check("...and it is NOT NULL", nullable2(0), "NO")

Check("add an integer column", Str(db.AddField("people", "age", "INTEGER", "0")), "0")

'' Report what the server actually built, rather than trusting what we asked for.
'' Declared (Any, Any) because SQLFind does ReDim rs(nRows - 1, nColumns - 1) -- an array declared
'' without dimensions cannot be indexed two-dimensionally.
Dim As String cols(Any, Any)
Dim As Long nCols = db.SQLFind("SHOW COLUMNS FROM people", cols())
Print "  columns as the server built them (" & Str(nCols) & " rows):"
For i As Integer = 0 To UBound(cols, 1)
	Print "    " & cols(i, 0) & " | " & cols(i, 1) & " | null=" & cols(i, 2) & " | default=" & cols(i, 4)
Next i

'' --- insert -------------------------------------------------------------------------------
'' REGRESSION 4 -- Insert used to return 0 from every error path AND from its success path, which
'' fell off the end unassigned. A caller could not tell a stored row from a silently dropped one.
'' It now returns the new row's id on success and -1 on failure.
''
'' Both halves are asserted, because a fix that only makes success distinguishable is half a fix.
Check("insert returns the new row id",   Str(db.Insert("people", "name='Ada', age=36")),   "1")
Check("insert returns the next row id",  Str(db.Insert("people", "name='Grace', age=45")), "2")
Check("insert returns the third row id", Str(db.Insert("people", "name='Alan', age=41")),  "3")

'' The failing case must be distinguishable from every one of those.
Check("a failed insert reports -1", Str(db.Insert("people", "no_such_column='x'")), "-1")

'' And the effect on the table is still checked independently of what Insert claims -- the return
'' value is now trustworthy, but proving it by its effect is what established that.
Check("row count", Str(db.Count("people")), "3")
Check("conditional count", Str(db.Count("people", "age > 40")), "2")

'' --- read back ----------------------------------------------------------------------------
'' A value that went out must come back identical. Reading through the component's own Find is
'' the point -- the data surviving in the server proves nothing if the wrapper mangles it.
''
'' Note the difference from A1: SQLite3Component puts the column names in row 0, MariaDBBox does
'' not -- SQLFind redims to exactly nRows. Row 0 here is data, not a header.
Dim As String rs(Any, Any)
Dim As Long nRows = db.Find("people", "age > 40", rs(), "name,age", "name")
Check("find returned two rows", Str(nRows), "2")
If nRows = 2 Then
	Check("first match name",  rs(0, 0), "Alan")
	Check("first match age",   rs(0, 1), "41")
	Check("second match name", rs(1, 0), "Grace")
End If

Check("FindOnly single value", db.FindOnly("people", "name='Ada'", "age"), "36")
Check("Sum over a column", Str(db.Sum("people", "", "age")), "122")
Check("MaxID", Str(db.MaxID("people", "ID")), "3")

'' --- UTF-8 round trip -----------------------------------------------------------------------
'' Non-ASCII text is the only way to tell a working conversion from one that happens to be a no-op
'' for ASCII. The asymmetry here is the component's design, not a bug, and is worth stating: Insert
'' takes a UString and converts it to UTF-8 going in, but the result arrays are named rs_Utf8 and
'' come back as raw UTF-8 bytes with no decode on the way out. So the value read back is compared
'' against the UTF-8 ENCODING of what was written, not against the wide string itself.
''
'' Both sides are built from explicit code points rather than typed literally, so the test cannot
'' be broken by how this source file happens to be encoded. That matters more than usual here:
'' Astoria saves BOM-less UTF-8 precisely because FreeBASIC treats a BOM as an instruction to make
'' literals wide, and a literal in this file would be the very ambiguity under test.
Dim As UString NonAscii = WChr(&hC9) & WChr(&hE7) & WChr(&h4E2D)          '' E-acute, c-cedilla, U+4E2D
Dim As String NonAsciiUtf8 = Chr(&hC3, &h89) & Chr(&hC3, &hA7) & Chr(&hE4, &hB8, &hAD)

db.Insert("people", "name='Ada Lovelace " & NonAscii & "', age=36")
Check("non-ASCII row landed", Str(db.Count("people", "ID>3")), "1")
Check("non-ASCII survives the round trip", _
	db.FindOnly("people", "age=36 AND ID>3", "name"), "Ada Lovelace " & NonAsciiUtf8)

'' --- update and delete ------------------------------------------------------------------------
'' Update and DeleteItem return mysql_affected_rows via Exec, so one row changed reads as 1, not 0.
'' The first version of this test expected 0 and reported two failures against working code -- the
'' return conventions are genuinely inconsistent across this API (Exec: -1 on error else affected
'' rows; Insert: 0 regardless), which is worth stating rather than quietly accommodating.
Check("update a row reports one affected", Str(db.Update("people", "name='Ada'", "age=37")), "1")
Check("update took effect", db.FindOnly("people", "name='Ada'", "age"), "37")
Check("delete a row reports one affected", Str(db.DeleteItem("people", "name='Alan'")), "1")
Check("count after delete", Str(db.Count("people")), "3")

'' --- transactions -------------------------------------------------------------------------
'' Worth its own check because a rollback that silently commits is the kind of defect that only
'' shows up in production, and MariaDB only honours it if the table engine is transactional.
db.TransactionBegin()
db.Insert("people", "name='Rolled Back', age=99")
Check("row is visible inside the transaction", Str(db.Count("people", "name='Rolled Back'")), "1")
db.TransactionRollback()
Check("rollback removed it", Str(db.Count("people", "name='Rolled Back'")), "0")

'' --- persistence across a real reconnect --------------------------------------------------
'' The strongest assertion here. Closing drops the socket, so anything still readable afterwards
'' genuinely lives in the server rather than in this process.
db.Close()
Check("reopen after close", _
	Str(db.Open(EnvDb, EnvUser, EnvPass, @zHost, CULng(ValInt(EnvPort)))), "true")
Check("data survived the reconnect", Str(db.Count("people")), "3")
Check("value survived the reconnect", db.FindOnly("people", "name='Ada'", "age"), "37")

'' --- clean up -------------------------------------------------------------------------------
db.Exec("DROP TABLE IF EXISTS people")
db.Close()

Print ""
Print "A3 RESULT: " & Str(gPass) & " passed, " & Str(gFail) & " failed"
If gFail = 0 Then
	Print "A3 OVERALL: PASS"
	End 0
Else
	Print "A3 OVERALL: FAIL"
	End 1
End If
