# Política legal deste repositório

Este repositório é **código de ferramenta**. Ele não contém, e nunca vai conter, nada que pertença
ao jogo: nem arquivos, nem dados, nem código extraído, nem chaves.

## O que é permitido no repositório

- código-fonte do port (o runtime, o gerador, as ferramentas, a app Android);
- documentação, capturas de tela do jogo rodando (JPEG/PNG, para mostrar o progresso);
- listas de nomes de símbolos/funções **medidas** pelo jogador na sua própria cópia, quando
  necessário para documentar uma incompatibilidade (sem código de máquina, sem dados);
- ferramentas de terceiros, com a licença dela no lugar.

## O que é **proibido** no repositório

- o jogo em qualquer formato: `.nsp`, `.xci`, `.nsz`, `.xcz`, `.nca`, `.ncz`, `.nso`, `.nro`,
  `.npdm`, dumps de memória;
- `exefs/`, `romfs/`, `extracted/`, `input/`, `generated/`, `build/`;
- as chaves do console (`prod.keys`, `title.keys`, `dev.keys`) ou qualquer linha no formato delas;
- o **código do jogo recompilado** (`libitpgame.so`/`.dll`/`.dylib`) ou objeto derivado dele;
- assets: texturas, modelos, áudio, fonte do sistema, scripts do jogo;
- saves do jogador (podem conter dados do usuário).

O `.gitignore` cobre a maior parte; o workflow **Guard** (`.github/workflows/guard.yml`) falha o
build se algo disso aparecer mesmo assim. Nenhum PR é aceito sem o Guard passando.

## Modelo BYOG (bring your own game)

O usuário jogável é quem tem o jogo. O app **lê** os arquivos que o próprio usuário aponta e **não
inclui nenhum deles**:

1. o jogador extrai o jogo do **seu** Switch (o `.nsp`/`.xci` dele);
2. o jogador coloca o pacote e as **suas** `prod.keys` numa pasta do celular;
3. o app decifra, extrai os módulos e compila o código do jogo **no aparelho**;
4. o código gerado fica no aparelho do jogador. Ele não é distribuído, nem pelo app, nem pelo
   repositório, nem pelo GitHub Actions.

> Nenhuma instrução de como extrair o jogo é fornecida aqui. O jogador usa as ferramentas que já
> conhece, para a cópia que comprou. Este projeto não pede, não busca e não sugere fontes de dumps.

## Quem pode fazer o quê

| | |
|---|---|
| Jogador | extrai o jogo do próprio console, compila o código no próprio aparelho, joga |
| Jogador que fez o port | mantém o código da ferramenta neste repositório |
| Ninguém | redistribui o jogo, o dump, as chaves ou o código recompilado |

## Licenças

- O **código deste repositório** é MIT (veja `LICENSE`). A licença cobre o nosso código e o do
  LAS Recomp herdado; **ela não concede nada** sobre o jogo, que continua sendo de seus donos.
- `third_party/` mantém as licenças de cada biblioteca (SDL3 zlib, ImGui MIT, shaderc Apache 2.0,
  FFmpeg LGPL, VMA/volk MIT, SMAA BSD, FSR MIT, Turnip MIT).
- Avisos de copyright originais do LAS Recomp e do EoWRecomp preservados.

## Não é afiliado

Este projeto é de fã e não é afiliado, endossado, patrocinado ou aprovado por ScottGames,
Mega Cat Studios, Nintendo ou qualquer outro detentor de direitos. *Five Nights at Freddy's*,
*Into the Pit* e os nomes e personagens citados são marcas de seus donos, usadas apenas para
identificar o jogo ao qual esta ferramenta se destina.

## Em caso de notificação de takedown

A Nintendo já derrubou repositórios hospedados de emulação/recompilação (fevereiro de 2026).
Plano de contingência, se isso acontecer com este repositório:

1. **Não há nada a esconder no repositório**: ele contém só a ferramenta. Tirar o repositório
   público não tira nada do jogador — o app e o código do jogo continuam na máquina dele.
2. O espelho privado `itp-recomp-android-mirror` guarda o histórico; o clone local
   (`itp-recomp-android/`) é a fonte de verdade do trabalho.
3. Publicar de novo só com outro nome e sem material protegido, e avisar no README a situação.
4. Responder à notificação reconhecendo o conteúdo e pedindo a remoção do que for considerado
   protegido — o conteúdo do repositório é da ferramenta, não do jogo.

## Responsabilidade

O código é distribuído "como está", sem garantia. Quem o usa é responsável por ter uma cópia
legal do jogo e por cumprir a lei do seu país. Decisões sobre uso pessoal, emulação e
recompilação são de quem executa, não de quem escreveu a ferramenta.
