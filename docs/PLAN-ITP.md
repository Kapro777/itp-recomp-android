# Plano do port: *Into the Pit* (Switch) → Android

Documento de trabalho do ITPRecomp. Fica aqui o que muda em relação à base (LAS Recomp /
EoWRecomp), o que ainda é desconhecido e o que precisa ser feito em cada marco.

## O que já se sabe do jogo

| Item | Valor |
|---|---|
| Jogo | *Five Nights at Freddy's: Into the Pit* |
| Estúdio | Mega Cat Studios (publicado por ScottGames) |
| Motor | **Unity** (IL2CPP) — 2D, side-scroller |
| Versão Switch | 31/10/2024, updates 1.04 → 1.0.14 (jun/2025) |
| Title ID (Switch) | `010015F01C8EC000` (a confirmar no dump) |
|(other) | Steam/Epic/PS/Xbox existem; **Android não existe** — é esse o gap |

Consequências de ser Unity:
- o código do jogo (C#/IL2CPP) já chega **compilado em ARM64** dentro do NSO → o lifter trata
  igual ao resto, sem trabalho extra;
- o renderizador do Unity na Switch usa **NVN** → o caminho NVN→Vulkan já existente serve;
- audio/FS/input passam pelos serviços da Nintendo SDK (`audren:u`, `fsp-srv`, `hid`, `time`, `set`,
  `vi`, `pl`, `oe`) → a maior parte já está no runtime herdado;
- Unity costuma falar com o sistema por `nn::fs`, `nn::hid`, `nn::os` e, em alguns casos,
  `nn::socket`/`nn::account` (a remover se o jogo só os chama para analytics).

## Marcos

| # | Marco | Entrega | Estado |
|---|---|---|---|
| 0 | Base | Repositório importado do EoWRecomp, renomeado para ITP, README/avisos/legal | ✅ |
| 1 | **Lift** | Todos os módulos do ITP recompilados para C, 0 instruções sem suporte | ⬜ |
| 2 | **Boot** | Runtime carrega os NSOs, resolve imports, chama `nn::init::Start` | ⬜ |
| 3 | **Frame** | Primeiro frame apresentado | ⬜ |
| 4 | **Imagem** | Cena correta (menus/abertura) | ⬜ |
| 5 | **Jogável** | Input, som, saves (nn::fs) funcionando | ⬜ |
| 6 | **Android** | APK: launcher (escolher `.nsp`/`.xci` + `prod.keys`), build do código no celular, controles de toque | ⬜ |
| 7 | **Polimento** | Widescreen, 60 fps, import/export de save, mods via RomFS, log/diagnóstico | ⬜ |

## Trabalho de cada marco

### Marco 1 — lift
1. Extrair o dump: `tools/nca_extract.py <prod.keys> <jogo.nsp> extracted`.
2. Descobrir os módulos reais do ITP (o EoW tem `main`, `sdk`, `subsdk0`=glslc,
   `subsdk1`=multimedia). Unity costuma ter `main` + `sdk` + subsdks próprios → **adaptar
   `runtime/modules.h`** (hoje a lista é fixa) e, de preferência, passar a lê-la do diretório
   `exefs/` em vez de hardcode.
3. Rodar `tools/analyze.py --census` em cada módulo: funções, imports por módulo de origem,
   nomes `nvn*`, SVCs e atômicos (LSE, `ldxp/stxp`).
4. `tools/gen.py` por módulo. Se aparecer instrução sem suporte no lifter, implementar em
   `tools/lifter.py` (o EoW precisou de `LDXP/STXP` e LSE — o SDK 16.2 do Unity provavelmente
   também usa).
5. Conferir o relatório de instruções não suportadas: precisa zerar.

### Marco 2 — boot
1. `runtime/loader.c`: a lista de módulos vem de `modules.h` → ajustar.
2. `runtime/kernel.c`: SVCs que o SDK do ITP usa e o do EoW não tem (o SDK do Unity é mais
   antigo — 15.x? — então deve ser um **subconjunto**; o EoW usa 16.2).
3. `runtime/ipc.c` + `runtime/services/`: garantir `fsp-srv` (save), `hid`, `audren:u`,
   `audout:u`, `time:*`, `set`, `vi`, `oe`/`appletOE`, `pl`, `lm`, `acc` (só se o jogo pedir).
4. `GetInfo` com o title ID do ITP.

### Marcos 3-4 — imagem
1. NVN: medir quantas das 516 funções `nvn*` o Unity chama (o EoW usou 276; o Unity usa um
   subconjunto diferente — focar em memória/heap, filas, sync, window).
2. Shaders: o Unity **pré-compila** os shaders para Maxwell em build → o tradutor Maxwell→GLSL
   do EoW deve servir; se o ITP importar `glslc` (subsdk0), decidir: recompilar o glslc ou HLE que
   chama o shaderc direto (o EoW документа essa decisão como "medir antes").
3. Texturas: layout block-linear da Tegra (`runtime/nvn/tegra.c`) e ASTC em software
   (`astc.c`) — o Unity usa ASTC e BC; conferir.

### Marco 5 — jogável
1. Save: o Unity salva por `nn::fs` (mount + user save). O formato do save do Switch é
   específico — exportar/importar em formato de console (como o EoW faz no menu Saves).
2. Input: `hid` com o layout do Switch (c.gamepad) → controles de toque + gamepad Bluetooth.
3. Áudio: `audren:u` com as vozes/músicas do jogo.

### Marco 6 — Android
1. Pacote `com.itprecomp.android` (já renomeado).
2. Launcher: escolher a pasta com `.nsp`/`.xci` + `prod.keys`; o app lê os dados direto do
   pacote (sem segunda cópia) e escreve só o código (~40 MB).
3. Build do código do jogo **no aparelho** (Python + clang/zig dentro do APK) — tira o peso de
   compilar na máquina do usuário; alternativa: build no CI/PC.
4. Controles de toque e menu (ImGui), overlay de performance, log em arquivo.

## Onde compilar (decisão)

O notebook do usuário é um Celeron com 4 GB de RAM; cada arquivo do código recompilado pede
1-2 GB para o clang. Portanto:

- **runtime + APK** → GitHub Actions (runner de 4 núcleos/16 GB) — rápido e sem depender do
  notebook;
- **código do jogo** → dentro do APK, no celular (como o EoWRecomp e o LASRecompAndroid fazem), ou
  no CI se couber no limite de artefato;
- **lift (gen.py)** → Python puro; roda no notebook mesmo (é lento, mas roda).

## Riscos

| Risco | Mitigação |
|---|---|
| Unity fala com serviços que o runtime não implementa | log por serviço; stub que responde OK com zeros |
| Faltam funções NVN | HLE no padrão `hle/<nome>.c` |
| `glslc` (subsdk0) chamado em runtime | HLE com shaderc, ou recompilar o módulo |
| Memória: o heap do jogo é de 3,25 GB | Android precisa de RAM; lowering de resolução e texturas |
| Shaders do Unity em formato não coberto pelo tradutor | ampliar `runtime/nvn/maxwell/translate.c` |
| Volume do dump (multi-GB) | nunca versionar; `.gitignore` já cobre `extracted/`, `generated/` |

## Registro de decisões

- **Base**: EoWRecomp (MIT) — mesma linhagem do LAS Recomp, com o caminho Android mais maduro.
- **Identificadores**: `com.itprecomp.android`, `libitpgame.so`, `ITPRECOMP_*` no ambiente.
- **Repo privado** durante o desenvolvimento (risco de takedown, cf. README).
- **Nunca** versionar `extracted/`, `generated/`, dumps ou `prod.keys`.
