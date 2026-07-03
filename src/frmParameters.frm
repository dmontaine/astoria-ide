'#########################################################
'#  frmParameters.bas                                    #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmParameters.bi"
#include once "Main.bi"
#include once "frmCompilerOptions.frm"

'#Region "Form"
	Constructor frmParameters
		This.Name = "frmParameters"
		This.Text = "Parameters"
		This.Caption = ML("Parameters")
		This.StartPosition = FormStartPosition.CenterParent
		This.CancelButton = @cmdCancel
		This.DefaultButton = @cmdOK
		This.OnCreate = @Form_Create
		This.OnShow = @Form_Show
		This.SetBounds 0, 0, 742, 360
		grbCompile.Name = "grbCompile"
		grbCompile.Text = ML("Compile")
		grbCompile.TabIndex = 0
		grbCompile.SetBounds 8, 8, 712, 58
		grbCompile.Parent = @This
		grbMake.Name = "grbMake"
		grbMake.Text = ML("Make")
		grbMake.TabIndex = 7
		grbMake.SetBounds 8, 72, 712, 88
		grbMake.Parent = @This
		grbRun.Name = "grbRun"
		grbRun.Text = ML("Run")
		grbRun.TabIndex = 14
		grbRun.SetBounds 8, 168, 712, 58
		grbRun.Parent = @This
		With grbDebug
			.Name = "grbDebug"
			.Text = ML("Debug")
			.TabIndex = 18
			.SetBounds 8, 232, 712, 58
			.Parent = @This
		End With
		cmdOK.Name = "cmdOK"
		cmdOK.Default = True
		cmdOK.Text = ML("OK")
		cmdOK.TabIndex = 25
		cmdOK.SetBounds 528, 300, 96, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.TabIndex = 26
		cmdCancel.SetBounds 624, 300, 96, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		With txtfbc64
			.Name = "txtfbc64"
			.TabIndex = 6
			.RightMargin = 20
			.SetBounds 136, 24, 561, 21
			.Parent = @grbCompile
		End With
		With txtMake1
			.Name = "txtMake1"
			.TabIndex = 10
			.SetBounds 376, 24, 321, 21
			.Parent = @grbMake
		End With
		With txtMake2
			.Name = "txtMake2"
			.TabIndex = 13
			.SetBounds 376, 48, 321, 21
			.Parent = @grbMake
		End With
		With txtRun
			.Name = "txtRun"
			.TabIndex = 17
			.SetBounds 376, 24, 321, 21
			.Parent = @grbRun
		End With
		With lblfbc64
			.Name = "lblfbc64"
			.Text = ML("Command line") & ":"
			.TabIndex = 4
			.SetBounds 16, 24, 120, 16
			.Caption = ML("Command line") & ":"
			.Parent = @grbCompile
		End With
		With lblMake1
			.Name = "lblMake1"
			.Text = ML("make") & " 1:"
			.TabIndex = 8
			.SetBounds 16, 24, 76, 16
			.Parent = @grbMake
		End With
		With llblMake2
			.Name = "llblMake2"
			.Text = ML("make") & " 2:"
			.TabIndex = 11
			.SetBounds 16, 48, 76, 16
			.Parent = @grbMake
		End With
		With lblRun
			.Name = "lblRun"
			.Text = ML("run") & ":"
			.TabIndex = 15
			.SetBounds 16, 24, 256, 16
			.Parent = @grbRun
		End With
		With cboCompiler64
			.Name = "cboCompiler64"
			.Visible = False
			.TabIndex = 5
			.SetBounds 90, 24, 278, 21
			.Parent = @grbCompile
		End With
		With cboMake1
			.Name = "cboMake1"
			.Text = "ComboBoxEdit12"
			.TabIndex = 9
			.SetBounds 90, 24, 278, 21
			.Parent = @grbMake
		End With
		With cboMake2
			.Name = "cboMake2"
			.Text = "ComboBoxEdit111"
			.TabIndex = 12
			.SetBounds 90, 48, 278, 21
			.Parent = @grbMake
		End With
		With cboRun
			.Name = "cboRun"
			.Text = "ComboBoxEdit13"
			.TabIndex = 16
			.SetBounds 90, 24, 278, 21
			.Parent = @grbRun
		End With
		With txtDebug64
			.Name = "txtDebug64"
			.TabIndex = 24
			.SetBounds 376, 24, 321, 21
			.Parent = @grbDebug
		End With
		With lblDebug64
			.Name = "lblDebug64"
			.Text = ML("debug") & ":"
			.TabIndex = 22
			.SetBounds 16, 28, 266, 17
			.Parent = @grbDebug
		End With
		With cboDebug64
			.Name = "cboDebug64"
			.TabIndex = 23
			.SetBounds 90, 24, 278, 21
			.Parent = @grbDebug
		End With
		With lblAddCompilerOption64
			.Name = "lblAddCompilerOption64"
			.Text = "+"
			.ControlIndex = 6
			.Graphic = "//Add"
			.Caption = "+"
			.Style = LabelStyle.lsText
			.ID = 1058
			.SetBounds 680, 28, 12, 12
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lblAddCompilerOption64_Click)
			.Parent = @grbCompile
		End With
	End Constructor
	
	Destructor frmParameters
	End Destructor
	
	Dim Shared fParameters As frmParameters
	pfParameters = @fParameters
'#End Region

Sub frmParameters.LoadSettings()
	With fParameters
		.txtfbc64.Text = *Compiler64Arguments
		.txtMake1.Text = *Make1Arguments
		.txtMake2.Text = *Make2Arguments
		.txtRun.Text = *RunArguments
		.txtDebug64.Text = *Debug64Arguments
		.cboMake1.Clear
		.cboMake2.Clear
		For i As Integer = 0 To pMakeTools->Count - 1
			.cboMake1.AddItem pMakeTools->Item(i)->Key
			.cboMake2.AddItem pMakeTools->Item(i)->Key
		Next
		.cboMake1.ItemIndex = .cboMake1.IndexOf(*CurrentMakeTool1)
		.cboMake2.ItemIndex = .cboMake2.IndexOf(*CurrentMakeTool2)
		If .cboMake1.ItemIndex = -1 Then .cboMake1.ItemIndex = .cboMake1.IndexOf(*DefaultMakeTool)
		If .cboMake2.ItemIndex = -1 Then .cboMake2.ItemIndex = .cboMake2.IndexOf(*DefaultMakeTool)
		.cboRun.Clear
		For i As Integer = 0 To pTerminals->Count - 1
			.cboRun.AddItem pTerminals->Item(i)->Key
		Next
		.cboRun.ItemIndex = .cboRun.IndexOf(*CurrentTerminal)
		If .cboRun.ItemIndex = -1 Then .cboRun.ItemIndex = .cboRun.IndexOf(*DefaultTerminal)
		.cboDebug64.Clear
		.cboDebug64.AddItem ML("Integrated IDE Debugger")
		.cboDebug64.AddItem ML("Integrated GDB Debugger")
		For i As Integer = 0 To pDebuggers->Count - 1
			.cboDebug64.AddItem pDebuggers->Item(i)->Key
		Next
		.cboDebug64.ItemIndex = IIf(CurrentDebuggerType64 = CustomDebugger, .cboDebug64.IndexOf(*CurrentDebugger64), CurrentDebuggerType64)
		If .cboDebug64.ItemIndex = -1 Then .cboDebug64.ItemIndex = IIf(DefaultDebuggerType64 = CustomDebugger, .cboDebug64.IndexOf(ML(*DefaultDebugger64)), DefaultDebuggerType64)
		If .cboDebug64.ItemIndex = -1 Then .cboDebug64.ItemIndex = 0
	End With
End Sub

Private Sub frmParameters.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fParameters
		.LoadSettings
	End With
End Sub

Private Sub frmParameters.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	
End Sub

Private Sub frmParameters.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fParameters
		WLet(Compiler64Arguments, .txtfbc64.Text)
		WLet(Make1Arguments, .txtMake1.Text)
		WLet(Make2Arguments, .txtMake2.Text)
		WLet(RunArguments, .txtRun.Text)
		WLet(Debug64Arguments, .txtDebug64.Text)
		SetBundledCompilerPath()
		WLet(CurrentMakeTool1, .cboMake1.Text)
		WLet(MakeToolPath1, pMakeTools->Get(*CurrentMakeTool1, pMakeTools->Get(*DefaultMakeTool)))
		WLet(CurrentMakeTool2, .cboMake2.Text)
		WLet(MakeToolPath2, pMakeTools->Get(*CurrentMakeTool2, pMakeTools->Get(*DefaultMakeTool)))
		WLet(CurrentTerminal, .cboRun.Text)
		WLet(TerminalPath, IIf(.cboRun.ItemIndex = 0, pTerminals->Get(*DefaultTerminal), pTerminals->Get(*CurrentTerminal)))
		WLet(CurrentDebugger64, IIf(.cboDebug64.ItemIndex = 0, WStr("Integrated IDE Debugger"), IIf(.cboDebug64.ItemIndex = 1, WStr("Integrated GDB Debugger"), .cboDebug64.Text)))
		CurrentDebuggerType64 = IIf(.cboDebug64.ItemIndex = 0, IntegratedIDEDebugger, IIf(.cboDebug64.ItemIndex = 1, IntegratedGDBDebugger, CustomDebugger))
		WLet(Debugger64Path, IIf(.cboDebug64.ItemIndex = 0, pDebuggers->Get(*DefaultDebugger64), pDebuggers->Get(*CurrentDebugger64)))
		piniSettings->WriteString "Parameters", "Compiler64Arguments", *Compiler64Arguments
		piniSettings->WriteString "Parameters", "Make1Arguments", *Make1Arguments
		piniSettings->WriteString "Parameters", "Make2Arguments", *Make2Arguments
		piniSettings->WriteString "Parameters", "RunArguments", *RunArguments
		piniSettings->WriteString "Parameters", "Debug64Arguments", *Debug64Arguments
		.CloseForm
	End With
End Sub

Private Sub frmParameters.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fParameters.CloseForm
End Sub

Private Sub frmParameters.lblAddCompilerOption64_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fParameters
		If frmCompilerOptions.ShowModal(fParameters) = ModalResults.OK Then
			For i As Integer = 0 To frmCompilerOptions.lvCompilerOptions.ListItems.Count - 1
				If frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Checked Then
					.txtfbc64.Text = RTrim(.txtfbc64.Text) & " " & frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Text(0)
				End If
			Next
			frmCompilerOptions.CloseForm
			.BringToFront
		End If
	End With
End Sub

