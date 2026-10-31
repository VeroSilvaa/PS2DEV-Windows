# Configura o ambiente do PS2DEV-Windows.
#   .\setup.ps1            so nesta janela do PowerShell (uso portatil)
#   .\setup.ps1 -Persist   tambem para o usuario (novas janelas e VS Code)
#   .\setup.ps1 -Remove    desfaz o -Persist
param(
    [switch]$Persist,
    [switch]$Remove
)

$root = $PSScriptRoot -replace '\\', '/'
$dirs = 'bin', 'ee/bin', 'iop/bin', 'dvp/bin', 'ps2sdk/bin', 'posix/usr/bin' |
    ForEach-Object { ("$root/$_") -replace '/', '\' }

function Without-Ps2Dirs($path) {
    # Tira as pastas de qualquer instalacao deste pacote, reconhecida pelo arquivo marcador.
    @($path -split ';' | Where-Object {
        $_ -and -not ($dirs -contains $_) -and
        -not (Test-Path -LiteralPath (Join-Path ($_ -replace '\\(posix\\usr\\bin|bin|ee\\bin|iop\\bin|dvp\\bin|ps2sdk\\bin)$', '') 'ps2dev-windows.version'))
    }) -join ';'
}

# O PATH do usuario e lido e gravado direto no registro para manter variaveis como %USERPROFILE%.
function Get-UserPath {
    (Get-Item 'HKCU:\Environment').GetValue('Path', '', 'DoNotExpandEnvironmentNames')
}
function Set-UserPath($value) {
    $key =[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
    $key.SetValue('Path', $value, 'ExpandString')
    $key.Close()
}

if ($Remove) {
    Set-UserPath (Without-Ps2Dirs (Get-UserPath))
    # Por ultimo: SetEnvironmentVariable tambem avisa o Windows da mudanca.
    foreach ($name in 'PS2DEV', 'PS2SDK', 'GSKIT') { [Environment]::SetEnvironmentVariable($name, $null, 'User') }
    Write-Host 'PS2DEV-Windows removido das variaveis do usuario. Os arquivos nao foram apagados.'
    return
}

# Os Makefiles do PS2SDK nao aceitam espacos nos caminhos.
if ($root -match '\s') {
    Write-Error "O PS2DEV-Windows nao pode ficar em uma pasta com espacos: $root"
    return
}

$env:PS2DEV = $root
$env:PS2SDK = "$root/ps2sdk"
$env:GSKIT  = "$root/gsKit"
$env:Path   = ($dirs -join ';') + ';' + (Without-Ps2Dirs $env:Path)

if ($Persist) {
    # O PATH do usuario vem depois do PATH do Windows: find e sort continuam sendo os do Windows.
    $userPath = Without-Ps2Dirs (Get-UserPath)
    Set-UserPath ((@($userPath) + $dirs | Where-Object { $_ }) -join ';')
    [Environment]::SetEnvironmentVariable('PS2SDK', $env:PS2SDK, 'User')
    [Environment]::SetEnvironmentVariable('GSKIT',  $env:GSKIT,  'User')
    [Environment]::SetEnvironmentVariable('PS2DEV', $env:PS2DEV, 'User')
    Write-Host 'Variaveis gravadas para o usuario. Abra novas janelas para usar.'
}

Write-Host "PS2DEV = $env:PS2DEV"
& mips64r5900el-ps2-elf-gcc --version | Select-Object -First 1
