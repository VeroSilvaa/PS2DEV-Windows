# Etapas 4 a 6 — VS Code, exemplos e pacote portátil (30/10/2026)

Scripts: `12-pacote.sh` monta o pacote, e `13-teste-pacote.ps1` o testa. Os arquivos do pacote ficam
em `package/`.

## Decisões

### `sh` e comandos POSIX

Os Makefiles do PS2SDK usam `mkdir -p`, `rm`, `cat` e `printf`, que o CMD não tem. O `make` do Windows
usa o `sh.exe` que encontrar no PATH.

A pasta `posix/usr/bin` traz o `sh` e os comandos do MSYS2, com o `msys-2.0.dll`. A estrutura existe
porque o runtime calcula a raiz a partir de `usr/bin`. Compilar o busybox-w32 foi considerado, mas
exigiria baixar e executar código de outro repositório, e a execução foi negada pelo ambiente.

### PATH

Na janela atual, as pastas do pacote vêm antes das do Windows. Com `-Persist`, ficam no PATH do
usuário, que vem depois do PATH do Windows: `find` e `sort` continuam sendo os do Windows.

O `setup.ps1` lê e grava o PATH do usuário direto no registro, para não expandir variáveis como
`%USERPROFILE%`. Ele descarta entradas vazias (`;;`).

### Caminhos

`PS2DEV`, `PS2SDK` e `GSKIT` usam barras normais, porque os Makefiles concatenam esses valores. Caminhos
com espaços não são aceitos, e o `setup` avisa.

## Testes

Todos com o MSYS2 fora do PATH.

| Teste | Resultado |
|---|---|
| Exemplos com `make` no PowerShell | ok |
| `hello-world` com `make` no CMD | ok |
| PS2FileManager com `make -j4` | ok |
| `hello`, `gamepad`, `graphics` e PS2FileManager no PCSX2 | iniciam e registram a mensagem esperada |
| Tudo acima, exceto o PCSX2, com `C:\msys64` renomeado | ok |
| `pkg-config`, `ps2-packer` e `sh` com `C:\msys64` renomeado | ok |
| `-Persist`, compilação com o PATH resultante e `-Remove` | ok |
| VS Code: comando de build padrão (o do `Ctrl+Shift+B`) | tarefa `Compilar` com saída 0; gera `hello.elf` |
| VS Code: IntelliSense em `scr_printf` | definição em `ps2sdk/ee/include/debug.h`, sem erros |
| VS Code: controle com `#include` inexistente | erro detectado |

O teste do VS Code 1.144.0 usou a extensão C/C++ 1.34.4 em um perfil isolado, com as variáveis gravadas
pelo `-Persist`. Uma extensão de teste executou os comandos pela API, sem digitação na janela.

## Ainda não testado

- Windows limpo: o Windows 11 Home desta máquina não tem Windows Sandbox.
- Interação com o exemplo `gamepad`: só a inicialização foi verificada.
- PS2DVDPlayer e console real, que a especificação também pede na Etapa 5.
