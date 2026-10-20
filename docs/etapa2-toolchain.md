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

### Problemas encontrados no caminho (e correções)

| Tentativa | Sintoma | Causa | Correção |
|---|---|---|---|
| 2 | Ainda dependia de `libzstd.dll` (gdb: 9 DLLs) | O libtool descarta `-static` para bibliotecas externas | `LDFLAGS` += `--static` (o libtool não reconhece e repassa ao gcc) |
| 3 | gdb: 175 × `undefined reference to __imp_...` (ncurses) | Headers do ncurses declaram `dllimport` | `CPPFLAGS=-DNCURSES_STATIC` |
| 4 | gdb: `multiple definition of PC/UP/BC` | `termcap.h` do MSYS2 define variáveis sem `extern`; GCC ≥ 10 usa `-fno-common` | `CFLAGS="-g -O2 -fcommon"` em `02-ee-binutils.sh` |

### Resultado final (tentativa 5) ✅
- Tempo: 12,6 min.
- Teste com o MSYS2 **fora do PATH**: `as` 2.45.1 e `ld` montam/ligam código R5900 (flags `abi2, 5900, mips3`); `gdb` 17.0.50 executa.
- DLLs usadas por todos os 17 `.exe`: apenas `KERNEL32`, `USER32`, `WS2_32`, `bcrypt` e UCRT (`api-ms-win-crt-*`, parte do Windows 10/11).

## 2.2 GCC EE estágio 1

Script: `scripts/03-ee-gcc-stage1.sh` → oficial `002-gcc-stage1.sh` (C apenas, sem newlib).
