# hugo
if (Get-Command hugo -ErrorAction SilentlyContinue) {
	hugo completion powershell | Out-String | Invoke-Expression
}
