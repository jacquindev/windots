<#
.SYNOPSIS
    Update all installed modules
.EXAMPLE
    Update-Modules -Scope CurrentUser
.PARAMETER AllowPrerelease
    Updating module to latest prerelease version.
.PARAMETER WhatIf
    Run function without actually executing it.
.PARAMETER Name
    Name of the module you want to update.
.PARAMETER Scope
    The scope apply when updating modules.
#>

function Update-Modules {
    param (
        [switch]$AllowPrerelease,

        [switch]$WhatIf,

        [string]$Name = "*",

        [ValidateSet('AllUsers', 'CurrentUser')]
        [string]$Scope = "CurrentUser"
    )

    if ($Scope -eq "AllUsers") {
        if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $False) {
            Write-Warning "Function $($MyInvocation.MyCommand) needs admin privileges to perform actions."
            break
        }
    }

    $CurrentModules = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue | Select-Object -Property Name, Version | Sort-Object Name

    if (!$CurrentModules) { Write-Host "No modules found." -ForegroundColor Red; return }
    else {
        $i = 1
        $moduleCount = $CurrentModules.Count
        ''; Write-Host "$moduleCount " -ForegroundColor Yellow -NoNewline; Write-Host "module(s) installed." -ForegroundColor Green; ''

        if ($AllowPrerelease) { Write-Host "Trying to update modules to latest " -ForegroundColor Blue -NoNewline; Write-Host "prerelease " -NoNewline -ForegroundColor Magenta; Write-Host "version" -ForegroundColor Blue }
        else { Write-Host "Trying to update modules to latest " -ForegroundColor Blue -NoNewline; Write-Host "stable " -NoNewline -ForegroundColor Magenta; Write-Host "version" -ForegroundColor Blue }

        foreach ($module in $CurrentModules) {
            $OnlineVersion = (Find-Module -Name $($module.Name) -AllVersions | Sort-Object PublishedDate -Descending)[0].Version
            $CurrentVersion = (Get-InstalledModule -Name $($module.Name)).Version

            if ($CurrentVersion -ne $OnlineVersion) {
                try {
                    Update-Module -Name $($module.Name) -AllowPrerelease:$AllowPrerelease -Scope:$Scope -Force:$True -WhatIf:$WhatIf.IsPresent
                } catch {
                    Write-Error "Error occurred while updating module $($module.Name): $_"
                }
            }

            [int]$percentCompleted = ($i / $moduleCount) * 100
            Write-Progress -Activity "Updating Module $($module.Name)" -Status "$percentCompleted% Completed - $($module.Name) v$OnlineVersion" -PercentComplete $percentCompleted
            $i++
        }
        if ($?) { Write-Host "Everything is up-to-date!" -ForegroundColor Green }
    }
}

Export-ModuleMember -Function Update-Modules
