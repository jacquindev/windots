if (Get-Command pdm -ErrorAction SilentlyContinue) {
	(& pdm completion powershell) | Out-String | Invoke-Expression
}
