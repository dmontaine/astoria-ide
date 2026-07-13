#include once "Component.bi"

Using My.Sys.ComponentModel

Namespace My.Sys.Forms
	Type HTTPRequest
		Headers As String
		ResourceAddress As String
		Body As String
	End Type
	Type HTTPResponce
		Headers As String
		StatusCode As Integer
		Body As String
		BodyFileName As String
		Reason As String
	End Type
	
	'Provides a class for sending HTTP requests and receiving HTTP responses from a resource identified by a URI (Windows, Linux, Web).
	Type HTTPConnection Extends Component
		
	Private:
		FAbort As Boolean
	Public:
			Declare Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		'Get or set request cancellation.
		Declare Property Abort As Boolean
		Declare Property Abort(Value As Boolean)
		
		As String Host = "127.0.0.1"
		As Integer Port = 80
		As Integer Timeout = 3000
			'' AstoriaIDE T-SON-2 (F-N7): was a hardcoded fake "Chrome/115" string with no way for
			'' the host app to change it -- now a configurable property with a neutral, honest
			'' default (identifies the library, doesn't impersonate a browser).
			As String UserAgent = "MyFbFramework-HTTPConnection"
			'' T-SON-2 (F-N7): Responce.Body accumulated with no cap -- a hostile or huge endpoint
			'' could exhaust the host app's memory. 0 = unlimited (unchanged default behavior);
			'' set to a positive byte count to stop reading once Body reaches that size.
			As Integer MaxResponseSize = 0
		'Get response content and HTTP status code.
		Declare Sub CallMethod(HTTPMethod As String, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
		Declare Constructor
		Declare Destructor
		OnReceive  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
		OnComplete As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
	End Type
End Namespace

	#include once "HTTP.bas"

