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
( use_gcc_ldflags
  time bash "$PROJ/src/ps2toolchain-ee/scripts/006-gcc-stage2.sh" )
install_bfd_plugin ee mips64r5900el-ps2-elf

# O gsKit compila com LTO: falha cedo se o gcc ficou sem "linker plugin".
echo 'int f(int x){return x+1;}' > /tmp/lto_check.c
mips64r5900el-ps2-elf-gcc -O2 -flto -fno-fat-lto-objects -c /tmp/lto_check.c -o /tmp/lto_check.o
echo "LTO com linker plugin: ok"

echo "=== post-install"
time bash "$PROJ/src/ps2toolchain-ee/scripts/007-post-install.sh"

echo "=== instalado:"
ls "$PS2DEV/ee/bin" | grep -E 'g\+\+|c\+\+|gcc$'
