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

function InitializeSetup(): Boolean;
begin
  if FileExists(ExpandConstant('{app}\bin\64bit\obs64.exe')) or
     FileExists(ExpandConstant('{app}\bin\64bit\obs.exe')) then
  begin
    Result := True;
    Exit;
  end;

  Result := MsgBox(
    'OBS Studio was not found in the selected folder. Continue only if you plan to choose your OBS Studio install folder on the next screen.',
    mbConfirmation,
    MB_YESNO
  ) = IDYES;
end;
