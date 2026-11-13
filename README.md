# ITPRecomp — *Five Nights at Freddy's: Into the Pit* nativo no Android

Recompilação estática do build de **Nintendo Switch** de *Five Nights at Freddy's: Into the Pit*
(Mega Cat Studios, 2024) para rodar **nativamente** em aparelhos Android arm64.

**Não é emulação.** O código ARM64 do Switch é convertido para C *ahead of time* e compilado para
ARM64; em tempo de execução não há interpretador, translatedor ou emulador — o jogo roda como
código nativo, direto no seu celular, com o Vulkan no lugar da API gráfica da Nintendo.

---

## Aviso legal (leia antes de usar)

Este é um **projeto de fã, sem fins lucrativos**. Ele **não** é afiliado, endossado, patrocinado
ou aprovado por ScottGames, Mega Cat Studios ou Nintendo. *Five Nights at Freddy's*, *Into the Pit*,
Fazbear e todos os personagens, artes, áudios e código do jogo são propriedade de seus respectivos
donos.

- **Nenhum arquivo do jogo está incluído** neste repositório, em nenhuma build, APK ou release —
  nem código, nem assets, nem dados, nem chaves.
- **Quem usa é o dono da cópia.** Para jogar você precisa da sua **própria cópia legítima** do jogo
  (o seu arquivo `.nsp`/`.xci`, extraído do **seu** Switch) e das **suas** `prod.keys`. O app
  apenas lê o que você aponta para ele.
- **Nada disso deve ser redistribuído.** O APK "limpo" (sem código do jogo) pode ser compartilhado;
  o código recompilado do jogo, os dumps, as chaves e os saves são seus e só seus.
- Este software é distribuído "como está", sem garantia de nenhum tipo. A responsabilidade pelo
  uso que você faz dele é inteiramente sua. Decida você mesmo se a lei do seu país permite o que
  você está fazendo — a responsabilidade é de quem executa, não de quem escreveu a ferramenta.
- Nenhuma afiliação, vínculo comercial, conta ou conteúdo de terceiros é criada ou mantida aqui.

---

## Como funciona

```
seu .nsp / .xci  ──►  tools/nca_extract.py  ──►  exefs (NSOs) + romfs
                                                     │
                            tools/gen.py (Python) ◄──┘
                                  │
                                  ▼
                    generated/*.c  ──clang──►  libitpgame.so  (ARM64)
                                  │
   app Android (SDL3 + Vulkan) ──┴──►  runtime: kernel Horizon HLE, IPC com os serviços
                                      do sistema (fs, hid, áudio, tempo, display) e a API
                                      gráfica NVN reimplementada sobre Vulkan
```

A base do runtime vem do [LAS Recomp](https://github.com/peiikai/LASRecomp) e do
[EoWRecomp](https://github.com/Nycolazs/EoWRecomp) — a mesma linhagem que já roda *Link's
Awakening*, *Echoes of Wisdom* e *Tears of the Kingdom* recompilados. O que este repositório faz é
adaptar essa ferramenta para o *Into the Pit*: os módulos do ExeFS, os serviços que o jogo usa, o
formato de save e a camada de UI/launcher.

Detalhe técnico por etapa: [docs/PLAN-ITP.md](docs/PLAN-ITP.md).

## Requisitos

- Celular/tablet **arm64**, Android **11+**
- **Vulkan 1.3** (Adreno 620+ recomendado; drivers mais antigos podem rodar com recursos reduzidos)
- ~8 GB livres (código do jogo + dados + cache de shaders)
- O seu `.nsp`/`.xci` e as suas `prod.keys`

## Estado

Fase inicial: base importada e renomeada, aguardando o dump para começar o
[Marcos do port](docs/PLAN-ITP.md#marcos).

## Créditos e licenças

- [LAS Recomp](https://github.com/peiikai/LASRecomp) — peiikai (MIT): recompilador, runtime
  Horizon, NVN sobre Vulkan, tradutor de shaders Maxwell → GLSL.
- [EoWRecomp](https://github.com/Nycolazs/EoWRecomp) — Nycolazs (MIT): base deste repositório
  (ferramentas, serviço de pacotes NCA, build Android, modelo de "sem arquivos de jogo").
- [LASRecomp-Android-Plus](https://github.com/Nycolazs/LASRecomp-Android-Plus) — Nycolazs (MIT):
  camada Android, controles de toque, build do código do jogo no próprio aparelho.
- SDL3 (zlib), Dear ImGui (MIT), shaderc (Apache 2.0), Vulkan-Headers (Apache 2.0/MIT),
  volk (MIT), Vulkan Memory Allocator (MIT), FFmpeg (LGPL 2.1+), SMAA (BSD 3-Clause),
  AMD FidelityFX FSR 1 (MIT), Turnip (MIT), Switchbrew, Atmosphère, Ryujinx (referência).
- Este repositório mantém os avisos de copyright originais do LAS Recomp. O código do port é MIT;
  a licença **não** concede nada sobre o jogo do usuário.

## Aviso sobre a Nintendo e o GitHub

Em fevereiro de 2026 a Nintendo derrubou 13 repositórios de emulador/recompilação hospedados no
GitHub. Este repositório é privado durante o desenvolvimento. Se um dia for publicado, o conteúdo
deve ser apenas o **código da ferramenta** — nunca arquivos, dados ou código extraído do jogo.
