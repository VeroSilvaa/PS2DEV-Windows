#!/usr/bin/env bash
# Etapa 2.6 - Toolchain do DVP (unidades vetoriais VU0/VU1): binutils dvp, masp e openvcl,
# com os scripts oficiais (sem modificacoes).
# Grava D:\ps2build\07-dvp.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/07-dvp.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

# masp/openvcl usam CMake; Ninja e o gerador padrao do CMake no MSYS2 (deixado explicito).
# O CMake le LDFLAGS do ambiente (ligacao estatica, ver env.sh).
export CMAKE_GENERATOR=Ninja

echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion) | $(cmake --version | head -n 1)"
mkdir -p "$BUILD/dvp"
cd "$BUILD/dvp"

echo "=== binutils DVP"
# Mesmo ajuste do EE/IOP (termcap.h do MSYS2 com -fno-common)
( export CFLAGS="-g -O2 -fcommon"
  time bash "$PROJ/src/ps2toolchain-dvp/scripts/001-binutils.sh" )

echo "=== masp"
time bash "$PROJ/src/ps2toolchain-dvp/scripts/002-masp.sh"

echo "=== openvcl"
time bash "$PROJ/src/ps2toolchain-dvp/scripts/003-openvcl.sh"

echo "=== instalado:"
ls "$PS2DEV/dvp/bin" "$PS2DEV/bin" 2>/dev/null
