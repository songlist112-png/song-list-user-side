$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$sourcePath = Join-Path $projectRoot '.env'
$outputPath = Join-Path $projectRoot 'dart_defines.local.json'
$allowedKeys = @(
    'SUPABASE_URL'
    'SUPABASE_ANON_KEY'
    'GOOGLE_AUTH_WEB_CLIENT_ID'
    'GOOGLE_AUTH_ANDROID_CLIENT_ID'
    'GOOGLE_AUTH_IOS_CLIENT_ID'
)
$requiredKeys = $allowedKeys[0..2]

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing legacy configuration file: $sourcePath"
}

$settings = [ordered]@{}
foreach ($line in Get-Content -LiteralPath $sourcePath) {
    $trimmedLine = $line.Trim()
    if (-not $trimmedLine -or $trimmedLine.StartsWith('#')) {
        continue
    }

    $parts = $trimmedLine -split '=', 2
    if ($parts.Count -ne 2) {
        continue
    }

    $key = $parts[0].Trim()
    if ($key -notin $allowedKeys) {
        continue
    }

    $value = $parts[1].Trim().Trim('"').Trim("'")
    if ($value) {
        $settings[$key] = $value
    }
}

$missingKeys = @($requiredKeys | Where-Object { -not $settings.Contains($_) })
if ($missingKeys.Count) {
    throw "Missing required public values: $($missingKeys -join ', ')"
}

$json = ($settings | ConvertTo-Json) + [Environment]::NewLine
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($outputPath, $json, $utf8WithoutBom)

Write-Output "Created local public configuration: $outputPath"
