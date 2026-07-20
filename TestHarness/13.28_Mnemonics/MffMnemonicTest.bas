'' Minimal MyFbFramework application, built to answer one question for ROADMAP 13.28 part 3:
'' are Alt+C, Alt+G and Alt+R blocked by something in MFF itself -- which every user program
'' built on it would inherit -- or by something specific to Astoria?
''
'' The earlier WinForms control app could not answer this: WinForms does its own mnemonic
'' handling in managed code before DefWindowProc sees the key, so it never exercises the Win32
'' menu-bar search that MFF relies on. This one uses the same framework, the same MainMenu API
'' and the same Form.Menu attachment as Astoria's own menu bar.
''
'' &File and &Tools are the controls: they work in Astoria, so they must work here too, or the
'' test is broken rather than informative.

#include once "mff/Form.bi"
#include once "mff/Menus.bi"
#include once "mff/Panel.bi"
#include once "mff/TabControl.bi"
'' BISECTION STEP 3 (Astoria's EditControl) was ATTEMPTED AND ABANDONED -- see the README.
'' EditControl.bi's own includes are all mff headers, which made it look self-contained, but
'' EditControl.bas references a long tail of Astoria globals (DbgTrace, mApplyingWorkspaceLoad,
'' LineInputWstr, HighlightCurrentWord, pComps, pGlobalTypes, ...). Hosting it here would mean
'' stubbing them one compile at a time, and stubs risk changing the very behaviour under test.
'' Left out deliberately; pick a different rung.

Using My.Sys.Forms

Type MainType Extends Form
	Declare Constructor
	Dim As MainMenu mnu
	Dim As PopupMenu ctx
	'' BISECTION STEP 2: reproduce the window structure Astoria has when the keys are lost.
	'' Its focus chain at that moment is TabControl -> Panel -> Panel -> Form, so the nesting
	'' below is deliberate rather than decorative.
	Dim As Panel pnlOuter
	Dim As Panel pnlInner
	Dim As TabControl tabTest
	Dim As EditControl txtCode
End Type

Constructor MainType
	With This
		.Name = "MffMnemonicTest"
		.Text = "MFF mnemonic test"
		.Designer = @This
		.SetBounds 0, 0, 520, 260
	End With

	'' Each top-level item needs at least one child, or Windows will not open the popup.
	Var miFile = mnu.Add("&File", "", "File")
	miFile->Add("File item", "", "FileItem")

	Var miCode = mnu.Add("&Code", "", "Code")
	miCode->Add("Code item", "", "CodeItem")

	Var miGit = mnu.Add("&Git", "", "Git")
	miGit->Add("Git item", "", "GitItem")

	Var miRun = mnu.Add("&Run", "", "Run")
	miRun->Add("Run item", "", "RunItem")

	Var miTools = mnu.Add("&Tools", "", "Tools")
	miTools->Add("Tools item", "", "ToolsItem")

	'' BISECTION STEP 1 (ROADMAP 13.28 pt 3): Astoria attaches context menus to many controls, and
	'' their items carry accelerator text after a tab exactly as menu-bar items do. MFF builds its
	'' accelerator table from any caption containing a tab, so this reproduces that shape. The
	'' accelerators chosen are the three Astoria really has on the cursed letters:
	''   Ctrl+C = Copy, Ctrl+G = Goto, Ctrl+R = Project Explorer.
	'' If the mnemonics survive this, context menus are not the cause and the bisection moves on.
	Var miCopy = ctx.Add("&Copy" & Chr(9) & "Ctrl+C", "", "Copy")
	Var miGoto = ctx.Add("&Goto" & Chr(9) & "Ctrl+G", "", "Goto")
	Var miExpl = ctx.Add("Project Explorer" & Chr(9) & "Ctrl+R", "", "Explorer")
	This.ContextMenu = @ctx

	'' Panel -> Panel -> TabControl, matching Astoria's nesting. The tab captions are Astoria's
	'' own left-panel tabs, in case the caption text turns out to matter.
	pnlOuter.Name = "pnlOuter"
	pnlOuter.Align = DockStyle.alLeft
	pnlOuter.Width = 240
	pnlOuter.Parent = @This

	pnlInner.Name = "pnlInner"
	pnlInner.Align = DockStyle.alClient
	pnlInner.Parent = @pnlOuter

	tabTest.Name = "tabTest"
	tabTest.Align = DockStyle.alClient
	tabTest.AddTab("Project")
	tabTest.AddTab("Toolbox")
	tabTest.Parent = @pnlInner

	'' The editor fills the rest of the form, as it does in Astoria.
	txtCode.Name = "txtCode"
	txtCode.Align = DockStyle.alClient
	txtCode.Parent = @This

	This.Menu = @mnu
End Constructor

Dim Shared MainF As MainType

MainF.MainForm = True
MainF.Show
'' Focus the tab control, so the probe runs against the same focused window class Astoria had
'' when Alt+C / Alt+G / Alt+R were lost.
MainF.tabTest.SetFocus
App.Run
