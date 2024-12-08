if (Get-Command glow -ErrorAction SilentlyContinue) {
	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		glow completion powershell | Out-String | Invoke-Expression
	} | Out-Null
}
