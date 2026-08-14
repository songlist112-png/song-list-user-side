param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("run", "apk", "reset")]
    [string]$Command
)

$DefinesFile = "dart_defines.local.json"

if (!(Test-Path $DefinesFile)) {
    Write-Host "Error: '$DefinesFile' not found in the current directory." -ForegroundColor Red
    exit 1
}

switch ($Command) {
    "run" {
        flutter run --dart-define-from-file=$DefinesFile
    }

    "apk" {
        flutter build apk --release --dart-define-from-file=$DefinesFile
    }
    "reset" {
        flutter clean
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        flutter pub get
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        Write-Host "`nFlutter project reset completed successfully." -ForegroundColor Green
    }

}
