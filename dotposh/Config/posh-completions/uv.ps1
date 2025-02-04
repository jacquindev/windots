Invoke-Expression -Command $(uv generate-shell-completion powershell | Out-String)

if (Get-Command uvx -ErrorAction SilentlyContinue) {
	Invoke-Expression -Command $(uvx --generate-shell-completion powershell | Out-String)
}
