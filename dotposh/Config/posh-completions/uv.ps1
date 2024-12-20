if (Get-Command uv -ErrorAction SilentlyContinue) {
	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		uv generate-shell-completion powershell | Out-String | Invoke-Expression
	} | Out-Null
}
