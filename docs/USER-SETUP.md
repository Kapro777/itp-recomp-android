# O que você precisa ter em mãos

O port **não inclui nada do jogo**. Para jogar, o app precisa de duas coisas que só você pode ter,
extraídas do **seu** Switch:

## 1. O jogo

O arquivo do *Five Nights at Freddy's: Into the Pit* no formato de Nintendo Switch:

| Formato | Como o app lê |
|---|---|
| `.nsp` | direto (pacote com as NCAs) |
| `.xci` | direto (cartucho) |
| `.nsz` / `.xcz` | descomprime sozinho durante o setup |

Qualquer versão serve (a base ou um update mais recente); o app identifica a versão pelo build id
do `exefs/main`.

## 2. As chaves do seu console

O arquivo `prod.keys` do **seu** Switch. Sem ele o pacote não pode ser decifrado — o app nunca
baixa chaves, e o repositório não tem nenhuma.

> O `prod.keys` sai do próprio console, no mesmo processo em que você extrai o jogo. É a mesma
> chave que os emuladores de Switch usam. Use as ferramentas de extração que você já conhece.

## 3. Onde colocar

Uma pasta qualquer no celular, por exemplo:

```
Download/ITP/
├── itp.nsp          (ou .xci)
└── prod.keys
```

O app lê o pacote **diretamente desse lugar** (via SAF, sem copiar os vários GB), escreve só o
código do jogo (~40 MB) no diretório dele e guarda save e log em
`Android/data/com.itprecomp.android/files/`.

## 4. O que acontece na primeira execução

1. Você abre o app e aponta a pasta.
2. O app decifra o pacote e lê os módulos do ExeFS (`main`, `sdk`, subsdks).
3. O **gerador** (Python embarcado no APK) converte o código ARM64 do Switch para C e o **clang**
   embarcado compila para ARM64 do Android — o build do código do jogo acontece **no seu
   aparelho**, em few minutos. Nada disso é baixado da internet.
4. Você toca em **Play**.

O APK "limpo" (o que o CI gera) não contém código do jogo: ele só monta o pacote do passo 3. O
código gerado a partir do seu jogo fica no seu aparelho — não compartilhe.

## Requisitos do aparelho

| | |
|---|---|
| Arquitetura | arm64 (qualquer celular de 2018 em diante) |
| Android | 11 ou mais novo |
| GPU | Vulkan 1.3 (Adreno 620+ ideal; Mali/PowerVR podem rodar com recursos reduzidos) |
| Espaço | ~8 GB livres |
| Driver extra (opcional) | Turnip (Mesa) para 60 fps em Adreno mais antigos |

## Se algo der errado

O app grava um log em `Android/data/com.itprecomp.android/files/itprecomp.log`. Ele é a primeira
coisa a olhar (e a anexar num relatório de bug).
