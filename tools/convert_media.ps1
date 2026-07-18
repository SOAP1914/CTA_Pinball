$src = "media_src"
$vidOut = "video"
$sndOut = "sounds"
New-Item -ItemType Directory -Force -Path $vidOut, $sndOut | Out-Null

$files = Get-ChildItem "$src\*.mp4"
$i = 0
foreach ($f in $files) {
    $i++
    $out = Join-Path $vidOut ($f.BaseName + ".ogv")
    if (Test-Path $out) { Write-Host "[$i/$($files.Count)] SKIP (exists): $($f.Name)"; continue }
    Write-Host "[$i/$($files.Count)] Converting: $($f.Name)"
    ffmpeg -y -loglevel error -i $f.FullName -vf "scale=1920:1080:flags=lanczos" -c:v libtheora -q:v 6 -c:a libvorbis -q:a 5 $out
}

Get-ChildItem "$src\*.wav" | Copy-Item -Destination $sndOut -Force
Write-Host "DONE. Converted to $vidOut, copied wavs to $sndOut."