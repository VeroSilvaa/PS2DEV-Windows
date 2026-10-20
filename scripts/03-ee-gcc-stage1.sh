#!/usr/bin/env bash
# Etapa 2.2 - GCC EE estagio 1 (so C, sem newlib) com o script oficial (sem modificacoes)
set -e
source "$(dirname "$0")/env.sh"
echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion)"
echo "binutils EE: $(mips64r5900el-ps2-elf-as --version | head -n 1)"
mkdir -p "$BUILD/ee"
cd "$BUILD/ee"
time bash "$PROJ/src/ps2toolchain-ee/scripts/002-gcc-stage1.sh"
echo "=== instalado:"
ls "$PS2DEV/ee/bin" | grep -E 'gcc|cpp'
