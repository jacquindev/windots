### pyenv-win-venv powershell completion

$pyenvVenvCommand = (Get-Command 'pyenv-win-venv' -ErrorAction SilentlyContinue)

if ($pyenvVenvCommand) {
	if ($pyenvVenvCommand.ScriptContents | Select-String -Pattern 'completion') {
		# Run pyenv-venv completion script asynchronously
		Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
			&"pyenv-win-venv.ps1" completion | Out-String | Invoke-Expression
		} | Out-Null

	} else {
		# If there is no internet connection, then silently exit
		if ((Test-Connection -ComputerName www.google.com -Count 1 -Quiet -ErrorAction Stop) -eq $False) { return }

		# Completion script from pyenv-win-venv fork repository: https://github.com/jacquindev/pyenv-win-venv
		Invoke-RestMethod -Uri "https://raw.githubusercontent.com/jacquindev/pyenv-win-venv/refs/heads/main/completions/pyenv-win-venv.ps1" |
		Invoke-Expression
	}
}

Remove-Variable pyenvVenvCommand
