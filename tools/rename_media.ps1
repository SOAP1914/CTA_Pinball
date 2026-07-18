# Renames video/*.ogv and sounds/**/*.wav to clean ASCII slug names.
# Strips curly quotes, apostrophes, #, commas, collapses spaces to underscores.
# Writes rename_map.txt (old -> new) for reference. Preserves leading number code.

function Get-Slug($name) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
    $ext  = [System.IO.Path]::GetExtension($name).ToLower()
    # strip smart quotes / apostrophes / hash / commas
    $base = $base -replace "[\u2018\u2019\u201C\u201D`'`"#,]", ""
    $base = $base -replace "[\u2013\u2014]", "-"
    # leading code token (digits + optional letter)
    $code = ""
    if ($base -match '^(\d+[A-Za-z]?)') { $code = $Matches[1].ToLower() }
    $rest = $base -replace '^(\d+[A-Za-z]?)', ''
    # non-alphanumeric -> space, lower, split
    $rest = ($rest -replace '[^A-Za-z0-9]+',' ').Trim().ToLower()
    $stop = @('the','a','an','to','of','is','it','you','your','my','i','and','for','in','on','s','t','m','re','with','was','has','not','that','this','just','so','we','us','be','are','can','if','he','her','his')
    $words = @($rest -split '\s+' | Where-Object { $_ -and ($stop -notcontains $_) })
    if ($words.Count -gt 4) { $words = $words[0..3] }
    $slug = ($words -join '_')
    if (-not $slug) { $slug = 'clip' }
    if ($code) { $out = "${code}_${slug}${ext}" } else { $out = "${slug}${ext}" }
    $out = $out -replace '_+','_'
    return $out
}

$map = @()
$seen = @{}
foreach ($dir in @('video','sounds')) {
    Get-ChildItem $dir -Recurse -File -Include *.ogv,*.wav | ForEach-Object {
        $new = Get-Slug $_.Name
        if ($seen.ContainsKey($new)) { $seen[$new]++; $b=[IO.Path]::GetFileNameWithoutExtension($new); $e=[IO.Path]::GetExtension($new); $new="${b}_$($seen[$new])${e}" }
        else { $seen[$new] = 1 }
        if ($_.Name -ne $new) {
            $dest = Join-Path $_.DirectoryName $new
            $map += "$($_.FullName)`t->`t$new"
            Rename-Item -LiteralPath $_.FullName -NewName $new
        }
    }
}
$map | Set-Content -Encoding UTF8 rename_map.txt
Write-Host "Renamed $($map.Count) files. See rename_map.txt."