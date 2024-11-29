# npm (nodejs)
if (Get-Command npm -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "npm-completion" -ErrorAction SilentlyContinue)) {
        Install-Module -Name "npm-completion" -AcceptLicense -Scope CurrentUser -Force
    }
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module npm-completion -Global } | Out-Null
}