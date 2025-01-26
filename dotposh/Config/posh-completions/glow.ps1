if (Get-Command glow -ErrorAction SilentlyContinue) {
	glow completion powershell | Out-String | Invoke-Expression
}
