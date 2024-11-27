<#
.SYNOPSIS
    Add git aliases/completions for powershell
#>

if (-not (Get-Module -ListAvailable -Name git-aliases -ErrorAction SilentlyContinue)) {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        if (!($(scoop bucket list).Name -eq "extras")) { scoop bucket add extras }
        scoop install git-aliases
    }
    else {
        Install-Module git-aliases -Scope CurrentUser -AllowClobber
    }
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module git-aliases -Global -DisableNameChecking } | Out-Null

# gh cli
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh completion -s powershell | Out-String | Invoke-Expression
}

# gitleaks
if (Get-Command gitleaks -ErrorAction SilentlyContinue) {
    gitleaks completion powershell | Out-String | Invoke-Expression
}