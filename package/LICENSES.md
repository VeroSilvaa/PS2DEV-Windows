# Licenças e código-fonte

Este pacote redistribui, sem alterações no código, componentes de terceiros. Cada um mantém a própria
licença; o texto completo acompanha o respectivo código-fonte.

| Componente | Licença | Código-fonte |
|---|---|---|
| Binutils (EE, DVP) | GPL-3.0-or-later | https://github.com/ps2dev/binutils-gdb (tags `ee-v2.45.1`, `dvp-v2.45.1`) |
| GCC (EE) | GPL-3.0-or-later, com exceção de runtime | https://github.com/ps2dev/gcc (tag `ee-v15.2.0`) |
| Binutils e GCC (IOP) | GPL-3.0-or-later | https://ftp.gnu.org/gnu/binutils/, https://ftp.gnu.org/gnu/gcc/ (2.45.1, 15.2.0) |
| Newlib | Licenças permissivas diversas | https://github.com/ps2dev/newlib (tag `ee-v4.6.0`) |
| pthread-embedded | LGPL | https://github.com/ps2dev/pthread-embedded |
| masp, openvcl | Ver repositório | https://github.com/ps2dev/masp, https://github.com/ps2dev/openvcl |
| PS2SDK | AFL-2.0, BSD e outras | https://github.com/ps2dev/ps2sdk |
| ps2sdk-ports | Varia por biblioteca | https://github.com/ps2dev/ps2sdk-ports |
| gsKit | AFL-2.0 | https://github.com/ps2dev/gsKit |
| ps2-packer, ps2client | Ver repositório | https://github.com/ps2dev/ps2-packer, https://github.com/ps2dev/ps2client |
| GNU make | GPL-3.0-or-later | https://packages.msys2.org/base/mingw-w64-make |
| pkgconf | ISC | https://packages.msys2.org/base/mingw-w64-pkgconf |
| Runtime e comandos do MSYS2 (`posix/`) | GPL, LGPL e outras | https://packages.msys2.org/ |

As bibliotecas de `ps2sdk/ports` têm licenças diferentes, algumas GPL ou LGPL. Confira a licença de cada
biblioteca antes de distribuir um programa que a utilize.

Os scripts de build estão em `scripts/` e em https://github.com/VeroSilvaa/PS2DEV-Windows (BSD 2-Clause).
