<#
.SYNOPSIS
    Add / Remove / Get Environment Variables in PowerShell.
.DESCRIPTION
    Add-EnvPath: Add environment variables to the system PATH.
    Remove-EnvPath: Remove environment variables from the system PATH.
    Get-EnvPath: List all environment variables in the system PATH
.LINK
    https://gist.github.com/mkropat/c1226e0cc2ca941b23a9
#>

function Add-Path {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet("Machine", "User", "Session")]
        [Alias('c')][string]$Container = "Session"
    )

    if ($Container -ne "Session") {
        $containerMapping = @{
            Machine = [System.EnvironmentVariableTarget]::Machine
            User    = [System.EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]
        $persistedPaths = [Environment]::GetEnvironmentVariable("Path", $containerType) -split ";"
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable("Path", $persistedPaths -join ";", $containerType)
        }
    }
    $envPaths = $Env:Path -split ";"
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | Where-Object { $_ }
        $Env:Path = $envPaths -join ";"
    }
}

function Remove-Path {
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet("Machine", "User", "Session")]
        [Alias('c')][string] $Container = "Session"
    )

    if ($Container -ne "Session") {
        $containerMapping = @{
            Machine = [System.EnvironmentVariableTarget]::Machine
            User    = [System.EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable("Path", $containerType) -split ";"
        if ($persistedPaths -contains $Path) {
            $persistedPaths = $persistedPaths | Where-Object { $_ -and $_ -ne $Path }
            [Environment]::SetEnvironmentVariable("Path", $persistedPaths -join ";", $containerType)
        }
    }

    $envPaths = $Env:Path -split ";"
    if ($envPaths -contains $Path) {
        $envPaths = $envPaths | Where-Object { $_ -and $_ -ne $Path }
        $Env:Path = $envPaths -join ';'
    }
}

function Get-Paths {
    [alias('paths')]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Machine', 'User')]
        [Alias('c')][string]$Container
    )

    if ($PSBoundParameters.Count -eq 0) {
        return $Env:PATH -Split ";"
    } else {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        [Environment]::GetEnvironmentVariable("Path", $containerType) -split ";" |
        Where-Object { $_ }
    }
}

Export-ModuleMember -Function Add-Path, Remove-Path
Export-ModuleMember -Function Get-Paths -Alias paths
