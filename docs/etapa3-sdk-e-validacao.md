# Etapa 3 — DVP, PS2SDK, ports, extras e validação (30/10/2026)

Scripts: `07-dvp.sh`, `08-ps2sdk.sh`, `09-ports-gskit.sh`, `10-extras.sh`, `11-teste-ps2filemanager.sh`.
Os scripts oficiais continuam sem modificação.

## Problemas encontrados e correções

### GCC sem plugin de LTO

O gsKit falhou com `-fno-fat-lto-objects are supported only with linker plugin`. Com `-static`, o
GCC só gera o `liblto_plugin` estático, e o `configure` grava `HAVE_LTO_PLUGIN 0` no driver.

Correção: `use_gcc_ldflags` (`env.sh`) copia as `.a` das bibliotecas do host para uma pasta própria
e liga o GCC sem `-static`. `install_bfd_plugin` copia `liblto_plugin.dll` para `lib/bfd-plugins`.

### `crt0.o` apagado ao refazer o GCC do EE

O `007-post-install.sh` oficial remove o `crt0.o`, que é reinstalado pelo PS2SDK. Refazer o
`05-ee-gcc-stage2.sh` exige refazer o `08-ps2sdk.sh`. O `09-ports-gskit.sh` confere isso no início.

### Ferramentas instaladas sem `.exe`

`iopfixup`, `eefixup`, `irx-strip` e `erx-strip` são cópias de `srxfixup.exe` sem extensão: só o bash
do MSYS2 as executa. O `08-ps2sdk.sh` as renomeia. O ELF do PS2FileManager saiu com o mesmo SHA-256
antes e depois da troca.

### Ports

| Erro | Causa | Correção |
|---|---|---|
| `autoreconf`, `autopoint` ausentes | pacotes | `autotools`, `gettext-devel` |
| `MINGW64-make: command not found` | o script monta o nome pelo `uname` | atalho `mingw64-make` |
| CMake não executa o pkg-config do PS2SDK | é um script sh | `tools/pkg-config-wrapper.c` |
| `unknown type name 'jmp_buf'` no gsKit | ver abaixo | `libpng.pc` criado antes dos ports |
| `failed to create symbolic link 'bzcmp'` | Windows exige modo de desenvolvedor ou administrador | atalho `cmake` com `-DENABLE_LIB_ONLY=ON` |

**libpng:** o `CMakeLists.txt` só instala o `.pc` com `if(NOT CMAKE_HOST_WIN32 OR CYGWIN OR MINGW)`.
Com o CMake nativo gerando para o PS2, a condição é falsa, e o gsKit fica sem `HAVE_LIBPNG`. O erro
aparece como `jmp_buf`, porque o `setjmp.h` só entra pelo `png.h`. O script agora também falha se
`LIBPNG_FOUND` não estiver no cache do gsKit.

**bzip2:** só a biblioteca é instalada. `bzip2.elf` e demais programas para PS2 não fazem parte
desta distribuição, ao contrário da imagem Docker.

**`.pc` relocáveis:** o `sed` oficial procura `/d/PS2DEV-Windows/...`, mas o CMake nativo grava
`D:/PS2DEV-Windows/...`. O `09-ports-gskit.sh` faz a troca por `${pcfiledir}`.

### Extras com DLLs do MSYS2

`ps2client.exe` e `fsclient.exe` precisavam de `libwinpthread-1.dll`, e `zlib-packer.dll` precisava
de `zlib1.dll`. Corrigido em `10-extras.sh`.

## Validação

Todos os testes usaram um PATH só com a toolchain e `C:\Windows`, sem MSYS2.

| Teste | Resultado |
|---|---|
| DLLs nos 134 `.exe`/`.dll`, depois das correções | só do Windows |
| EE: C, C++ e LTO, com link no PS2SDK | ok |
| IOP: compilação com `-msoft-float` e com LTO | ok |
| `dvp-as`: mesmo código de teste no Windows e no Docker | objeto com SHA-256 idêntico |
| `ps2-packer` com zlib e lzma | ok |
| `hello.elf` no PCSX2 | imprime a mensagem esperada |
| PS2FileManager no PCSX2 | inicia até `FM STATUS: PS2FileManager pronto.` |
| Cópia da toolchain em outra pasta | `hello.elf` idêntico; LTO e packer ok |

### PS2FileManager: Windows x Docker (commit 09e22f1)

| | Windows | Docker |
|---|---|---|
| `.text` | 613736 | 613736 |
| `.rodata` | 78616 | 78616 |
| `.data` | 815476 | 815252 |
| Entry point | 0x104288 | 0x104288 |
| Flags | 0x20920025 | 0x20920025 |

Os bytes não são idênticos. A imagem Docker tem bibliotecas de 03/10/2026, e aqui o PS2SDK e o gsKit
vêm do `master` de 30/10. A causa exata da diferença não foi investigada. O teste no PCSX2 cobriu a
inicialização, não as funções de SMB, HDD e USB.

## Pendências para o pacote (Etapa 6)

- Incluir `pkg-config.exe`: fora do MSYS2 o wrapper responde `pkg-config is not found`.
- Incluir `make`, e o que os Makefiles do PS2SDK usam (`rm`, `mkdir` etc.).
- Caminhos fixos ainda presentes em 7 `.la`, 5 scripts `*-config` e 2 `.cmake` de ports
  (`CURLTargets.cmake`, `Argtable3Config.cmake`).
- Testar `openvcl`, `masp` e `ps2client` com uso real: até agora só foram executados.
