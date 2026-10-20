#!/usr/bin/env bash
# Etapa 1 - clona os repositorios oficiais do PS2DEV em src/
set -e
SRC="/d/PS2DEV Toolchain/src"
mkdir -p "$SRC"
cd "$SRC"
for r in ps2toolchain ps2toolchain-ee ps2toolchain-iop ps2toolchain-dvp ps2dev; do
    if [ ! -d "$r" ]; then
        git clone -q --depth 1 "https://github.com/ps2dev/$r.git"
    fi
    echo "OK $r ($(git -C "$r" log -1 --format='%h %cs'))"
done
