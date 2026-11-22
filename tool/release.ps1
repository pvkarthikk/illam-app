flutter build apk --release --flavor dev; if ($LASTEXITCODE -ne 0) { exit 1 }
& "$PSScriptRoot\check_release.ps1"; if ($LASTEXITCODE -ne 0) { exit 1 }
flutter build appbundle --release --flavor dev
