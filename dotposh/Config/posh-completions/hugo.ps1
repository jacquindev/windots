# hugo
if (Get-Command hugo -ErrorAction SilentlyContinue) {
	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		hugo completion powershell | Out-String | Invoke-Expression
	} | Out-Null
}
