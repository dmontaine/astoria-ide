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
'' THREE DEFECTS ARE EXPECTED, all inherited from SQLite3Component by a copy that was never run
'' against a real server. They are RECORDED rather than asserted, and the test works around them so
'' that everything downstream still gets exercised -- a test that stops at the first known bug
'' proves nothing about the code after it. Each is called out at the site below.
''
'' SELF-CONTAINED AND SELF-EXITING. Exit code is non-zero if any assertion failed.

#include once "MariaDBBox.bi"

Dim Shared As Integer gPass, gFail, gDefects

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

'' A known-broken behaviour: reported, counted separately, never fails the run. When one of these
'' starts passing, the workaround below it should be removed and the check promoted to Check().
Sub Defect(ByRef DefectName As String, ByVal Broken As Boolean, ByRef Detail As String)
	If Broken Then
		gDefects += 1
		Print "DEFECT " & DefectName & " -- " & Detail
	Else
		Print "FIXED? " & DefectName & " now succeeds -- promote this to a real assertion"
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

'' DEFECT 1 -- CreateTable emits SQLite's AUTOINCREMENT, which MariaDB does not accept
'' (MariaDBBox.bas, CreateTableUtf). The statement is a syntax error, so the table is never
'' created and every subsequent call fails against a table that does not exist.
Dim As Long rcCreate = db.CreateTable("people")
Defect("CreateTable uses SQLite AUTOINCREMENT", rcCreate <> 0, _
	"rc=" & Str(rcCreate) & " err=[" & db.ErrMsg() & "] -- MariaDB needs AUTO_INCREMENT")

'' Workaround so the rest of the test has a table to work with.
If rcCreate <> 0 Then
	Check("workaround: create the table with correct MariaDB syntax", _
		Str(db.Exec("CREATE TABLE people (ID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL)")), "0")
End If

'' DEFECT 2 -- a text default is escaped but never quoted (AddField), so this emits
'' DEFAULT hello and MariaDB rejects it. Same bug as the one A1 found and fixed in SQLite.
Dim As Long rcTextDefault = db.AddField("people", "note", "VARCHAR(64)", "hello")
Defect("AddField does not quote a text default", rcTextDefault <> 0, _
	"rc=" & Str(rcTextDefault) & " err=[" & db.ErrMsg() & "]")

If rcTextDefault <> 0 Then
	Check("workaround: add the column with a quoted default", _
		Str(db.Exec("ALTER TABLE people ADD note VARCHAR(64) DEFAULT 'hello'")), "0")
End If

'' DEFECT 3 -- nNull defaults to 0, which appends NOT NULL with no default value. SQLite refuses
'' this outright; MariaDB accepts it outside strict mode by inventing an implicit default, which
'' is worse: the call succeeds and the column silently does not mean what the caller asked for.
'' Recorded either way, because the outcome depends on the server's sql_mode.
Dim As Long rcName = db.AddField("people", "name", "VARCHAR(64)")
Print "  AddField(3-arg) rc=" & Str(rcName) & " err=[" & db.ErrMsg() & "]"
Defect("AddField appends NOT NULL with no default", rcName <> 0, _
	"rc=" & Str(rcName) & " -- outcome depends on sql_mode; see the column dump below")

If rcName <> 0 Then
	Check("workaround: add a plain nullable column", _
		Str(db.Exec("ALTER TABLE people ADD name VARCHAR(64)")), "0")
End If

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
Check("insert first row",  Str(db.Insert("people", "name='Ada', age=36")), "0")
Check("insert second row", Str(db.Insert("people", "name='Grace', age=45")), "0")
Check("insert third row",  Str(db.Insert("people", "name='Alan', age=41")), "0")
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

Check("insert non-ASCII text", _
	Str(db.Insert("people", "name='Ada Lovelace " & NonAscii & "', age=36")), "0")
Check("non-ASCII survives the round trip", _
	db.FindOnly("people", "age=36 AND ID>3", "name"), "Ada Lovelace " & NonAsciiUtf8)

'' --- update and delete ------------------------------------------------------------------------
Check("update a row", Str(db.Update("people", "name='Ada'", "age=37")), "0")
Check("update took effect", db.FindOnly("people", "name='Ada'", "age"), "37")
Check("delete a row", Str(db.DeleteItem("people", "name='Alan'")), "0")
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
Print "A3 RESULT: " & Str(gPass) & " passed, " & Str(gFail) & " failed, " & _
	Str(gDefects) & " known defects recorded"
If gFail = 0 Then
	Print "A3 OVERALL: PASS (with " & Str(gDefects) & " recorded defects to fix)"
	End 0
Else
	Print "A3 OVERALL: FAIL"
	End 1
End If
