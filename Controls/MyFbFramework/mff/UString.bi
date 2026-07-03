#define UNICODE
#include once "file.bi"
	#undef FileExists
		#include once "win\shlwapi.bi"
#include once "utf_conv.bi"
#if MEMCHECK
#include once "FBMemCheck.bi"
#else
	#define _Allocate(bytes) Allocate(bytes)
	#define _CAllocate(bytes) CAllocate(bytes)
	#define _CAllocateWithSize(num_elements, size) CAllocate(num_elements, size)
	#define _Reallocate(pt, bytes) Reallocate(pt, bytes)
	#define _Deallocate(pt) Deallocate(pt)
	#macro _New(type_)
		New type_
	#endmacro
	#macro _Delete(pt)
		Delete pt
	#endmacro
	#macro _DeleteSquareBrackets(pt)
		Delete[] pt
	#endmacro
	#define FreeFile_ FreeFile
#endif

Private Function CloseFile_(filenum As Long) As Long
	Return Close(filenum)
End Function
Private Type UStr As UString

'Represents unicode text (Windows, Linux, Android, Web).
Private Type UString Extends WString
Public:
	Declare Constructor()
	Declare Constructor(ByRef Value As WString)
	Declare Constructor(ByRef Value As ZString)
	Declare Constructor(ByRef Value As String)
	Declare Constructor(ByRef Value As UString)
	
	Declare Destructor()
	
	Declare Sub Resize(NewLength As Integer)
	Declare Function AppendBuffer(ByVal addrMemory As Any Ptr, ByVal NumBytes As ULong) As Boolean
	Declare Operator [](ByVal Index As Integer) ByRef As UShort
	
	Declare Operator Let(ByRef Value As WString)
	Declare Operator Let(ByRef Value As UString)
	Declare Operator Let(ByRef Value As String)
	Declare Operator Let(ByRef Value As Const ZString)
	
	Declare Operator Cast() ByRef As WString
	Declare Operator Cast() As Any Ptr
	
	Declare Property Length() As Integer
	Declare Function vptr As WString Ptr
	
	Declare Function StartsWith(ByRef Value As WString) As Boolean
	Declare Function EndsWith(ByRef Value As WString) As Boolean
	Declare Function Contains(ByRef Value As WString) As Boolean
	Declare Function TrimAll As UString
	Declare Function TrimEnd As UString
	Declare Function TrimStart As UString
	Declare Function ToLower As UString
	Declare Function ToUpper As UString
	Declare Function SubString(ByVal start As Integer, ByVal n As Integer, ByRef expression As Const WString = "") As UString
	
	m_Length As Integer
	m_BufferLen As Integer
	m_BytesCount As Integer
	m_Capacity As Integer
	m_Data As WString Ptr
	m_Owner As Any Ptr
	OnChange As Sub(ByRef Sender As UString)
Protected:
	
End Type

Declare Function WStrPtr(ByRef Value As UString) As WString Ptr
Declare Operator & (ByRef LeftText As UString, ByRef RightText As UString) As UString
Declare Function Left Overload(ByRef subject As UString, ByVal n As Integer) As UString
Declare Function Right Overload(ByRef subject As UString, ByVal n As Integer) As UString
Declare Function Val Overload(ByRef subject As UString) As Double
Declare Operator Len(ByRef lhs As UString) As Integer
Declare Function WGet(ByRef subject As WString Ptr) ByRef As WString
Declare Sub WDeAllocateEx(subject() As WString Ptr)

Declare Function ToUtf8(ByRef nWString As WString) As String
Declare Function FromUtf8(pZString As ZString Ptr) As WString Ptr
Declare Function FromHexStrUTF8(ByRef HexString As WString) As String
Declare Function ToHexStrUTF8(ByRef iString As WString) As String
Declare Function FromHexStrUnicode(ByRef HexString As WString) As String
Declare Function ToHexStrUnicode(ByRef iString As WString) As String
Declare Function Replace(ByRef Expression As WString, ByRef FindingText As WString, ByRef ReplacingText As WString, ByVal Start As Integer = 1, ByVal Count As Integer = -1, MatchCase As Boolean = True, ByRef CountReplaced As Integer = 0) As UString
Declare Function ZGet(ByRef subject As ZString Ptr) As String
Declare Function InStrCount(ByRef subject As WString, ByRef searchtext As WString, start As Integer = 1, MatchCase As Boolean = True) As Long
'Declare Function Replace Overload(ByRef wszMainStr As WString, ByRef wszMatchStr As Const WString, ByRef wszReplaceWith As Const WString, ByVal Start As Integer = 1, ByRef Count As Integer = 0, MatchCase As Boolean = True) As String
'Declare Function Replace Overload(ByRef wszMainStr As WString, MatchedStr() As WString Ptr, ReplaceWith() As WString Ptr, ByVal Start As Integer = 1, ByRef Count As Integer = 0, MatchCase As Boolean = True) As String
Declare Function Split Overload(ByRef wszMainStr As String, ByRef Delimiter As Const String, Result() As String, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
Declare Function Split(ByRef wszMainStr As WString, ByRef Delimiter As Const WString, Result() As String, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
Declare Function Split(ByRef wszMainStr As WString, ByRef Delimiter As Const WString, Result() As UString, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
Declare Function Split(ByRef wszMainStr As WString, ByRef Delimiter As Const WString, Result() As WString Ptr, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
Declare Function Split(ByRef wszMainStr As ZString, ByRef Delimiter As Const ZString, Result() As ZString Ptr, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
Declare Function Join Overload(Subject() As String, ByRef Delimiter As Const String, ByVal skipEmptyElement As Boolean = False, iStart As Integer = 0, iStep As Integer = 1) As String
Declare Function Join(Subject() As UString, ByRef Delimiter As Const WString, ByVal skipEmptyElement As Boolean = False, iStart As Integer = 0, iStep As Integer = 1) As UString
Declare Function Join(SubjectPtr() As WString Ptr, ByRef Delimiter As Const WString, ByVal skipEmptyElement As Boolean = False, iStart As Integer = 0, iStep As Integer = 1) As WString Ptr
Declare Function Join(SubjectPtr() As ZString Ptr, ByRef Delimiter As Const ZString, ByVal skipEmptyElement As Boolean = False, iStart As Integer = 0, iStep As Integer = 1) As ZString Ptr

Declare Function StartsWith(ByRef a As Const WString, ByRef b As Const WString, Start As Integer = 0) As Boolean
Declare Function EndsWith(ByRef a As Const WString, ByRef b As Const WString) As Boolean
Declare Function StringExtract Overload(ByRef wszMainStr As WString, ByRef wszMatchStr As Const WString, ByVal nStart As Long = 1, ByVal MatchCase As Boolean = True) As UString
Declare Function StringExtract(ByRef wszMainStr As WString, ByRef wszDelim1 As Const WString, ByRef wszDelim2 As Const WString, ByVal nStart As Long = 1, ByVal MatchCase As Boolean = True) As UString
Declare Function StringSubStringAll(ByRef wszMainStr As WString, ByRef ParseStart As Const WString, ByRef ParseEnd As Const WString, Result() As WString Ptr, MatchCase As Boolean = True) As Long
'When expression Is empty, uses FreeBASIC's native Mid function,extracts a portion of the string,
'In-place replacement: When expression is provided, replaces the specified SubString range With the New larger text
'Example: Dim As WString * 20 mainStr = "Hello World" : Dim As WString * 100 result = SubString(mainStr, 7, 5, "FreeBasic" )(Expected: 'Hello FreeBasic')
Declare Function SubString(ByRef wszMainStr As WString, ByVal start As Integer, ByVal n As Integer, ByRef expression As Const WString = "" ) As UString
Declare Function FormatFileName(ByRef originalName As WString) As String
	Declare Function FileExists Overload(ByRef FileName As UString) As Boolean
	Declare Function FileExists Overload(ByRef FileName As WString) As Boolean

	#include once "UString.bas"