#!/usr/bin/env bash
# Etapa 2.3 - Newlib e Newlib-nano do EE com os scripts oficiais (sem modificacoes)
set -e
source "$(dirname "$0")/env.sh"
echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion)"
echo "gcc EE: $(mips64r5900el-ps2-elf-gcc --version | head -n 1)"
mkdir -p "$BUILD/ee"
cd "$BUILD/ee"
echo "=== newlib"
time bash "$PROJ/src/ps2toolchain-ee/scripts/003-newlib.sh"
echo "=== newlib-nano"
time bash "$PROJ/src/ps2toolchain-ee/scripts/004-newlib-nano.sh"
echo "=== instalado:"
ls "$PS2DEV/ee/mips64r5900el-ps2-elf/lib" | grep -E '^lib(c|m|g|nosys)' || true
