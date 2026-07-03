' courtesy https://www.freebasic.net/forum/viewtopic.php?t=4199&hilit=Simple+Web+Server
' Simple Web Server, (c) Anselme Dewavrin 2006 - dewavrin@yahoo.com
' Feel free to use it, provided you mention my name.
' based on the example provided with freebasic tweaked by thrive4 march 2024.
' Improved by Xusinboy Bekchanov, 2024.

#include once "Object.bi"
#include once "Dictionary.bi"
	#include once "win/winsock2.bi"
	#include once "windows.bi"
	#include once "win/shellapi.bi"
	#include once "fbthread.bi"

Using My.Sys.ComponentModel

Namespace My.Sys.Forms
	Type HTTPServerRequest
		Headers As String
		HTTPMethod As String
		RelativeURL As String
		Body As String
	End Type
	Type HTTPServerResponce
		Headers As String
		StatusCode As Integer
		Body As String
		BodyFileName As String
		Reason As String
	End Type
	
	Type CLIENT
			_socket     As SOCKET
		ip          As Integer
		port        As Integer
		recvthread  As Any Ptr
		prev        As CLIENT Ptr
		next_       As CLIENT Ptr
		server      As Any Ptr
	End Type
	
	'This class implements a simple HTTP server (Windows only).
	Type HTTPServer Extends Component
	Private:
		#define BuffSize 16
			_socket     As SOCKET
		acceptthread    As Any Ptr
		isrunning       As Integer
		globmutex       As Any Ptr
		filemutex       As Any Ptr
		clientlisthead  As CLIENT Ptr
		
		' multithreaded socket handling
		Declare Sub Del(ByVal client As CLIENT Ptr)
		Declare Function Quit() As Integer
		' thread waiting for data to arrive, parsing HTTP GET requests and sending responses
		Declare Static Sub Receive(ByVal client As CLIENT Ptr)
		Declare Static Sub Accept(server As HTTPServer Ptr)
	Public:
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		As String Address = "127.0.0.1"
		As String HomeDir = "./"
		As Integer Port = 80
		Declare Function Run() As Integer
		Declare Constructor
		Declare Destructor
		OnReceive As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPServer, ByRef Request As HTTPServerRequest, ByRef Responce As HTTPServerResponce)
	End Type
End Namespace

	#include once "HTTPServer.bas"

