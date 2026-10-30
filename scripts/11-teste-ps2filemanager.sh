#!/usr/bin/env bash
# Etapa 5.1 - Teste real: compila o PS2FileManager com o toolchain nativo.
# Trabalha numa COPIA (arquivos do git) em $BUILD/fmtest; a pasta do usuario nao e alterada.
# Grava D:\ps2build\11-teste-ps2filemanager.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/11-teste-ps2filemanager.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

SRC=/d/PS2FileManager
DST="$BUILD/fmtest"

rm -rf "$DST"
mkdir -p "$DST"
( cd "$SRC" && git ls-files -z | xargs -0 -I{} cp --parents {} "$DST/" )
echo "copiados: $(cd "$DST" && find . -type f | wc -l) arquivos (commit $(git -C "$SRC" log -1 --format=%h))"

cd "$DST"
time make -j "$(getconf _NPROCESSORS_ONLN)"

echo "=== resultado"
ls -l PS2FileManager.elf
mips64r5900el-ps2-elf-readelf -h PS2FileManager.elf | grep -E 'Flags|Entry'
sha256sum PS2FileManager.elf
