'###############################################################################
'#  Component.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Component.bi"

Namespace My.Sys.ComponentModel
	Private Function MarginsType.ToString ByRef As WString
		WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Right & "; " & This.Bottom)
		If FTemp <> 0 Then Return *FTemp Else Return WStr("")
	End Function
	
		Private Function Component.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "designmode": Return @FDesignMode
			Case "classancestor": Return FClassAncestor
			Case "tag": Return Tag
				Case "handle": Return @FHandle
			Case "left": FLeft = This.Left: Return @FLeft
			Case "top": FTop = This.Top: Return @FTop
			Case "width": FWidth = This.Width: Return @FWidth
			Case "height": FHeight = This.Height: Return @FHeight
			Case "parent": Return FParent
			Case "margins": Return @Margins
			Case "margins.left": Return @Margins.Left
			Case "margins.right": Return @Margins.Right
			Case "margins.top": Return @Margins.Top
			Case "margins.bottom": Return @Margins.Bottom
			Case "extramargins": Return @ExtraMargins
			Case "extramargins.left": Return @ExtraMargins.Left
			Case "extramargins.right": Return @ExtraMargins.Right
			Case "extramargins.top": Return @ExtraMargins.Top
			Case "extramargins.bottom": Return @ExtraMargins.Bottom
			Case "name": Return FName
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Component.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "tag": This.Tag = Value
				Case "name": This.Name = QWString(Value)
				Case "designmode": This.DesignMode = QBoolean(Value)
					Case "handle": This.Handle = *Cast(HWND Ptr, Value)
				Case "left": This.Left = QInteger(Value)
				Case "top": This.Top = QInteger(Value)
				Case "width": This.Width = QInteger(Value)
				Case "height": This.Height = QInteger(Value)
				Case "parent": This.Parent = Value
				Case "margins.left": This.Margins.Left = QInteger(Value)
				Case "margins.right": This.Margins.Right = QInteger(Value)
				Case "margins.top": This.Margins.Top = QInteger(Value)
				Case "margins.bottom": This.Margins.Bottom = QInteger(Value)
				Case "extramargins.left": This.ExtraMargins.Left = QInteger(Value)
				Case "extramargins.right": This.ExtraMargins.Right = QInteger(Value)
				Case "extramargins.top": This.ExtraMargins.Top = QInteger(Value)
				Case "extramargins.bottom": This.ExtraMargins.Bottom = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
		Private Function Component.GetTopLevel As Component Ptr
			If FParent = 0 Then
				Return @This
			Else
				Return FParent->GetTopLevel()
			End If
		End Function
	
		Private Property Component.Parent As Component Ptr
			Return FParent
		End Property
		
		Private Property Component.Parent(Value As Component Ptr)
			If FParent <> Value Then
				FParent = Value
				Value->FComponents.Add @This
					If FDesignMode AndAlso FHandle <> 0 AndAlso Value <> 0 AndAlso Value->Handle <> 0 Then
						If GetParent(FHandle) <> Value->Handle Then
							SetParent FHandle, Value->Handle
						End If
					End If
			End If
		End Property
	
	Private Function Component.ClassAncestor ByRef As WString
		If FClassAncestor Then Return *FClassAncestor Else Return WStr("")
	End Function
	
	Private Property Component.DesignMode As Boolean
		Return FDesignMode
	End Property
	
	Private Property Component.DesignMode(Value As Boolean)
		FDesignMode = Value
	End Property
	
	Private Property Component.Name ByRef As WString
		If FName> 0 Then Return *FName Else Return WStr("")
	End Property
	
	Private Property Component.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
			Private Property Component.Handle As HWND
				Return FHandle
			End Property
			
			Private Property Component.Handle(Value As HWND)
				FHandle = Value
			End Property
			
			Private Property Component.LayoutHandle As HWND
				Return FHandle
			End Property
			
			Private Property Component.LayoutHandle(Value As HWND)
				FHandle = Value
			End Property
	
		Private Sub Component.Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
			'#ifdef __USE_GTK__
			'	Dim As Integer iLeft = FLeft, iTop = FTop, iWidth = FWidth, iHeight = FHeight
			'#else
				Dim As Integer iLeft = cLeft, iTop = cTop, iWidth = cWidth, iHeight = cHeight
			'#endif
			If FParent Then
				Dim As Component Ptr cParent = FParent
				If cParent Then
'					iLeft = iLeft + cParent->Margins.Left
'					iTop = iTop + cParent->Margins.Top
					'iWidth = iWidth - cParent->Margins.Left - cParent->Margins.Right
					'iHeight = iHeight - cParent->Margins.Top - cParent->Margins.Bottom
					'iWidth = Min(iWidth, Max(0, cParent->Width - iLeft - cParent->Margins.Right))
					'iHeight = Min(iHeight, Max(0, cParent->Height - iTop - cParent->Margins.Bottom))
				End If
			End If
				If FHandle Then
					MoveWindow FHandle, ScaleX(iLeft), ScaleY(iTop), ScaleX(iWidth), ScaleY(iHeight), True
				End If
		End Sub
	
	Private Sub Component.GetBounds(ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)
		ALeft = This.Left
		ATop = This.Top
		AWidth = This.Width
		AHeight = This.Height
	End Sub
	
	Private Sub Component.SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
		FLeft   = ALeft
		FTop    = ATop
		FWidth  = AWidth
		FHeight = AHeight
		FWidth = Max(FMinWidth, FWidth)
		FHeight = Max(FMinHeight, FHeight)
		Move FLeft, FTop, FWidth, FHeight
	End Sub
	
		Private Property Component.Left As Integer
			If Not (FDesignMode AndAlso (Designer = @This)) Then
					If FHandle Then
						If FParent AndAlso UCase(FParent->ClassName) = "TABCONTROL" Then
						Else
							Dim As RECT R
							GetWindowRect Handle, @R
							MapWindowPoints 0, GetParent(Handle), Cast(Point Ptr, @R), 2
							FLeft = UnScaleX(R.left)
							'If FParent Then FLeft -= FParent->Margins.Left
						End If
					End If
			End If
			Return FLeft
		End Property
		
			Private Property Component.Left(Value As Integer)
				FLeft = Value
				Move FLeft, Top, This.Width, Height
			End Property
	
		Private Property Component.Top As Integer
			If Not (FDesignMode AndAlso (Designer = @This)) Then
					If FHandle Then
						If FParent AndAlso UCase(FParent->ClassName) = "SYSTABCONTROL32" Or UCase(FParent->ClassName) = "TABCONTROL" Then
						Else
							Dim As RECT R
							GetWindowRect Handle,@R
							MapWindowPoints 0, GetParent(Handle), Cast(Point Ptr, @R), 2
							FTop = UnScaleY(R.top)
							'If FParent Then FTop -= FParent->Margins.Top
						End If
					End If
			End If
			Return FTop
		End Property
		
			Private Property Component.Top(Value As Integer)
				FTop = Value
				Move This.Left, FTop, This.Width, Height
			End Property
	
		Private Property Component.Width As Integer
				If FHandle Then
					Dim As RECT R
					GetWindowRect Handle, @R
					MapWindowPoints 0, GetParent(FHandle), Cast(Point Ptr, @R), 2
					FWidth = UnScaleX(R.right - R.left)
					'#endif
				End If
			Return FWidth
		End Property
		
		Private Property Component.Width(Value As Integer)
			FWidth = Max(FMinWidth, Value)
			Move This.Left, This.Top, FWidth, Height
		End Property
	
		Private Property Component.Height As Integer
				If FHandle Then
					Dim As RECT R
					GetWindowRect Handle, @R
					MapWindowPoints 0, GetParent(FHandle), Cast(Point Ptr, @R), 2
					FHeight = UnScaleY(R.bottom - R.top)
				End If
			Return FHeight
		End Property
		
		Private Property Component.Height(Value As Integer)
			FHeight = Max(FMinHeight, Value)
			Move This.Left, This.Top, This.Width, FHeight
		End Property
	
	Private Function Component.ToString ByRef As WString
		Return This.Name
	End Function
	
	Private Sub Component.FreeWidget()
	End Sub
	
	Destructor Component
		If FName Then _Deallocate(FName)
		If FClassAncestor Then _Deallocate(FClassAncestor)
			If FHandle Then
				DestroyWindow FHandle
				FHandle = 0
			End If
	End Destructor
End Namespace

Function ThreadCreate_(ByVal ProcPtr_ As Sub ( ByVal userdata As Any Ptr ), ByVal param As Any Ptr = 0, ByVal stack_size As Integer = 0) As Any Ptr
		Return ThreadCreate(ProcPtr_, param, stack_size)
End Function

Private Sub ThreadsEnter
End Sub

Private Sub ThreadsLeave
End Sub

	Function Q_Component Alias "Q_Component"(Cpnt As Any Ptr) As My.Sys.ComponentModel.Component Ptr __EXPORT__
		Return Cast(My.Sys.ComponentModel.Component Ptr, Cpnt)
	End Function

	Sub ComponentGetBounds Alias "ComponentGetBounds" (Cpnt As My.Sys.ComponentModel.Component Ptr, ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer) __EXPORT__
		Cpnt->GetBounds(ALeft, ATop, AWidth, AHeight)
	End Sub

	Sub ComponentSetBounds Alias "ComponentSetBounds"(Cpnt As My.Sys.ComponentModel.Component Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer) __EXPORT__
		Cpnt->SetBounds(ALeft, ATop, AWidth, AHeight)
	End Sub

	Function IsComponent Alias "IsComponent"(Obj As My.Sys.Object Ptr) As Boolean Export
		If Obj > 0  Then Return *Obj Is My.Sys.ComponentModel.Component Else Return  False
	End Function


