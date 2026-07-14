'###############################################################################
'#  ContainerControl.bi                                                        #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "ContainerControl.bi"

Namespace My.Sys.Forms
		Private Function ContainerControl.ReadProperty(ByRef PropertyName As String) As Any Ptr
			FTempString = LCase(PropertyName)
			Select Case FTempString
			Case "autosize": Return @FAutoSize
			Case "canvas": Return @Canvas
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ContainerControl.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "autosize": AutoSize = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	
	Private Sub ContainerControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Property ContainerControl.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property ContainerControl.Visible(Value As Boolean)
		Base.Visible = Value
	End Property
	
	Property ContainerControl.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Property ContainerControl.AutoSize(Value As Boolean)
		FAutoSize = Value
	End Property
	
	Private Operator ContainerControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Operator ContainerControl.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ContainerControl
		WLet(FClassName, "ContainerControl")
		FControlParent = True
	End Constructor
	
	Private Destructor ContainerControl
	End Destructor
End Namespace

	Function ControlIsContainer Alias "ControlIsContainer"(Ctrl As My.Sys.Forms.Control Ptr) As Boolean Export
		Return (*Ctrl Is My.Sys.Forms.ContainerControl)
	End Function


