#!/usr/bin/env bash
# Etapa 6 - Monta o pacote portatil em D:\ps2build\package\PS2DEV-Windows:
# a instalacao, make.exe, pkg-config.exe, sh e comandos POSIX (usr/bin do MSYS2), exemplos e setup.
# Grava D:\ps2build\12-pacote.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/12-pacote.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

PKG="$BUILD/package/PS2DEV-Windows"
rm -rf "$BUILD/package"
mkdir -p "$PKG"
cp -a "$PS2DEV/." "$PKG/"

# Copia um executavel e as DLLs de que ele depende, de $3 (ucrt64 ou usr), para $2.
copy_with_dlls() {
    local exe="$1" dest="$2" prefix="$3"
    cp -L "$exe" "$dest/"
    ldd "$exe" | awk '{print $3}' | grep -E "^$prefix/" | while read -r dll; do
        cp -Ln "$dll" "$dest/" 2>/dev/null || true
    done
}

# make.exe: o mingw32-make usa o sh.exe do PATH para executar as receitas.
copy_with_dlls /ucrt64/bin/mingw32-make.exe "$PKG/bin" /ucrt64
mv -f "$PKG/bin/mingw32-make.exe" "$PKG/bin/make.exe"

# pkg-config.exe: procurado ao lado do tools/pkg-config-wrapper.c compilado.
copy_with_dlls /ucrt64/bin/pkg-config.exe "$PKG/ps2sdk/bin" /ucrt64

# sh e comandos POSIX. O msys-2.0.dll calcula a raiz a partir de usr/bin, dai a estrutura.
POSIX="$PKG/posix"
mkdir -p "$POSIX/usr/bin" "$POSIX/tmp" "$POSIX/etc"
printf 'none / cygdrive binary,posix=0,noacl,user 0 0\n' > "$POSIX/etc/fstab"
for tool in sh bash basename cat chmod cmp cp cut date diff dirname echo env expr false find \
            grep gzip head install ln ls mkdir mktemp mv printf pwd rm rmdir sed sleep sort tail \
            tar tee test touch tr true uname uniq wc which xargs awk; do
    path="$(command -v "/usr/bin/$tool" || true)"
    [ -n "$path" ] || { echo "ERRO: /usr/bin/$tool nao existe"; exit 1; }
    copy_with_dlls "$path" "$POSIX/usr/bin" /usr/bin
done

# Setup, exemplos, documentacao
SRC="$PROJ/package"
cp "$SRC/setup.ps1" "$SRC/setup.cmd" "$SRC/README.md" "$SRC/LICENSES.md" "$PKG/"
cp -r "$SRC/examples" "$PKG/"
for example in "$PKG"/examples/*/; do
    mkdir -p "$example/.vscode"
    cp "$SRC/vscode/"*.json "$example/.vscode/"
done
mkdir -p "$PKG/scripts"
cp "$PROJ"/scripts/*.sh "$PROJ"/scripts/*.ps1 "$PKG/scripts/"
mkdir -p "$PKG/tools"
cp "$PROJ/tools/pkg-config-wrapper.c" "$PKG/tools/"
# Marcador usado pelo setup.ps1 para reconhecer instalacoes anteriores no PATH
git -C "$PROJ" rev-parse --short HEAD > "$PKG/ps2dev-windows.version"

echo "=== pacote"
du -sh "$PKG"
ls "$PKG"
ls "$POSIX/usr/bin" | grep -E '\.dll$'
