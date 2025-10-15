param(
  [switch]$DryRun
)

try {
  $temp = [System.IO.Path]::GetTempPath()
  Write-Output ("Scanning '{0}' for *.mpf_cache files..." -f $temp)
  $files = Get-ChildItem -Path $temp -Filter *.mpf_cache -File -Recurse -ErrorAction SilentlyContinue
  if (-not $files) {
    Write-Output 'No MPF cache files found.'
    exit 0
  }
  $count = $files.Count
  if ($DryRun) {
    Write-Output ("Would remove {0} file(s):" -f $count)
    $files | ForEach-Object { "DRYRUN: {0}" -f $_.FullName }
    exit 0
  }
  $removed = 0
  foreach ($f in $files) {
    try {
      Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
      $removed++
      Write-Output ("REMOVED: {0}" -f $f.FullName)
    } catch {
      Write-Warning ("Failed to remove {0}: {1}" -f $f.FullName, $_)
    }
  }
  Write-Output ("Removed {0} MPF cache file(s)." -f $removed)
  exit 0
} catch {
  Write-Error $_
  exit 1
}
