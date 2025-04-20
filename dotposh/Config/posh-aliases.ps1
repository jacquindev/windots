# ----------------------------------------------------------------------------------- #
# Aliases:                                                                            #
# ----------------------------------------------------------------------------------- #

# Helper functions
function New-Directory {
    <#
    .SYNOPSIS
        Creates a new directory and cd into it. Alias: mkcd
    #>
    [CmdletBinding()]
    param ([Parameter(Mandatory = $True)]$Path)
    if (!(Test-Path $Path -PathType Container)) { New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null }
    Set-Location -Path $Path
}

function New-File {
    <#
    .SYNOPSIS
        Creates a new file with the specified name and extension. Alias: touch
    #>
    [CmdletBinding()]
    param ([Parameter(Mandatory = $true, Position = 0)][string]$Name)
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Find-File {
    <#
    .SYNOPSIS
        Finds a file in the current directory and all subdirectories. Alias: ff
    #>
    [CmdletBinding()]
    param ([Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)][string]$SearchTerm)
    $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -File -ErrorAction SilentlyContinue
    $result.FullName
}

function Find-String {
    <#
    .SYNOPSIS
        Searches for a string in a file or directory. Alias: grep
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchTerm,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [Alias('d')][string]$Directory,
        [Parameter(Mandatory = $false)]
        [Alias('f')][switch]$Recurse
    )

    if ($Directory) {
        if ($Recurse) { Get-ChildItem -Recurse $Directory | Select-String $SearchTerm; return }
        Get-ChildItem $Directory | Select-String $SearchTerm
        return
    }

    if ($Recurse) { Get-ChildItem -Recurse | Select-String $SearchTerm; return }
    Get-ChildItem | Select-String $SearchTerm
}

function Get-Aliases {
    <#
    .SYNOPSIS
        Show information of user's defined aliases. Alias: aliases
    #>
    [CmdletBinding()]
    param()

    #requires -Module PSScriptTools
    Get-MyAlias |
    Sort-Object Source, Name |
    Format-Table -Property Name, Definition, Version, Source -AutoSize
}

function Get-CommandInfo {
    <#
    .SYNOPSIS
        Displays the definition of a command. Alias: which
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    $commandExists = Get-Command $Name -ErrorAction SilentlyContinue
    if ($commandExists) {
        return $commandExists | Select-Object -ExpandProperty Definition
    } else {
        Write-Warning "Command not found: $Name."
        break
    }
}

function Remove-MyItem {
    <#
    .SYNOPSIS
        Removes an item and (optionally) all its children. Alias: rm
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$rf,
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )
    Remove-Item $Path -Recurse:$rf -Force:$rf
}

function Get-PSProfile {
    <#
    .SYNOPSIS
        Get all current in-use powershell profile
    .LINK
        https://powershellmagazine.com/2012/10/03/pstip-find-all-powershell-profiles-from-profile/
    #>
    $PROFILE.PSExtended.PSObject.Properties |
    Select-Object Name, Value, @{Name = 'IsExist'; Expression = { Test-Path -Path $_.Value -PathType Leaf } }
}

# ----------------------------------------------------------------------------------- #
# general
Set-Alias -Name 'aliases' -Value 'Get-Aliases'
Set-Alias -Name 'ff' -Value 'Find-File'
Set-Alias -Name 'grep' -Value 'Find-String'
Set-Alias -Name 'mkcd' -Value 'New-Directory'
Set-Alias -Name 'touch' -Value 'New-File'
Set-Alias -Name 'which' -Value 'Get-CommandInfo'

#Remove-Item Alias:rm -Force -ErrorAction SilentlyContinue
Set-Alias -Name 'rm' -Value 'Remove-MyItem'

# windows file explorer
function e { Invoke-Item . }

# common locations
function dotf { Set-Location $env:DOTFILES }
function dotp { Set-Location $env:DOTPOSH }
function home { Set-Location $env:USERPROFILE }
function docs { Set-Location $env:USERPROFILE\Documents }
function desktop { Set-Location $env:USERPROFILE\Desktop }
function downloads { Set-Location $env:USERPROFILE\Downloads }
function HKLM { Set-Location HKLM: }
function HKCU { Set-Location HKCU: }

# network
function flushdns { ipconfig /flushdns }
function displaydns { ipconfig /displaydns }
function chrome { Start-Process chrome }
function edge { Start-Process microsoft-edge: }

# powershell reload /restart
# Source: - https://stackoverflow.com/questions/11546069/refreshing-restarting-powershell-session-w-out-exiting\
function reload {
    if (Test-Path -Path $PROFILE) { . $PROFILE }
    elseif (Test-Path -Path $PROFILE.CurrentUserAllHosts) { . $PROFILE.CurrentUserAllHosts }
}
function restart { Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope } }

# windows system
function sysinfo { if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch -c all } else { Get-ComputerInfo } }
function lock { Invoke-Command { rundll32.exe user32.dll, LockWorkStation } }
function hibernate { shutdown.exe /h }
function shutdown { Stop-Computer }
function reboot { Restart-Computer }

function paths { $env:PATH -Split ';' }
function envs { Get-ChildItem Env: }
function profiles { Get-PSProfile { $_.exists -eq "True" } | Format-List }

# List NPM (NodeJS) Global Packages
# To export global packages to a file, for-example: `npm-ls > global_packages.txt`
function Get-NpmGlobalPackages { (npm ls -g | Select-Object -skip 1).Trim().Split() | ForEach-Object { if ($_ -match [regex]::Escape("@")) { Write-Output $_ } } }
function Get-BunGlobalPackages { (bun pm ls -g | Select-Object -Skip 1).Trim().Split() | ForEach-Object { if ($_ -match [regex]::Escape("@")) { Write-Output $_ } } }
function Get-PnpmGlobalPackages { (pnpm ls -g | Select-Object -Skip 5) | ForEach-Object { $name = $_.Split()[0]; $version = $_.Split()[1]; Write-Output "$name@$version" } }

Set-Alias -Name 'npm-ls' -Value 'Get-NpmGlobalPackages'
Set-Alias -Name 'bun-ls' -Value 'Get-BunGlobalPackages'
Set-Alias -Name 'pnpm-ls' -Value 'Get-PnpmGlobalPackages'

## Podman ##
if (Get-Command podman -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'docker' -Value 'podman'
}
