# Executa as etapas em sequencia, cada uma so depois da anterior terminar com EXIT=0.
# Cada etapa grava D:\ps2build\<etapa>.log e <etapa>.exit; o andamento geral fica em pipeline.status.
#
# Uso (processo independente da sessao):
#   Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-File','D:\PS2DEV Toolchain\scripts\pipeline.ps1'
param(
    [string]$WaitFor = '07-dvp',
    [string[]]$Steps = @('08-ps2sdk', '09-ports-gskit', '10-extras', '11-teste-ps2filemanager')
)

# Com -File, uma lista chega como texto unico ("a,b,c"): separa aqui.
$Steps = @($Steps | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

# Impede a suspensao do Windows enquanto este processo roda (a suspensao mata o build).
# Vale so durante a sequencia; as configuracoes de energia nao mudam.
Add-Type -Namespace Win32 -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'
[void][Win32.Power]::SetThreadExecutionState([uint32]'0x80000001')   # ES_CONTINUOUS | ES_SYSTEM_REQUIRED

$build  = 'D:\ps2build'
$status = Join-Path $build 'pipeline.status'

function Log($msg) { "$(Get-Date -Format 'dd/MM HH:mm:ss')  $msg" | Out-File $status -Append -Encoding utf8 }

function ExitCode($step) {
    $f = Join-Path $build "$step.exit"
    if (-not (Test-Path $f)) { return $null }
    $line = (Get-Content $f -Raw).Trim()
    if ($line -match 'EXIT=(\d+)') { return [int]$Matches[1] }
    return $null
}

Log "pipeline iniciado (aguardando $WaitFor; depois: $($Steps -join ', '))"

if ($WaitFor) {
    while ($null -eq (ExitCode $WaitFor)) { Start-Sleep 30 }
    $code = ExitCode $WaitFor
    Log "$WaitFor terminou com EXIT=$code"
    if ($code -ne 0) { Log 'PARADO: etapa anterior falhou'; exit 1 }
}

$env:MSYSTEM = 'UCRT64'
$env:CHERE_INVOKING = '1'

foreach ($step in $Steps) {
    Log "$step iniciado"
    & C:\msys64\usr\bin\bash.exe -l "/d/PS2DEV Toolchain/scripts/$step.sh" *> (Join-Path $build "$step.log")
    $code = ExitCode $step
    Log "$step terminou com EXIT=$code"
    if ($code -ne 0) { Log "PARADO em $step"; exit 1 }
}

Log 'pipeline CONCLUIDO'
