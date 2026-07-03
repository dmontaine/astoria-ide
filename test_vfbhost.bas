#define _NOT_AUTORUN_FORMS_
#include once "windows.bi"
#include once "mff/Form.bi"
#include once "mff/Application.bi"
Using My.Sys.Forms
Dim As Any Ptr h1 = DyLibLoad("C:\Users\dmont\VisualFBEditor\Controls\cJSON\cJSONComponent_x64.dll")
Dim As Any Ptr h2 = DyLibLoad("C:\Users\dmont\VisualFBEditor\Controls\MyFbFramework\mff64.dll")
Print "cJSON="; h1; " mff="; h2; " err="; GetLastError()
