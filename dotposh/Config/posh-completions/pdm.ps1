if (Get-Command pdm -ErrorAction SilentlyContinue) {
	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		pdm completion powershell | Out-String | Invoke-Expression
	} | Out-Null
}
