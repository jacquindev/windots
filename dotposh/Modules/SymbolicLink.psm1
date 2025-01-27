function New-Symlink {
    [alias('symlink')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Target,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Path
    )

    Write-Host "Creating symbolic link to $Target at $Path..." -ForegroundColor "Green"
    New-Item -Path $Path -ItemType SymbolicLink -Value $Target
}

function Get-Symlinks {
    [alias('symlinks')]
    param (
        [string]$Path = "$($(Get-Location).Path)",
        [switch]$Recurse,
        [int]$Depth
    )

    Get-ChildItem -Path $Path -Recurse:$Recurse -Depth:$Depth | `
        Where-Object { $_.LinkType -eq 'SymbolicLink' } | `
        Select-Object Mode, LastWriteTime, Name, FullName, LinkTarget, Attributes |`
        Format-Table -AutoSize
}

Export-ModuleMember -Function New-Symlink, Get-Symlinks -Alias symlink, symlinks
