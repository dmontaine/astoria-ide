cd ..
cd ..

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

set FBC64=%~dp0..\..\Compiler\fbc64.exe
set FORCE_MFF=1

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "Controls" -Force

7z\7za.exe x "FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z" -oCompiler

cd Controls

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -x "../mff64.dll"

if not exist ../mff64.dll exit 1

cd ..\..\..\src

"%FBC64%" "AstoriaIDE.bas" -s gui -gen gcc -mt -Wc -O2 -x "../astoria.exe" "AstoriaIDE.rc" -i "..\Controls\MyFbFramework"

if not exist ../astoria.exe exit 1

cd ..
ls
