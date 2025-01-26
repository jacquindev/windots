if (Get-Command yq -ErrorAction SilentlyContinue) {
    yq shell-completion powershell | Out-String | Invoke-Expression
}
