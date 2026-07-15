; AstoriaIDE.iss - Inno Setup script for Astoria-IDE
;
; Packages the release tree produced by StageRelease.ps1 into a per-user,
; no-admin-required installer with a proper uninstall entry in Windows
; Settings. Run StageRelease.ps1 first to (re)generate that tree, then
; compile this script - it reads exclusively from the staged tree, never
; back into this dev repo, so the installer only ever contains what
; StageRelease.ps1 decided belongs in a release.
;
; AppId is a fixed GUID (not regenerated per release) so future versions
; upgrade in place instead of installing side-by-side - do not change it.

#define MyAppName "Astoria IDE"
#define MyAppVersion "1.3.7"
#define MyAppPublisher "Astoria IDE Project"
#define MyAppURL "https://github.com/dmontaine/astoria-ide"
#define MyAppExeName "astoria.exe"
#define ReleaseDir GetEnv("USERPROFILE") + "\Astoria-IDE-Release"
#define InstallerOutputDir GetEnv("USERPROFILE") + "\Astoria-IDE-Installer"

[Setup]
AppId={{2F5CBB40-1EF1-4EAD-9630-08F6DF26F1EF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
; Per-user install, no admin/elevation prompt - {autopf} resolves to
; {localappdata}\Programs when PrivilegesRequired is lowest.
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
LicenseFile={#ReleaseDir}\license.txt
OutputDir={#InstallerOutputDir}
OutputBaseFilename=AstoriaIDE-Setup-{#MyAppVersion}
SetupIconFile={#ReleaseDir}\Resources\AstoriaIDE.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// The app's own compiled-in default (ProjectsPath="./Projects", relative to
// wherever astoria.exe runs from) is deliberate and stays untouched in
// source - it's correct for a dev/portable checkout, where Projects/ sits
// visibly alongside the app. It's wrong specifically for *this* installed,
// per-user distribution: {app} resolves under %LOCALAPPDATA%\Programs, so
// the same relative default would put a new user's own project files inside
// a hidden AppData folder. Seeding a fresh astoria.ini here - scoped to this
// install method, not the app's own defaults - points new users at Documents
// instead. Never overwrites an existing ini, so reinstalling/upgrading over
// a copy that already has user-customized settings leaves them untouched.
const
  DefaultProjectsFolderName = 'AstoriaProjects'; // no spaces - avoids path-quoting issues when this is passed through to fbc64/gdb

procedure CurStepChanged(CurStep: TSetupStep);
var
  IniPath, ProjectsPath, IniContent: String;
begin
  if CurStep = ssPostInstall then
  begin
    IniPath := ExpandConstant('{app}\Settings\astoria.ini');
    if not FileExists(IniPath) then
    begin
      ProjectsPath := ExpandConstant('{userdocs}\' + DefaultProjectsFolderName);
      ForceDirectories(ProjectsPath);
      IniContent := '[Options]' + #13#10 + 'ProjectsPath=' + ProjectsPath + #13#10;
      SaveStringToFile(IniPath, IniContent, False);
    end;
  end;
end;
