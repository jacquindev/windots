if (Get-Command pdm -ErrorAction SilentlyContinue) {
	if ((pdm config check_update) -eq 'True') { pdm config check_update false }
	pdm completion powershell | Out-String | Invoke-Expression
}
