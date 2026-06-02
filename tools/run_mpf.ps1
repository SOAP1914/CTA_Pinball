# Run MPF for this machine (venv activate + mpf -X -l logs/mpf-current.log).
#
# gmc.cfg encoding: Godot's ConfigFile cannot parse a UTF-8 BOM. If you edit
# gmc.cfg in PowerShell, save as UTF-8 without BOM, e.g.:
#   [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
# Default Out-File / Set-Content often add a BOM and break [keyboard] detection.

$ErrorActionPreference = "Stop"

$rootDir = Split-Path -Parent $PSScriptRoot
$venvActivate = "C:\Users\ricar\mpf-env312\Scripts\Activate.ps1"
$venvPython = "C:\Users\ricar\mpf-env312\Scripts\python.exe"
$mpfExe = "C:\Users\ricar\mpf-env312\Scripts\mpf.exe"
$logFile = Join-Path $rootDir "logs\mpf-current.log"

if (-not (Test-Path $venvActivate)) {
    throw "Missing venv activate script: $venvActivate"
}
if (-not (Test-Path $venvPython)) {
    throw "Missing venv python: $venvPython"
}
if (-not (Test-Path $mpfExe)) {
    throw "Missing mpf executable: $mpfExe"
}

if (-not (Test-Path (Split-Path -Parent $logFile))) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $logFile) -Force | Out-Null
}

# Ensure no prior MPF process is still running.
Get-CimInstance Win32_Process -Filter "name='python.exe'" |
    Where-Object { $_.CommandLine -match "mpf\.exe" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Get-Process mpf -ErrorAction SilentlyContinue | Stop-Process -Force

# Activate venv so PATH and env variables are consistent in this shell.
. $venvActivate

Push-Location $rootDir
try {
    & $venvPython $mpfExe -X -l $logFile
}
finally {
    Pop-Location
}
