param(
  [Parameter(Mandatory = $true)]
  [string] $SourceDll,

  [string] $AppVersion = "0.1.0",

  [string] $OutputDir = "."
)

$ErrorActionPreference = "Stop"

$sourcePath = Resolve-Path $SourceDll
$scriptPath = Join-Path $PSScriptRoot "ptz-tracking-dock.iss"
$iscc = Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"

if (-not (Test-Path $iscc)) {
  throw "Inno Setup 6 was not found. Install it from https://jrsoftware.org/isinfo.php or with Chocolatey: choco install innosetup -y"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

& $iscc $scriptPath `
  /DSourceDll="$($sourcePath.Path)" `
  /DAppVersion="$AppVersion" `
  /O"$OutputDir"
