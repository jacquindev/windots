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
        -> Install JaxCore's skins by run the script 'JaxCore.ps1' 
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
$npmPackages = $listApps.npm

$SymLinks = @{
    $PROFILE.CurrentUserAllHosts                                                                  = ".\Profile.ps1"
    "$Env:USERPROFILE\.config\eza"                                                                = ".\config\eza"
    "$Env:USERPROFILE\.config\fastfetch"                                                          = ".\config\fastfetch"
    "$Env:USERPROFILE\.config\komorebi"                                                           = ".\config\komorebi"
    "$Env:USERPROFILE\.config\whkdrc"                                                             = ".\config\whkdrc"
    "$Env:USERPROFILE\.config\yasb"                                                               = ".\config\yasb"
    "$Env:USERPROFILE\.config\yazi"                                                               = ".\config\yazi"
    "$Env:USERPROFILE\.config\delta"                                                              = ".\config\delta"
    "$Env:USERPROFILE\.config\gh-dash"                                                            = ".\config\gh-dash"
    "$Env:USERPROFILE\.config\npm"                                                                = ".\config\npm"
    # "$Env:USERPROFILE\.glzr\glazewm\config.yaml"                                                  = ".\config\glazewm\config.yaml"
    "$Env:APPDATA\bat"                                                                            = ".\config\bat"
    "$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
    # "$Env:LOCALAPPDATA\nvim"                                                                      = ".\config\nvim"
    "$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
    "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
    "$Env:USERPROFILE\.gitconfig"                                                                 = ".\home\.gitconfig"
    "$ENv:USERPROFILE\.czrc"                                                                      = ".\home\.czrc"
}


###########################################################################################################
###                                             HELPERS FUNCTIONS                                       ###
###########################################################################################################

function Write-PrettyOutput {
    param (
        [Alias('p')][string]$ProcessName,
        [Alias('e')][string]$EntryName,
        [Alias('m')][string]$Message
    )
    Write-Host "$ProcessName" -ForegroundColor "Green" -NoNewline
    Write-Host " ▏ " -ForegroundColor "DarkGray" -NoNewline
    Write-Host "$EntryName" -ForegroundColor "Yellow" -NoNewline
    Write-Host " $Message"
}

function Write-PrettyTitle {
    param (
        [string]$Title
    )
    
    $charCount = $Title.Length
    $line = ""
    for ($i = 0; $i -lt $charCount; $i++) {
        $line = $line.Insert($i, '―') 
    }
    Write-Host "$line" -ForegroundColor "Blue"
    Write-Host "$Title" -ForegroundColor "Blue"
    Write-Host "$line" -ForegroundColor "Blue"
}

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
                Write-PrettyOutput -p "WinGet" -e "$app" -m "installed."
            }
            elseif ($Uninstall) {
                Write-PrettyOutput -p "WinGet" -e "$app" -m "is not available to uninstall. Skipping..."
            }
        }
        else {
            if ($Install) {
                Write-PrettyOutput -p "WinGet" -e "$app" -m "already installed. Skipping..."
            }
            elseif ($Uninstall) {
                winget uninstall --exact --silent --accept-source-agreements $app
                Write-PrettyOutput -p "WinGet" -e "$app" -m "uninstalled."
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
                    Write-PrettyOutput -p "Scoop" -e "$app" -m "installed."
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
                Write-PrettyOutput -p "Scoop" -e "$app" -m "is not available to uninstall. Skipping..."
            }
        }
        else {
            if ($Install) {
                Write-PrettyOutput -p "Scoop" -e "$app" -m "already installed. Skipping..."
            }
            elseif ($Uninstall) {
                scoop uninstall $Package --purge | Out-Null
                Write-PrettyOutput -p "Scoop" -e "$app" -m "uninstalled."
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
            Write-PrettyOutput -p "Scoop Bucket" -e "$Bucket" -m "added for Scoop."
        }
        elseif ($Remove) {
            Write-PrettyOutput -p "Scoop Bucket" -e "$Bucket" -m "is not available to remove. Skipping..."
        }
    }
    else {
        if ($Add) {
            Write-PrettyOutput -p "Scoop Bucket" -e "$Bucket" -m "already added for Scoop. Skipping..."
        }
        elseif ($Remove) {
            scoop bucket rm $Bucket
            Write-PrettyOutput -p "Scoop Bucket" -e "$Bucket" -m "removed for Scoop."
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
                Install-Module -Name $Module -AllowClobber -Scope CurrentUser -Force
                Write-PrettyOutput -p "Module" -e "$Module" -m "installed."
            }
            elseif ($Uninstall) {
                Write-PrettyOutput -p "Module" -e "$Module" -m "is not available. Skipping..."
            }
        }
        else {
            if ($Install) {
                Write-PrettyOutput -p "Module" -e "$Module" -m "installed."
            }
            elseif ($Uninstall) {
                Uninstall-Module -Name $Module -Force
                Write-PrettyOutput -p "Module" -e "$Module" -m "uninstalled."
            }
        }
    }
}

function Write-ModuleLockFile {
    Get-InstalledModule |
    Select-Object Name, Version, Author, InstalledDate, Description |
    ConvertTo-Json -Depth 100 |
    Out-File "$PSScriptRoot\modules.lock.json" -Encoding utf8 -Force
    ''
    Write-Host "==> " -ForegroundColor "Cyan" -NoNewline
    Write-Host "PowerShell Modules installed was written in " -NoNewline
    Write-Host "$PSScriptRoot\modules.lock.json" -ForegroundColor "Cyan"
}

function Test-DeveloperMode {
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if ((Test-Path $RegistryKeyPath) -and (Get-ItemProperty -Path $RegistryKeyPath | Select-Object -ExpandProperty AllowDevelopmentWithoutDevLicense)) {
        return $true
    }
    else {
        return $false
    }
}

function Test-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-SymbolicLinks {
    param (
        [hashtable]$Symlinks,
        [switch]$Add,
        [switch]$Remove
    )

    foreach ($symlink in $Symlinks.GetEnumerator()) {
        $symlinkFile = Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
        $symlinkKey = $symlink.Key
        if ($Add) {
            $symLinkTarget = Resolve-Path $symlink.Value
            if (Test-Path -Path $symlinkTarget) {
                $symlinkFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                if (((Test-DeveloperMode) -eq $False) -and ((Test-IsElevated) -eq $False)) {
                    gsudo { New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null }
                }
                else {
                    New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null
                }
                Write-PrettyOutput -p "Symlink" -e "$symlinkKey" -m "added."
            }
        }
        elseif ($Remove) {
            if (($symlinkFile) -and (($symlinkFile.LinkType) -eq "SymbolicLink")) {
                Remove-Item "$symlinkKey" -Force -Recurse -ErrorAction SilentlyContinue
                Write-PrettyOutput -p "Symlink" -e "$symlinkKey" -m "removed."
            }
            else {
                Write-PrettyOutput -p "Symlink" -e "$symlinkKey" -m "is not a symlink / is not available to remove." 
            }
        }
    }
}

function Set-GsudoCacheMode {
    param([switch]$on, [switch]$off)
    if (Get-Command gsudo -ErrorAction SilentlyContinue) {
        if ($on) { 
            Write-PrettyTitle "Enable Gsudo CacheMode"
            Start-Sleep -Seconds 5
            & gsudo cache on 
        }
        if ($off) { 
            Write-PrettyTitle "Disable Gsudo CacheMode"
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
        Write-PrettyOutput -p "Environment Variable" -e "$Value" -m "already set! Skipping..."
    }
}

function Test-InternetConnection {
    $testconnection = Test-Connection -ComputerName www.google.com -Count 1 -Quiet -ErrorAction Stop 
    if ($testconnection -eq $False) {
        Write-Host "―――――――――――――――――――――――――――――――――" -ForegroundColor "Yellow"
        Write-Warning "NO INTERNET CONNECTION AVAILABLE!"
        Write-Host "―――――――――――――――――――――――――――――――――" -ForegroundColor "Yellow"
        Write-Host "Please recheck your internet connection and rerun this script." -ForegroundColor "Red"
        Write-Host "Exiting..."
        Start-Sleeps -Seconds 1
        Break
    }
}


###################################################################################################
###                                             MAIN FUNCTIONS                                  ###
###################################################################################################
function Setup {
    # Winget
    ''
    Write-PrettyTitle "Install WinGet Packages"
    Set-WinGetApps -Install -AppList $WingetApps
    $wingetLockFile = "$PSScriptRoot\packages.lock.json"
    if (Test-Path $wingetLockFile) {
        Remove-Item $wingetLockFile -Force -Recurse -ErrorAction SilentlyContinue
    }
    winget export -o "$wingetLockFile" | Out-Null
    Write-Host ""
    Write-Host "==> " -NoNewline -ForegroundColor "Cyan"
    Write-Host "Packages installed by WinGet was written in " -NoNewline
    Write-Host "$wingetLockFile" -ForegroundColor "Cyan" 
    ''
    Set-GsudoCacheMode -on
    Start-Sleep -Seconds 1

    # Scoop
    ''
    Write-PrettyTitle "Install Scoop Packages"

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
    ''
    Write-PrettyTitle "Install PowerShell Modules"
    Set-PoshModules -Install -ModuleList $PoshModules
    Write-ModuleLockFile
    Start-Process pwsh -WindowStyle Hidden -ArgumentList "-NoProfile -Command Update-Help -Scope CurrentUser"

    # Setup Git
    ''
    Write-PrettyTitle "Setup Git Name & Email"
    if (Test-Path -Path "$Env:USERPROFILE\.gitconfig-local") {
        if ($(Get-Content -Path "$Env:USERPROFILE\.gitconfig-local" -Raw).Contains("[user]") -eq $False) {
            Write-GitConfigLocal
        }
        else {
            Write-Host "Git Email and Name already set in " -NoNewLine
            Write-Host "$Env:USERPROFILE\.gitconfig-local" -ForegroundColor "Cyan"
        }
    }
    else {
        New-Item -Path "$Env:USERPROFILE\.gitconfig-local" -ItemType File | Out-Null
        Write-GitConfigLocal
    }
    git submodule update --init --recursive

    # Symlinks
    ''
    Write-PrettyTitle "Create Symbolic Links"
    Set-SymbolicLinks -Add -Symlinks $SymLinks
    Start-Sleep -Seconds 1
    
    ''
    Write-PrettyTitle "Setup Environment Variables"
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
        Write-PrettyTitle "Setup Bat Cache Themes"
        bat cache --clear
        bat cache --build
    }

    # btop: add Catppuccin themes
    if (Get-Command btop -ErrorAction SilentlyContinue) {
        # !! Since we installed btop with scoop, so the themes folder would be:
        $btopThemeDir = "$scoopDir\apps\btop\current\themes"
        if (Test-Path -PathType Container $btopThemeDir) {
            ''
            Write-PrettyTitle "Add Catppuccin Theme for BTOP"
            $catppuccinThemes = (Get-ChildItem -Path $btopThemeDir -Recurse | Where-Object { $_.FullName -match 'catppuccin' }).Name
            if (!($catppuccinThemes)) {
                $catppuccinThemeNames = @('catppuccin_frappe', 'catppuccin_latte', 'catppuccin_macchiato', 'catppuccin_mocha')
                foreach ($theme in $catppuccinThemeNames) {
                    Write-Host "Btop: " -ForegroundColor "Green" -NoNewline
                    Write-Host "Catppuccin Theme: " -ForegroundColor "Yellow" -NoNewline
                    Write-Host "$theme " -ForegroundColor "Magenta" -NoNewline
                    Write-Host "is being installed..."
                    Install-File -Dir $btopThemeDir -Url "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme"
                }
            }
            else {
                Write-PrettyOutput -p "Btop" -e "Catppuccin Themes" -m "already installed! Skipping..."
            }
        }
    }

    # flow-launcher theme
    $flowLauncherThemeFolder = "$Env:APPDATA\FlowLauncher\Themes"
    if (Test-Path -PathType Container -Path "$flowLauncherThemeFolder") {
        ''
        Write-PrettyTitle "Add Catppuccin Theme for FlowLauncher"
        $flowThemes = (Get-ChildItem -Path $flowLauncherThemeFolder -Recurse | Where-Object { $_.FullName -match 'Catppuccin' }).Name
        if (!($flowThemes)) {
            @('Frappe', 'Latte', 'Macchiato', 'Mocha') | ForEach-Object {
                Write-Host "FlowLauncher: " -ForegroundColor "Green" -NoNewline
                Write-Host "Catppuccin Theme: " -ForegroundColor "Yellow" -NoNewline
                Write-Host "Catppuccin $_ " -ForegroundColor "Magenta" -NoNewline
                Write-Host "is being installed..."
                Install-File -Dir $flowLauncherThemeFolder -Url "https://raw.githubusercontent.com/catppuccin/flow-launcher/refs/heads/main/themes/Catppuccin%20$_.xaml"
            }
        }
        else {
            Write-PrettyOutput -p "FlowLauncher" -e "Catppuccin Themes" -m "already installed! Skipping..."
        }
    }

    # spicetify marketplace
    if (Get-Command spicetify -ErrorAction SilentlyContinue) {
        ''
        Write-PrettyTitle "Install Spicetify's Marketplace"
        $customAppsFolder = "$env:APPDATA\spicetify\CustomApps"
        if (Test-Path -PathType Container -Path $customAppsFolder) {
            if (!(Test-Path -PathType Container -Path "$customAppsFolder\marketplace")) {
                Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1" | Invoke-Expression | Out-Null
                Write-PrettyOutput -p "spicetify" -e "marketplace" -m "installed."
            }
            else {
                Write-PrettyOutput -p "spicetify" -e "marketplace" -m "already exists. Skipping..."
            }
        }
    } 

    # NodeJS
    # Since we installed nvm using scoop, nvm dir would be:
    if ((!(Get-Command npm -ErrorAction SilentlyContinue)) -and (Get-Command nvm -ErrorAction SilentlyContinue)) {
        ''
        Write-PrettyTitle "Install NodeJS, NPM, YARN, etc"
        $ltsOrLatest = $(Write-Host "NodeJS not found. Install lts (y) or latest (n)? "-ForegroundColor "Cyan" -NoNewline; Read-Host)
        if ($ltsOrLatest -eq 'y') {
            nvm install lts
            nvm use lts
        }
        else {
            nvm install latest
            nvm use latest
        }
        corepack enable
        npm config set userconfig="$env:USERPROFILE\.config\npm\.npmrc" --global
    }
    elseif (Get-Command npm -ErrorAction SilentlyContinue) {
        ''
        Write-PrettyTitle "Install NPM Global Packages"
        foreach ($package in $npmPackages) {
            npm install --global --silent $package
            Write-PrettyOutput -p "npm" -e "$package" -m "installed."
        }
    }

    # VSCode Extensions
    if (Get-Command code -ErrorAction SilentlyContinue) {
        ''
        Write-PrettyTitle "Visual Studio Code Extensions"
        $extensionList = Get-Content -Path "$PSScriptRoot\vscode\extensions.list"
        foreach ($extension in $extensionList) {
            code --install-extension $extension | Out-Null
            Write-PrettyOutput -p "VSCode Extension" -e "$extension" -m "installed."
        }
    }

    # Run komorebic start --whkd
    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        ''
        Write-PrettyTitle "Komorebi with WHKD"
        $komorebiProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
        if ($null -eq $komorebiProcess) {
            $startKomorebiConfirm = $(Write-Host "Komorebi found. Run Komorebi now (y) or later (n)? " -ForegroundColor "Cyan" -NoNewline; Read-Host)
            if ($startKomorebiConfirm -eq 'y') {
                try {
                    & komorebic start --whkd > $null 2>&1
                    Write-PrettyOutput -p "Komorebic" -e "Komorebi with WHKD" -m "started."
                }
                catch {
                    Write-Host "Komorebi: " -ForegroundColor "Green" -NoNewline
                    Write-Host "Failed to start komorebic: " -NoNewline
                    Write-Host "$_" -ForegroundColor "Red" -NoNewline
                }
            }
            else {
                Write-PrettyOutput -p "Komorebic" -e "Komorebi" -m "skipped process."
            }
        }
        else {
            Write-PrettyOutput -p "Komorebic" -e "Komorebi" -m "is already running! Skipping..."
        }
    }

    # Run yasb
    ''
    Write-PrettyTitle "YASB Status Bar"
    $yasbProcess = Get-Process -Name yasb -ErrorAction SilentlyContinue
    if ($null -eq $yasbProcess) {
        $yasbShortcutPath = Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Windows\Start Menu\Programs\Yasb.lnk"
        if (Test-Path $yasbShortcutPath) {
            $confirmYasbRun = $(Write-Host "Found Yasb. Run now? (y/n) " -ForegroundColor "Cyan" -NoNewline; Read-Host)
            if ($confirmYasbRun -eq 'y') {
                Start-Process -FilePath $yasbShortcutPath > $null 2>&1
                Write-Host "Yasb: " -ForegroundColor "Green" -NoNewline
                Write-Host "Starting status bar..." -NoNewline
                Write-Host " OK" -ForegroundColor "Green"
            }
            else {
                Write-Host "Yasb: " -ForegroundColor "Green" -NoNewline
                Write-Host "Skipping..."
            }
        }
        else {
            Write-Host "Yasb: " -ForegroundColor "Green" -NoNewline
            Write-Host "Shortcut not found at " -NoNewLine
            Write-Host "$yasbShortcutPath" -ForegroundColor Red
        }
    }
    else {
        Write-PrettyOutput -p "Yasb" -e "" -m "is already running. Skipping..."
    }

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
    Write-PrettyTitle "Uninstall Scoop Packages"
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
    Write-PrettyTitle "Uninstall WinGet Packages"
    Set-WinGetApps -Uninstall -AppList $WingetApps

    # PowerShell Modules
    ''
    Write-PrettyTitle "Uninstall PowerShell Modules"
    Set-PoshModules -Uninstall -ModuleList $PoshModules

    # Symlinks
    ''
    Write-PrettyTitle "Create Symbolic Links"
    Set-SymbolicLinks -Remove -Symlinks $SymLinks
}


###############################################################################
###                              START THE SCRIPT                           ###
###############################################################################

Test-InternetConnection

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


Start-Sleep -Seconds 2

""
Write-Host "┌────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "│        █████╗ ██╗     ██╗         ██████╗  ██████╗ ███╗   ██╗███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██╗██║     ██║         ██╔══██╗██╔═══██╗████╗  ██║██╔════╝ ██║      │" -ForegroundColor "Green"
Write-Host "│       ███████║██║     ██║         ██║  ██║██║   ██║██╔██╗ ██║█████╗   ██║      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██║██║     ██║         ██║  ██║██║   ██║██║╚██╗██║██╔══╝   ╚═╝      │" -ForegroundColor "Green"
Write-Host "│       ██║  ██║███████╗███████╗    ██████╔╝╚██████╔╝██║ ╚████║███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═╝      │" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "└────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor "Green"

""
Write-Host "For more information, please visit " -NoNewline
Write-Host "https://github.com/jacquindev/windots" -ForegroundColor "Blue"
Write-Host "- Submit an issue via: " -NoNewline
Write-Host "https://github.com/jacquindev/windots/issues/new" -ForegroundColor "Blue"
Write-Host "- Contact me via email: " -NoNewline
Write-Host "jacquindev@outlook.com" -ForegroundColor "Blue"
