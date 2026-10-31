# Etapa 6 - Testa o pacote portatil sem o MSYS2 no PATH: compila os exemplos pelo PowerShell e pelo
# CMD e, se informado, um projeto real (-Projeto). Resultado em D:\ps2build\13-teste-pacote.exit.
param(
    [string]$Pacote = 'D:\ps2build\package\PS2DEV-Windows',
    [string]$Projeto = ''
)

$exitFile = 'D:\ps2build\13-teste-pacote.exit'
Remove-Item $exitFile -ErrorAction SilentlyContinue
$falhas = 0
function Confere($nome, $ok) {
    Write-Output ("{0,-48} {1}" -f $nome, $(if ($ok) { 'ok' } else { 'FALHOU' }))
    if (-not $ok) { $script:falhas++ }
}

$env:Path = "$env:SystemRoot\System32;$env:SystemRoot;$env:SystemRoot\System32\WindowsPowerShell\v1.0"
Remove-Item Env:PS2DEV, Env:PS2SDK, Env:GSKIT, Env:MSYSTEM, Env:CHERE_INVOKING -ErrorAction SilentlyContinue

# Roda um script em um PowerShell novo, que so conhece o PATH acima.
function NovoPowerShell($corpo) {
    $f = Join-Path $env:TEMP 'ps2dev-teste-ps.ps1'
    $corpo | Set-Content $f -Encoding utf8
    $saida = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $f $Pacote $Projeto 2>&1 | ForEach-Object { "$_" }
    Remove-Item $f
    return $saida
}

Write-Output '=== PowerShell'
$saida = NovoPowerShell @'
param($Pacote)
& "$Pacote\setup.ps1" | Out-Null
foreach ($e in 'hello-world', 'gamepad', 'graphics') {
    Set-Location "$Pacote\examples\$e"
    make clean | Out-Null
    make | Select-Object -Last 1
    Write-Output "RESULTADO $e $LASTEXITCODE"
}
Write-Output "MAKE $((Get-Command make).Source)"
Write-Output "SH $((Get-Command sh).Source)"
'@
$saida
foreach ($e in 'hello-world', 'gamepad', 'graphics') {
    Confere "PowerShell: $e" (($saida -match "^RESULTADO $e 0$").Count -gt 0)
}
Confere 'make e sh vem do pacote' ((($saida -match '^(MAKE|SH) ') | Where-Object { $_ -notlike "*$Pacote*" }).Count -eq 0)
Get-ChildItem "$Pacote\examples" -Recurse -Filter '*.elf' | ForEach-Object { Write-Output "$($_.Name) $($_.Length)" }

Write-Output '=== CMD'
$bat = Join-Path $env:TEMP 'ps2dev-teste-cmd.bat'
@"
@echo off
call "$Pacote\setup.cmd" >nul
cd /d "$Pacote\examples\hello-world"
make clean >nul 2>&1
make
echo RESULTADO %ERRORLEVEL%
"@ | Set-Content $bat -Encoding ascii
$cmd = & cmd.exe /c $bat 2>&1 | ForEach-Object { "$_" }
$cmd | Select-Object -Last 2
Confere 'CMD: hello-world' (($cmd -match '^RESULTADO 0').Count -gt 0)
Remove-Item $bat

if ($Projeto) {
    Write-Output "=== Projeto real: $Projeto"
    $saida = NovoPowerShell @'
param($Pacote, $Projeto)
& "$Pacote\setup.ps1" | Out-Null
Set-Location $Projeto
make -j4 | Select-Object -Last 1
Write-Output "RESULTADO $LASTEXITCODE"
'@
    $saida | Select-Object -Last 1
    Confere 'Projeto real' (($saida -match '^RESULTADO 0$').Count -gt 0)
}

"EXIT=$falhas" | Set-Content $exitFile -Encoding ascii
Write-Output "falhas: $falhas"
