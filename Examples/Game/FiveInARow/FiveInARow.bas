'A small AI experiment for the game of Gomoku (Five in a Row)
'https://zhuanlan.zhihu.com/p/551562016  Illustrated guide to 26 winning Gomoku formations
' Implementing Gomoku AI in VB.NET  http://www.west999.com/www/info/24067-1.htm
' Implementing Gomoku AI - design ideas for a Gomoku AI https://blog.csdn.net/elizabethxxy/article/details/103150370?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_title~default-8.pc_relevant_default&spm=1001.2101.3001.4242.5&utm_relevant_index=11
' Translated to FreeBASIC by Avata. This program requires the MyFbFramework framework, with the visual form designed using VisualFBEditor
' You may copy, distribute, and modify any code in this program; contributions adding LAN multiplayer support are welcome
'
'Change history:
'April 12, 2022 - Avata added dynamic resizing of the board, and fixed an issue where the algorithm became inaccurate and the computer played erratically after enlarging the board from 10x10 to 19x19.
'April 13, 2022 - Avata added the ability to change the board color, and adjusted the search range to change the game's difficulty
'Gomoku rules and gameplay
'1/ Black loses on a forbidden move: a forbidden move is when Black's stone simultaneously creates two or more open threes, a double four, or an overline. When this happens White should immediately point out the forbidden move and wins automatically
'
'2/ White has no forbidden moves. Black's forbidden moves include "double three" (Double Three, including "four-three-three"), "double four" (Double Four, including "four-four-three"), and "overline" (Overline). Black can only win with a "four-three".
'
'3/ Whoever is first to form five consecutive stones of the same color horizontally, vertically, or diagonally on the board wins.
'
'4/ It's different when Black plays an overline (a forbidden move): as long as it's before the game ends, whenever White notices this overline forbidden-move point and points it out to declare victory, White is ruled the winner.
'
'5/ If Black's fifth stone both completes a five-in-a-row and forms a forbidden move at the same time, the forbidden move is voided because the five-in-a-row already exists, and Black wins.
'
'6/ When Black forms a forbidden move, White should point it out immediately, and Black loses at once. If White doesn't notice, or notices but doesn't point it out and keeps responding with moves, Black cannot be ruled as having lost.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "FiveInARow.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/sys.bi"
	#include once "mff/Picture.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/UpDown.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/LinkLabel.bi"
	#include once "mff/NumericUpDown.bi"
	Using My.Sys.Forms
	
	Dim Shared As Integer mSteps, ChessR = 30, ChessSize, WinStepSum 'Stone size, board size WinStepSum, 19->354, 10-> 192
	'Defines the virtual board:
	Dim Shared As Integer Table(Any, Any) ' =0, empty, 1 black stone, 2 white stone
	'Defines the score of each empty cell for the current player:
	Dim Shared pScore(Any, Any) As Integer
	'Defines the score of each empty cell for the current computer:
	Dim Shared cScore(Any, Any) As Integer
	'Defines the player's winning combinations:
	Dim Shared  PersonWin(Any, Any, Any) As Boolean
	'Defines the computer's winning combinations:
	Dim Shared  ComputerWin(Any, Any, Any) As Boolean
	'Defines the player's winning-combination flags:
	Dim Shared  PersonFlag(Any) As Boolean
	'Defines the computer's winning-combination flags:
	Dim Shared ComputerFlag(Any) As Boolean
	'Defines the game-active flag
	Dim Shared PlayingFlag As Boolean
	Dim Shared As Integer zhX, zhY, zhXOld, zhYOld
	Dim Shared As Integer colorPerson, ColorComputer, ColorLastStep, ColorChessBK, ColorChessGrid
	
	
	Type frmWuziqiType Extends Form
		Declare Sub cmdStart_Click(ByRef Sender As Control)
		Declare Sub GameButton_Move(ByRef Sender As Control)
		Declare Sub InitPlayEnvironment()
		Declare Sub CheckWhoWin(ByVal BlackOrWhite As Integer)
		Declare Sub ComputerAI
		Declare Function WinStepsTotal(ByVal n As Long) As Long
		Declare Sub DrawCompter(ByVal x As Integer, ByVal y As Integer)

		Declare Sub Form_Show(ByRef Sender As Form)
		
		Declare Sub Picture1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub cmdChangBK_Click(ByRef Sender As Control)
		Declare Sub Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Constructor
		
		Dim As Picture Picture1
		Dim As GroupBox GroupBox1
		Dim As CommandButton cmdStart, cmdChangBK(1)
		Dim As RadioButton optComputer(1)
		Dim As Label lblInfomation, Label2, lblChessText(1), lblColorBK(1)
		Dim As NumericUpDown numChessSize
		Dim As CheckBox chkComputerFirst
		Dim As LinkLabel LinkLblAbout
		Dim As ColorDialog ColorDialog1
		
	End Type
	
	Constructor frmWuziqiType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmWuziqi
		With This
			.Name = "frmWuziqi"
			.Text = ML("Wuziqi")  '"Gomoku"
			.Designer = @This
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Show)
			.Graphic.Icon.LoadFromResourceID(1, , 48, 48)
			.BorderStyle = FormBorderStyle.FixedSingle
			.SetBounds 0, 0, 811, 667
			.Designer = @This
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 0
			.Cursor = crHand
			.BackColor = 8421376
			.ForeColor = 255
			.SetBounds 6, 8, 625, 625
			.Designer = @This
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture1_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture1_MouseMove)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture1_Paint)
			.Parent = @This
		End With
		
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = ML("Setting") '"Settings"
			.TabIndex = 3
			.SetBounds 638, 13, 159, 242
			.Designer = @This
			.Parent = @This
		End With
		' cmdStart
		With cmdStart
			.Name = "cmdStart"
			.Text = ML("Restart")  '"Restart"
			.TabIndex = 5
			.SetBounds 13, 198, 135, 35
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdStart_Click)
			.Parent = @GroupBox1
		End With
		' optComputer3
		With optComputer(0)
			.Name = "optComputer(0)"
			.Text = ML("Man-Computer Playing")
			.TabIndex = 5
			.Checked = True
			.SetBounds 16, 46, 129, 22
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' optComputer4
		With optComputer(1)
			.Name = "optComputer(1)"
			.Text = ML("Man-Man Playing")
			.TabIndex = 6
			.SetBounds 15, 23, 127, 24
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' lblInfomation
		With lblInfomation
			.Name = "lblInfomation"
			.Text = "lblInfomation"
			.TabIndex = 8
			.BackColor = 255
			.SetBounds 17, 166, 135, 26
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = ML("Chess Board Size") '"Board size:"
			.TabIndex = 8
			.SetBounds 9, 97, 97, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' numChessSize
		With numChessSize
			.Name = "numChessSize"
			.Text = "19"
			.TabIndex = 10
			.MinValue= 6
			.MaxValue= 19
			.SetBounds 114, 98, 31, 17
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' chkComputerFirst
		With chkComputerFirst
			.Name = "chkComputerFirst"
			.Text = ML("Computer first") '"Computer moves first"
			.TabIndex = 9
			.Checked = True
			.SetBounds 18, 74, 117, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' LinkLblAbout
		With LinkLblAbout
			.Name = "LinkLblAbout"
			.Text = ML("Wuziqi(also known as 'Five in a Row', Gomoku, GoLang) is a two-player abstract strategy game generally played with Go pieces on a 19x19 Go board.") & Chr(13, 10)  & _
			        ML("Ruler:")  & Chr(13, 10)  & _
			        ML("The objective of the game is to be the first player to create a sequence of five same-colored pieces vertically, horizontally, or diagonally.") & _
			        ML("Pieces are never taken off the board, and once the whole board is filled, the game draws.") & Chr(13, 10)  & _
			        ML("This APP made by Avata with") & "<a href=""https://www.freebasic.net/"">freeBasic</a>"  & Chr(13, 10)  & _
			        ML("Compile the source code need the frame") & " <a href=""https://github.com/XusinboyBekchanov/MyFbFramework"">MyFbFramework</a>"  & Chr(13, 10)  & _
			        ML("Edited by freeBasic visual design.") & " <a href=""https://github.com/XusinboyBekchanov/VisualFBEditor"">VisualFBEditor</a>" & Chr(13, 10)  & _
			        ML("Download address:") & "<a href=""https://gitee.com/avata/MyFbFramework"">https://gitee.com/avata/MyFbFramework</a> "  & Chr(13, 10)  & _
			        "VisualFBEditor: <a href=""https://gitee.com/avata/VisualFBEditor""> https://gitee.com/avata/VisualFBEditor</a>"
		
			.TabIndex = 10
			.SetBounds 639, 264, 159, 367
			.Designer = @This
			.Parent = @This
		End With
		' lblChessText
		With lblChessText(0)
			.Name = "lblChessText(0)"
			.Text = ML("Chess Background:")
			.TabIndex = 11
			.SetBounds 10, 120, 100, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		With lblChessText(1)
			.Name = "lblChessText(1)"
			.Text = ML("Grid Color:")
			.TabIndex = 11
			.SetBounds 10, 141, 100, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		' lblColorBK
		With lblColorBK(0)
			.Name = "lblColorBK(0)"
			.Text = ""
			.TabIndex = 12
			.Caption = ""
			.SetBounds 103, 123, 15, 14
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' lblColorBK
		With lblColorBK(1)
			.Name = "lblColorBK(1)"
			.Text = ""
			.TabIndex = 12
			.Caption = ""
			.SetBounds 103, 141, 15, 14
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		' cmdChangBK
		With cmdChangBK(0)
			.Name = "cmdChangBK(0)"
			.Text = "..."
			.TabIndex = 13
			.Caption = "..."
			.SetBounds 120, 123, 27, 17
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdChangBK_Click)
			.Parent = @GroupBox1
		End With
		
		With cmdChangBK(1)
			.Name = "cmdChangBK(1)"
			.Text = "..."
			.TabIndex = 13
			.Caption = "..."
			.SetBounds 120, 141, 27, 17
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdChangBK_Click)
			.Parent = @GroupBox1
		End With
		
		' ColorDialog1
		With ColorDialog1
			.Name = "ColorDialog1"
			.SetBounds 692, 1, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		
	End Constructor
	
	Dim Shared frmWuziqi As frmWuziqiType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		App.DarkMode = True
		frmWuziqi.MainForm = True
		frmWuziqi.Show
		App.Run
	#endif
'#End Region

Private Sub frmWuziqiType.cmdStart_Click(ByRef Sender As Control)
	InitPlayEnvironment
End Sub

Private Sub frmWuziqiType.InitPlayEnvironment()
	If ChessSize<> Val(numChessSize.Text) Then
		ChessSize= Max(10, Min(19, Val(numChessSize.Text)))
		numChessSize.Text = Str(ChessSize)
		
		WinStepSum = Max(WinStepsTotal(Val(numChessSize.Text)), 192)
		ReDim As Integer Table(ChessSize+ 1, ChessSize+ 1) ' =0, empty, 1 black stone, 2 white stone
		'Defines the virtual board:
		ReDim Table(ChessSize, ChessSize) As Integer
		'Defines the score of each empty cell for the current player:
		ReDim pScore(ChessSize, ChessSize) As Integer
		'Defines the score of each empty cell for the current computer:
		ReDim cScore(ChessSize, ChessSize) As Integer
		'Defines the player's winning combinations:
		ReDim  PersonWin(ChessSize, ChessSize, WinStepSum) As Boolean
		'Defines the computer's winning combinations:
		ReDim  ComputerWin(ChessSize, ChessSize, WinStepSum) As Boolean
		'Defines the player's winning-combination flags:
		ReDim  PersonFlag(WinStepSum) As Boolean
		'Defines the computer's winning-combination flags:
		ReDim ComputerFlag(WinStepSum) As Boolean
	End If
	With Picture1.Canvas
		.Cls
		For i As Integer = 1 To ChessSize     ''''''draws the game board ChessSize 19*19
			.Line i * ChessR + ChessR / 2, ChessR + ChessR / 2, i * ChessR + ChessR / 2, ChessSize * ChessR + ChessR / 2, ColorChessGrid
			.TextOut i * ChessR + ChessR / 3, ChessR / 3, Str(i), clBlack
			.Line ChessR + ChessR / 2 , ChessR *i + ChessR / 2, ChessSize * ChessR + ChessR / 2, ChessR *i + ChessR / 2, ColorChessGrid
			.TextOut  ChessR / 3 , ChessR *i + ChessR / 3 , Chr(i + 64), clBlack
		Next
	End With
	
	PlayingFlag = True           'Game active
	lblInfomation.Visible = True       'Show the game status label
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.Text = ML("Player Turn......" )  '"Waiting for player to move......"
	Dim  As Integer i, j, m, n

	'Initialize the board
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 1
			Table(i, j) = 0
		Next
	Next

	'Initialize the winning-combination flags
	For i = 0 To WinStepSum
		PersonFlag(i) = True
		ComputerFlag(i) = True
	Next

	'******** Initialize winning combinations ********
	n = 0
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(j + m, i, n) = True
				ComputerWin(j + m, i, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(i, j + m, n) = True
				ComputerWin(i, j + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(j + m, i + m, n) = True
				ComputerWin(j + m, i + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = ChessSize - 1 To 4 Step -1
			For m = 0 To 4
				PersonWin(j - m, i + m, n) = True
				ComputerWin(j - m, i + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	''Since we set the computer to move first and it plays at coordinates ChessSize*ChessR / 2, call the drawing function to render the computer's first move
	If chkComputerFirst.Checked = True Then
		zhX = ChessSize / 2 : zhY = ChessSize/ 2
		zhXOld = -2: zhYOld = -2
		DrawCompter((zhX + 1)*ChessR + ChessR / 2 , (zhY + 1)*ChessR + ChessR / 2 )
		Table(zhX , zhY) = 1              'Since the computer moves first and played at ChessSize / 2, ChessSize / 2, set that cell's value to 1
		'Since the computer has played at ChessSize/ 2, ChessSize/ 2 we need to re-evaluate the player's winning flags
		For i = 0 To WinStepSum
			If PersonWin(zhX,  zhY, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	Else
		zhXOld = -2: zhYOld = -2
	End If

	'******** End of winning-combination initialization ********
	
End Sub

Private Sub frmWuziqiType.Form_Show(ByRef Sender As Form)
	colorPerson = clWhite: ColorComputer = clBlack: ColorLastStep = clPurple: ColorChessBK = 8421376: ColorChessGrid = &HF00f0000
	lblColorBK(0).BackColor = ColorChessBK
	lblColorBK(1).BackColor = ColorChessGrid
	InitPlayEnvironment
End Sub

Private Sub frmWuziqiType.Picture1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If PlayingFlag = False Then Exit Sub '检查游戏状态是否有效
	If x > ChessR  And y > ChessR  And x < ChessSize * ChessR + ChessR  And y < ChessSize * ChessR + ChessR Then
		Dim As Integer i, j, k
		k = mSteps Mod 2
		zhX =  Int(x / ChessR) - 1
		zhY =  Int(y / ChessR) - 1
		'检查当前鼠标点击的格子是否有效
		For i = 0 To ChessSize - 1
			For j = 0 To ChessSize - 1
				If Table(zhX, zhY) > 0 Then
					Exit Sub
				End If
			Next
		Next
		
		Dim myColor As Integer
		'绘制玩家的棋子
		If zhXOld > -1 Then
			Picture1.Canvas.Pen.Color = ColorComputer
			Picture1.Canvas.Brush.Color = ColorComputer
			Picture1.Canvas.Circle((zhXOld + 1) * ChessR + ChessR / 2, (zhYOld + 1) * ChessR + ChessR / 2, ChessR - 2, ColorComputer)
		End If
		Picture1.Canvas.Pen.Color = ColorLastStep
		Picture1.Canvas.Circle((zhX + 1) * ChessR + ChessR / 2, (zhY + 1) * ChessR + ChessR / 2, ChessR - 2, colorPerson)
		zhXOld = zhX:  zhYOld = zhY
		Table(zhX, zhY) = 2
		For i = 0 To WinStepSum
			If ComputerWin(zhX, zhY, i) = True Then
				ComputerFlag(i) = False
			End If
		Next
		
		'重设电脑的获胜标志
		CheckWhoWin(1)               '检查当前玩家是否获胜
		ComputerAI()                '调用电脑算法
	End If
	
End Sub

'*****************************************************************************
'** 模块名称: 获胜检查算法。 CheckWhoWin
'* *
'* * 描述: 此模块执行以下功能:
'* * 1. 检查是否和棋。
'* * 2. 检查电脑是否获胜。
'* * 3. 检查玩家是否获胜。
'**
'*****************************************************************************

Sub frmWuziqiType.CheckWhoWin(ByVal BlackOrWhite As Integer)
	Dim  As Integer i, j, k, m, n
	Dim ca As Integer
	Dim pa As Integer
	Dim ComputerNormal As Integer = 0
	Picture1.Cursor = crHand '14 - 手型
	For i = 0 To WinStepSum
		If ComputerFlag(i) = False Then ComputerNormal = ComputerNormal + 1
	Next
	
	'设定和棋规则
	If ComputerNormal = WinStepSum  - 1 Then
		lblInfomation.Visible = True
		lblInfomation.BackColor = clBlue
		lblInfomation.Text = ML("Noone Win.") '"和棋，请重新开始！"
		PlayingFlag = False
		Exit Sub
	End If
	
	Dim As Integer Xmin, XMax, YMin, YMax
	Xmin = 0: XMax = ChessSize-1
	YMin = 0: YMax = ChessSize-1
	'检查电脑是否获胜
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			ca = 0
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 1 Then
						If ComputerWin(j, k, i) = True Then
							ca = ca + 1
						End If
					End If
				Next
			Next
			
			If ca = 5 Then
				lblInfomation.Visible = True
				lblInfomation.BackColor = clGreen
				lblInfomation.Text = ML("Computer win.")  '"电脑获胜,请重新开始"
				PlayingFlag = False
				Exit Sub
			End If
		End If
	Next
	
	'检查玩家是否获胜
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			pa = 0
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 2 Then
						If PersonWin(j, k, i) = True Then
							pa = pa + 1
						End If
					End If
				Next
			Next
			
			If pa = 5 Then
				lblInfomation.Visible = True
				lblInfomation.BackColor = clRed
				lblInfomation.Text = ML("Player Win.")  '"玩家获胜,请重新开始"
				PlayingFlag = False
				Exit Sub
			End If
		End If
	Next
	
End Sub


'*****************************************************************************
'* * 模块名称: 电脑算法 ComputerAI

'** 描述: 此程序主要执行以下功能：
'** 1. 初始化赋值系统。
'** 2. 赋值加强算法。
'** 3. 计算电脑和玩家的最佳攻击位。
'** 4. 比较电脑和玩家的最佳攻击位并决定电脑的最佳策略。
'** 5. 执行检查获胜函数。
'*****************************************************************************

Sub frmWuziqiType.ComputerAI()
	Dim  As Integer i, j, k, m, n
	Dim dc As Integer
	Dim cab As Integer
	Dim pab As Integer
	If PlayingFlag = False Then Exit Sub
	lblInfomation.Visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.Text = "Computer Searching......"    ' "电脑思考中......"
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 1
			pScore(i, j) = 0
			cScore(i, j) = 0
		Next
	Next
	
	'调整搜索范围，改变游戏难易程度
	Dim As Integer Xmin, XMax, YMin, YMax
	Xmin = 0: XMax = ChessSize-1
	YMin = 0: YMax = ChessSize-1
	Picture1.Cursor = crWait
	'初始化赋值数组
	'* * * * * * * * 电脑加强算法 * * * * * * * *
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			cab = 0
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 1 Then
						If ComputerWin(j, k, i) = True Then
							cab = cab + 1
						End If
					End If
				Next
			Next
			
			Select Case cab
			Case 3
				For m = Xmin To XMax
					For n = YMin To YMax
						If Table(m, n) = 0 Then
							If ComputerWin(m, n, i) = True Then
								cScore(m, n) = cScore(m, n) + 5
							End If
						End If
					Next
				Next
			Case 4
				For m = Xmin To XMax
					For n = YMin To YMax
						If Table(m, n) = 0 Then
							If ComputerWin(m, n, i) = True Then
								DrawCompter((m + 1) * ChessR + ChessR / 2, (n + 1) * ChessR + ChessR / 2)
								Table(m, n) = 1
								For dc = 0 To WinStepSum
									If PersonWin(m, n, dc) = True Then
										PersonFlag(dc) = False
										CheckWhoWin(1)
										Picture1.Cursor = crHand
										Exit Sub
									End If
								Next
							End If
						End If
					Next
				Next
			End Select
		End If
	Next
	
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			pab = 0
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 2 Then
						If PersonWin(j, k, i) = True Then
							pab = pab + 1
						End If
					End If
				Next
			Next
			
			Select Case pab
			Case 3
				For m = Xmin To XMax
					For n = YMin To YMax
						If Table(m, n) = 0 Then
							If PersonWin(m, n, i) = True Then
								pScore(m, n) = pScore(m, n) + ChessR
							End If
						End If
					Next
				Next
			Case 4
				For m = Xmin To XMax
					For n = YMin To YMax
						If Table(m, n) = 0 Then
							If PersonWin(m, n, i) = True Then
								DrawCompter((m + 1) * ChessR + ChessR / 2, (n + 1) * ChessR + ChessR / 2)
								Table(m, n) = 1
								For dc = 0 To WinStepSum
									If PersonWin(m, n, dc) = True Then
										PersonFlag(dc) = False
										CheckWhoWin(0)
										Picture1.Cursor = crHand
										Exit Sub
									End If
								Next
							End If
						End If
					Next
				Next
			End Select
		End If
	Next
	
	'******** 电脑加强算法结束 ********
	
	'******** 赋值系统 ********
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 0 Then
						If ComputerWin(j, k, i) = True Then
							For m = Xmin To XMax
								For n = YMin To YMax
									If Table(m, n) = 1 Then
										If ComputerWin(m, n, i) = True Then
											cScore(j, k) = cScore(j, k) + 1
										End If
									End If
								Next
							Next
						End If
					End If
				Next
			Next
		End If
	Next
	
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			For j = Xmin To XMax
				For k = YMin To YMax
					If Table(j, k) = 0 Then
						If PersonWin(j, k, i) = True Then
							For m = Xmin To XMax
								For n = YMin To YMax
									If Table(m, n) = 2 Then
										If PersonWin(m, n, i) = True Then
											pScore(j, k) = pScore(j, k) + 1
										End If
									End If
								Next
							Next
						End If
					End If
				Next
			Next
		End If
	Next
	
	'******** 赋值系统结束 ********
	
	'* * * * * * * * 分值比较算法 * * * * * * * *
	Dim As Integer a, b, c, d
	Dim cs As Integer = 0
	Dim ps As Integer = 0
	For i = Xmin To XMax
		For j = YMin To YMax
			If cScore(i, j) > cs Then
				cs = cScore(i, j)
				a = i
				b = j
			End If
		Next
		
	Next
	
	For i = Xmin To XMax
		For j = YMin To YMax
			If pScore(i, j) > ps Then
				ps = pScore(i, j)
				c = i
				d = j
			End If
		Next
	Next
	
	If cs > ps Then
		DrawCompter((a + 1) * ChessR + ChessR / 2, (b + 1) * ChessR + ChessR / 2)
		Table(a, b) = 1
		For i = 0 To WinStepSum
			If PersonWin(a, b, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	Else
		DrawCompter((c + 1) * ChessR + ChessR / 2, (d + 1) * ChessR + ChessR / 2)
		Table(c, d) = 1
		For i = 0 To WinStepSum
			If PersonWin(c, d, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	End If
	lblInfomation.Visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.Text = "Player Turn......"  '"等待玩家落子......"
	Picture1.Cursor = crHand
	'******** 分值比较算法结束 ********
	CheckWhoWin(0)
End Sub
''*****************************************************************************
'* * 模块名称: 绘制棋子  DrawCompter
'** 描述: 此函数主要进行电脑棋子的绘制。
'*****************************************************************************

Sub frmWuziqiType.DrawCompter(ByVal x As Integer, ByVal y As Integer)
	Dim As Integer tX, tY
	tX =  Int(x / ChessR)
	tY =  Int(y / ChessR)
	lblInfomation.Visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.Text = ML("Player Turn......" ) '"等待玩家落子......"
	If zhXOld > -1 Then
		Picture1.Canvas.Pen.Color = colorPerson
		Picture1.Canvas.Brush.Color = colorPerson
		Picture1.Canvas.Circle((zhXOld + 1) * ChessR + ChessR / 2, (zhYOld + 1) * ChessR + ChessR / 2, ChessR - 2, colorPerson)
	End If
	Picture1.Canvas.Pen.Color = ColorLastStep
	Picture1.Canvas.Brush.Color = ColorComputer
	Picture1.Canvas.Circle(tX * ChessR + ChessR / 2, tY * ChessR + ChessR / 2, ChessR - 2, ColorComputer)
	zhXOld = tX - 1: zhYOld = tY - 1
End Sub

Public Function frmWuziqiType.WinStepsTotal(ByVal tChessSize As Long) As Long
	'根据输入的棋盘布局n*n计算总共有多少种获胜组合
	'假定棋盘为10X10相应的棋盘数组就是Table(9, 9)
	'水平方向每一列获胜组合是6共10列6*10=60
	' 垂直方向每一-行获胜组合是6共10行8*10=60
	'正对角线方向6+(5+4+3+2+1)*2=36
	'反对角线方向 6+(5+4+3+2+1)*2=36
	' 总的获胜组合数为60 + 60 + 36 +36= 192
	Dim As Long i, j, m, n

	'******** 初始化获胜组合 ********
	n = 0
	n = 0
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = ChessSize - 1 To 4 Step -1
			n = n + 1
		Next
	Next
	Return n
	
End Function

Private Sub frmWuziqiType.Picture1_MouseMove(ByRef Sender As Control, MouseButton As Integer,x As Integer,y As Integer, Shift As Integer)
	If x > ChessR And y > ChessR And x < ChessR * ChessSize And y < ChessR * ChessSize Then
	Else
		frmWuziqi.Cursor = crHand
	End If
End Sub

Private Sub frmWuziqiType.cmdChangBK_Click(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	ColorDialog1.Color = lblColorBK(Index).BackColor
	If ColorDialog1.Execute Then
		lblColorBK(Index).BackColor = ColorChessBK
		If Index = 0 Then
			ColorChessBK = ColorDialog1.Color
		Else
			ColorChessGrid = ColorDialog1.Color
		End If
	End If
End Sub

Private Sub frmWuziqiType.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Canvas.Cls
	For i As Integer = 1 To ChessSize     ''''''draws the game board ChessSize 19*19
		Canvas.Line i * ChessR + ChessR / 2, ChessR + ChessR / 2, i * ChessR + ChessR / 2, ChessSize * ChessR + ChessR / 2, ColorChessGrid
		Canvas.TextOut i * ChessR + ChessR / 3, ChessR / 3, Str(i), clBlack
		Canvas.Line ChessR + ChessR / 2 , ChessR *i + ChessR / 2, ChessSize * ChessR + ChessR / 2, ChessR *i + ChessR / 2, ColorChessGrid
		Canvas.TextOut  ChessR / 3 , ChessR *i + ChessR / 3 , Chr(i + 64), clBlack
	Next
	
	For j As Integer = 0 To ChessSize-1
		For k As Integer = 0 To ChessSize-1
			If Table(j, k) = 1 Then
				Canvas.Pen.Color = ColorComputer
				Canvas.Brush.Color = ColorComputer
				Canvas.Circle((j + 1) * ChessR + ChessR / 2, (k + 1) * ChessR + ChessR / 2, ChessR - 2, ColorComputer)
			ElseIf Table(j, k) = 2 Then
				Canvas.Pen.Color = colorPerson
				Canvas.Brush.Color = colorPerson
				Canvas.Circle((j + 1) * ChessR + ChessR / 2, (k + 1) * ChessR + ChessR / 2, ChessR - 2, colorPerson)
			End If
		Next
	Next
End Sub

