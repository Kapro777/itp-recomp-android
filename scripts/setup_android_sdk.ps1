# Instala o toolchain do Android SDK (JDK 17 + command-line tools + NDK) sem instalador grafico.
# Todas as versoes sao fixadas e conferidas por hash: nada de "latest".
#   powershell -ExecutionPolicy Bypass -File scripts\setup_android_sdk.ps1
$ErrorActionPreference = 'Stop'

$Home_ = if ($PSScriptFile) { Split-Path -Parent $PSScriptFile } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root = Split-Path -Parent $Home_
$base = Join-Path $root 'toolchain'
$dl   = Join-Path $base 'dl'
$sdk  = Join-Path $base 'android-sdk'
New-Item -ItemType Directory -Force -Path $dl, $sdk | Out-Null

# --- 1. JDK 17 (Temurin 17.0.21+9): release oficial do Adoptium no GitHub, SHA-256 conferido
$jdkUrl = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.21%2B9/OpenJDK17U-jdk_x64_windows_hotspot_17.0.21_9.zip'
$jdkSha = '98518ecf554465057ee5509462631deeee374bc368c12a411d225cd29381f84b'
# --- 2. Command-line tools 11.0 do Android SDK: dl.google.com, SHA-1 do manifesto oficial
#     (https://dl.google.com/android/repository/repository2-3.xml)
$cmdUrl  = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'
$cmdSha1 = '3d2917302740f476999a091bc5558837c7a863c5'

function Get-Verified($url, $sha, $out, $alg = 'SHA256') {
    if (Test-Path $out) {
        $h = (Get-FileHash $out -Algorithm $alg).Hash.ToLower()
        if ($h -eq $sha.ToLower()) { Write-Host "ok (ja existe): $(Split-Path -Leaf $out)"; return $true }
        Write-Host "hash diferente, baixando de novo: $(Split-Path -Leaf $out)"
        Remove-Item $out -Force
    }
    Write-Host "baixando $(Split-Path -Leaf $out) ..."
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    $h = (Get-FileHash $out -Algorithm $alg).Hash.ToLower()
    if ($h -ne $sha.ToLower()) { throw "hash de $(Split-Path -Leaf $out): $h (esperado $sha)" }
    Write-Host "conferido: $(Split-Path -Leaf $out)"
    return $true
}

Get-Verified $jdkUrl $jdkSha (Join-Path $dl 'jdk17.zip') | Out-Null
Get-Verified $cmdUrl $cmdSha1 (Join-Path $dl 'cmdline-tools.zip') 'SHA1' | Out-Null

# --- 3. JDK
$jdkDir = Join-Path $base 'jdk'
if (-not (Test-Path (Join-Path $jdkDir 'bin\java.exe'))) {
    Write-Host 'extraindo o JDK...'
    Remove-Item $jdkDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $jdkDir | Out-Null
    & tar.exe -xf (Join-Path $dl 'jdk17.zip') -C $jdkDir
    $inner = Get-ChildItem $jdkDir -Directory | Select-Object -First 1
    if ($inner) { Move-Item $inner.FullName (Join-Path $base 'jdk-tmp'); Remove-Item $jdkDir -Recurse -Force; Move-Item (Join-Path $base 'jdk-tmp') $jdkDir }
}
$java = Get-ChildItem $jdkDir -Recurse -Filter java.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\bin\\java\.exe$' } | Select-Object -First 1
if (-not $java) { throw 'java.exe nao encontrado no JDK extraido' }
$jdkHome = Split-Path -Parent (Split-Path -Parent $java.FullName)
Write-Host "JAVA_HOME: $jdkHome"
& $java.FullName -version

# --- 4. command-line tools (o zip tem uma pasta cmdline-tools/ dentro; o SDK quer cmdline-tools/latest/)
$cmdRoot = Join-Path $sdk 'cmdline-tools'
$latest  = Join-Path $cmdRoot 'latest'
if (-not (Test-Path (Join-Path $latest 'bin\sdkmanager.bat'))) {
    Write-Host 'extraindo as command-line tools...'
    Remove-Item $cmdRoot -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $cmdRoot | Out-Null
    & tar.exe -xf (Join-Path $dl 'cmdline-tools.zip') -C $cmdRoot
    if (Test-Path (Join-Path $cmdRoot 'cmdline-tools')) {
        Move-Item (Join-Path $cmdRoot 'cmdline-tools') $latest
    } else {
        Move-Item (Join-Path $cmdRoot '*') $latest
    }
}
$sdkmanager = Join-Path $latest 'bin\sdkmanager.bat'
if (-not (Test-Path $sdkmanager)) { throw "sdkmanager nao encontrado em $latest" }

# --- 5. pacotes: o sdkmanager confere os proprios hashes (vem do repository2-3.xml do Google)
$env:JAVA_HOME = $jdkHome
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
Write-Host 'licencas...'
1..20 | ForEach-Object { & $sdkmanager --licenses 2>&1 | Out-Null }
Write-Host 'instalando pacotes (platform-tools, platform 36, build-tools, NDK 27.2, cmake)...'
& $sdkmanager 'platform-tools' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;27.2.12479018' 'cmake;3.22.1'

# --- 6. o Gradle le o SDK por local.properties
$lp = Join-Path $root 'android\local.properties'
"sdk.dir=$sdk" | Set-Content -Path $lp -Encoding ASCII
Write-Host "pronto: SDK em $sdk"
Write-Host "para buildar: cd android; ..\toolchain\jdk\bin\java -version; use o gradlew com JAVA_HOME=$jdkHome"
