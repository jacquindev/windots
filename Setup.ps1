#requires -Version 7
<#
.SYNOPSIS
    Script to setup Windows machine
.DESCRIPTION
    This script will install and setup apps for Windows machine.
.PARAMETER Install
    Install all apps listed in 'appList.json'.
    Setup this 'windots' repo.
    Add extra environment variables from apps.
.PARAMETER Uninstall
    Uninstall all apps listed in 'appList.json'.
.EXAMPLE
    .\Setup.ps1
.EXAMPLE
    .\Setup.ps1 -u
.NOTES
    !! Please read the script carefully before you decide to you this 'windots' repo!
    - Remember to backup your files / Create a restore point before using this script.
    - My main screen is 3440x1440. You will need to modified 'komorebi.json' to fit your needs.
    - Rainmeter skins are included in 'windows/rainmeter' folder.
        -> Install jaxCore's skins by run the script 'JaxCore.ps1' 
    - Most of applications I am using are modified with Catppuccin Theme!

    Author: Jacquin Moon
    Created Date: October 7th, 2024
.LINK
    https://github.com/jacquindev/windots
#>

param (
    [Parameter(Mandatory = $False, HelpMessage = "Install all apps listed in 'appList.json'")]
    [Alias('i')][switch]$Install,
    [Parameter(Mandatory = $False, HelpMessage = "Uninstall all apps listed in 'appList.json'")]
    [Alias('u')][switch]$Uninstall
)

# Set working directory
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

# Define global var
$scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
$listApps = (Get-Content "$PSScriptRoot\appList.json" | ConvertFrom-Json).source

$WingetApps = $listApps.winget
$ScoopBuckets = $listApps.scoop.bucket
$ScoopApps = $listApps.scoop.user
$ScoopGlobalApps = $listApps.scoop.global
$PoshModules = $listApps.modules

$SymLinks = @{
    $PROFILE.CurrentUserAllHosts                                                                  = ".\Profile.ps1"
    "$Env:USERPROFILE\.config\eza"                                                                = ".\config\eza"
    "$Env:USERPROFILE\.config\fastfetch"                                                          = ".\config\fastfetch"
    "$Env:USERPROFILE\.config\komorebi"                                                           = ".\config\komorebi"
    "$Env:USERPROFILE\.config\whkdrc"                                                             = ".\config\whkdrc"
    "$Env:USERPROFILE\.config\yazi"                                                               = ".\config\yazi"
    "$Env:USERPROFILE\.config\delta"                                                              = ".\config\delta"
    "$Env:USERPROFILE\.config\gh-dash"                                                            = ".\config\gh-dash"
    # "$Env:USERPROFILE\.glzr\glazewm\config.yaml"                                                  = ".\config\glazewm\config.yaml"
    "$Env:APPDATA\bat"                                                                            = ".\config\bat"
    "$Env:APPDATA\topgrade.toml"                                                                  = ".\config\topgrade.toml"
    "$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
    "$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
    "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
    "$Env:USERPROFILE\.gitconfig"                                                                 = ".\home\.gitconfig"
}


###############################################################################
###                              HELPER FUNCTIONS                           ###
###############################################################################
function Set-WinGetApps {
    param (
        [array]$AppList,
        [switch]$Install,
        [switch]$Uninstall
    )

    foreach ($app in $AppList) {
        $installed = winget list --exact --accept-source-agreements -q $app
        if (![String]::Join("", $installed).Contains($app)) {
            if ($Install) {
                winget install --exact --silent --accept-source-agreements --accept-package-agreements $app --source winget
                Write-Host "WinGet: " -ForegroundColor "Green" -NoNewline
                Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                Write-Host "installed."
            }
            elseif ($Uninstall) {
                Write-Host "WinGet: " -ForegroundColor "Green" -NoNewline
                Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                Write-Host "is not available to uninstall. Skipping..."
            }
        }
        else {
            if ($Install) {
                Write-Host "WinGet: " -ForegroundColor "Green" -NoNewline
                Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                Write-Host "already installed. Skipping..."
            }
            elseif ($Uninstall) {
                winget uninstall --exact --silent --accept-source-agreements $app
                Write-Host "WinGet: " -ForegroundColor "Green" -NoNewline 
                Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                Write-Host "uninstalled."
            }
        }
    }
}

function Set-ScoopApps {
    param (
        [array]$AppList,
        [switch]$CurrentUser,
        [switch]$AllUsers,
        [switch]$Install,
        [switch]$Uninstall
    )

    foreach ($app in $AppList) {
        if (!(scoop info $app).Installed) {
            if ($Install) {
                if ($CurrentUser) {
                    scoop install $app | Out-Null
                    Write-Host "Scoop: " -ForegroundColor "Green" -NoNewline
                    Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                    Write-Host "installed."
                }
                elseif ($AllUsers) {
                    if ($(gsudo status IsElevated) -eq $False) {
                        gsudo scoop install $app --global | Out-Null
                    }
                    else {
                        scoop install $app --global | Out-Null
                    }
                }
            }
            elseif ($Uninstall) {
                Write-Host "Scoop: " -NoNewline -ForegroundColor "Green"
                Write-Host "$app " -NoNewline -ForegroundColor "Yellow"
                Write-Host "is not available to uninstall. Skipping..." 
            }
        }
        else {
            if ($Install) {
                Write-Host "Scoop: " -NoNewline -ForegroundColor "Green"
                Write-Host "$app " -NoNewline -ForegroundColor "Yellow"
                Write-Host "already installed. Skipping..."
            }
            elseif ($Uninstall) {
                scoop uninstall $Package --purge | Out-Null
                Write-Host "Scoop: " -ForegroundColor "Blue" -NoNewline
                Write-Host "$app " -ForegroundColor "Yellow" -NoNewline
                Write-Host "uninstalled."
            }
        }
    }
}

function Set-ScoopBucket {
    param (
        [string]$Bucket,
        [switch]$Add,
        [switch]$Remove
    )

    $BucketDir = "$scoopDir\buckets"
    if (!(Test-Path -PathType Container -Path "$BucketDir\$Bucket")) {
        if ($Add) {
            scoop bucket add $Bucket
            Write-Host "Bucket: " -ForegroundColor "Green" -NoNewline
            Write-Host "$Bucket " -ForegroundColor "Yellow" -NoNewline
            Write-Host "added for Scoop."
        }
        elseif ($Remove) {
            Write-Host "Bucket: " -ForegroundColor "Green" -NoNewline
            Write-Host "$Bucket " -ForegroundColor "Yellow" -NoNewline
            Write-Host "is not available to remove. Skipping..."
        }
    }
    else {
        if ($Add) {
            Write-Host "Bucket: " -NoNewline -ForegroundColor "Green"
            Write-Host "$Bucket " -NoNewline -ForegroundColor "Yellow"
            Write-Host "already added for Scoop. Skipping..."
        }
        elseif ($Remove) {
            Write-Host "Bucket: " -ForegroundColor "Green" -NoNewline
            Write-Host "$Bucket " -ForegroundColor "Yellow" -NoNewline
            Write-Host "removed for Scoop."
            scoop bucket rm $Bucket
        }
    }
}

function Set-PoshModules {
    param (
        [array]$ModuleList,
        [switch]$Install,
        [switch]$Uninstall
    )

    foreach ($module in $ModuleList) {
        if (!(Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
            if ($Install) {
                Write-Host "Module: " -ForegroundColor "Green" -NoNewline
                Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
                Write-Host "is being installed" 
                Install-Module -Name $Module -AllowClobber -Scope CurrentUser -Force
            }
            elseif ($Uninstall) {
                Write-Host "Module: " -ForegroundColor "Green" -NoNewline
                Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
                Write-Host "is not available. Skipping..."
            }
        }
        else {
            if ($Install) {
                Write-Host "Module: " -ForegroundColor "Green" -NoNewline
                Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
                Write-Host "already installed. Skipping..."
            }
            elseif ($Uninstall) {
                Uninstall-Module -Name $Module -Force
                Write-Host "Module: " -ForegroundColor "Blue" -NoNewline
                Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
                Write-Host "uninstalled." 
            }
        }
    }
}

function Write-ModuleLockFile {
    Get-InstalledModule |
    Select-Object Name, Version, Author, InstalledDate, Description |
    ConvertTo-Json -Depth 100 |
    Out-File "$PSScriptRoot\modules.lock.json" -Encoding utf8 -Force
}

function Set-SymbolicLinks {
    param (
        [hashtable]$Symlinks,
        [switch]$Add,
        [switch]$Remove
    )

    foreach ($symlink in $Symlinks.GetEnumerator()) {
        $symlinkFile = Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
        if ($Add) {
            Write-Host "Symlink: " -ForegroundColor "Green" -NoNewline
            Write-Host "added for $($symlink.Key)" -ForegroundColor "Gray"
            $symlinkFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
            Start-Sleep -Seconds 1
        }
        elseif ($Remove) {
            if (($symlinkFile) -and (($symlinkFile.LinkType) -eq "SymbolicLink")) {
                Write-Host "Symlink: " -ForegroundColor "Blue" -NoNewline
                Write-Host "removing $($symlink.Key)" -ForegroundColor "Gray"
                Remove-Item "$($symlink.Key)" -Force -Recurse -ErrorAction SilentlyContinue
            }
            else {
                Write-Host "Symlink: " -ForegroundColor "Blue" -NoNewline
                Write-Host "$($symlink.Key) " -NoNewline -ForegroundColor "Yellow"
                Write-Host "is not a symlink / is not available to remove." 
            }
        }
    }
}

function Set-GsudoCacheMode {
    param([switch]$on, [switch]$off)
    if (Get-Command gsudo -ErrorAction SilentlyContinue) {
        if ($on) { 
            Write-Host "-----------------------" -ForegroundColor "Cyan"
            Write-Host "Enable gsudo CacheMode:" -ForegroundColor "Cyan"
            Write-Host "-----------------------" -ForegroundColor "Cyan"
            Start-Sleep -Seconds 5
            & gsudo cache on 
        }
        if ($off) { 
            Write-Host "------------------------" -ForegroundColor "Cyan"
            Write-Host "Disable gsudo CacheMode:" -ForegroundColor "Cyan"
            Write-Host "------------------------" -ForegroundColor "Cyan"
            Start-Sleep -Seconds 5
            & gsudo cache off 
        }
    } 
}

function Install-File {
    param (
        [string]$Dir,
        [string]$Url
    )
    if (Get-Command wget.exe -ErrorAction SilentlyContinue) {
        & wget.exe --quiet -P "$Dir" "$Url"
    }
    else {
        Invoke-WebRequest -Uri "$Url" -OutFile "$Dir"
    }
}

function Set-EnvironmentVariable {
    param ([string]$Value, [string]$Path)

    if (!([System.Environment]::GetEnvironmentVariable("$Value"))) {
        Write-Host "Environment Variable: " -ForegroundColor "Green" -NoNewline
        Write-Host "adding $Value with Path: $Path" -ForegroundColor "Gray"
        [System.Environment]::SetEnvironmentVariable("$Value", "$Path", "User")
    }
    else {
        Write-Host "Environment Variable: " -ForegroundColor "Green" -NoNewline
        Write-Host "$Value " -NoNewline -ForegroundColor "Yellow"
        Write-Host "already set! Skipping..." -ForegroundColor "Gray"
    }
}

function Test-InternetConnection {
    $testconnection = Test-Connection -ComputerName www.google.com -Count 1 -Quiet -ErrorAction Stop 
    if ($testconnection -eq $False) {
        Write-Host "---------------------------------" -ForegroundColor "Yellow"
        Write-Warning "NO INTERNET CONNECTION AVAILABLE!"
        Write-Host "---------------------------------" -ForegroundColor "Yellow"
        Write-Host "Please recheck your internet connection and rerun this script." -ForegroundColor "Red"
        Write-Host "Exiting..."
        Start-Sleeps -Seconds 1
        Break
    }
}

function Test-DeveloperMode {
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path -Path $RegistryKeyPath)) { return $False }
}


###################################################################################
###                                     MAIN FUNCTIONS                          ###
###################################################################################
function Setup {
    # Winget
    ''
    Write-Host "------------------------" -ForegroundColor "Blue"
    Write-Host "Install WinGet Packages:" -ForegroundColor "Blue"
    Write-Host "------------------------" -ForegroundColor "Blue"
    Set-WinGetApps -Install -AppList $WingetApps
    $wingetLockFile = "$PSScriptRoot\packages.lock.json"
    if (Test-Path $wingetLockFile) {
        Remove-Item $wingetLockFile -Force -Recurse -ErrorAction SilentlyContinue
    }
    winget export -o "$PSScriptRoot\packages.lock.json" | Out-Null
    Write-Host ""
    Write-Host "==> " -NoNewline -ForegroundColor "Cyan"
    Write-Host "Packages installed by WinGet was written in " -NoNewline
    Write-Host "$wingetLockFile" -ForegroundColor "Cyan" 
    ''
    Set-GsudoCacheMode -on
    Start-Sleep -Seconds 1

    # Scoop
    ''
    Write-Host "-----------------------" -ForegroundColor "Blue"
    Write-Host "Install Scoop Packages:" -ForegroundColor "Blue"
    Write-Host "-----------------------" -ForegroundColor "Blue"
    
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..." -ForegroundColor "Yellow"
        if ($(gsudo status IsElevated) -eq $False) {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
        else {
            Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        }
    }
    
    foreach ($bucket in $ScoopBuckets) {
        Set-ScoopBucket -Add -Bucket $bucket
    }
    Set-ScoopApps -Install -AppList $ScoopApps -CurrentUser
    Set-ScoopApps -Install -AppList $ScoopGlobalApps -AllUsers

    # Powershell Modules
    Write-Host "---------------------------" -ForegroundColor "Blue"
    Write-Host "Install PowerShell Modules:" -ForegroundColor "Blue"
    Write-Host "---------------------------" -ForegroundColor "Blue"
    Set-PoshModules -Install -ModuleList $PoshModules
    Write-ModuleLockFile
    Start-Process pwsh -WindowStyle Hidden -ArgumentList "-NoProfile -Command Update-Help -Scope CurrentUser"

    # Symlinks
    ''
    Write-Host "----------------------" -ForegroundColor "Blue"
    Write-Host "Create Symbolic Links:" -ForegroundColor "Blue"
    Write-Host "----------------------" -ForegroundColor "Blue"
    Set-SymbolicLinks -Add -Symlinks $SymLinks

    ''
    Write-Host "----------------------------" -ForegroundColor "Blue"
    Write-Host "Setup Environment Variables:" -ForegroundColor "Blue"
    Write-Host "----------------------------" -ForegroundColor "BLue"
    # Yazi
    if (Get-Command yazi -ErrorAction SilentlyContinue) {
        $GitInstalledDir = Split-Path "$(Get-Command git.exe | Select-Object -ExpandProperty Definition)" | Split-Path
        $GitFileExePath = "$GitInstalledDir\usr\bin\file.exe"
        Set-EnvironmentVariable -Value "YAZI_FILE_ONE" -Path "$GitFileExePath"
        Set-EnvironmentVariable -Value "YAZI_CONFIG_HOME" -Path "$Env:USERPROFILE\.config\yazi"
        Remove-Variable GitInstalledDir, GitFileExePath
    }
    # Eza
    if (Get-Command eza -ErrorAction SilentlyContinue) { 
        Set-EnvironmentVariable -Value "EZA_CONFIG_DIR" -Path "$Env:USERPROFILE\.config\eza"
    }
    # Komorebi
    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        Set-EnvironmentVariable -Value "KOMOREBI_CONFIG_HOME" -Path "$Env:USERPROFILE\.config\komorebi"
    }

    # Bat
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        ''
        Write-Host "-----------------------" -ForegroundColor "Blue"
        Write-Host "Setup Bat Cache Themes:" -ForegroundColor "BLue"
        Write-Host "-----------------------" -ForegroundColor "Blue"
        bat cache --clear
        bat cache --build
    }

    # btop: add Catppuccin themes
    if (Get-Command btop -ErrorAction SilentlyContinue) {
        ''
        Write-Host "------------------------------" -ForegroundColor "Blue"
        Write-Host "Add Catppuccin Theme for BTOP:" -ForegroundColor "Blue"
        Write-Host "------------------------------" -ForegroundColor "Blue"
        # !! Since we installed btop with scoop, so the themes folder would be:
        $btopThemeDir = "$scoopDir\apps\btop\current\themes"
        if (Test-Path -PathType Container $btopThemeDir) {
            $catppuccinThemes = (Get-ChildItem -Path $btopThemeDir -Recurse | Where-Object { $_.FullName -match 'catppuccin' }).Name
            if (!($catppuccinThemes)) {
                $catppuccinThemeNames = @('catppuccin_frappe', 'catppuccin_latte', 'catppuccin_macchiato', 'catppuccin_mocha')
                foreach ($theme in $catppuccinThemeNames) {
                    Write-Host "Btop: Catppuccin Theme: " -ForegroundColor "Green" -NoNewline
                    Write-Host "$theme " -ForegroundColor "Yellow" -NoNewline
                    Write-Host "is being installed..."
                    Install-File -Dir $btopThemeDir -Url "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme"
                }
            }
            else {
                Write-Host "Btop: " -ForegroundColor "Green" -NoNewline
                Write-Host "Catppuccin Themes " -ForegroundColor "Yellow" -NoNewline
                Write-Host "already installed! Skipping..."
            }
        }
    }

    # VSCode Extensions
    if (Get-Command code -ErrorAction SilentlyContinue) {
        ''
        Write-Host "------------------------------" -ForegroundColor "Blue"
        Write-Host "Visual Studio Code Extensions:" -ForegroundColor "Blue"
        Write-Host "------------------------------" -ForegroundColor "Blue"
        $extensionList = Get-Content -Path "$PSScriptRoot\vscode\extensions.list"
        foreach ($extension in $extensionList) {
            code --install-extension $extension | Out-Null
            Write-Host "VSCode Extension: " -ForegroundColor "Green" -NoNewline
            Write-Host "$extension " -ForegroundColor "Yellow" -NoNewline
            Write-Host "installed"
        }
    }

    ''
    Write-Host "---------------------------" -ForegroundColor "Blue"
    Write-Host "Setup Git Name & Git Email:" -ForegroundColor "Blue"
    Write-Host "---------------------------" -ForegroundColor "Blue"
    if (Test-Path -Path "$Env:USERPROFILE\.gitconfig-local") {
        if ($(Get-Content -Path "$Env:USERPROFILE\.gitconfig-local" -Raw).Contains("[user]") -eq $False) {
            Write-GitConfigLocal
        }
        else {
            Write-Host "Git Email and Name already set in local config. Skipping update." -ForegroundColor "Yellow"
        }
    }
    else {
        New-Item -Path "$Env:USERPROFILE\.gitconfig-local" -ItemType File | Out-Null
        Write-GitConfigLocal
    }
    git submodule update --init --recursive

    ''
    Set-GsudoCacheMode -off
    Start-Sleep -Seconds 1
}


function Reverse {
    ''
    Set-GsudoCacheMode -on
    Start-Sleep -Seconds 1

    # Scoop
    ''
    Write-Host "--------------------------" -ForegroundColor "Blue"
    Write-Host "Uninstall WinGet Packages:" -ForegroundColor "Blue"
    Write-Host "--------------------------" -ForegroundColor "Blue"
    Set-ScoopApps -Uninstall -AppList $ScoopApps -CurrentUser
    Set-ScoopApps -Uninstall -AppList $ScoopGlobalApps -AllUsers
    foreach ($bucket in $ScoopBuckets) {
        Set-ScoopBucket -Remove -Bucket $bucket
    }

    ''
    Set-GsudoCacheMode -off
    Start-Sleep -Seconds 1

    # WinGet
    ''
    Write-Host "--------------------------" -ForegroundColor "Blue"
    Write-Host "Uninstall WinGet Packages:" -ForegroundColor "Blue"
    Write-Host "--------------------------" -ForegroundColor "Blue"
    Set-WinGetApps -Uninstall -AppList $WingetApps

    # PowerShell Modules
    ''
    Write-Host "-----------------------------" -ForegroundColor "Blue"
    Write-Host "Uninstall PowerShell Modules:" -ForegroundColor "Blue"
    Write-Host "-----------------------------" -ForegroundColor "Blue"
    Set-PoshModules -Uninstall -ModuleList $PoshModules

    # Symlinks
    ''
    Write-Host "----------------------" -ForegroundColor "Blue"
    Write-Host "Create Symbolic Links:" -ForegroundColor "Blue"
    Write-Host "----------------------" -ForegroundColor "Blue"
    Set-SymbolicLinks -Remove -Symlinks $SymLinks
}


###############################################################################
###                              START THE SCRIPT                           ###
###############################################################################
if (($PSBoundParameters.Count -eq 0) -or ($Install)) { Setup }
elseif ($Uninstall) { 
    ''
    Write-Host "WARNING: This will UNINSTALL all apps that installed by this script, which" -ForegroundColor "Yellow"
    Write-Host "         included: Scoop Packages, WinGet Packages, PowerShell Modules, " -ForegroundColor "Yellow"
    Write-Host "         AND symlink files/folders of this 'windots' repo!!!" -ForegroundColor "Yellow"
    ''
    Write-Host "NOTES: This script WILL NOT UNINSTALL Scoop/Winget itself, and the" -ForegroundColor "Blue"
    Write-Host "       ENVIRONMENT VARIABLES we have set, and this 'windots' folder." -ForegroundColor "Blue"
    ''
    $confirm = $(Write-Host "ARE YOU SURE TO PROCEED? (y/n) " -ForegroundColor "Red" -NoNewline; Read-Host)
    if ($confirm -eq 'y') {
        Reverse
    }
    else {
        Write-Host "Cancelled the process. Exiting..."
        Break
    }
}