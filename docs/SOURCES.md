# Procedência: de onde vem cada coisa

Regra do projeto: **toda dependência externa é baixada de fonte oficial, com versão fixada e hash
conferido**. Nada de "latest" flutuante, nada de espelho alheio, nada de binário solto.

## Ferramentas de base (instaladas nesta máquina)

| Item | Origem | Versão | Verificação |
|---|---|---|---|
| Git for Windows | `winget` (manifest oficial MSYS2/GitHub) | 2.56.0 | hash conferido pelo próprio winget |
| GitHub CLI | `C:\Users\USER\bin\gh-cli` | 2.103.3 | release oficial |
| Python | python.org | 3.12.10 | — |
| JDK 17 (Temurin) | github.com/adoptium/temurin17-binaries (release oficial) | 17.0.21+9 | SHA-256 `98518ecf…81f84b` fixado em `scripts/setup_android_sdk.ps1` |
| Android command-line tools | dl.google.com | 11.0 | SHA-1 `3d291730…63c5` (manifesto oficial `repository2-3.xml`) |
| Android NDK / platform / build-tools | sdkmanager do Google | NDK 27.2.12479018, platform 36 | hash verificado pelo próprio sdkmanager |
| Módulos Python (gerador) | PyPI oficial | capstone 5.0.9, unicorn 2.1.4, lz4 4.4.5, cryptography 50.0.2 | pip confere os hashes do PyPI |

## Dependências que o build baixa (com hash no próprio script)

Todas em `tools/android/build_deps.sh` e `tools/android/ondevice/build_python.sh`:

| Item | Origem | SHA-256 (prefixo) |
|---|---|---|
| SDL3 3.4.18 | github.com/libsdl-org/SDL (release oficial) | `9c75cf16…` |
| FFmpeg 9.0.2 | ffmpeg.org (release oficial) | `8c385028…` |
| shaderc 2026.3 | github.com/google/shaderc (tag oficial) | `ee493ccf…` |
| Vulkan-Headers 1.4.350.1 | github.com/KhronosGroup/Vulkan-Headers | `6d1bb65e…` |
| VulkanMemoryAllocator 3.3.0 | github.com/GPUOpen-LibrariesAndSDKs | `c4f6bbe6…` |
| volk 1.4.350.1 | github.com/zeux/volk | `078a9411…` |
| Mesa Turnip v24.3.0 R9v2 | github.com/K11MCH1/AdrenoToolsDrivers | `8a781186…` |
| CPython 3.14.8 (aarch64-android) | python.org (release oficial) | `11324313…` |
| capstone 5.0.9 / unicorn 2.1.4 / lz4 4.4.5 (sdist) | files.pythonhosted.org (PyPI) | fixados no script |

## Código de terceiros (base do port)

| Projeto | Autor | Licença | Papel |
|---|---|---|---|
| [LAS Recomp](https://github.com/peiikai/LASRecomp) | peiikai | MIT | recompilador ARM64→C, runtime Horizon, NVN→Vulkan, tradutor Maxwell→GLSL |
| [EoWRecomp](https://github.com/Nycolazs/EoWRecomp) | Nycolazs | MIT | base deste repositório (ferramentas, NCA, build Android) |
| [LASRecomp-Android-Plus](https://github.com/Nycolazs/LASRecomp-Android-Plus) | Nycolazs | MIT | camada Android, toque, build no aparelho |
| [SDL3](https://libsdl.org) | SDL | zlib | janela, input, áudio, activity Android |
| [Dear ImGui](https://github.com/ocornut/imgui) | Omar Cornut | MIT | menus e overlay |
| [shaderc](https://github.com/google/shaderc) | Google | Apache 2.0 | GLSL→SPIR-V em runtime |
| [Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers) | Khronos | Apache 2.0/MIT | headers Vulkan |
| [volk](https://github.com/zeux/volk) | zeux | MIT | loader Vulkan |
| [VMA](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator) | AMD | MIT | alocador de memória GPU |
| [FFmpeg](https://ffmpeg.org) | FFmpeg | LGPL 2.1+ | vídeos do jogo (build LGPL-only, verificado no script) |
| [SMAA](https://github.com/iryoku/smaa) | iryoku | BSD 3-Clause | antialiasing |
| [FSR 1](https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-FSR) | AMD | MIT | upscaler |
| [Turnip](https://github.com/mesa3d/mesa) | Mesa | MIT | driver Vulkan (carregado em runtime pelo usuário) |

Os avisos de copyright originais do LAS Recomp estão preservados em `LICENSE` e `third_party/`.

## O que **nunca** entra no repositório

- arquivos, dados, código ou assets do jogo (nem extraídos, nem recompilados);
- `prod.keys` do console;
- dumps (`.nsp`, `.xci`, `exefs/`, `romfs/`);
- o código do jogo gerado (`generated/`, `build/`).

O `.gitignore` cobre `extracted/`, `generated/`, `build/` e as chaves.
