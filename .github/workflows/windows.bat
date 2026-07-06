cd ..
cd ..
cd ..

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

set FBC64=%~dp0..\..\Compiler\fbc64.exe
set FORCE_MFF=1

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor\Controls" -Force

7z\7za.exe x "FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z" -oVisualFBEditor\Compiler

cd VisualFBEditor\Controls

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -x "../mff64.dll"

if not exist ../mff64.dll exit 1

cd ..\..\..\src

"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -mt -Wc -O2 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework"

if not exist ../VisualFBEditor64.exe exit 1

cd ..
ls
