#!/usr/bin/env bash
# Etapa 2.5 - Toolchain do IOP (mipsel-none-elf): Binutils e GCC (C/C++)
# com os scripts oficiais (sem modificacoes). Fontes upstream do GNU.
# Grava D:\ps2build\06-iop.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/06-iop.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

echo "MSYSTEM=$MSYSTEM host gcc: $(gcc -dumpmachine) $(gcc -dumpversion)"
mkdir -p "$BUILD/iop"
cd "$BUILD/iop"

echo "=== binutils IOP"
# Ja instalado: pula (refazer so o GCC). FORCE=1 compila de novo.
if [ -z "$FORCE" ] && [ -f "$PS2DEV/iop/bin/mipsel-none-elf-ld.exe" ]; then
    echo "ja instalado, pulando (FORCE=1 para refazer)"
else
    # Mesmo ajuste do EE: termcap.h do MSYS2 + readline do gdb (ver 02-ee-binutils.sh)
    ( export CFLAGS="-g -O2 -fcommon"
      time bash "$PROJ/src/ps2toolchain-iop/scripts/001-binutils.sh" )
fi

echo "=== gcc IOP"
( use_gcc_ldflags
  time bash "$PROJ/src/ps2toolchain-iop/scripts/002-gcc-stage1.sh" )
install_bfd_plugin iop mipsel-none-elf

echo "=== instalado:"
ls "$PS2DEV/iop/bin"
