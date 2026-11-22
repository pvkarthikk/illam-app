param([string]$Apk = "build\app\outputs\flutter-apk\app-dev-release.apk")
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
$analyzer = Join-Path $sdk 'cmdline-tools\latest\bin\apkanalyzer.bat'
if (-not (Test-Path $Apk)) { Write-Host "APK not found: $Apk  (run: flutter build apk --release --flavor dev)"; exit 1 }
$manifest = (& $analyzer manifest print $Apk) -join "`n"
$target = [int](& $analyzer manifest target-sdk $Apk)
$fail = $false
function Fail($msg) { Write-Host "FAIL  $msg" -ForegroundColor Red; $script:fail = $true }
foreach ($p in 'READ_SMS','RECEIVE_SMS','READ_CALL_LOG','BIND_NOTIFICATION_LISTENER_SERVICE') {
  if ($manifest -match [regex]::Escape($p)) { Fail "NFR-3a: manifest contains $p" } }
if ($manifest -notmatch 'android:allowBackup="false"')  { Fail 'NFR-3b: allowBackup must be false' }
if ($manifest -notmatch 'android:dataExtractionRules=') { Fail 'NFR-3b: dataExtractionRules missing' }
if ($manifest -notmatch 'android:fullBackupContent=')   { Fail 'NFR-3b: fullBackupContent missing' }
if ($manifest -notmatch 'android.permission.INTERNET')  { Fail 'INTERNET permission missing (Wi-Fi sync, backups)' }
if ($manifest -match 'android:debuggable="true"')       { Fail 'release APK is debuggable' }
if ($target -lt 36) { Fail "targetSdk is $target, Play needs 36" }
if ($target -lt 37 -and $manifest -match 'ACCESS_LOCAL_NETWORK') { Fail 'declare ACCESS_LOCAL_NETWORK only when targeting 37+' }
if ($fail) { exit 1 } else { Write-Host "OK  release checks passed (targetSdk $target)" -ForegroundColor Green; exit 0 }
