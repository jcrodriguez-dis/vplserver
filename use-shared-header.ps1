param(
    [string]$Root = $PSScriptRoot
)

$ErrorActionPreference = "Stop"
$pages = Get-ChildItem -Path $Root -Recurse -Filter "*.html" | Where-Object { $_.FullName -notlike "*\includes\*" }

foreach ($page in $pages) {
    $relativeDirectory = $page.Directory.FullName.Substring($Root.Length).TrimStart('\')
    $depth = if ([string]::IsNullOrWhiteSpace($relativeDirectory)) { 0 } else { ($relativeDirectory -split '\\').Count }
    $prefix = if ($depth -eq 0) { "" } else { ("..\" * $depth).Replace('\', '/') }
    $includePath = "${prefix}includes/header.html"
    $scriptPath = "${prefix}header-loader.js"
    $placeholder = '<div data-include="' + $includePath + '" data-root="' + $prefix + '"></div>'
    $html = Get-Content -Raw -Path $page.FullName
    $updated = [regex]::Replace($html, '(?s)<header class="site-header">.*?</header>', [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $placeholder })
    if ($updated -eq $html) {
        Write-Warning "No header found in $($page.FullName)"
        continue
    }
    $updated = $updated -replace '(?s)\s*<script src="(?:\.\./)*header-loader\.js" defer></script>', ''
    $updated = $updated -replace '(?s)(</body>)', ('    <script src="' + $scriptPath + '" defer></script>' + "`n`$1")
    Set-Content -Path $page.FullName -Value $updated -Encoding utf8 -NoNewline
    Write-Host "Updated $($page.FullName.Substring($Root.Length + 1))"
}
