if (Get-Command rye -ErrorAction SilentlyContinue) {
	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		rye self completion --shell powershell | Out-String | Invoke-Expression
	} | Out-Null
}
