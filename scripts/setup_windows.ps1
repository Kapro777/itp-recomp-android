# Instala o toolchain de build do Windows (o do MSYS2/UCRT64) e o venv do gerador.
# Base: tools/setup_windows.ps1 do EoWRecomp (MIT). Rodar com:
#   powershell -ExecutionPolicy Bypass -File scripts\setup_windows.ps1
$ErrorActionPreference = 'Stop'
$here = if ($PSScriptFile) { $PSScriptFile } else { $MyInvocation.MyCommand.Path }
$root = Split-Path -Parent (Split-Path -Parent $here)

# --- MSYS2 (clang, lld, make, SDL3, FFmpeg, Vulkan, shaderc)
if (-not (Test-Path C:\msys64\usr\bin\pacman.exe)) {
    winget install --id MSYS2.MSYS2 -e --accept-source-agreements --accept-package-agreements --silent
}
$env:MSYSTEM = 'UCRT64'
$env:CHERE_INVOKING = '1'
$bash = 'C:\msys64\usr\bin\bash.exe'
& $bash -lc 'pacman -Syu --noconfirm' | Out-Null
& $bash -lc 'pacman -Syu --noconfirm' | Out-Null   # segunda passada (atualizacao do core)
$pkgs = 'make', 'mingw-w64-ucrt-x86_64-clang', 'mingw-w64-ucrt-x86_64-lld', 'mingw-w64-ucrt-x86_64-sdl3',
        'mingw-w64-ucrt-x86_64-ffmpeg', 'mingw-w64-ucrt-x86_64-vulkan-devel', 'mingw-w64-ucrt-x86_64-shaderc',
        'mingw-w64-ucrt-x86_64-spirv-tools', 'mingw-w64-ucrt-x86_64-pkgconf', 'mingw-w64-ucrt-x86_64-gdb',
        'mingw-w64-ucrt-x86_64-vulkan-memory-allocator', 'mingw-w64-ucrt-x86_64-vulkan-validation-layers',
        'mingw-w64-ucrt-x86_64-nasm', 'git', 'python'
& $bash -lc "pacman -S --needed --noconfirm $($pkgs -join ' ')"

# --- Python do gerador (o build da MSYS2 nao compila as wheels do unicorn/capstone)
$py = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
if (-not (Test-Path $py)) {
    winget install --id Python.Python.3.12 -e --scope user --accept-source-agreements --accept-package-agreements --silent
}
if (-not (Test-Path "$root\tools\venv\Scripts\python.exe")) { & $py -m venv "$root\tools\venv" }
& "$root\tools\venv\Scripts\python.exe" -m pip install -q --upgrade pip
& "$root\tools\venv\Scripts\python.exe" -m pip install -q lz4 capstone unicorn cryptography

# --- LF nos arquivos (os scripts bash quebram com CRLF)
git -C $root config core.autocrlf false
git -C $root config core.eol lf

Write-Host 'Pronto. Para compilar, abra o shell MSYS2 UCRT64 e: make -j'
