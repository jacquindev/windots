if (Get-Command yarn -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name 'yarn-completion' -ErrorAction SilentlyContinue)) {
        Install-Module yarn-completion -AcceptLicense -Scope CurrentUser -Force
    }
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module yarn-completion -Global } | Out-Null
}