<#
.SYNOPSIS
Prompt scripts.

.DESCRIPTION
Prompt scripts.
#>


# Check invocation
if ($MyInvocation.InvocationName -ne '.')
{
    Write-Host `
        "Error: Bad invocation. $($MyInvocation.MyCommand) supposed to be sourced. Exiting..." `
        -ForegroundColor Red
    Exit
}

if (Get-Module PSReadline -ErrorAction "SilentlyContinue")
{
    Set-PSReadlineOption -ExtraPromptLineCount 1
}

function CheckGit($Path)
{
    if (Test-Path -Path (Join-Path $Path '.git'))
    {
        Write-VcsStatus
        return
    }
    $SplitPath = Split-Path $Path
    if ($SplitPath)
    {
        CheckGit($SplitPath)
    }
}

# ==========================================================================================
# Prompt Hooks
# ==========================================================================================
[ScriptBlock]$ExecutionTime = {
    $history = Get-History -ErrorAction Ignore -Count 1
    if ($history)
    {
        Write-Host "[" -NoNewline
        $ts = New-TimeSpan $history.StartExecutionTime $history.EndExecutionTime
        switch ($ts)
        {
            {$_.TotalSeconds -lt 1} {
                [int]$d = $_.TotalMilliseconds
                '{0}ms' -f ($d) | Write-Host -ForegroundColor Cyan -NoNewline
                break
            }
            {$_.totalminutes -lt 1} {
                [int]$d = $_.TotalSeconds
                '{0}s' -f ($d) | Write-Host -ForegroundColor Yellow -NoNewline
                break
            }
            {$_.totalminutes -ge 1} {
                "{0:HH:mm:ss}" -f ([datetime]$ts.Ticks) | Write-Host -ForegroundColor Red -NoNewline
                break
            }
        }
        Write-Host "] " -NoNewline
    }
}
[ScriptBlock]$GitPrompt = {
    $Host.UI.RawUI.ForegroundColor = "White"
    Microsoft.PowerShell.Utility\Write-Host $pwd.ProviderPath -NoNewLine -ForegroundColor Green
    checkGit($pwd.ProviderPath)
}

# ==========================================================================================
# This scriptblock runs every time the prompt is returned.
# Explicitly use functions from MS namespace to protect from being overridden in the user session.
# Custom prompt functions are loaded in as constants to get the same behaviour
# ==========================================================================================
[ScriptBlock]$Prompt = {
    $realLASTEXITCODE = $LASTEXITCODE
    Microsoft.PowerShell.Utility\Write-Host "[$realLASTEXITCODE] " -NoNewLine -ForegroundColor "Yellow"
    ExecutionTime | Microsoft.PowerShell.Utility\Write-Host -NoNewline
    $host.UI.RawUI.WindowTitle = Microsoft.PowerShell.Management\Split-Path $pwd.ProviderPath -Leaf
    GitPrompt
    Microsoft.PowerShell.Utility\Write-Host "`nλ " -NoNewLine -ForegroundColor "DarkGray"
    $global:LASTEXITCODE = $realLASTEXITCODE
    return " "
}

Set-Item -Path function:\GitPrompt      -Value $GitPrompt
Set-Item -Path function:\ExecutionTime  -Value $ExecutionTime
Set-Item -Path function:\Prompt         -Value $Prompt
