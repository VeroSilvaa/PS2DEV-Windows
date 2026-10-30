# Publica o repositorio quando o teste final passar.
#
# Espera D:\ps2build\11-teste-ps2filemanager.exit. Se EXIT=0:
#   - troca o README pelo D:\ps2build\README.publicar.md (status atualizado),
#   - commit + push,
#   - torna VeroSilvaa/PS2DEV-Windows publico.
# Se o teste falhar, nao publica nada. Andamento em D:\ps2build\pipeline.status.
#
# Uso (processo independente):
#   Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','D:\PS2DEV Toolchain\scripts\publicar.ps1'

$build  = 'D:\ps2build'
$repo   = 'D:\PS2DEV Toolchain'
$status = Join-Path $build 'pipeline.status'
$exit   = Join-Path $build '11-teste-ps2filemanager.exit'
$gh     = 'C:\Program Files\GitHub CLI\gh.exe'

function Log($msg) { "$(Get-Date -Format 'dd/MM HH:mm:ss')  PUBLICAR: $msg" | Out-File $status -Append -Encoding utf8 }

Log 'aguardando o teste final (11-teste-ps2filemanager)'

# Linhas antigas do status (falhas ja corrigidas) nao contam.
$startLines = @(Get-Content $status).Count

# Para sozinho se a sequencia parar antes do teste.
while (-not (Test-Path $exit)) {
    $novas = @(Get-Content $status | Select-Object -Skip $startLines)
    if ($novas -match 'PARADO em') {
        Log 'sequencia parou antes do teste final: nada publicado'
        exit 1
    }
    Start-Sleep 60
}

$code = if ((Get-Content $exit -Raw) -match 'EXIT=(\d+)') { [int]$Matches[1] } else { -1 }
if ($code -ne 0) { Log "teste final falhou (EXIT=$code): nada publicado"; exit 1 }

$env:Path = "C:\msys64\usr\bin;C:\Program Files\GitHub CLI;$env:Path"
Set-Location $repo

Copy-Item (Join-Path $build 'README.publicar.md') (Join-Path $repo 'README.md') -Force
git add -A
git commit -q -m "README: toolchain completo (EE, IOP, DVP, PS2SDK, ports, gsKit) e PS2FileManager compilado no Windows"
git push -q
if ($LASTEXITCODE -ne 0) { Log "git push falhou ($LASTEXITCODE): repositorio continua privado"; exit 1 }
Log "push feito ($(git log -1 --format=%h))"

& $gh repo edit VeroSilvaa/PS2DEV-Windows --visibility public --accept-visibility-change-consequences
if ($LASTEXITCODE -ne 0) { Log "falha ao tornar publico ($LASTEXITCODE)"; exit 1 }

$vis = & $gh repo view VeroSilvaa/PS2DEV-Windows --json visibility --jq .visibility
Log "repositorio agora: $vis - https://github.com/VeroSilvaa/PS2DEV-Windows"
