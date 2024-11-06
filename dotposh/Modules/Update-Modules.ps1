function Test-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-Modules {
    [CmdletBinding()]
    param (
        [Alias('p')][switch]$AllowPrerelease,
        [Alias('n', 'dryrun')][switch]$WhatIf,
        [string]$Name = "*",
        [ValidateSet('AllUsers', 'CurrentUser')][string]$Scope = 'CurrentUser'
    )   

    # Test elevated permissions for scope allusers
    if ($Scope -eq "AllUsers") {
        if ((Test-IsElevated) -eq $False) {
            Write-Warning "Function $($MyInvocation.MyCommand) needs admin privileges to perform actions."
            Break 
        }
    }

    # Status of allow prerelease switch
    if ($AllowPrerelease) {
        ''
        Write-Host "Updating modules to latest " -ForegroundColor "Blue" -NoNewline
        Write-Host "prerelease " -ForegroundColor "Yellow" -NoNewline
        Write-Host "versions..." -ForegroundColor "Blue"
        Write-Host "-------------------------------------------------" -ForegroundColor "Blue"
    }
    else {
        ''
        Write-Host "Updating modules to latest " -ForegroundColor "Blue" -NoNewline
        Write-Host "stable " -ForegroundColor "Yellow" -NoNewline
        Write-Host "versions..." -ForegroundColor "Blue"
        Write-Host "---------------------------------------------" -ForegroundColor "Blue"
    }

    # Get all installed modules
    if ((Test-Path "$Env:DOTFILES\modules.lock.json") -and ($Name -eq "*")) {
        $CurrentModules = Get-Content "$Env:DOTFILES\modules.lock.json" | ConvertFrom-Json | Select-Object -Property Name, Version | Sort-Object Name
    }
    else {
        $CurrentModules = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue | Select-Object -Property Name, Version | Sort-Object Name
    }

    # If no modules installed.
    if (-not $CurrentModules) {
        ''
        Write-Host "No modules found." -ForegroundColor "Red"
        Return
    }
    else {
        ''
        $ModulesCount = $CurrentModules.Count 
        Write-Host "$ModulesCount " -ForegroundColor "White" -NoNewLine
        Write-Host "module(s) installed." -ForegroundColor "Green"
    }

    foreach ($Module in $CurrentModules) {
        ''
        Write-Host "Checking for updated version of module: " -ForegroundColor "Gray" -NoNewLine
        Write-Host "$($Module.Name)" -ForegroundColor "White"
        $OnlineVersion = (Find-Module -Name $Module.Name -AllVersions | Sort-Object PublishedDate -Descending)[0].Version
        $CurrentVersion = (Get-InstalledModule -Name $Module.Name).Version
        if ($CurrentVersion -lt $OnlineVersion) {
            try {
                Update-Module -Name $Module.Name -AllowPrerelease:$AllowPrerelease -Scope:$Scope -Force:$True -ErrorAction Stop -WhatIf:$WhatIf.IsPresent
                $CurrentVersion = $CurrentModules | Where-Object Name -EQ $Module.Name
                if ($CurrentVersion.Version -notlike $Module.Version) {
                    Write-Host "Updated module $($Module.Name) from version $($CurrentVersion.Version) to $($Module.Version)" -ForegroundColor "Green"
                }
                foreach ($Version in $CurrentVersion) {
                    if ($Version.Version -ne $CurrentVersion[0].Version) {
                        Uninstall-Module -Name $Module.Name -RequiredVersion $Version.Version -Force:$True -ErrorAction Stop -WhatIf:$WhatIf.IsPresent
                    }
                }
            }
            catch {
                Write-Error "Error occurred while updating module $($Module.Name): $_"
            }
        }
        else {
            Write-Host "Already up-to-date!" -ForegroundColor "Blue"
        }
    }
    ''
}