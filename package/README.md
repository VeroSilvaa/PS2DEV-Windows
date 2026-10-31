# PS2DEV-Windows x64

Toolchain nativo para compilar aplicativos e jogos de PlayStation 2 no Windows 10/11 x64, sem Docker,
WSL, máquina virtual ou instalação do MSYS2.

Inclui compiladores do EE, IOP e DVP, PS2SDK, ps2sdk-ports, gsKit, `make`, `pkg-config`, ps2-packer e
ps2client.

## Instalação

Extraia o pacote em uma pasta **sem espaços**, como `C:\PS2DEV-Windows`.

### Só na janela atual (portátil)

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -NoExit -File C:\PS2DEV-Windows\setup.ps1
```

Prompt de Comando:

```bat
C:\PS2DEV-Windows\setup.cmd
```

### Para o usuário (necessário para o VS Code)

```powershell
powershell -ExecutionPolicy Bypass -File C:\PS2DEV-Windows\setup.ps1 -Persist
```

Depois abra novas janelas. Para desfazer, use `-Remove`; os arquivos não são apagados.

## Compilando um exemplo

```powershell
cd C:\PS2DEV-Windows\examples\hello-world
make
```

O resultado é `hello.elf`. Para testar no PCSX2:

```powershell
pcsx2-qt.exe -elf C:\PS2DEV-Windows\examples\hello-world\hello.elf
```

| Exemplo | Mostra |
|---|---|
| `examples/hello-world` | texto na tela e no console |
| `examples/gamepad` | leitura do controle 1 |
| `examples/graphics` | animação com gsKit |

## VS Code

1. Rode o `setup.ps1 -Persist` e abra o VS Code depois disso.
2. Instale a extensão C/C++ da Microsoft.
3. Abra a pasta de um exemplo e pressione `Ctrl+Shift+B` para compilar.

Para um projeto seu, copie a pasta `.vscode` de um exemplo.

## Limitações

- O caminho de instalação não pode ter espaços.
- O `bzip2.elf` e as outras ferramentas do bzip2 para PS2 não são incluídos; a biblioteca é.
- O CMake não faz parte do pacote. Alguns arquivos de ports têm o caminho do build gravado
  (`CURLTargets.cmake`, `Argtable3Config.cmake`, os `.la` e os scripts `*-config`), e podem exigir ajuste.
- `make.exe` e `pkg-config.exe` vêm com DLLs próprias, ao lado deles. A pasta `posix` traz o `sh` e os
  comandos usados pelos Makefiles, com o `msys-2.0.dll`.

Consulte [LICENSES.md](LICENSES.md) para as licenças e os códigos-fonte.
