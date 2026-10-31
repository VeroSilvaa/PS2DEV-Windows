# PS2DEV-Windows x64

Distribuição **nativa para Windows 10/11 x64** do toolchain [PS2DEV](https://github.com/ps2dev) —
compile aplicativos e jogos de PlayStation 2 direto no Windows, sem Docker, WSL ou máquina virtual.

Os compiladores são ligados estaticamente e dependem apenas de DLLs do próprio Windows. O `make`, o
`pkg-config` e os comandos POSIX usados pelos Makefiles vêm no pacote, com as DLLs de que precisam, e
o MSYS2 só é necessário para compilar o toolchain.

## Progresso

| Etapa | Componente | Status |
|---|---|---|
| 1 | Preparação do ambiente e análise dos fontes oficiais | ✅ |
| 2 | **EE** (Emotion Engine): Binutils, GCC C/C++, Newlib, pthread-embedded | ✅ |
| 2 | **IOP**: Binutils, GCC | ✅ |
| 2 | **DVP** (VU0/VU1): Binutils, masp, openvcl | ✅ |
| 3 | **PS2SDK**, ps2sdk-ports, **gsKit**, ps2-packer, ps2client | ✅ |
| 5 | Teste real: o [PS2FileManager](https://github.com/VeroSilvaa/PS2FileManager) (gsKit, rede, HDD, módulos IOP próprios) compila com este toolchain e inicia no PCSX2 | ✅ |
| 4 | Integração com VS Code: tarefas de compilação e IntelliSense nos exemplos | 🧪 Falta testar na interface |
| 6 | Pacote portátil (`setup.ps1`, `setup.cmd`, `make`, exemplos) | ✅ Testado sem MSYS2 |
| 6 | Teste em um Windows limpo e Release pública | ⏳ |

Resultados dos testes em [`docs/etapa3-sdk-e-validacao.md`](docs/etapa3-sdk-e-validacao.md) e
[`docs/etapa4-6-pacote.md`](docs/etapa4-6-pacote.md). As instruções de uso do pacote estão em
[`package/README.md`](package/README.md).

## Versões (equivalentes a `ghcr.io/ps2dev/ps2dev:latest`)

| Componente | Versão |
|---|---|
| Binutils EE / DVP | 2.45.1 (`ps2dev/binutils-gdb`, tags `ee-v2.45.1` / `dvp-v2.45.1`) |
| GCC EE | 15.2.0 (`ps2dev/gcc`, tag `ee-v15.2.0`) |
| Newlib EE | 4.6.0 (`ps2dev/newlib`, tag `ee-v4.6.0`) |
| Binutils / GCC IOP | 2.45.1 / 15.2.0 (upstream GNU) |
| masp / openvcl | v0.1.16 / v0.4.0 |
| PS2SDK, ps2sdk-ports, gsKit, ps2-packer, ps2client | `master` |

## Como compilar o toolchain

Requisitos: Windows 10/11 x64, [MSYS2](https://www.msys2.org/) e ~20 GB livres durante o build
(~1 GB depois de instalado).

```powershell
# 1. Pacotes de build (MSYS2)
C:\msys64\usr\bin\bash.exe -lc "pacman -S --needed --noconfirm base-devel autotools gettext-devel git wget texinfo bison flex unzip mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-gmp mingw-w64-ucrt-x86_64-mpfr mingw-w64-ucrt-x86_64-mpc mingw-w64-ucrt-x86_64-isl mingw-w64-ucrt-x86_64-zlib mingw-w64-ucrt-x86_64-zstd mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja"

# 2. Fontes oficiais
C:\msys64\usr\bin\bash.exe -l scripts/01-clone-sources.sh

# 3. Cada etapa (ambiente UCRT64)
$env:MSYSTEM = 'UCRT64'
C:\msys64\usr\bin\bash.exe -l scripts/02-ee-binutils.sh
C:\msys64\usr\bin\bash.exe -l scripts/03-ee-gcc-stage1.sh
C:\msys64\usr\bin\bash.exe -l scripts/04-ee-newlib.sh
C:\msys64\usr\bin\bash.exe -l scripts/05-ee-gcc-stage2.sh
C:\msys64\usr\bin\bash.exe -l scripts/06-iop.sh
C:\msys64\usr\bin\bash.exe -l scripts/07-dvp.sh
C:\msys64\usr\bin\bash.exe -l scripts/08-ps2sdk.sh
C:\msys64\usr\bin\bash.exe -l scripts/09-ports-gskit.sh
C:\msys64\usr\bin\bash.exe -l scripts/10-extras.sh

# 4. Pacote portátil e teste sem MSYS2 no PATH
C:\msys64\usr\bin\bash.exe -l scripts/12-pacote.sh
powershell -ExecutionPolicy Bypass -File scripts\13-teste-pacote.ps1
```

Ou tudo em sequência, como processo independente (cada etapa só começa se a anterior terminar bem;
andamento em `D:\ps2build\pipeline.status`):

```powershell
Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','scripts\pipeline.ps1','-WaitFor','""','-Steps','02-ee-binutils,03-ee-gcc-stage1,04-ee-newlib,05-ee-gcc-stage2,06-iop,07-dvp,08-ps2sdk,09-ports-gskit,10-extras'
```

Os scripts oficiais do ps2dev são usados **sem modificação**; os ajustes para Windows x64 ficam nos
nossos scripts (`scripts/env.sh` e cada etapa) e estão documentados em [`docs/`](docs/).

Caminhos padrão (editáveis em `scripts/env.sh`):

- Build temporário: `D:\ps2build`
- Instalação: `D:\PS2DEV-Windows`

## Usando o compilador

Com o pacote extraído em uma pasta sem espaços, rode `setup.ps1` (PowerShell) ou `setup.cmd` (CMD).
O `setup.ps1 -Persist` grava as variáveis para o usuário, o que o VS Code precisa. Detalhes em
[`package/README.md`](package/README.md).

## Ajustes para Windows x64 (resumo)

O CI oficial do ps2dev só compila para Windows em 32 bits (MINGW32). Para x64 (UCRT64) foram necessários:

| Problema | Correção |
|---|---|
| Executáveis dependiam de DLLs do MSYS2 | `LDFLAGS="-static --static -static-libgcc -static-libstdc++"` (`--static` atravessa o libtool) |
| GCC com `-static` fica sem o plugin de LTO, e o gsKit usa LTO | só o GCC liga com as bibliotecas estáticas em pasta própria, sem `-static` (`use_gcc_ldflags` em `env.sh`) |
| gdb: `undefined reference to __imp_*` (ncurses) | `CPPFLAGS=-DNCURSES_STATIC` |
| gdb: `multiple definition of PC/UP/BC` | `CFLAGS="-g -O2 -fcommon"` (termcap.h do MSYS2 + GCC ≥ 10) |
| `iopfixup`, `eefixup`, `irx-strip`, `erx-strip` instalados sem `.exe` | renomeados para `.exe` em `08-ps2sdk.sh` |
| ports: `MINGW64-make: command not found` | atalho `mingw64-make` → `mingw32-make` só durante o build |
| ports: `autoreconf`/`autopoint` ausentes | pacotes `autotools` e `gettext-devel` |
| ports: CMake nativo não executa o `pkg-config` do PS2SDK (script sh) | versão `.exe` em `tools/pkg-config-wrapper.c` |
| libpng não instala o `.pc` no CMake do Windows: gsKit sem PNG, erro `jmp_buf` | `libpng.pc` criado em `09-ports-gskit.sh` antes dos ports |
| bzip2: Windows recusa os links simbólicos dos programas | só a biblioteca (`-DENABLE_LIB_ONLY=ON`); **sem `bzip2.elf` e afins** |
| `.pc` com caminho `D:/...`, que o `sed` oficial não reconhece | `sed` próprio em `09-ports-gskit.sh` (`${pcfiledir}`) |
| `ps2client` e `zlib-packer.dll` dependiam de DLLs do MSYS2 | `CC="gcc -static"` e `LIBZA=-l:libz.a` em `10-extras.sh` |

Detalhes em [`docs/etapa2-toolchain.md`](docs/etapa2-toolchain.md) e
[`docs/etapa3-sdk-e-validacao.md`](docs/etapa3-sdk-e-validacao.md).

## Créditos e licenças

Este projeto apenas automatiza a compilação dos componentes oficiais do
[ps2dev](https://github.com/ps2dev) para Windows x64. Todo o mérito do toolchain e do SDK é dos
seus autores. Os scripts deste repositório estão sob a licença BSD 2-Clause (ver [LICENSE](LICENSE));
cada componente compilado mantém sua própria licença.
