@echo off
rem Configura o ambiente do PS2DEV-Windows nesta janela do Prompt de Comando.
set "PS2DEV_ROOT=%~dp0"
set "PS2DEV_ROOT=%PS2DEV_ROOT:~0,-1%"

rem Os Makefiles do PS2SDK nao aceitam espacos nos caminhos.
if not "%PS2DEV_ROOT: =%"=="%PS2DEV_ROOT%" (
    echo O PS2DEV-Windows nao pode ficar em uma pasta com espacos: %PS2DEV_ROOT%
    set "PS2DEV_ROOT="
    exit /b 1
)

set "PATH=%PS2DEV_ROOT%\bin;%PS2DEV_ROOT%\ee\bin;%PS2DEV_ROOT%\iop\bin;%PS2DEV_ROOT%\dvp\bin;%PS2DEV_ROOT%\ps2sdk\bin;%PS2DEV_ROOT%\posix\usr\bin;%PATH%"
set "PS2DEV=%PS2DEV_ROOT:\=/%"
set "PS2SDK=%PS2DEV%/ps2sdk"
set "GSKIT=%PS2DEV%/gsKit"
set "PS2DEV_ROOT="

echo PS2DEV = %PS2DEV%
mips64r5900el-ps2-elf-gcc --version | "%SystemRoot%\System32\findstr.exe" /B "mips64r5900el"
