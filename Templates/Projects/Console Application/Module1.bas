' Console application -- created with the Astoria IDE.
' The MyFbFramework console wrapper (mff/Console.bi) provides the window title,
' colours, and key input. Plain FreeBASIC Print writes to the console.

#include once "mff/Console.bi"
#include once "mff/NoInterface.bi"

Dim As ConsoleType Console

Console.Title = "Astoria Console Application"

Console.ForeColor = clGreen
Print "Hello, world!"
Console.ForeColor = clWhite

Print
Print "This is a FreeBASIC console application created with Astoria."
Print "Edit Module1.bas to start building your program."
Print

' Keep the window open when run interactively. Skipped when output is redirected
' to a pipe/file (e.g. the IDE's agent runner captures it), so this never hangs.
If GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) = FILE_TYPE_CHAR Then
	Print "Press any key to exit...";
	Console.ReadKey()
End If
