#!/usr/bin/env bash
# Etapa 3.1 - PS2SDK (bibliotecas EE/IOP, IRX, ferramentas) com o script oficial (sem modificacoes).
# Grava D:\ps2build\08-ps2sdk.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/08-ps2sdk.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

echo "ee: $(mips64r5900el-ps2-elf-gcc --version | head -n 1)"
echo "iop: $(mipsel-none-elf-gcc --version | head -n 1)"
echo "dvp: $(dvp-as --version | head -n 1)"
mkdir -p "$BUILD/ps2dev" "$PS2SDK"
cd "$BUILD/ps2dev"

echo "=== ps2sdk"
time bash "$PROJ/src/ps2dev/scripts/002-ps2sdk.sh"

# O PS2SDK instala estas copias do srxfixup.exe sem extensao: so o bash do MSYS2 as executa.
for tool in eefixup erx-strip iopfixup irx-strip; do
    if [ -f "$PS2SDK/bin/$tool" ] && [ ! -e "$PS2SDK/bin/$tool.exe" ]; then
        mv -f "$PS2SDK/bin/$tool" "$PS2SDK/bin/$tool.exe"
    fi
done

echo "=== instalado:"
ls "$PS2SDK"
echo "libs EE: $(ls "$PS2SDK/ee/lib" | wc -l) | IRX: $(ls "$PS2SDK/iop/irx" | wc -l)"
