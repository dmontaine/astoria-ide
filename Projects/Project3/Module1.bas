'' Project3 - AstoriaIDE debugger test bench (console)
'' A longer program for exercising the debugger: breakpoints via F9 / gutter /
'' menu, step in / over / out, the Locals and Watches panels, run-to-cursor,
'' and Stop-while-running. Blank and comment lines are here on purpose so the
'' "don't set a breakpoint on this line" refusal can be tested too.

Declare Function Factorial(ByVal n As Integer) As LongInt
Declare Function Fibonacci(ByVal n As Integer) As LongInt
Declare Sub PrintBanner(ByRef sTitle As String)

Dim As Integer i
Dim As LongInt total = 0
Dim As Integer count = 8

PrintBanner("Compute phase")

'' Loop 1: accumulate factorials. A breakpoint inside this loop hits once per
'' iteration -- good for testing Continue and watches on i / f / total.
For i = 1 To count
	Dim As LongInt f = Factorial(i)      '' step INTO here to enter Factorial
	total += f
	Print "Factorial("; i; ") = "; f; "   running total = "; total
Next i

Print
Print "Sum of factorials 1.."; count; " = "; total

'' Loop 2: recursion. Step into Fibonacci and step out; watch n unwind.
PrintBanner("Fibonacci phase")
For i = 1 To 12
	Dim As LongInt fib = Fibonacci(i)
	Print "Fib("; i; ") = "; fib
Next i

'' Free-run phase: a heartbeat loop so the program genuinely runs. Use this to
'' test Stop-while-running (slice 2B) and to set a breakpoint mid-run that the
'' running program then hits (slice 2C). Put a breakpoint on the "tick" line.
PrintBanner("Heartbeat phase - Stop me, or set a breakpoint on the tick line")
Dim As Integer tick = 0
Do
	tick += 1
	Print "tick "; tick
	Sleep 400
Loop Until tick >= 1000

Print "Done."
End 0


Function Factorial(ByVal n As Integer) As LongInt
	Dim As LongInt result = 1
	Dim As Integer k
	For k = 2 To n
		result *= k
	Next k
	Return result
End Function

Function Fibonacci(ByVal n As Integer) As LongInt
	If n < 2 Then Return n
	Return Fibonacci(n - 1) + Fibonacci(n - 2)
End Function

Sub PrintBanner(ByRef sTitle As String)
	Print
	Print "==== "; sTitle; " ===="
End Sub
