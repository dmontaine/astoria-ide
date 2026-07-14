'############################################################################################
'#  sudoku_solver                                                                           #
'#  This file is an examples of MyFBFramework.                                              #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                                 #
'# See also https://github.com/tropicalwzc/ice_sudoku.github.io/blob/master/sudoku_solver.c #
'############################################################################################

''Clears candidates in the row, column, and box of point (x,y)
Sub Clear_Point(sudo(Any, Any, Any) As Integer, ByVal tryNum As Integer, ByVal x As Integer, ByVal y As Integer)
	For v As Integer = 0 To 8
		sudo(tryNum, v, y) = 0
		sudo(tryNum, x, v) = 0
		sudo(v + 1, x, y) = 0
	Next v
	
	For r As Integer = 0 To 8
		sudo(tryNum, r \ 3 + x - x Mod 3, r Mod 3 + y - y Mod 3) = 0
	Next r
End Sub

''Completely clears the candidate array
Sub Clear_Bits(Save(Any, Any, Any) As Integer)
	For i As Integer = 0 To 8
		For j As Integer = 0 To 8
			For p As Integer = 1 To 9
				Save(p, i, j) = 0
			Next p
		Next j
	Next i
End Sub

Sub CopySudoMix(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer)
	Dim As Integer i, k, p
	For i = 0 To 8
		For k = 0 To 8
			Sudo(0, i, k) = SudoExt(i, k)
		Next k
	Next i
End Sub


''Copies a sudoku grid in candidate-bitmap form Sudo(0 To 9, 0 To 8, 0 To 8)
Sub BitCopySudo(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any, Any) As Integer)
	Dim As Integer i, k, p
	For p = 0 To 9
		For i = 0 To 8
			For k = 0 To 8
				Sudo(p, i, k) = SudoExt(p, i, k)
			Next k
		Next i
	Next p
End Sub

' Determines whether value z may be placed at point (x,y)
Function CanPutIn(Sudo(Any, Any, Any) As Integer, ByVal x As Integer, ByVal y As Integer, ByVal z As Integer) As Boolean
	If Sudo(0, x, y) <> 0 Then
		Return False
	End If
	Dim As Integer a, b
	
	For a = 0 To 8
		If Sudo(0, a, y) = z Then
			Return False
		End If
	Next a
	
	For b = 0 To 8
		If Sudo(0, x, b) = z Then
			Return False
		End If
	Next b
	
	For a = (x \ 3) * 3 To (x \ 3) * 3 + 2
		For b = (y \ 3) * 3 To (y \ 3) * 3 + 2
			If Sudo(0, a, b) = z Then
				Return False
			End If
		Next b
	Next a
	Return True
End Function

' Sums lay(0 To 8, 0 To 8)
Function SumLay(lay(Any, Any) As Integer, ByVal q As Integer, ByVal p As Integer) As Integer
	Dim As Integer  x, y
	For x = q * 3 To q * 3 + 2
		For y = p * 3 To p * 3 + 2
			If lay(x, y) = 0 Then
				Return 0
			End If
		Next y
	Next x
	Return 9
End Function

' Determines whether value z already exists in the 3x3 box containing (x,y)
Function IsExist(Sudo(Any, Any, Any) As Integer, ByVal x As Integer, ByVal y As Integer, ByVal z As Integer) As Boolean
	Dim As Integer a, b
	For a = (x \ 3) * 3 To (x \ 3) * 3 + 2
		For b = (y \ 3) * 3 To (y \ 3) * 3 + 2
			If Sudo(0, a, b) = z Then
				Return True
			End If
		Next b
	Next a
	Return False
End Function

' Refreshes the sudoku using cell (naked single) elimination   sudo(0 To 9, 0 To 8, 0 To 8)
Function Change_Bit(Sudo(Any, Any, Any) As Integer) As Integer
	Dim As Integer con, py, l, v, i, k
	Dim As Boolean al = 0
	For i = 0 To 8
		For k = 0 To 8
			If Sudo(0, i, k) <> 0 Then
				Continue For
			End If
			For l = 1 To 9
				If Sudo(l, i, k) = 1 Then
					If con = 1 Then
						con = 0
						Exit For
					Else
						con = 1
						py = l
					End If
				End If
			Next l
			If con = 1 Then
				Sudo(0, i, k) = py
				For v = 0 To 8
					Sudo(py, v, k) = 0
					Sudo(py, i, v) = 0
					Sudo(py, v \ 3 + i - i Mod 3, v Mod 3 + k - k Mod 3) = 0
				Next v
				al = True
				con = 0
			End If
		Next k
	Next i
	Return al
End Function

' Refreshes the sudoku using box (hidden single) elimination
Function Square_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer p, a, b, i, k, r, u, v, block(0 To 9)
	Dim As Boolean label
	For a = 0 To 2
		For b = 0 To 2
			Dim sum As Integer
			For i = a * 3 To a * 3 + 2
				For k = b * 3 To b * 3 + 2
					If Sudo(0, i, k) = 0 Then
						sum += 1
						For p = 1 To 9
							block(p) += Sudo(p, i, k)
						Next p
					End If
				Next k
			Next i
			For p = 1 To 9
				If block(p) = 1 Then
					For r = 0 To 8
						i = r \ 3 + a * 3
						k = r Mod 3 + b * 3
						If Sudo(p, i, k) = 1 Then
							Sudo(0, i, k) = p
							For u = 1 To 9
								Sudo(u, i, k) = 0
							Next u
							For v = 0 To 8
								Sudo(p, v, k) = 0
								Sudo(p, i, v) = 0
							Next v
							label = True
							Exit For
						End If
					Next r
				End If
				block(p) = 0
			Next p
		Next b
	Next a
	Return label
End Function

' Refreshes the sudoku using row elimination
Function Row_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Boolean ChangeOr = False
	Dim As Integer i, k, p, u, v, r
	Dim row(1 To 10) As Integer
	
	For i = 0 To 8
		For k = 0 To 8
			If Sudo(0, i, k) <> 0 Then
				Continue For
			End If
			For p = 1 To 9
				row(p) += Sudo(p, i, k)
			Next p
		Next k
		For p = 1 To 9
			If row(p) = 1 Then
				For k = 0 To 8
					If Sudo(p, i, k) = 1 Then
						Sudo(0, i, k) = p
						For u = 1 To 9
							Sudo(u, i, k) = 0
						Next u
						For v = 0 To 8
							Sudo(p, v, k) = 0
							Sudo(p, i, v) = 0
						Next v
						For r = 0 To 8
							Sudo(p, r \ 3 + i - i Mod 3, r Mod 3 + k - k Mod 3) = 0
						Next r
						ChangeOr = True
						Exit For
					End If
				Next k
			End If
			row(p) = 0
		Next p
	Next i
	
	Return ChangeOr
End Function

' Refreshes the sudoku using column elimination
Function Col_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Boolean changeor
	Dim As Integer Col(11), Colnum(11)
	For k As Integer = 0 To 8
		For i As Integer = 0 To 8
			If Sudo(0, i, k) <> 0 Then Continue For
			For p As Integer = 1 To 9
				If Sudo(p, i, k) = 1 Then
					Col(p) = Col(p) + 1
					Colnum(p) = i
				End If
			Next p
		Next i
		For p As Integer = 1 To 9
			If Col(p) = 1 Then
				Sudo(0, Colnum(p), k) = p
				For u As Integer = 0 To 8
					Sudo(p, Colnum(p), u) = 0
					Sudo(u + 1, Colnum(p), k) = 0
					Sudo(p, Colnum(p), u) = 0
					Sudo(p, u \ 3 + Colnum(p) - (Colnum(p) Mod 3), (u Mod 3) + k - (k Mod 3)) = 0
				Next u
				changeor = True
			End If
			Col(p) = 0
		Next p
	Next k
	Return changeor
End Function

' Quickly refreshes the candidate map by combining row, column, box, and cell elimination
Function PreSolveSudo(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim lok As Boolean
	Do While Square_Bit(Sudo()) Or Row_Bit(Sudo()) Or Col_Bit(Sudo())
		Change_Bit(Sudo())
		lok = True
	Loop
	Return lok
End Function

' Builds the base candidate map and applies automatic fast refresh
Sub Build_Bit(Sudo(Any, Any, Any) As Integer)
	Dim As Integer i, k, f
	For f = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If Sudo(0, i, k) = 0 Then
					If CanPutIn(Sudo(), i, k, f) Then
						Sudo(f, i, k) = 1
					End If
				End If
			Next k
		Next i
	Next f
	PreSolveSudo(Sudo())
End Sub

' Builds the base candidate map from a string and applies automatic fast refresh
Sub Build_Bit_FromStr(Sudo(Any, Any, Any) As Integer, SudoStr As String)
	Dim As Integer i, k, f
	If Len(SudoStr) = 81 Then
		For i As Integer = 0 To 80
			Sudo(0, i Mod 9, i \ 9) = SudoStr[i] - 48 'Asc("0")
		Next i
	End If
	For f = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If Sudo(0, i, k) = 0 Then
					If CanPutIn(Sudo(), i, k, f) Then
						Sudo(f, i, k) = 1
					End If
				End If
			Next k
		Next i
	Next f
	PreSolveSudo(Sudo())
End Sub

' Determines whether the current sudoku has an unsolvable contradiction  TempSudo(0 To 9, 0 To 8, 0 To 8)
Function LineCheck(TempSudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer i, k, p
	' Checks whether rows, columns, and boxes satisfy the logic
	For p = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If TempSudo(0, i, k) = p Then Exit For
				If TempSudo(p, i, k) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
		
		For i = 0 To 8
			For k = 0 To 8
				If TempSudo(0, k, i) = p Then Exit For
				If TempSudo(p, k, i) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
		
		For i = 0 To 8
			For k = 0 To 8
				Dim bx As Integer = i - (i Mod 3) + (k \ 3)
				Dim by As Integer = (i Mod 3) * 3 + (k Mod 3)
				If TempSudo(0, bx, by) = p Then Exit For
				If TempSudo(p, bx, by) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
	Next p
	
	' Checks whether any cell is left unfilled
	For i = 0 To 8
		For k = 0 To 8
			Dim found As Integer = 0
			For p = 0 To 9
				If TempSudo(p, i, k) <> 0 Then
					found = 1
					Exit For
				End If
			Next p
			If found = 0 Then Return False
		Next k
	Next i
	
	Return True
End Function

' Does the sudoku have any empty cells?
Function IsVacant(Sudo(Any, Any, Any) As Integer) As Boolean
	For i As Integer = 0 To 8
		For k As Integer = 0 To 8
			If Sudo(0, i, k) = 0 Then
				Return True
			End If
		Next k
	Next i
	Return False
End Function

' Is the sudoku fully solved?
Function IsOK(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer i, k, mul, sum
	sum = 0 : mul = 1
	For i = 0 To 8
		sum = 0 : mul = 1
		For k = 0 To 8
			sum += Sudo(0, i, k)
			mul *= Sudo(0, i, k)
		Next k
		If sum <> 45 Or mul <> 362880 Then
			Return False
		End If
	Next i
	
	For k = 0 To 8
		sum = 0 : mul = 1
		For i = 0 To 8
			sum += Sudo(0, i, k)
			mul *= Sudo(0, i, k)
		Next i
		If sum <> 45 Or mul <> 362880 Then
			Return False
		End If
	Next k
	Return True
End Function

' Checks whether two sudoku grids are the same
Function Check(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer) As Boolean
	For i As Integer = 0 To 8
		For k As Integer = 0 To 8
			If SudoExt(i, k) <> 0 Then
				If Sudo(0, i, k) <> SudoExt(i, k) Then
					Return False
				End If
			End If
		Next k
	Next i
	Return True
End Function

''Randomly and quickly solves the sudoku
Sub SolveSudo(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer)
	Dim As Integer rng, x, y, q, p, tryNum
	Dim Lay(0 To 8, 0 To 8) As Integer
	Dim As Integer backer, dt
	
	Dim SudoP(0 To 9, 0 To 8, 0 To 8) As Integer
	CopySudoMix(SudoP(), SudoExt())
	''Builds the base candidate map
	Build_Bit(SudoP())

	If Not IsVacant(SudoP()) Then
		''Over 90% of sudokus are this simple - they're solved before even a single refresh pass completes
		''can return directly
		BitCopySudo(Sudo(), SudoP())
		Exit Sub
	End If
	''Records values already tried
	Dim havetry(0 To 9) As Integer

	Do
		dt = 0
		backer = 0
		For i As Integer = 0 To 9
			havetry(i) = 0
		Next i
		''Restores the candidate map to the saved state
		BitCopySudo(Sudo(), SudoP())
		
		For dt = 1 To 9
			tryNum = Int(Rnd * 9) + 1
			While havetry(tryNum) = 1
				tryNum = Int(Rnd * 9) + 1
			Wend
			havetry(tryNum) = 1
			
			If dt >= 2 Then
				If Not LineCheck(Sudo()) Then
					' An error has occurred; roll back to the saved state and retry
					backer = 2
					Exit For
				End If
			End If
			
			If dt >= 2 Then
				If Not IsVacant(Sudo()) Then
					''Looks like it may already be solved - check it
					Exit Do
				End If
			End If
			
			For ii As Integer = 0 To 8
				For kk As Integer = 0 To 8
					Lay(ii, kk) = 0
				Next kk
			Next ii
			
			For b As Integer = 0 To 8
				p = b \ 3
				q = b Mod 3
				
				If IsExist(Sudo(), q * 3, p * 3, tryNum) Then Continue For
				
				x = Int(Rnd * 3) + q * 3
				y = Int(Rnd * 3) + p * 3
				Lay(x, y) = 1
				
				rng = Sudo(tryNum, x, y)
				While rng <> 1
					x = Int(Rnd * 3) + q * 3
					y = Int(Rnd * 3) + p * 3
					If Lay(x, y) = 1 Then
						Continue For
					End If
					Lay(x, y) = 1
					
					If SumLay(Lay(), q, p) = 9 Then
						Exit While
					End If
					rng = Sudo(tryNum, x, y)
				Wend
				
				If Sudo(0, x, y) = 0 Then
					Sudo(0, x, y) = tryNum
					Clear_Point(Sudo(), tryNum, x, y)
					PreSolveSudo(Sudo())
				Else
					''All possibilities have been tried and none returned, meaning tryNum cannot be satisfied in this box; roll back and retry
					backer = 2
					Exit For
				End If
			Next b
		Next dt
		''Only counts as solved once verified identical to the original givens, with all 81 cells filled in full compliance with sudoku rules
	Loop While CBool(backer = 2) OrElse IsOK(Sudo()) OrElse Check(Sudo(), SudoExt())
End Sub
