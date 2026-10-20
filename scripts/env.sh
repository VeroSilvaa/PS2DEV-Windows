#!/usr/bin/env bash
# Ambiente comum de build (MSYS2 UCRT64). Uso: source env.sh
export PROJ="/d/PS2DEV Toolchain"
export BUILD=/d/ps2build
export PS2DEV=/d/PS2DEV-Windows
export PS2SDK=$PS2DEV/ps2sdk
export GSKIT=$PS2DEV/gsKit
export PATH=$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin:$PATH
# Ligacao estatica: os .exe nao dependem de DLLs do MSYS2 (so das DLLs do Windows).
# O libtool remove "-static" das bibliotecas externas (zstd, gmp...); "--static" passa
# direto para o gcc, que o trata como -static.
export LDFLAGS="-static --static -static-libgcc -static-libstdc++"
# Sem isto os headers do ncurses (usado pelo gdb) declaram __declspec(dllimport)
export CPPFLAGS="-DNCURSES_STATIC"
mkdir -p "$BUILD" "$PS2DEV"
