#!/usr/bin/env bash
# Ambiente comum de build (MSYS2 UCRT64). Uso: source env.sh
export PROJ="/d/PS2DEV Toolchain"
export BUILD=/d/ps2build
export PS2DEV=/d/PS2DEV-Windows
export PS2SDK=$PS2DEV/ps2sdk
export GSKIT=$PS2DEV/gsKit
export PATH=$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin:$PATH
# Ligacao estatica: os .exe nao dependem de DLLs do MSYS2 (so das DLLs do Windows).
# O libtool remove "-static" das bibliotecas externas (zstd, gmp...); "--static" passa
# direto para o gcc, que o trata como -static.
export LDFLAGS="-static --static -static-libgcc -static-libstdc++"
# Sem isto os headers do ncurses (usado pelo gdb) declaram __declspec(dllimport)
export CPPFLAGS="-DNCURSES_STATIC"

# Para o GCC: "-static" faz o libtool gerar o plugin de LTO so como liblto_plugin.a;
# o GCC entao se configura SEM "linker plugin" (HAVE_LTO_PLUGIN 0) e o gsKit falha com
# "-fno-fat-lto-objects are supported only with linker plugin".
# Alternativa sem "-static": uma pasta so com as versoes .a das bibliotecas do host,
# procurada antes das pastas padrao -> os .exe continuam sem DLLs do MSYS2 e o plugin
# sai como DLL.
use_gcc_ldflags() {
    local libs="$BUILD/static-host-libs"
    mkdir -p "$libs"
    for l in gmp mpfr mpc isl zstd z iconv winpthread pthread; do
        [ -f "/ucrt64/lib/lib$l.a" ] && cp -f "/ucrt64/lib/lib$l.a" "$libs/"
    done
    export LDFLAGS="-L$libs -static-libgcc -static-libstdc++"
    echo "LDFLAGS (GCC): $LDFLAGS"
}

# Copia o plugin de LTO para lib/bfd-plugins (ar/nm/ranlib passam a ler objetos LTO).
install_bfd_plugin() {
    local alias="$1" target="$2"
    local dll="$PS2DEV/$alias/libexec/gcc/$target/15.2.0/liblto_plugin.dll"
    if [ ! -f "$dll" ]; then
        echo "ERRO: $dll nao foi instalado (plugin de LTO)"
        return 1
    fi
    mkdir -p "$PS2DEV/$alias/lib/bfd-plugins"
    cp -f "$dll" "$PS2DEV/$alias/lib/bfd-plugins/"
    echo "plugin LTO: $dll"
}
mkdir -p "$BUILD" "$PS2DEV"
