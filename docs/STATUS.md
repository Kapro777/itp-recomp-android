# Status

| | |
|---|---|
| Título | *Five Nights at Freddy's: Into the Pit* |
| Estúdio | Mega Cat Studios / ScottGames |
| Motor | Unity (IL2CPP) — 2D, side-scroller |
| Plataforma de origem | Nintendo Switch (31/10/2024) |
| Title ID | `010015F01C8EC000` |
| Alvo | Android arm64 (APK) — sem emulação |
| Base do código | [LAS Recomp](https://github.com/peiikai/LASRecomp) (MIT) + [EoWRecomp](https://github.com/Nycolazs/EoWRecomp) (MIT) |
| Licença do port | MIT (só o código da ferramenta; nada do jogo) |

## Marco atual: **M0 — base importada** (2026-11-13)

| Marco | Estado |
|---|---|
| M0 — base (importação, renome, docs, CI, toolchain) | ✅ |
| M1 — todos os módulos do ITP recompilados para C (0 instruções sem suporte) | ⬜ (falta o dump) |
| M2 — runtime carrega os NSOs e chama `nn::init::Start` | ⬜ |
| M3 — primeiro frame | ⬜ |
| M4 — imagem correta | ⬜ |
| M5 — jogável (input, som, save) | ⬜ |
| M6 — APK (launcher, build no aparelho, controles de toque) | ⬜ |
| M7 — polimento (widescreen, 60 fps, import/export de save, mods) | ⬜ |

## O que já funciona

- base do EoWRecomp importada e renomeada (pacote `com.itprecomp.android`, `libitpgame.so`,
  `ITPRECOMP_*`), com o histórico e os créditos preservados;
- launcher e kernel adaptados ao ITP: title id `010015F01C8EC000`, nome do jogo na tela de setup,
  build id tolerante (o do ITP entra quando o dump chegar);
- ferramentas prontas: `tools/nca_extract.py` (pacote NSP/NCA), `tools/gen.py` (lift ARM64→C),
  `tools/intake.py` (extração + censo dos módulos num comando);
- CI: `android-apk.yml` (APK sem nenhum arquivo do jogo) e `guard.yml` (falha se algo do jogo entrar
  no repo);
- toolchain local: SDK Android + NDK 27.2 + JDK 17 (versões fixadas, hash conferido —
  `scripts/setup_android_sdk.ps1`); venv do gerador com capstone/unicorn/lz4/cryptography;
- docs: `README.md` (aviso legal), `docs/PLAN-ITP.md` (marcos e trabalho de cada um),
  `docs/LEGAL.md` (política do repo), `docs/USER-SETUP.md` (o que o jogador precisa),
  `docs/SOURCES.md` (proveniência das dependências), `docs/GITHUB-PROMPTS.md` (prompts para o
  agente com acesso ao GitHub).

## O que falta / bloqueios

- **O dump do jogo** (`.nsp`/`.xci` + `prod.keys` do console do jogador): sem ele o M1 não começa.
- **Conta do GitHub**: o CI de repo privado esbarrou no limite de minutos da conta gratuita; o repo
  passou a ser público (minutos de Actions ilimitados) e o espelho privado
  `itp-recomp-android-mirror` guarda o histórico.
- **APK de teste**: ainda não houve build completo do app (o CI está sendo validado).

## Próximo passo

1. Jogador: extrair o jogo do próprio Switch e apontar a pasta (`.nsp`/`.xci` + `prod.keys`).
2. `python tools/intake.py <pasta>` → relatório com os módulos do ExeFS, imports, `nvn*`, SVCs e
   atômicos.
3. Ajustar `runtime/modules.h` (lista de módulos) e `tools/patches.py`/`runtime/hle/` conforme o
   relatório; rodar `tools/gen.py` até zerar as instruções sem suporte (M1).
4. `tools/test_lift.py --synth` (diferencial contra o Unicorn) a cada mudança no lifter.

## O que o jogador deve testar e observar (quando houver APK)

- o setup encontra o pacote e as chaves e extrai o ExeFS;
- o código do jogo compila no aparelho (barra de progresso, sem travar);
- o jogo abre, a primeira cena aparece e o input responde;
- o save é criado e sobrevive ao fechar o app.
