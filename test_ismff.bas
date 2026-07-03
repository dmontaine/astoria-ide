Function IsMyFbFrameworkLibrary(ByRef Path As UString) As Boolean
	Return InStr(LCase(Path), "myfbframework") > 0 AndAlso EndsWith(LCase(Path), "mff64.dll")
End Function
Dim As UString p = "Controls\MyFbFramework\mff64.dll"
Print IsMyFbFrameworkLibrary(p)
Dim As UString p2 = "C:\Users\dmont\VisualFBEditor\Controls\MyFbFramework\mff64.dll"
Print IsMyFbFrameworkLibrary(p2)
