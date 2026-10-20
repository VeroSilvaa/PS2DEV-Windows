# PS2DEV-Windows x64

Distribuição **nativa para Windows 10/11 x64** do toolchain [PS2DEV](https://github.com/ps2dev) —
compile aplicativos e jogos de PlayStation 2 direto no Windows, sem Docker, WSL ou máquina virtual.

> 🚧 **Em desenvolvimento.** Acompanhe o progresso na tabela abaixo.

## Progresso

| Etapa | Componente | Status |
|---|---|---|
| 1 | Preparação do ambiente e análise dos fontes oficiais | ✅ |
| 2 | Binutils EE (`as`, `ld`, `objcopy`, `objdump`) | 🔄 em andamento |
| 2 | GCC EE estágio 1, Newlib, pthread-embedded, GCC estágio 2 (C/C++) | ⏳ |
| 2 | Toolchains IOP e DVP | ⏳ |
| 3 | PS2SDK, ps2sdk-ports, gsKit | ⏳ |
| 4 | Integração com VS Code | ⏳ |
| 5 | Testes reais (PCSX2 / console) | ⏳ |
| 6 | Pacote portátil e release | ⏳ |

## Versões (equivalentes a `ghcr.io/ps2dev/ps2dev:latest`)

| Componente | Versão |
|---|---|
| Binutils EE | 2.45.1 (`ps2dev/binutils-gdb` tag `ee-v2.45.1`) |
| GCC EE | 15.2.0 (`ps2dev/gcc` tag `ee-v15.2.0`) |
| Newlib EE | 4.6.0 (`ps2dev/newlib` tag `ee-v4.6.0`) |
| Binutils / GCC IOP | 2.45.1 / 15.2.0 (upstream GNU) |
| PS2SDK, gsKit | `master` |

## Como compilar o toolchain (desenvolvedores)

Requisitos: Windows 10/11 x64, [MSYS2](https://www.msys2.org/) e ~20 GB livres.

```powershell
# 1. Pacotes de build (MSYS2)
C:\msys64\usr\bin\bash.exe -lc "pacman -S --needed --noconfirm base-devel git wget texinfo bison flex unzip mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-gmp mingw-w64-ucrt-x86_64-mpfr mingw-w64-ucrt-x86_64-mpc mingw-w64-ucrt-x86_64-isl mingw-w64-ucrt-x86_64-zlib mingw-w64-ucrt-x86_64-zstd"

# 2. Fontes oficiais
C:\msys64\usr\bin\bash.exe -l scripts/01-clone-sources.sh

# 3. Binutils EE
$env:MSYSTEM='UCRT64'; C:\msys64\usr\bin\bash.exe -l scripts/02-ee-binutils.sh
```

O MSYS2 é usado **apenas para construir**. Os executáveis gerados são ligados estaticamente
e rodam no Windows sem o MSYS2.

Caminhos padrão (editáveis em `scripts/env.sh`):

- Build temporário: `D:\ps2build`
- Instalação: `D:\PS2DEV-Windows`

## Documentação

- [docs/etapa1-analise.md](docs/etapa1-analise.md) — análise dos fontes oficiais e decisões de projeto

## Créditos e licenças

Este projeto apenas automatiza a compilação dos componentes oficiais do
[ps2dev](https://github.com/ps2dev) para Windows x64. Todo o mérito do toolchain e do SDK é dos
seus autores. Os scripts deste repositório estão sob a licença BSD 2-Clause (ver [LICENSE](LICENSE));
cada componente compilado mantém sua própria licença.
