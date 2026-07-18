# Converts any .wav in sounds\ that is NOT pcm_s16le into 16-bit PCM, in place.
# Godot only imports 16-bit PCM or 32-bit float WAV; 24-bit (s24le) and
# 32-bit int (s32le) fail with "not PCM".
Get-ChildItem sounds -Recurse -Filter *.wav | ForEach-Object {
    $codec = ffprobe -v error -show_entries stream=codec_name -of csv=p=0 $_.FullName
    if ($codec -ne "pcm_s16le") {
        $tmp = Join-Path $_.DirectoryName ($_.BaseName + "_16tmp.wav")
        Write-Host "Fixing ($codec): $($_.Name)"
        ffmpeg -y -loglevel error -i $_.FullName -c:a pcm_s16le -ar 44100 $tmp
        if (Test-Path $tmp) {
            Move-Item -Force $tmp $_.FullName
        } else {
            Write-Host "  FAILED: $($_.Name)"
        }
    }
}
Write-Host "Done. Re-run the sweep to confirm all are pcm_s16le."