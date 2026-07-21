[CmdletBinding()]
param(
    [switch]$Clean,
    [string]$Device
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Require-Command([string]$Name, [string]$Hint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name não encontrado no PATH. $Hint"
    }
}

if (-not (Get-Command 'flutter' -ErrorAction SilentlyContinue)) {
    $flutterCandidates = @(
        (Join-Path $env:USERPROFILE 'Development\flutter\bin'),
        (Join-Path $env:USERPROFILE 'flutter\bin'),
        (Join-Path $env:LOCALAPPDATA 'flutter\bin')
    )
    foreach ($candidate in $flutterCandidates) {
        if (Test-Path (Join-Path $candidate 'flutter.bat')) {
            $env:Path = "$candidate;$env:Path"
            break
        }
    }
}
Require-Command 'flutter' 'Instale o Flutter stable ou adicione flutter/bin ao PATH.'

if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
    $gitCandidates = @(
        (Join-Path $env:ProgramFiles 'Git\cmd'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd')
    )
    foreach ($gitBin in $gitCandidates) {
        if (Test-Path (Join-Path $gitBin 'git.exe')) { $env:Path = "$gitBin;$env:Path"; break }
    }
}

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
    $jdkCandidates = @(
        (Join-Path $env:USERPROFILE 'Development\jdk-17'),
        (Join-Path $env:ProgramFiles 'Eclipse Adoptium\jdk-17*'),
        (Join-Path $env:ProgramFiles 'Java\jdk-17*')
    )
    foreach ($candidate in $jdkCandidates) {
        $match = Get-Item -LiteralPath $candidate -ErrorAction SilentlyContinue
        if ($match) { $env:JAVA_HOME = $match.FullName; break }
        $match = Get-Item -Path $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) { $env:JAVA_HOME = $match.FullName; break }
    }
}
if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
    throw 'JDK 17 não encontrado. Defina JAVA_HOME apontando para um JDK 17.'
}

if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
if (-not (Test-Path (Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'))) {
    throw "Android SDK não encontrado em $env:ANDROID_HOME. Instale o Android SDK Platform Tools."
}
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

Write-Host "Flutter: $((Get-Command flutter).Source)"
Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "ANDROID_HOME: $env:ANDROID_HOME"
Write-Host '[1/5] Diagnóstico do ambiente (informativo)...'
flutter doctor -v

if ($Clean) {
    Write-Host '[2/5] Limpando build...'
    flutter clean
    if ($LASTEXITCODE -ne 0) { throw 'flutter clean falhou.' }
} else {
    Write-Host '[2/5] Limpeza ignorada (use -Clean para executar).'
}

Write-Host '[3/5] Resolvendo dependências...'
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get falhou.' }
Write-Host '[4/5] Executando análise e testes...'
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze falhou.' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'flutter test falhou.' }
Write-Host '[5/5] Gerando APK debug...'
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { throw 'flutter build apk --debug falhou.' }

if ($Device) {
    Write-Host "Executando no device $Device..."
    flutter run -d $Device
    if ($LASTEXITCODE -ne 0) { throw "flutter run falhou no device $Device." }
} else {
    Write-Host 'APK pronto em build\app\outputs\flutter-apk\app-debug.apk'
    Write-Host 'Para executar depois: flutter devices; flutter run -d <device-id>'
}
