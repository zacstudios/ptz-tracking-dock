#ifndef SourceDll
  #define SourceDll "..\..\artifact\obs-plugins\64bit\ptz-tracking-dock.dll"
#endif

#ifndef AppVersion
  #define AppVersion "0.1.0"
#endif

[Setup]
AppId={{6F8D76E8-BB20-4F9E-A79E-3C9F7F30D2E4}
AppName=PTZ Tracking Dock for OBS
AppVersion={#AppVersion}
AppPublisher=TallyHub Pro
DefaultDirName={code:GetObsDir}
DisableProgramGroupPage=yes
OutputBaseFilename=ptz-tracking-dock-windows-installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayName=PTZ Tracking Dock for OBS

[Files]
Source: "{#SourceDll}"; DestDir: "{app}\obs-plugins\64bit"; DestName: "ptz-tracking-dock.dll"; Flags: ignoreversion

[Code]
function GetObsDir(Default: String): String;
var
  InstallPath: String;
begin
  if RegQueryStringValue(HKLM64, 'Software\OBS Studio', '', InstallPath) then
  begin
    Result := InstallPath;
    Exit;
  end;

  if RegQueryStringValue(HKLM32, 'Software\OBS Studio', '', InstallPath) then
  begin
    Result := InstallPath;
    Exit;
  end;

  Result := ExpandConstant('{autopf}\obs-studio');
end;

function IsObsDir(Dir: String): Boolean;
begin
  Result :=
    FileExists(AddBackslash(Dir) + 'bin\64bit\obs64.exe') or
    FileExists(AddBackslash(Dir) + 'bin\64bit\obs.exe');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  if CurPageID <> wpSelectDir then
    Exit;

  if IsObsDir(WizardDirValue) then
    Exit;

  if MsgBox(
    'OBS Studio was not found in the selected folder. Continue only if this is your OBS Studio install folder.',
    mbConfirmation,
    MB_YESNO
  ) = IDNO then
  begin
    Result := False;
    Exit;
  end;
end;
