#define INITGUID

#include once "windows.bi"
#include once "win/ocidl.bi"

'Convert String to BSTR
'Please follow with SysFreeString(BSTR) after use to avoid memory leak
Function StringToBSTR(cnv_string As String) As BSTR
	Dim sb As BSTR
	Dim As Integer n
	n = (MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, StrPtr(cnv_string), -1, NULL, 0)) - 1
	sb = SysAllocStringLen(sb, n)
	MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, StrPtr(cnv_string), -1, sb, n)
	Return sb
End Function

Function BstrToStr(ByVal szW As BSTR) As String
	Static szA As ZString * 256
	If szW = NULL Then Return ""
	WideCharToMultiByte(CP_ACP, 0, szW, -1, szA, 256, NULL, NULL)
	Return szA
End Function

/' Convert a programmatic ID to a class ID '/

Function ProgIDToClassID( ProgID As Const String) As GUID
	Dim Result As GUID
	CLSIDFromProgID(WStr(ProgID), @Result)
	Return Result
End Function

Function CreateObject (ByVal strProgID As String, ByVal clsctx As Integer = CLSCTX_INPROC_SERVER Or CLSCTX_LOCAL_SERVER Or CLSCTX_REMOTE_SERVER) As LPVOID
	Dim pDispatch As IDispatch Ptr
	Dim pUnknown As IUnknown Ptr
	Dim hr As HRESULT
	Dim ClassID As CLSID
	ClassID = ProgIDToClassID(strProgID)
	
	hr = CoCreateInstance(@ClassID, NULL, clsctx, @IID_IUnknown, @pUnknown)
	If hr <> 0 Or pUnknown = 0 Then Return NULL
	
	' Ask for the dispatch interface
	hr = IUnknown_QueryInterface(pUnknown, @IID_IDispatch, @pDispatch)
	' If it fails, return the Iunknown interface
	If hr <> 0 Or pDispatch = 0 Then
		Return pUnknown
	End If

	' Release the IUnknown interface
	IUnknown_Release(pUnknown)
	
	' Return a pointer to the dispatch interface
	Return pDispatch
	
End Function

#include once "WellCOM_Constant.bi"
#include once "WellCOM2.0_vtable.bi"

Dim g As IObject

CoInitialize(NULL)
g = CreateObject("WellCOM.Object")

If (g <> NULL) Then
	
	Dim As LPOLESTR bStrSet = StringToBSTR("AYELMA 2012")
	Dim As LPOLESTR bStrGet = NULL
	
	g->lpvtbl->putstring(g, bStrSet)
	g->lpvtbl->getstring(g, @bStrGet)
	
	Print "Getting a string from COM: "; BstrToStr(bStrGet)
	
	SysFreeString(bStrSet)
	SysFreeString(bStrGet)
	
	g->lpvtbl->Release(g)
	
Else
	
	Print "UNABLE TO LAUNCH THE DLL OBJECT"
	
End If

CoUninitialize()
Sleep

