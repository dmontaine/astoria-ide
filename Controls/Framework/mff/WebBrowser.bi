'################################################################################
'#  WebBrowser.bi                                                               #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2023)                                     #
'################################################################################

#include once "Control.bi"
	#include once "win/exdisp.bi"
	#include once "win/unknwnbase.bi"

Namespace My.Sys.Forms
	#define QWebBrowser(__Ptr__) (*Cast(WebBrowser Ptr, __Ptr__))
	Type NewWindowRequestedEventArgs
			Handle As Any Ptr
		Declare Property Handled As Boolean
		Declare Property Handled(Value As Boolean)
		Declare Function GetIsUserInitiated() As Boolean
		Declare Function GetURL() ByRef As WString
	End Type
	
	'`WebBrowser` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`WebBrowser` - Enables the user to navigate Web pages inside your form (Windows, Linux).
	Private Type WebBrowser Extends Control
	Private:
			Declare Static Sub WndProc(ByRef Message As Message)
			Declare Static Sub HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
	Protected:
				hWebBrowser As HINSTANCE
				g_IWebBrowser As IWebBrowser2Vtbl Ptr
				pIWebBrowser As Integer Ptr
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
		Dim As WString Ptr ScriptResult
			'Reads a property value from a stream
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			'Writes a property value to a stream
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property TabIndex As Integer
		'Gets/sets the tab order of the control within its container
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Determines whether the control can receive focus via Tab key
		Declare Property TabStop(Value As Boolean)
		'Navigates to the specified URL
		Declare Sub Navigate(ByVal URL As WString Ptr)
		'Navigates to the next page in history
		Declare Sub GoForward()
		'Navigates to the previous page in history
		Declare Sub GoBack()
		'Execute JavaScript code in the current document
		Declare Function ExecuteScript(ByRef JavaScript As WString, bWait As Boolean = False) ByRef As WString
		'Reloads the current document
		Declare Sub Refresh()
		'Returns the current URL of the displayed document
		Declare Function GetURL() As UString
		'Returns the current navigation state (e.g., Loading, Complete)
		Declare Function State() As Integer
		'Stops loading the current page
		Declare Sub Stop()
		'Retrieves the HTML content of the document's <body> element
		Declare Function GetBody(ByVal flag As Long = 0) As UString
		'Updates the HTML content of the document's <body> element
		Declare Sub SetBody(ByRef tText As WString, ByVal flag As Long = 0)
		Declare Operator Cast As My.Sys.Forms.Control Ptr
		Declare Constructor
		Declare Destructor
		'Triggered when a new browser window is requested (e.g., target="_blank" links)
		OnNewWindowRequested As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As WebBrowser, ByRef e As NewWindowRequestedEventArgs)
		'OnNavigationStarting As Sub(ByRef Sender As WebBrowser)
		'OnNavigationCompleted As Sub(ByRef Sender As WebBrowser)
		'OnWebMessageReceived As Sub(ByRef Sender As WebBrowser)
		'OnWebResourceRequested As Sub(ByRef Sender As WebBrowser)
		'OnContentLoading As Sub(ByRef Sender As WebBrowser)
		'OnDownloadStarting As Sub(ByRef Sender As WebBrowser)
		'OnExecuteScript As Sub(ByRef Sender As WebBrowser)
		'OnHistoryChanged As Sub(ByRef Sender As WebBrowser)
		'OnCreateWebViewCompleted As Sub(ByRef Sender As WebBrowser)
		'OnDocumentTitleChanged As Sub(ByRef Sender As WebBrowser)
		'OnPrintToPDFCompleted As Sub(ByRef Sender As WebBrowser)
		'OnWindowCloseRequested As Sub(ByRef Sender As WebBrowser)
		
	End Type
End Namespace

	#include once "WebBrowser.bas"

