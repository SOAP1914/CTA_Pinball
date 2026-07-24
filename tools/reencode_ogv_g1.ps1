# Re-encode all video/*.ogv with Theora keyframe interval -g 1 (no flicker seek).
# Writes to *_g1tmp.ogv then replaces the original on success.
# Usage (from project root): .\tools\reencode_ogv_g1.ps1

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Parent $PSScriptRoot
$videoDir = Join-Path $rootDir "video"

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    throw "ffmpeg not found on PATH"
}

$files = @(Get-ChildItem -LiteralPath $videoDir -File -Filter "*.ogv" |
    Where-Object { $_.Name -notlike "*_g1tmp.ogv" } |
    Sort-Object Name)

Write-Host "Re-encoding $($files.Count) ogv files with -g 1..."
$failed = @()

foreach ($f in $files) {
    $tmp = Join-Path $f.DirectoryName ($f.BaseName + "_g1tmp.ogv")
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
    Write-Host "g1: $($f.Name)"
    & ffmpeg -y -loglevel error -i $f.FullName `
        -pix_fmt yuv420p -c:v libtheora -q:v 6 -g 1 -r 30 -fps_mode cfr `
        -c:a libvorbis -q:a 4 $tmp
    if (Test-Path -LiteralPath $tmp) {
        Move-Item -LiteralPath $tmp -Destination $f.FullName -Force
    } else {
        Write-Host "  FAILED: $($f.Name)"
        $failed += $f.Name
    }
}

if ($failed.Count) {
    Write-Host "DONE with $($failed.Count) failure(s):"
    $failed | ForEach-Object { Write-Host "  $_" }
    exit 1
}

Write-Host "DONE - all ogv re-encoded with -g 1."
