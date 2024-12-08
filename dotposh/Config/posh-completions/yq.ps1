if (Get-Command yq -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        yq shell-completion powershell | Out-String | Invoke-Expression
    } | Out-Null
}
