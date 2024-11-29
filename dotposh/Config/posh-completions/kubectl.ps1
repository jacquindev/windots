# kubectl
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        kubectl completion powershell | Out-String | Invoke-Expression
        Set-Alias -Name 'k' -Value 'kubectl'
        Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
    } | Out-Null
}