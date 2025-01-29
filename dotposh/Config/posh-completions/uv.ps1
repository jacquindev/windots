if (Get-Command uv -ErrorAction SilentlyContinue) {
	(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
}

if (Get-Command uvx -ErrorAction SilentlyContinue) {
	(& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression
}
