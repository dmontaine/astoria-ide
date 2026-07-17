'###############################################################################
'#  JsonLite.bi                                                                #
'#  Minimal, dependency-free JSON parser/serializer for the Agent MCP pipe.   #
'#  Shared by astoria.exe (AgentPipe) and the astoria-mcp sidecar, so it must #
'#  not depend on the MFF framework or any DLL. Strings are UTF-8 throughout  #
'#  (the pipe and MCP both speak UTF-8); callers convert to/from WString at   #
'#  their own boundary.                                                        #
'#                                                                             #
'#  DOM shape follows cJSON: each value owns a first-Child pointer and a      #
'#  NextSib pointer (object members carry Name). No dynamic-array UDT fields  #
'#  needed. Delete of the root frees the whole tree via the destructor.       #
'###############################################################################
#pragma once

Enum JsonKind
	jkNull
	jkBool
	jkNumber
	jkString
	jkObject
	jkArray
End Enum

Type JsonValue
	Kind As JsonKind = jkNull
	BoolValue As Boolean
	NumValue As Double
	StrValue As String            '' UTF-8 (jkString)
	Name As String                '' UTF-8 member name when the parent is an object
	Child As JsonValue Ptr        '' first child (jkObject/jkArray)
	NextSib As JsonValue Ptr      '' next sibling in the parent's child list

	Declare Function Count() As Integer                          '' children
	Declare Function Find(ByRef nm As String) As JsonValue Ptr   '' object member, 0 if absent
	Declare Function ItemAt(idx As Integer) As JsonValue Ptr     '' 0-based child, 0 if out of range
	Declare Function GetStr(ByRef nm As String, ByRef dflt As String = "") As String
	Declare Function GetNum(ByRef nm As String, dflt As Double = 0) As Double
	Declare Function GetBool(ByRef nm As String, dflt As Boolean = False) As Boolean
	Declare Sub Append(v As JsonValue Ptr)                       '' array element (takes ownership)
	Declare Sub SetMember(ByRef nm As String, v As JsonValue Ptr) '' object member (takes ownership; replaces an existing name)
	Declare Destructor                                           '' frees all descendants
End Type

'' Constructors (heap; caller/parent owns)
Declare Function JsonNewNull() As JsonValue Ptr
Declare Function JsonNewBool(b As Boolean) As JsonValue Ptr
Declare Function JsonNewNumber(n As Double) As JsonValue Ptr
Declare Function JsonNewString(ByRef s As String) As JsonValue Ptr
Declare Function JsonNewObject() As JsonValue Ptr
Declare Function JsonNewArray() As JsonValue Ptr

'' Parse a complete JSON document (UTF-8). Returns 0 on any syntax error.
Declare Function JsonParse(ByRef s As String) As JsonValue Ptr

'' Serialize a value tree to compact JSON (UTF-8, no insignificant whitespace).
Declare Function JsonSerialize(v As JsonValue Ptr) As String

'' Escape a raw UTF-8 string for embedding inside a JSON string literal
'' (returns the content only -- no surrounding quotes).
Declare Function JsonEscape(ByRef s As String) As String

#include once "JsonLite.bas"
