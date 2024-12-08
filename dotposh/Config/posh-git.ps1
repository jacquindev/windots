# Set alias for `Git` before import `Posh-Git` module
Set-Alias -Name 'g' -Value 'git'

if (-not (Get-Module -ListAvailable -Name posh-git -ErrorAction SilentlyContinue)) {
    Install-Module posh-git -Scope CurrentUser -Force
}
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module posh-git -Global } | Out-Null

# git-aliases
if (-not (Get-Module -ListAvailable -Name git-aliases -ErrorAction SilentlyContinue)) {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        if (!($(scoop bucket list).Name -eq "extras")) { scoop bucket add extras }
        scoop install git-aliases
    } else {
        Install-Module git-aliases -Scope CurrentUser -Force
    }
}
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module git-aliases -Global -DisableNameChecking } | Out-Null

# lazygit alias
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'lg' -Value 'lazygit'
}

# github cli
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        Invoke-Expression -Command $(gh completion -s powershell | Out-String)
    } | Out-Null
}

# gitleaks
if (Get-Command gitleaks -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        gitleaks completion powershell | Out-String | Invoke-Expression
    } | Out-Null
}
