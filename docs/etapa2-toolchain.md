# Etapa 2 — Compilação do toolchain

## 2.1 Binutils EE (19/10/2026)

Script: `scripts/02-ee-binutils.sh`, que executa o oficial `ps2toolchain-ee/scripts/001-binutils.sh` **sem modificações**.

### Primeira compilação (ligação dinâmica)
- Tempo: 15 min (12 núcleos). 19 ferramentas instaladas em `PS2DEV-Windows/ee/bin`.
- Teste: montagem de `pmaddw`, `lq` e `mult1` (instruções exclusivas do R5900), ligação e `objdump` → OK.
  ELF gerado com flags `abi2, 5900, mips3` (mesmo padrão do ps2dev).
- **Problema:** no PowerShell puro, `as`/`ld` falharam com `-1073741515` (STATUS_DLL_NOT_FOUND).
  - `as`, `ld`, `objcopy`, `objdump` dependiam de `libzstd.dll` do MSYS2.
  - `gdb` dependia de gmp, mpfr, ncurses, expat, iconv, libstdc++, entre outras.

### Correção: ligação estática
Adicionado em `scripts/env.sh`:

```sh
export LDFLAGS="-static -static-libgcc -static-libstdc++"
```

O script oficial não foi alterado; o `configure` do binutils/GCC lê `LDFLAGS` do ambiente.
Objetivo: os `.exe` dependem apenas de DLLs do próprio Windows (KERNEL32, UCRT `api-ms-win-crt-*`, etc.).
