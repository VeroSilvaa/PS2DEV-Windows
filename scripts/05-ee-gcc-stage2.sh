#!/usr/bin/env bash
# Etapa 2.4 - pthread-embedded, GCC EE estagio 2 (C/C++) e pos-instalacao,
# com os scripts oficiais (sem modificacoes).
# Grava D:\ps2build\05-ee-gcc-stage2.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/05-ee-gcc-stage2.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion)"
mkdir -p "$BUILD/ee"
cd "$BUILD/ee"

echo "=== pthread-embedded"
time bash "$PROJ/src/ps2toolchain-ee/scripts/005-pthread-embedded.sh"

echo "=== gcc stage2"
time bash "$PROJ/src/ps2toolchain-ee/scripts/006-gcc-stage2.sh"

echo "=== post-install"
time bash "$PROJ/src/ps2toolchain-ee/scripts/007-post-install.sh"

echo "=== instalado:"
ls "$PS2DEV/ee/bin" | grep -E 'g\+\+|c\+\+|gcc$'
