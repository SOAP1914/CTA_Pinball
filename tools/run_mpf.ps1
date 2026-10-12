# Run MPF for this machine (venv activate + mpf -X -l logs/mpf-current.log).
#
# gmc.cfg encoding: Godot's ConfigFile cannot parse a UTF-8 BOM. If you edit
# gmc.cfg in PowerShell, save as UTF-8 without BOM, e.g.:
#   [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
# Default Out-File / Set-Content often add a BOM and break [keyboard] detection.
#
# Godot also corrupts YAML with tab indentation. run_mpf auto-fixes tabs before launch.

$ErrorActionPreference = "Stop"

$rootDir = Split-Path -Parent $PSScriptRoot
$venvActivate = "C:\Users\ricar\mpf-env312\Scripts\Activate.ps1"
$venvPython = "C:\Users\ricar\mpf-env312\Scripts\python.exe"
$mpfExe = "C:\Users\ricar\mpf-env312\Scripts\mpf.exe"
$logFile = Join-Path $rootDir "logs\mpf-current.log"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Expand-LeadingTabs {
    param([string]$Line)

    $i = 0
    while ($i -lt $Line.Length -and ($Line[$i] -eq ' ' -or $Line[$i] -eq "`t")) {
        $i++
    }

    if ($i -eq 0) {
        return $Line
    }

    $leading = $Line.Substring(0, $i)
    $rest = $Line.Substring($i)
    $expanded = $leading -replace "`t", "    "
    return $expanded + $rest
}

function Repair-YamlTabs {
    param([string]$Root)

    # Godot/Cursor often rewrite YAML with tabs (illegal in YAML). Fix before MPF loads.
    $yamlFiles = @()
    $yamlFiles += Get-ChildItem -Path (Join-Path $Root "config") -Recurse -Include *.yaml,*.yml -File -ErrorAction SilentlyContinue
    $yamlFiles += Get-ChildItem -Path (Join-Path $Root "modes") -Recurse -Include *.yaml,*.yml -File -ErrorAction SilentlyContinue

    foreach ($yamlFile in $yamlFiles) {
        $yamlPath = $yamlFile.FullName
        $text = [System.IO.File]::ReadAllText($yamlPath)
        if ($text -notmatch "`t") {
            continue
        }

        $fixed = (($text -split "`r?`n", -1) | ForEach-Object { Expand-LeadingTabs $_ }) -join "`n"
        $item = Get-Item -LiteralPath $yamlPath
        if ($item.IsReadOnly) {
            $item.IsReadOnly = $false
        }
        [System.IO.File]::WriteAllText($yamlPath, $fixed, $utf8NoBom)
        Write-Host "Fixed tab indentation in $yamlPath"
    }
}

function Prepare-LogFile {
    param([string]$Path)

    $logDir = Split-Path -Parent $Path
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    if (-not (Test-Path $Path)) {
        return $Path
    }

    try {
        Remove-Item $Path -Force -ErrorAction Stop
        return $Path
    } catch {
        $rotated = "$Path.$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
        try {
            Move-Item $Path $rotated -Force -ErrorAction Stop
            Write-Host "Rotated locked log to $rotated"
            return $Path
        } catch {
            $fallback = Join-Path $logDir ("mpf-{0}.log" -f (Get-Date).ToString('yyyyMMdd-HHmmss'))
            Write-Host "Log file locked; using $fallback"
            return $fallback
        }
    }
}

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

Start-Sleep -Milliseconds 500

# Activate venv so PATH and env variables are consistent in this shell.
. $venvActivate

Push-Location $rootDir
try {
    Repair-YamlTabs -Root $rootDir
    $logFile = Prepare-LogFile -Path $logFile
    & $venvPython $mpfExe -X -l $logFile
}
finally {
    Pop-Location
}
