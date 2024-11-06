function New-SymbolicLink {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Target,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Path
    )

    Write-Host "Creating symbolic link to $Target at $Path..." -ForegroundColor "Green"
    New-Item -Path $Path -ItemType SymbolicLink -Value $Target
}