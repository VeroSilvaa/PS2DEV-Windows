#!/usr/bin/env bash
# Etapa 3.3 - ferramentas extras: ps2-packer (compressao de ELF) e ps2client (envio pela rede),
# com os scripts oficiais (sem modificacoes).
# Grava D:\ps2build\10-extras.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/10-extras.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

mkdir -p "$BUILD/ps2dev"
cd "$BUILD/ps2dev"

echo "=== ps2-packer"
# zlib-packer.dll: zlib estatica, sem depender do zlib1.dll do MSYS2
( export MAKEFLAGS="LIBZA=-l:libz.a"
  time bash "$PROJ/src/ps2dev/scripts/004-ps2-packer-extra.sh" )

echo "=== ps2client"
# O Makefile usa o CC do ambiente: -static evita depender do libwinpthread-1.dll do MSYS2
( export CC="gcc -static"
  time bash "$PROJ/src/ps2dev/scripts/005-ps2client-extra.sh" )

echo "=== instalado:"
ls "$PS2DEV/bin"
