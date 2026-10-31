# Licenças e código-fonte

Este pacote redistribui componentes de terceiros. Eles foram compilados a partir do código publicado
abaixo, e este projeto não altera esse código. Cada componente mantém a própria licença; os textos
principais estão na pasta `licenses/`, e o texto completo de cada um acompanha o respectivo código-fonte.

## Toolchain e SDK

| Componente | Licença | Código-fonte (branch ou tag, commit usado) |
|---|---|---|
| Binutils EE | GPL-3.0-or-later | https://github.com/ps2dev/binutils-gdb (branch `ee-v2.45.1`, `616e51fa`) |
| Binutils DVP | GPL-3.0-or-later | https://github.com/ps2dev/binutils-gdb (branch `dvp-v2.45.1`, `3eb45ea3`) |
| GCC EE | GPL-3.0-or-later, com exceção de runtime | https://github.com/ps2dev/gcc (branch `ee-v15.2.0`, `df77d03b`) |
| Binutils IOP | GPL-3.0-or-later | https://gnu.googlesource.com/binutils-gdb (tag `binutils-2_45_1`) |
| GCC IOP | GPL-3.0-or-later, com exceção de runtime | https://gnu.googlesource.com/gcc (tag `releases/gcc-15.2.0`) |
| Newlib | Licenças diversas, ver `COPYING.NEWLIB` | https://github.com/ps2dev/newlib (branch `ee-v4.6.0`, `8881dc4b`) |
| pthread-embedded | Arquivos `LICENSE` (MIT) e `COPYING` (LGPL) | https://github.com/ps2dev/pthread-embedded (branch `platform_agnostic`, `b1746fd`) |
| masp | GPL-2.0 | https://github.com/ps2dev/masp (tag `v0.1.16`) |
| openvcl | AFL-2.0 | https://github.com/ps2dev/openvcl (tag `v0.4.0`) |
| PS2SDK | AFL-2.0; dependências com licenças próprias | https://github.com/ps2dev/ps2sdk (`2a18d15`) |
| gsKit | AFL-2.0 | https://github.com/ps2dev/gsKit (tag `v1.5.1`) |
| ps2-packer | GPL-2.0 | https://github.com/ps2dev/ps2-packer (`d43ac51`) |
| ps2client | Estilo BSD (Naomi Peori), ver `licenses/ps2client.txt` | https://github.com/ps2dev/ps2client (`e154231`) |

## Bibliotecas de `ps2sdk/ports`

Cada biblioteca tem a própria licença, e algumas são GPL ou LGPL. As versões e os repositórios de cada
uma estão em `build-cmakelibs.sh` e nos Makefiles de https://github.com/ps2dev/ps2sdk-ports (`d7b2d8a`).
Confira a licença de cada biblioteca antes de distribuir um programa que a utilize.

## Ferramentas do MSYS2

Código-fonte em https://packages.msys2.org/.

| Componente | Licença | Versão |
|---|---|---|
| GNU make (`bin/make.exe`) | GPL-3.0-or-later | 4.4.1-5 |
| gettext-runtime (`libintl-8.dll`) | GPL-3.0-or-later e LGPL-2.1-or-later | 1.0-1 |
| libiconv (`libiconv-2.dll`) | LGPL-2.1-or-later | 1.19-1 |
| pkgconf (`pkg-config.exe`) | ISC | 3.0.9-1 |
| Runtime do MSYS2 (`msys-2.0.dll`) | GPL-3.0-or-later | 3.6.11-4 |
| bash, coreutils, sed, grep, gawk, findutils, tar, gzip, diffutils, which (`posix/`) | GPL-3.0 | versões do MSYS2 em 30/10/2026 |

## Scripts deste projeto

Os scripts de build estão em `scripts/` e em https://github.com/VeroSilvaa/PS2DEV-Windows (BSD 2-Clause).
