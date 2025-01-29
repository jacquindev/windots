if (Get-Command pyenv-win-venv -ErrorAction SilentlyContinue) {
	pyenv-win-venv completion | Out-String | Invoke-Expression
}
