if (Get-Command uv -ErrorAction SilentlyContinue) {
	uv generate-shell-completion powershell | Out-String | Invoke-Expression
}
