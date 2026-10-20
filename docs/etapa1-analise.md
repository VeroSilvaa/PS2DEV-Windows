# Etapa 1 — Análise (19/10/2026)

## Ambiente de build
- Windows 11 Home x64 (build 26200), 12 núcleos, 31 GB RAM.
- MSYS2 em `C:\msys64` (instalador 2026-06-11, atualizado com `pacman -Syu`).
- Ambiente host: **UCRT64** — gcc 16.2.0, binutils 2.47, make 4.4.1, git 2.56.0,
  bison 3.8.2, flex 2.6.4, texinfo 7.2, gmp/mpfr/mpc/isl/zlib/zstd.

## Versão alvo (compatibilidade com PS2DVDPlayer / PS2FileManager)
Os dois projetos usam `ghcr.io/ps2dev/ps2dev:latest`, ou seja, o `master` atual.

| Componente | Repositório | Referência |
|---|---|---|
| ps2dev (meta) | ps2dev/ps2dev | master @ 594e2b2 (2026-10-14) |
| ps2toolchain | ps2dev/ps2toolchain | master @ 1b32a27 (2026-07-23) |
| EE binutils | ps2dev/binutils-gdb | `ee-v2.45.1` |
| EE gcc | ps2dev/gcc | `ee-v15.2.0` |
| EE newlib | ps2dev/newlib | `ee-v4.6.0` |
| EE pthread-embedded | ps2dev/pthread-embedded | `platform_agnostic` |
| IOP binutils | gnu.googlesource.com/binutils-gdb | `binutils-2_45_1` (upstream) |
| IOP gcc | gnu.googlesource.com/gcc | `releases/gcc-15.2.0` (upstream) |
| DVP binutils | ps2dev/binutils-gdb | `dvp-v2.45.1` |
| masp / openvcl | ps2dev/masp, ps2dev/openvcl | `v0.1.16` / `v0.4.0` |
| ps2sdk, ps2sdk-ports, ps2-packer, ps2client | ps2dev/* | master |
| gsKit | ps2dev/gsKit | master (instalado à parte no Dockerfile do PS2DVDPlayer) |

Os patches do PS2 já estão aplicados nos forks `ps2dev/binutils-gdb`, `ps2dev/gcc` e `ps2dev/newlib`
(tags `ee-*` / `dvp-*`); não há arquivos .patch separados.

## Ordem de build oficial
1. `ps2toolchain`: `001-dvp.sh` → `002-iop.sh` → `003-ee.sh`
2. EE: binutils → gcc stage1 → newlib → newlib-nano → pthread-embedded → gcc stage2 (C/C++) → post-install
3. `ps2dev`: toolchain → ps2sdk → ps2sdk-ports → ps2-packer → ps2client
4. Extra (do nosso Dockerfile): gsKit; módulos HDD `ps2atad/ps2hdd/ps2fs.irx`; `pkg-config` do alvo.

## Observações para Windows
- O CI oficial compila para Windows com **MSYS2 MINGW32 (i686, 32 bits)**. Nosso alvo é x64 via
  **UCRT64**, que não é testado oficialmente → possível necessidade de ajustes.
- Os scripts EE já tratam GCC 16 no host (`-fno-char8_t` para o libcody).
- Os scripts só têm caminhos especiais para macOS; no Windows usam os defaults do configure.
- **Caminhos com espaço** (`D:\PS2DEV Toolchain`) costumam quebrar o build do GCC/newlib →
  build e prefixo de instalação devem ficar em caminho sem espaços.
- O PS2DVDPlayer usa também `bin2c`, `pkgconf` (como `mips64r5900el-ps2-elf-pkg-config`), `cmake`, `zip`, `python3`.
