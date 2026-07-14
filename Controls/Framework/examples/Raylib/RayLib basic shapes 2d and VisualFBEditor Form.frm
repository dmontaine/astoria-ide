'################################################################################
' # RayLib basic shapes 2d and VisualFBEditor Form.frm #
' # This file is an examples of MyFBFramework #
' # Authors: Xusinboy Bekchanov, Liu XiaLin #
' ################################################################################
' #Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	Using My.Sys.Forms
	
	' This is where you define module-level Shared variables and Add include file.
	' The "RenderProj" sub is the main rendering code subroutine.
	' 。“RenderProj”。
	Declare Sub RenderProj(Param As Any Ptr)

	' if drawing with RayLib
	#include once "inc/raymath.bi"
	#include once "inc/raylib.bi"
	Using RayLib
	Dim Shared As Single rotation
	Dim Shared As Integer IMAGE_W, IMAGE_H
	#ifdef __USE_WINAPI__
		Dim Shared As HWND HandleRender
	#endif
	
	Type Form1Type Extends Form
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel PanelRender
	End Type
	
	Constructor Form1Type
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "VisualFBEditor-3D"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 350, 300
		End With
		
		' PanelRender
		With PanelRender
			.Name = "PanelRender"
			.Text = "PanelRender"
			.TabIndex = 2
			.BackColor = 8421376
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 90, 10, 230, 240
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = False
		Form1.MainForm = True
		Form1.Show
		' Put the Render code here
		RenderProj(0)
		App.Run
	#endif
' #End Region

' the main rendering code. 。
Sub RenderProj(Param As Any Ptr)
	#ifdef __fbgfx_bi__
		
	#elseif defined(RAYLIB_H)
		While RayLib.WindowShouldClose = False
			Dim t As Double = GetTime()
			 rotation += 0.2  '' Polygon shapes and lines rotation
			' '----------------------------------------------------------------------------------
			' ' Draw
			' '----------------------------------------------------------------------------------
			RayLib.BeginDrawing()
			RayLib.ClearBackground(RAYWHITE)
			RayLib.DrawText("some basic shapes available on raylib", 20, 20, 20, DARKGRAY)
			
			' ' Circle shapes and lines
			RayLib.DrawCircle(IMAGE_W / 5, 120, 35, DARKBLUE)
			RayLib.DrawCircleGradient(IMAGE_W / 5, 220, 60, GREEN, SKYBLUE)
			RayLib.DrawCircleLines(IMAGE_W / 5, 340, 80, DARKBLUE)
			
			' ' Rectangle shapes and ines
			RayLib.DrawRectangle(Int(IMAGE_W / 4 * 2 - 60), 100, 120, 60, RED)
			RayLib.DrawRectangleGradientH(Int(IMAGE_W / 4 * 2 - 90), 170, 180, 130, MAROON, GOLD)
			RayLib.DrawRectangleLines(Int(IMAGE_W / 4 * 2 - 40), 320, 80, 60, ORANGE)  '' NOTE: Uses QUADS internally, not lines
			
			' ' Triangle shapes and lines
			RayLib.DrawTriangle(Type<Vector2>(IMAGE_W / 4.0 * 3.0, 80.0), _
			Type<Vector2>(IMAGE_W / 4.0 * 3.0 - 60.0, 150.0), _
			Type<Vector2>(IMAGE_W / 4.0 * 3.0 + 60.0, 150.0), VIOLET)
			
			RayLib.DrawTriangleLines(Type<Vector2>(IMAGE_W / 4.0 * 3.0, 160.0), _
			Type<Vector2>(IMAGE_W / 4.0 * 3.0 - 20.0, 230.0), _
			Type<Vector2>(IMAGE_W / 4.0 * 3.0 + 20.0, 230.0), DARKBLUE)
			
			' ' Polygon shapes and lines
			RayLib.DrawPoly(Type<Vector2>(IMAGE_W / 4.0 * 3, 330), 6, 80, rotation, BROWN)
			RayLib.DrawPolyLines(Type<Vector2>(IMAGE_W / 4.0 * 3, 330 ), 6, 90, rotation, BROWN)

			' ' Polygon shapes and lines (Alternative :)
			RayLib.DrawPoly(Type<Vector2>(IMAGE_W / 4.0 * 3, 320), 6, 80, rotation, BROWN)
			RayLib.DrawPolyLines(Type<Vector2>(IMAGE_W / 4.0 * 3, 330 ), 6, 90, rotation, BROWN)
			RayLib.DrawPolyLinesEx(Type<Vector2>(IMAGE_W / 4.0 * 3, 320), 6, 80, rotation, 6, BEIGE)
			
			' ' NOTE: We draw all LINES based shapes together to optimize internal drawing,
			' ' this way, all LINES are rendered in a single draw pass
			RayLib.DrawLine(18, 42, IMAGE_W - 18, 42, BLACK)
			RayLib.EndDrawing()
		Wend
	#endif
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	' Initialize the drawing engine in sub Form_Create or Form_Show. The official freeBasic drawing engine is fbgfx,
	' and third-party drawing engines like RayLib are employed. It cannot be mixed simultaneously.
	' Form_CreateForm_Show。freeBasicfbgfxRayLib。。
	IMAGE_W = ScaleX(PanelRender.Width)
	IMAGE_H = ScaleY(PanelRender.Height)
	#ifdef __fbgfx_bi__
		ScreenRes IMAGE_W, IMAGE_H, 32
		ScreenControl(2, Cast(Integer, HandleRender))
	#elseif defined(RAYLIB_H)
		RayLib.SetConfigFlags(FLAG_MSAA_4X_HINT) ' Enable anti-aliasing
		RayLib.InitWindow(IMAGE_W, IMAGE_H, "RaylibWindows")
		HandleRender = RayLib.GetWindowHandle
		If HandleRender = 0 Then
			Debug.Print("Failed to create RayLib window")
			Return
		End If
		RayLib.SetTargetFPS(60) ' Set animation frame rate (fps)
		SetExitKey(0)
		With Camera
			.position   = Type(40, 20, 0)
			.target     = Type(0, 0, 0)
			.up         = Type(0, 1, 0)
			.fovy       = 70
			.projection = CAMERA_PERSPECTIVE
		End With
	#endif
	
	' Move the render windows to container PanelRender.
	' PanelRender。
	If HandleRender > 0 Then
		SetParent(HandleRender, PanelRender.Handle)
		SetWindowLongW(HandleRender, GWL_STYLE, WS_VISIBLE)
		MoveWindow(HandleRender, 0, 0, IMAGE_W, IMAGE_H, True)
	End If
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	#if defined(__fbgfx_bi__)
		
	#elseif defined(RAYLIB_H)
		MoveWindow(HandleRender, 0, 0, ScaleX(PanelRender.Width), ScaleY(PanelRender.Height), True)
	#endif
End Sub

Private Sub Form1Type.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	#ifdef __fbgfx_bi__
	#elseif defined(RAYLIB_H)
		RayLib.CloseWindow
	#endif
End Sub
