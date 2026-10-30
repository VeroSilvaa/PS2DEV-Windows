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
