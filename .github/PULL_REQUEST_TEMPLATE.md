<!--
Checklist de PR. O workflow "Guard" roda em todo PR: se algo proibido entrar, ele falha.
-->

- [ ] O PR **não** contém nenhum arquivo do jogo, chave de console, dump, `exefs/`, `romfs/`,
      `generated/` ou o código do jogo recompilado.
- [ ] O workflow **Guard** passou.
- [ ] Se houve mudança no runtime/NVN, ela foi **vista funcionando** (screenshot ou log) — e o
      backend testado está dito no texto (Vulkan / Metal).
- [ ] Se houve mudança no gerador, o `tools/test_lift.py --synth` e os testes de `tools/` passam.
- [ ] Commit pequeno e descritivo, um assunto por commit.
- [ ] Licenças de terceiros preservadas; nenhum aviso de copyright removido.
