#!/usr/bin/env bash
# Etapa 2.1 - Binutils do EE com o script oficial (sem modificacoes)
set -e
source "$(dirname "$0")/env.sh"
echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion)"
mkdir -p "$BUILD/ee"
cd "$BUILD/ee"
time bash "$PROJ/src/ps2toolchain-ee/scripts/001-binutils.sh"
echo "=== instalado:"
ls "$PS2DEV/ee/bin"
