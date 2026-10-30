#!/usr/bin/env bash
# Etapa 3.2 - ps2sdk-ports (zlib, libpng, freetype, SDL...) e gsKit,
# com os scripts/Makefiles oficiais (sem modificacoes).
# Grava D:\ps2build\09-ports-gskit.exit com EXIT=<codigo> ao terminar.
source "$(dirname "$0")/env.sh"
EXIT_FILE="$BUILD/09-ports-gskit.exit"
rm -f "$EXIT_FILE"
trap 'echo "EXIT=$?" > "$EXIT_FILE"' EXIT
set -e

# crt0.o vem do PS2SDK. O 05-ee-gcc-stage2.sh (007-post-install oficial) o apaga, entao
# refazer o GCC do EE exige refazer o 08-ps2sdk.sh antes de chegar aqui.
CRT0="$PS2DEV/ee/mips64r5900el-ps2-elf/lib/crt0.o"
if [ ! -f "$CRT0" ]; then
    echo "ERRO: $CRT0 nao existe: rode 08-ps2sdk.sh depois do 05-ee-gcc-stage2.sh"
    exit 1
fi

# Ports com CMake: mesmo gerador do DVP.
export CMAKE_GENERATOR=Ninja

# build-cmakelibs.sh monta o nome do make a partir do uname: no CI oficial (MINGW32)
# vira "MINGW32-make"; no UCRT64 vira "MINGW64-make", que nao existe (o executavel
# continua sendo mingw32-make). Atalho so para o build, sem alterar o script oficial.
SHIMS="$BUILD/shims"
mkdir -p "$SHIMS"
printf '#!/bin/sh\nexec mingw32-make "$@"\n' > "$SHIMS/mingw64-make"
chmod +x "$SHIMS/mingw64-make"

# O bzip2 tambem gera os programas para o PS2 (bzip2.elf, bzcmp...), com links simbolicos que
# o Windows recusa sem modo de desenvolvedor ou administrador. So a biblioteca interessa:
# o script oficial chama "cmake" pelo nome, e este atalho acrescenta a opcao so nesse caso.
REAL_CMAKE="$(command -v cmake)"
cat > "$SHIMS/cmake" <<EOF
#!/bin/sh
case "\$PWD" in
    */build/bzip2/build_ee) exec "$REAL_CMAKE" -DENABLE_LIB_ONLY=ON "\$@" ;;
esac
exec "$REAL_CMAKE" "\$@"
EOF
chmod +x "$SHIMS/cmake"
export PATH="$SHIMS:$PATH"

# O PS2SDK instala mips64r5900el-ps2-elf-pkg-config como script sh, que o CMake nativo do
# Windows nao executa. Instala a versao .exe (tools/pkg-config-wrapper.c) e guarda o script
# como .sh (no bash do MSYS2 o nome sem extensao passa a achar o .exe).
PKGCFG="$PS2SDK/bin/mips64r5900el-ps2-elf-pkg-config"
if [ -f "$PKGCFG" ] && head -c 2 "$PKGCFG" | grep -q '#!'; then
    mv -f "$PKGCFG" "$PKGCFG.sh"
fi
gcc -O2 -static -o "$PKGCFG.exe" "$PROJ/tools/pkg-config-wrapper.c"
echo "pkg-config do PS2: $("$PKGCFG.exe" --version) | zlib: $("$PKGCFG.exe" --modversion zlib 2>/dev/null || echo '-')"

# O CMake do libpng so instala o .pc com "NOT CMAKE_HOST_WIN32": no CMake nativo do Windows
# ele nunca e instalado, e o gsKit (pkg_check_modules libpng) fica sem PNG e nao compila
# (o setjmp.h so entra pelo png.h). Precisa existir antes do script oficial, que faz tudo de
# uma vez. Versao fixada em build-cmakelibs.sh.
mkdir -p "$PS2SDK/ports/lib/pkgconfig"
cat > "$PS2SDK/ports/lib/pkgconfig/libpng16.pc" <<'EOF'
prefix=${pcfiledir}/../..
exec_prefix=${prefix}
libdir=${prefix}/lib
includedir=${prefix}/include/libpng16

Name: libpng
Description: Loads and saves PNG files
Version: 1.6.53
Requires.private: zlib
Libs: -L${libdir} -lpng16
Libs.private: -lz -lm
Cflags: -I${includedir}
EOF
cp -f "$PS2SDK/ports/lib/pkgconfig/libpng16.pc" "$PS2SDK/ports/lib/pkgconfig/libpng.pc"

mkdir -p "$BUILD/ps2dev"
cd "$BUILD/ps2dev"

# O CMake guarda em cache o resultado do pkg_check_modules: refaz a configuracao do gsKit.
rm -rf ps2sdk-ports/build/gsKit/build_ee ps2sdk-ports/build/bzip2/build_ee

echo "=== ps2sdk-ports"
time bash "$PROJ/src/ps2dev/scripts/003-ps2sdk-ports.sh"
echo "ports: $(ls "$PS2SDK/ports/lib" 2>/dev/null | wc -l) bibliotecas"

# Falha cedo se o gsKit ficou sem PNG (o PS2FileManager depende disso).
grep -q '^LIBPNG_FOUND:INTERNAL=1' ps2sdk-ports/build/gsKit/build_ee/CMakeCache.txt
echo "gsKit com PNG: ok"

# gsKit: se os ports nao o instalaram, compila como o Dockerfile do PS2DVDPlayer.
echo "=== gsKit"
if [ ! -f "$GSKIT/lib/libgskit.a" ]; then
    if [ ! -d gsKit ]; then
        git clone --depth 1 https://github.com/ps2dev/gsKit.git gsKit
    else
        git -C gsKit fetch origin --depth=1 && git -C gsKit checkout -f FETCH_HEAD
    fi
    ( cd gsKit && time make -j "$(getconf _NPROCESSORS_ONLN)" && make install )
fi
ls "$GSKIT/lib"

# O sed oficial torna os .pc relocaveis procurando "/d/PS2DEV-Windows/...", mas o CMake
# nativo grava "D:/PS2DEV-Windows/...": sem isto o pacote ficaria preso a este caminho.
for root in "$PS2SDK/ports" "$GSKIT"; do
    [ -d "$root/lib/pkgconfig" ] || continue
    find "$root/lib/pkgconfig" -iname '*.pc' -exec sed -i -e "s|$(cygpath -m "$root")|\${pcfiledir}/../..|g" {} +
done
echo "libpng pelo pkg-config: $("$PKGCFG.exe" --cflags --libs libpng)"
