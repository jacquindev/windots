function New-SymbolicLinks {
	param (
		[string]$Source,
		[string]$Destination,
		[switch]$Recurse
	)

	Get-ChildItem $Source -Recurse:$Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
		$destinationPath = $_.FullName -replace [regex]::Escape($Source), $Destination
		if (!(Test-Path (Split-Path $destinationPath))) {
			New-Item (Split-Path $destinationPath) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
		}
		New-Item -ItemType SymbolicLink -Path $destinationPath -Target $($_.FullName) -Force -ErrorAction SilentlyContinue | Out-Null
		Write-ColorText "{Blue}[symlink] {Green}$($_.FullName) {Yellow}--> {Gray}$destinationPath"
	}
}

New-SymbolicLinks -Source "$PSScriptRoot\home" -Destination "$env:USERPROFILE" -Recurse
New-SymbolicLinks -Source "$PSScriptRoot\AppData" -Destination "$env:USERPROFILE\AppData" -Recurse
New-SymbolicLinks -Source "$PSScriptRoot\config" -Destination "$env:USERPROFILE\.config" -Recurse
