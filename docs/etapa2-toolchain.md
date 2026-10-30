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

### Resultado (19/10/2026) ✅
- Tempo: 32 min. `mips64r5900el-ps2-elf-gcc` 15.2.0 nativo, sem DLLs do MSYS2.
- Objeto gerado com flags `0x20920025` (noreorder, cpic, abi2, 5900, mips3) — iguais às do ELF do Docker.

## 2.3 Newlib e Newlib-nano ✅

Script: `scripts/04-ee-newlib.sh` → oficiais `003-newlib.sh` e `004-newlib-nano.sh`.
- Tempo: 3 min 17 s + 3 min 21 s.
- Instalado: `libc.a`, `libm.a`, `libg.a` e versões `_nano`.
- Observação: builds em segundo plano do Claude Code morrem quando a sessão termina — a primeira tentativa foi perdida.
  Agora os builds longos rodam como processo independente (`Start-Process powershell -WindowStyle Hidden`) e gravam `<etapa>.exit`.

## 2.4 pthread-embedded, GCC EE estágio 2 (C/C++) e pós-instalação ✅

Script: `scripts/05-ee-gcc-stage2.sh` → oficiais `005`, `006` e `007`.
- Tempo: pthread 9 s; GCC estágio 2 **19 min 51 s**; pós-instalação instantânea.
- Mensagem `largefile-config.h ... Error 1 (ignored)` da libstdc++ é conhecida e ignorada pelo próprio build oficial.

### Testes (MSYS2 fora do PATH)
| Teste | Resultado |
|---|---|
| `gcc` / `g++` 15.2.0 | ✅ |
| Compilar C (printf, malloc, math, 64 bits, float) e C++17 (string, vector, sort, unique_ptr, exceções, virtual) | ✅ |
| 35 `.exe` do EE (bin + libexec) com DLL fora do Windows | **0** |
| Ligação **sem** o PS2SDK (`-nostdlib -lstdc++ -lm -lc -lgcc`) | ✅ ELF C (632 KB) e C++ (1,1 MB, 303 símbolos da libstdc++) |

Na ligação sem PS2SDK só faltam o que o PS2SDK fornece: chamadas de sistema (`_write`, `_sbrk`, `_read`...),
travas da newlib (`__retarget_lock_*`), `pthread_*` (pthreadglue) e `__dso_handle` (crt0).
A ligação normal (`gcc prog.c -o prog.elf`) pede `-lkernel -lcglue -lpthreadglue -lcdvd` — chegam na Etapa 3 (PS2SDK).

**Compilador do EE completo.** Pendente: comparar o código gerado com o do Docker (Docker Desktop estava fechado).

## 2.5 Toolchain do IOP (mipsel-none-elf) ✅

Script: `scripts/06-iop.sh` → oficiais `ps2toolchain-iop/scripts/001-binutils.sh` e `002-gcc-stage1.sh`
(fontes **upstream** do GNU: binutils `binutils-2_45_1`, gcc `releases/gcc-15.2.0`).
- Mesmo ajuste do EE no binutils (gdb): `CFLAGS="-g -O2 -fcommon"`.
- Tempo: binutils 17 min 26 s; GCC 34 min 3 s (o checkout do GCC upstream tem 144 mil arquivos).

### Testes (MSYS2 fora do PATH)
| Teste | Resultado |
|---|---|
| `mipsel-none-elf-gcc` 15.2.0 | ✅ |
| Compilar com as flags do IOP (`-march=r3000 -msoft-float -G0`) | ✅ objeto `MIPS R3000`, `o32, mips1` |
| Instruções de FPU geradas | **0** (float vira `__mulsf3` da libgcc, como esperado no IOP) |
| Ligação com a `libgcc` | ✅ |
| 34 `.exe` do IOP com DLL fora do Windows | **0** |
