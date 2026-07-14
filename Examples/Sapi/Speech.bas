'Speech.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "Speech.bi"
#include once "mff/ComboBoxEdit.bi"

Using My.Sys.Forms
Using Speech

Private Sub TokenCategory2Cob(ByVal pszCategoryId As WString Ptr, ByRef cob As ComboBoxEdit)
	Debug.Print *pszCategoryId
	Dim ClassID As GUID, RIid As GUID
	CLSIDFromString(CLSID_SpObjectTokenCategory, @classID)
	IIDFromString(IID_ISpObjectTokenCategory, @RIid)
	Dim As ISpObjectTokenCategory Ptr pSpObjectTokenCategory
	Debug.Print "CoCreateInstance:          " & CoCreateInstance(@ClassID, NULL, CLSCTX_ALL, @RIid, @pSpObjectTokenCategory)
	Debug.Print "pSpObjectTokenCategory:    " & pSpObjectTokenCategory
	Debug.Print "SetId:                     " & pSpObjectTokenCategory->SetId(pszCategoryId, False)
	
	Dim As IEnumSpObjectTokens Ptr pEnumTokens
	Debug.Print "EnumTokens:                " & pSpObjectTokenCategory->EnumTokens(NULL, NULL, @pEnumTokens)
	Dim pCount As ULong
	Dim mwstr As WString Ptr
	Debug.Print "GetCount:                  " & pEnumTokens->GetCount(@pCount)
	cob.Clear
	
	If pCount > 0 Then
		cob.Enabled = True
		Dim pToken As ISpObjectToken Ptr
		Dim i As Integer
		For i = 0 To pCount-1
			pEnumTokens->Item(i, @pToken)
			pToken->GetStringValue(NULL, @mwstr)
			cob.AddItem *mwstr
			cob.ItemData(cob.ItemCount - 1) = pToken
		Next
		cob.ItemIndex = 0
	Else
		cob.Enabled = False
	End If
	pEnumTokens->Release()
	pSpObjectTokenCategory->Release()
End Sub


