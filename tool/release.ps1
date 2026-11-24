param([Parameter(Mandatory)][string]$Version)
if (-not ($Version -cmatch '^v?(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})$')) {
    Write-Host "Version '$Version' must look like v1.2.3 (each number 0-999)."
    exit 1
}
$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$name = "$major.$minor.$patch"
$code = $major * 1000000 + $minor * 1000 + $patch

flutter build apk --release --flavor dev "--build-name=$name" "--build-number=$code"; if ($LASTEXITCODE -ne 0) { exit 1 }
& "$PSScriptRoot\check_release.ps1"; if ($LASTEXITCODE -ne 0) { exit 1 }
flutter build appbundle --release --flavor dev "--build-name=$name" "--build-number=$code"
