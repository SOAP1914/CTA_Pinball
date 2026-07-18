# Dry-run only — Get-Slug + preview. No Rename-Item.

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

$rows = @()
$seen = @{}
foreach ($dir in @('video','sounds')) {
  Get-ChildItem $dir -Recurse -File -Include *.ogv,*.wav | ForEach-Object {
    $new = Get-Slug $_.Name
    if ($seen.ContainsKey($new)) { $seen[$new]++; $b=[IO.Path]::GetFileNameWithoutExtension($new); $e=[IO.Path]::GetExtension($new); $new="${b}_$($seen[$new])${e}" }
    else { $seen[$new] = 1 }
    $rows += [pscustomobject]@{ Dir=$dir; Old=$_.Name; New=$new }
  }
}
# Full-width table (avoid console truncating New)
$rows | Format-Table -AutoSize | Out-String -Width 500 | Write-Host
Write-Host "`n=== COLLISIONS (same new name) ==="
$coll = @($rows | Group-Object New | Where-Object Count -gt 1 | Select-Object Name,Count)
if ($coll.Count -eq 0) { Write-Host "(none)" }
else { $coll | Format-Table -AutoSize | Out-String -Width 200 | Write-Host }
Write-Host "`n=== The two reference-critical files ==="
$rows | Where-Object { $_.Old -match 'Opening Title Music|royal' } | Format-Table -AutoSize | Out-String -Width 500 | Write-Host
