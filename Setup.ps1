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

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

. "$PSScriptRoot\Functions.ps1"

$scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
$appsList = (Get-Content "$PSScriptRoot\appList.json" | ConvertFrom-Json).source

$wingetApps = $appsList.winget
$scoopBuckets = $appsList.scoop.bucket
$scoopApps = $appsList.scoop.user
$scoopGlobalApps = $appsList.scoop.global
$poshModules = $appsList.modules
$extensionList = Get-Content -Path "$PSScriptRoot\vscode\extensions.list"
$ghExtensions = $appsList.github_extension
$npmPackages = $appsList.npm

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
    "$Env:USERPROFILE\.config\spotify-tui\config.yml"                                             = ".\config\spotify-tui\config.yml"
    # "$Env:USERPROFILE\.glzr\glazewm\config.yaml"                                                  = ".\config\glazewm\config.yaml"
    "$Env:APPDATA\bat"                                                                            = ".\config\bat"
    "$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
    # "$Env:LOCALAPPDATA\nvim"                                                                      = ".\config\nvim"
    "$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
    "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
    "$Env:USERPROFILE\.gitconfig"                                                                 = ".\home\.gitconfig"
    "$Env:USERPROFILE\.czrc"                                                                      = ".\home\.czrc"
    "$Env:USERPROFILE\.bashrc"                                                                    = ".\home\.bashrc"
    "$Env:USERPROFILE\.wslconfig"                                                                 = ".\home\.wslconfig"
}


function Main {
    # WinGet Apps
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "WinGet Packages"
        Install-WingetApps -AppList $wingetApps
        $wingetLockFile = "$PSScriptRoot\packages.lock.json"
        if (Test-Path $wingetLockFile) {
            Remove-Item $wingetLockFile -Force -Recurse -ErrorAction SilentlyContinue
        }
        winget export -o "$wingetLockFile" | Out-Null
        Write-PrettyInfo -Message "Packages installed by `winget` was written in" -Info "$wingetLockFile"
    }

    # Gsudo cache mode on
    Set-GsudoCacheMode -on
    Start-Sleep -Seconds 1

    # Scoop Packages
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-PrettyTitle "Install Scoop"
        Write-Host "Installing Scoop..." -ForegroundColor "Yellow"
        if ($(gsudo status IsElevated) -eq $False) {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
        else {
            Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        }
    }
    else {
        Write-PrettyTitle "Scoop Packages"
        foreach ($bucket in $scoopBuckets) {
            Enable-ScoopBucket -Bucket $bucket
        }
        Install-ScoopApps -AppList $scoopGlobalApps -Scope AllUsers
        Install-ScoopApps -AppList $scoopApps -Scope CurrentUser
    }

    # VSCode Extensions
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "VSCode Extensions"
        Install-CodeExtensions -ExtensionList $extensionList
        Write-PrettyInfo -Message "List of VSCode Extensions can be found at" -Info "$PSScriptRoot\vscode\extensions.list"
    }

    # Git Setup
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "Git"
        if (Test-Path -Path "$Env:USERPROFILE\.gitconfig-local") {
            if ($(Get-Content -Path "$Env:USERPROFILE\.gitconfig-local" -Raw).Contains("[user]") -eq $False) {
                Write-GitConfigLocal
            }
            else {
                Write-PrettyInfo -Message "Git Email and Name already set in" -Info "$Env:USERPROFILE\.gitconfig-local"
            }
        }
        else {
            New-Item -Path "$Env:USERPROFILE\.gitconfig-local" -ItemType File | Out-Null
            Write-GitConfigLocal
        }

        git submodule update --init --recursive
    }

    # Setup GitHub CLI
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (!(Test-Path -Path "$env:APPDATA\GitHub CLI\hosts.yml")) {
            gh auth login 
        }
        $installed = (gh extension list)
        foreach ($ext in $ghExtensions) {
            if (-not ($installed | Select-String "$ext")) {
                gh extension install "$ext" --force | Out-Null
                Write-PrettyOutput -Process "git" -Entry "github extension:" -Extra "$ext" -Message "installed."
            }
            else {
                Write-PrettyOutput -Process "git" -Entry "github extension:" -Extra "$ext" -Message "installed."
            }
        }
    }

    # symlinks
    Write-PrettyTitle "Symbolic Links"
    Set-SymbolicLinks -Symlinks $SymLinks

    # PowerShell modules
    Write-PrettyTitle "PowerShell Modules"
    Install-PoshModules -ModuleList $poshModules
    $modulesLockFile = "$PSScriptRoot\modules.lock.json"
    Get-InstalledModule | Select-Object Name, Version, Author, InstalledDate, Description | ConvertTo-Json -Depth 100 | Out-File "$modulesLockFile" -Encoding utf8 -Force
    Write-PrettyInfo -Message "PowerShell modules installed are listed in" -Info "$PSScriptRoot\modules.lock.json"

    # environment variables
    Write-PrettyTitle "Environment Variables"
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

    # NodeJS
    # Since we installed nvm using scoop, nvm dir would be:
    if ((!(Get-Command npm -ErrorAction SilentlyContinue)) -and (Get-Command nvm -ErrorAction SilentlyContinue)) {
        Write-PrettyTitle "NodeJS, NPM, YARN, etc"
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
        Write-PrettyTitle "NPM Global Packages"
        foreach ($package in $npmPackages) {
            $cmd = $package.Command
            $packages = $package.Packages
            if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
                foreach ($pkg in $packages) {
                    npm install --global --silent $pkg
                    Write-PrettyOutput -Process "npm" -Entry "$pkg" -Message "installed."
                }
            }
            else {
                Write-PrettyOutput -Process "npm" -Entry "$cmd" -Message "already installed."
            }
        }
    }

    # Nerd Font
    # Write-PrettyTitle "Install Nerd Fonts"
    # $nerdFontConfirm = $(Write-Host "Install Nerd Fonts now (y/n)? " -ForegroundColor "Cyan" -NoNewline; Read-Host)
    # if ($nerdFontConfirm -eq 'y') {
    #     $whichUser = $(Write-Host "1) Install Nerd Fonts for AllUsers (y) or CurrentUser (n)? " -NoNewline; Read-Host)
    #     $whichInstaller = $(Write-Host "2) Install Nerd Fonts using Script (y) or Scoop (n)? " -NoNewline; Read-Host)
    #     ""
    #     if ($whichUser -eq 'y') {
    #         if ($whichInstaller -eq 'y') {
    #             Install-NerdFonts -Scope AllUsers -Script
    #         }
    #         else { Install-NerdFonts -Scope AllUsers -Scoop }
    #     }
    #     else {
    #         if ($whichInstaller -eq 'y') {
    #             Install-NerdFonts -Scope CurrentUser -Script
    #         }
    #         else {
    #             Install-NerdFonts -Scope CurrentUser -Scoop
    #         }
    #     }
    # }

    # MISC
    # Bat
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "Bat Theme"
        bat cache --clear > $null
        bat cache --build 
    }

    # Btop
    if (Get-Command btop -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "Btop Themes"
        $btopThemeDir = "$scoopDir\apps\btop\current\themes"
        $catppuccinThemes = @('catppuccin_frappe', 'catppuccin_latte', 'catppuccin_macchiato', 'catppuccin_mocha')
        foreach ($theme in $catppuccinThemes) {
            if (!(Test-Path -PathType Leaf -Path "$btopThemeDir\$theme.theme")) {
                Install-File -Dir $btopThemeDir -Url "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme"
                Write-PrettyOutput -Process "btop" -Entry "theme:" -Extra "$theme" -Message "installed."
            }
            else {
                Write-PrettyOutput -Process "btop" -Entry "theme:" -Extra "$theme" -Message "already installed."
            }
        }
        Remove-Variable catppuccinThemes, btopThemeDir
    }

    # flow launcher
    if (Test-Path -PathType Container -Path "$env:LOCALAPPDATA\FlowLauncher") {
        Write-PrettyTitle "FlowLauncher Themes"
        $flowThemeDir = "$env:APPDATA\FlowLauncher\Themes"
        $catppuccinThemes = @('Frappe', 'Latte', 'Macchiato', 'Mocha')
        foreach ($theme in $catppuccinThemes) {
            $themePath = "'$flowThemeDir\Catppuccin $theme.xaml'"
            if (!(Test-Path -Path "$themePath")) {
                Install-File -Dir $flowThemeDir -Url "https://raw.githubusercontent.com/catppuccin/flow-launcher/refs/heads/main/themes/Catppuccin%20$theme.xaml"
                Write-PrettyOutput -Process "FlowLauncher" -Entry "theme:" -Entry2 "Catppuccin $theme" -Message "installed." -Extra 
            }

            else {
                Write-PrettyOutput -Process "FlowLauncher" -Entry "theme:" -Entry2 "Catppuccin $theme" -Message "already installed." -Extra 
            }
        }
        Remove-Variable flowThemeDir, catppuccinThemes
    }

    # spicetify
    if (Get-Command spicetify -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "Spicetify CLI"
        $customAppsFolder = "$env:APPDATA\spicetify\CustomApps"
        if (Test-Path -PathType Container -Path $customAppsFolder) {
            if (!(Test-Path -PathType Container -Path "$customAppsFolder\marketplace")) {
                Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1" | Invoke-Expression | Out-Null
                Write-PrettyOutput -Process "spicetify" -Entry "custom app:" -Extra "marketplace" -Message "installed."
            }
            else {
                Write-PrettyOutput -Process "spicetify" -Entry "custom app:" -Extra "marketplace" -Message "already installed."
            }
        }
    }

    # nvm
    if (Get-Command nvm -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "NVM - Node Version Manager"
        if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
            $ltsOrLatest = $(Write-Host "NodeJS not found. Install LTS (y) or latest node (n) " -ForegroundColor Magenta -NoNewline; Read-Host)
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
        else {
            foreach ($pkg in $npmPackages) {
                $cmd = $pkg.Command
                $packages = $pkg.Packages
                if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
                    foreach ($package in $packages) {
                        npm install --global --silent $package
                        Write-PrettyOutput -Process "nvm" -Entry "npm:" -Extra "$package" -Message "installed."
                    }
                }
                else {
                    foreach ($package in $packages) {
                        Write-PrettyOutput -Process "nvm" -Entry "npm:" -Extra "$package" -Message "already installed."
                    }
                }
            }
        }
    }

    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "Komorebi With WHKD"
        $komorebiProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
        if ($null -eq $komorebiProcess) {
            $startKomorebi = $(Write-Host "Komorebi found. Run Komorebi now (y) or later (n)? " -ForegroundColor "Cyan" -NoNewline; Read-Host)
            if ($startKomorebi -eq 'y') {
                $ komorebic start --whkd > $null 2>&1
                Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "started."
            }
            else {
                Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "skipped."
            }
        }
        else {
            Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "already running..."
        }
    }


    if (Get-Command yasb -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "YASB Status Bar"
        $yasbProcess = Get-Process -Name yasb -ErrorAction SilentlyContinue
        if ($null -eq $yasbProcess) {
            $yasbShortcutPath = Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Windows\Start Menu\Programs\Yasb.lnk"
            $confirmYasbRun = $(Write-Host "Found Yasb. Run now? (y/n) " -ForegroundColor Magenta -NoNewline; Read-Host)
            if ($confirmYasbRun -eq 'y') {
                if (Test-Path $yasbShortcutPath) {
                    Start-Process -FilePath $yasbShortcutPath > $null 2>&1
                    Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "started."
                }
                else {
                    Write-PrettyOutput -Process "yasb" -Entry "$yasbShortcutPath" -Message "not found to run!"
                }
            }
            else {
                Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "skipped."
            }
        }
        else {
            Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "already running..."
        }
    }


    # Gsudo cache mode off
    Set-GsudoCacheMode -off
    Start-Sleep -Seconds 1

    ""
}

function Reverse {
    Set-GsudoCacheMode -on
    Start-Sleep -Seconds 1

    
    Write-PrettyTitle "Scoop Packages"
    Remove-ScoopApps -AppList $scoopApps -Scope CurrentUser
    Remove-ScoopApps -AppList $scoopGlobalApps -Scope AllUsers
    foreach ($bucket in $ScoopBuckets) {
        Disable-ScoopBucket -Bucket $bucket
    }
    
    Set-GsudoCacheMode -off
    Start-Sleep -Seconds 1

    # WinGet
    Write-PrettyTitle "WinGet Packages"
    Remove-WinGetApps -AppList $wingetApps

    # PowerShell Modules
    Write-PrettyTitle "PowerShell Modules"
    Remove-PoshModules -ModuleList $poshModules

    # Symlinks
    Write-PrettyTitle "Symbolic Links"
    Remove-SymbolicLinks -Symlinks $SymLinks
}

Test-InternetConnection
if (($PSBoundParameters.Count -eq 0) -or ($Install)) { 
    Main 

    
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
}
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

