# Prompts prontos para um agente de IA com acesso ao GitHub

Eu trabalho o código **localmente** (em `C:\Users\USER\itp\itp-recomp-android`) e te entrego o
que está pronto. Quando alguma coisa só dá para resolver **do lado do GitHub** (billing, permissões,
disparo de workflow, artefatos), te mando um prompt daqui para colar no seu agente.

> Regra que vale para todos os prompts: **nunca** subir arquivo, dado ou código extraído do jogo
> (dump, `exefs/`, `romfs/`, `prod.keys`, `generated/`, `libitpgame.so`). O repositório é
> `https://github.com/Kapro777/itp-recomp-android` (privado). O código do jogo é compilado **no
> celular**, dentro do APK — ele nunca passa pelo GitHub.

---

## P1 — Destravar o Actions (billing)

> No repositório privado `Kapro777/itp-recomp-android`, os jobs do GitHub Actions não começam e o
> erro é: *"The job was not started because recent account payments have failed or your spending
> limit needs to be increased."*
>
> 1. Verifique o estado do billing da conta `Kapro777` (Settings → Billing & plans; API:
>    `GET /users/Kapro777/settings/billing/actions`).
> 2. Se houver um **spending limit** em Actions zerado ou abaixo do necessário, aumente-o para o
>    mínimo que rode o workflow (~1 h/mês de runner).
> 3. Se o problema for **pagamento recusado**, me diga exatamente qual campo está pendente (cartão
>    não cadastrado, cobrança falha, etc.) — **não** tentei cadastrar cartão sozinho.
> 4. Depois, dispare o workflow: `gh workflow run android-apk.yml --repo Kapro777/itp-recomp-android`
>    e me traga o status e o log da última execução.

## P2 — Rodar o workflow e trazer o log

> No repositório `Kapro777/itp-recomp-android`, rode o workflow `android-apk.yml` e me traga:
> o link da execução, o status de cada passo e, se falhar, as **últimas 60 linhas do log do passo
> que falhou** (`gh run view <id> --log-failed`). Não altere nada no repositório.

## P3 — Receber a APK pronta

> No repositório `Kapro777/itp-recomp-android`, baixe o artefato `itprecomp-apk-debug` da execução
> bem-sucedida mais recente e me diga o nome do arquivo e o tamanho. **Não** faça push, não
> modifique branches.

## P4 — Abrir PR com as minhas mudanças

> No repositório `Kapro777/itp-recomp-android`, crie um branch novo a partir de `main` chamado
> `feature/<nome>`, aplique o patch em `<caminho do patch local>`, abra um PR para `main` com o
> título e a descrição que eu te passar, e me traga o link do PR. Não fa��a merge.

## P5 — Issue de bug reportada por jogador

> No repositório `Kapro777/itp-recomp-android`, crie uma issue a partir do texto e do log que eu te
> passar, com o template `.github/ISSUE_TEMPLATE` se houver. Adicione o log como anexo. Não
> responda a issue.

## P6 — Auditoria do repositório

> No repositório `Kapro777/itp-recomp-android`, verifique e me reporte:
> 1. se algum arquivo versionado parece conter dado extraído de jogo (dump, `exefs/`, `romfs/`,
>    `prod.keys`, `generated/`, `libitpgame.so`);
> 2. o tamanho do repositório e dos artefatos;
> 3. se o workflow `android-apk.yml` está habilitado e qual foi a última execução;
> 4. se há segredos expostos (tokens, chaves).
> **Não** apague nada: apenas reporte.

## P7 — Liberar o repo (quando o port estiver pronto)

> No repositório `Kapro777/itp-recomp-android`, verifique antes de qualquer mudança pública:
> 1. que nenhum arquivo do jogo está versionado (use `git ls-files` e procure por `exefs`, `romfs`,
>    `prod.keys`, `generated`, `*.nsp`, `*.xci`);
> 2. que o README tem o aviso legal e a política BYOG;
> 3. que as licenças de terceiros estão preservadas em `LICENSE` e `third_party/`.
> Só então mude a visibilidade para pública e me confirme. **Não** faça push de conteúdo novo.
