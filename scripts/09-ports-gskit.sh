#!/usr/bin/env bash
# Etapa 3.2 - ps2sdk-ports (zlib, libpng, freetype, SDL...) e gsKit,
# com os scripts/Makefiles oficiais (sem modificacoes).
# Grava D:\ps2build\09-ports-gskit.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/09-ports-gskit.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

# Ports com CMake: mesmo gerador do DVP.
export CMAKE_GENERATOR=Ninja

# build-cmakelibs.sh monta o nome do make a partir do uname: no CI oficial (MINGW32)
# vira "MINGW32-make"; no UCRT64 vira "MINGW64-make", que nao existe (o executavel
# continua sendo mingw32-make). Atalho so para o build, sem alterar o script oficial.
SHIMS="$BUILD/shims"
mkdir -p "$SHIMS"
printf '#!/bin/sh\nexec mingw32-make "$@"\n' > "$SHIMS/mingw64-make"
chmod +x "$SHIMS/mingw64-make"
export PATH="$SHIMS:$PATH"

# O PS2SDK instala mips64r5900el-ps2-elf-pkg-config como script sh, que o CMake nativo do
# Windows nao executa. Instala a versao .exe (tools/pkg-config-wrapper.c) e guarda o script
# como .sh (no bash do MSYS2 o nome sem extensao passa a achar o .exe).
PKGCFG="$PS2SDK/bin/mips64r5900el-ps2-elf-pkg-config"
if [ -f "$PKGCFG" ] && head -c 2 "$PKGCFG" | grep -q '#!'; then
    mv -f "$PKGCFG" "$PKGCFG.sh"
fi
gcc -O2 -static -o "$PKGCFG.exe" "$PROJ/tools/pkg-config-wrapper.c"
echo "pkg-config do PS2: $("$PKGCFG.exe" --version) | zlib: $("$PKGCFG.exe" --modversion zlib 2>/dev/null || echo '-')"

mkdir -p "$BUILD/ps2dev"
cd "$BUILD/ps2dev"

echo "=== ps2sdk-ports"
time bash "$PROJ/src/ps2dev/scripts/003-ps2sdk-ports.sh"
echo "ports: $(ls "$PS2SDK/ports/lib" 2>/dev/null | wc -l) bibliotecas"

# gsKit: se os ports nao o instalaram, compila como o Dockerfile do PS2DVDPlayer.
echo "=== gsKit"
if [ ! -f "$GSKIT/lib/libgskit.a" ]; then
    if [ ! -d gsKit ]; then
        git clone --depth 1 https://github.com/ps2dev/gsKit.git gsKit
    else
        git -C gsKit fetch origin --depth=1 && git -C gsKit checkout -f FETCH_HEAD
    fi
    ( cd gsKit && time make -j "$(getconf _NPROCESSORS_ONLN)" && make install )
fi
ls "$GSKIT/lib"
