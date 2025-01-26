if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
	Set-Alias -Name 'omp' -Value 'oh-my-posh'
	oh-my-posh completion powershell | Out-String | Invoke-Expression
}
