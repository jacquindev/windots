kubectl completion powershell | Out-String | Invoke-Expression
Set-Alias -Name 'k' -Value 'kubectl'
Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
