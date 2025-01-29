if (Get-Command deno -ErrorAction SilentlyContinue) {
	deno completions powershell | Out-String | Invoke-Expression
}
