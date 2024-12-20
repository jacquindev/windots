#requires -Version 7
#requires -runasadministrator

<#
.SYNOPSIS
    Script to setup Windows machine
.DESCRIPTION
    This script will install and setup apps for Windows machine.
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

#######################################################################################################
###                                             PREREQUISITES                                       ###
#######################################################################################################
# set current working directory location
Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

# Helpers functions
. "$PSScriptRoot\Functions.ps1"

if ((Test-Connection -ComputerName www.google.com -Count 1 -Quiet -ErrorAction Stop) -eq $False) {
    Write-Warning "NO INTERNET CONNECTION AVAILABLE!"
    Write-Host "Please re-check your internet connection and re-run this script." -ForegroundColor "Red"
    Write-Host "Exiting..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 2
    Break
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warning "Command not found: winget."
    Write-Host "Installing winget..."
    Start-Process pwsh -Verb RunAs -ArgumentList "&([ScriptBlock]::Create((irm winget.pro)))", "-Force", "-Wait" -WindowStyle Hidden -Wait
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Warning "Command not found: scoop."
    Write-Host "Installing scoop..."
    if ((Test-IsElevated) -eq $False) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
    } else {
        Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    }
}

if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-Warning "Command not found: gum."
    Write-Host "Installing gum..."
    scoop install charm-gum
}


#######################################################################################################
###                                           HELPER VARIABLES                                      ###
#######################################################################################################
# symlinks
$symbolicLinks = @{
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
    "$Env:USERPROFILE\.config\spotify-tui"                                                        = ".\config\spotify-tui"
    "$Env:USERPROFILE\.config\bash"                                                               = ".\config\bash"
    # "$Env:USERPROFILE\.glzr\glazewm\config.yaml"                                                  = ".\config\glazewm\config.yaml"
    "$Env:APPDATA\bat"                                                                            = ".\config\bat"
    "$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
    # "$Env:LOCALAPPDATA\nvim"                                                                      = ".\config\nvim"
    "$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
    "$Env:APPDATA\Code\User\keybindings.json"                                                     = ".\vscode\keybindings.json"
    "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
    "$Env:USERPROFILE\.gitconfig"                                                                 = ".\home\.gitconfig"
    "$Env:USERPROFILE\.czrc"                                                                      = ".\home\.czrc"
    "$Env:USERPROFILE\.bash_profile"                                                              = ".\home\.bash_profile"
    "$Env:USERPROFILE\.bashrc"                                                                    = ".\home\.bashrc"
    "$Env:USERPROFILE\.inputrc"                                                                   = ".\home\.inputrc"
    "$Env:USERPROFILE\.wslconfig"                                                                 = ".\home\.wslconfig"
}

# appList.json
$appList = (Get-Content "$PSScriptRoot\appList.json" | ConvertFrom-Json).source

# scoop
$scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
$scoopBuckets = $appList.scoop.bucket
$scoopUserApps = $appList.scoop.user
$scoopGlobalApps = $appList.scoop.global

# winget
$wingetApps = $appList.winget

# vscode extension
$vscodeExtensions = Get-Content -Path "$PSScriptRoot\vscode\extensions.list"

# powershell modules
$poshModules = $appList.modules

# github cli extensions
$githubExtensions = $appList.github_extension

# nerd fonts
$nerdFonts = $appList.nerdfont

# npm global packages
$npmGlobalPackages = $appList.npm

#######################################################################################################
###                                              MAIN SCRIPT                                        ###
#######################################################################################################
# Install all function
function Install {
    # Winget Packages
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "WINGET PACKAGES"
        Install-WingetApps -List $wingetApps

        $wingetLockFile = "$PSScriptRoot\winget.lock.json"
        if (Test-Path -PathType Leaf -Path $wingetLockFile) {
            Remove-Item $wingetLockFile -Force -Recurse -ErrorAction SilentlyContinue
        }
        winget export -o "$wingetLockFile" | Out-Null
        Write-PrettyInfo -Message "Packages installed by winget was written in" -Info "$wingetLockFile"
    }

    # Scoop Packages
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "SCOOP PACKAGES"
        if (!(Get-Command aria2c.exe -ErrorAction SilentlyContinue)) {
            gum spin --title="Installing aria2c..." -- scoop install aria2c
        }
        # aria2 config
        Set-Aria2-Configuration 'aria2-enabled' 'True'
        Set-Aria2-Configuration 'aria2-warning-enabled' 'False'
        Set-Aria2-Configuration 'aria2-max-connection-per-server' '10'
        # scoop aliases
        Set-Scoop-Alias 'ls' 'scoop list $args' 'List all installed apps, or the apps matching the supplied query'
        Set-Scoop-Alias 'rm' 'scoop uninstall $args[0] && scoop cache rm $args[0]' 'Uninstall an app and clean its cache files'
        Set-Scoop-Alias 'st' 'scoop status $args' 'Show status and check for new app versions'
        Set-Scoop-Alias 'up' 'scoop cache rm * && scoop update * && scoop cleanup *' 'Clean all cache files, update all apps, and cleanup all old versions'
        # scoop buckets
        Enable-ScoopBuckets -List $scoopBuckets
        # scoop applications
        Install-ScoopApps -List $scoopGlobalApps -Scope AllUsers
        Install-ScoopApps -List $scoopUserApps -Scope CurrentUser
        $scoopLockFile = "$PSScriptRoot\scoop.lock.json"
        if (Test-Path -Path "$scoopLockFile") {
            Remove-Item "$scoopLockFile" -Force -Recurse -ErrorAction SilentlyContinue
        }
        scoop export > "$scoopLockFile"
        Write-PrettyInfo -Message "Packages installed by scoop was written in" -Info "$scoopLockFile"
    }

    # Nerd Fonts
    Write-PrettyTitle "NERD FONTS INSTALLATION"
    Install-NerdFonts -List $nerdFonts
    Start-Sleep -Seconds 1

    # Git & GitHub CLI setup
    Write-PrettyTitle "GIT SETUP"
    $gitUserName = (git config --global user.name)
    $gitUserMail = (git config --global user.email)

    if ($null -eq $gitUserName) {
        $gitUserName = (gum input --prompt="Input Git Name: " --placeholder="Your Name")
    }
    if ($null -eq $gitUserMail) {
        $gitUserMail = (gum input --prompt="Input Git Email: " --placeholder="yourmail@domain.com")
    }

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (!(Test-Path -PathType Leaf -Path "$env:APPDATA\GitHub CLI\hosts.yml")) {
            gh auth login
        }
        Install-GitHub-Extensions -List $githubExtensions
    }

    Set-Location "$PSScriptRoot"
    git submodule update --init --recursive


    # Symlinks
    Write-PrettyTitle "SYMBOLIC LINKS"
    Set-Symlinks -Symlinks $symbolicLinks

    git config --global --unset user.email | Out-Null
    git config --global --unset user.name | Out-Null
    git config --global user.name $gitUserName | Out-Null
    git config --global user.email $gitUserMail | Out-Null


    # Powershell Modules
    Write-PrettyTitle "POWERSHELL MODULES"
    Install-Modules -List $poshModules
    $modulesLockFile = "$PSScriptRoot\modules.lock.json"
    Get-InstalledModule | Select-Object Name, Version, Author, InstalledDate, Description | ConvertTo-Json -Depth 100 | Out-File "$modulesLockFile" -Encoding utf8 -Force
    Write-PrettyInfo -Message "PowerShell modules installed are listed in" -Info "$modulesLockFile"

    # VSCode Extensions
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "CODE EXTENSIONS"
        Install-VSCode-Extensions -List $vscodeExtensions
        Write-PrettyInfo -Message "VSCode Extensions List can be found at" -Info "$PSScriptRoot\vscode\extensions.list"
    }

    # NodeJS setup
    # Write-PrettyTitle "NVM (Node Version Manager)"
    # if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    #     # Installing nvm using the installer
    #     $nvmVersion = $(&"curl.exe" -s "https://api.github.com/repos/coreybutler/nvm-windows/releases/latest" | jq -r '.tag_name').Trim()
    #     $nvmDownloadLink = "https://github.com/coreybutler/nvm-windows/releases/download/$nvmVersion/nvm-setup.exe"
    #     $downloadFolderPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    #     $nvmInstallerFile = "$downloadFolderPath/nvm-setup.exe"
    #     $obj = New-Object System.Net.WebClient
    #     $obj.DownloadFile($nvmDownloadLink, $nvmInstallerFile)
    #     Start-Process -FilePath "$nvmInstallerFile"
    #     Remove-Variable nvmVersion, nvmDownloadLink, nvmInstallerFile, downloadFolderPath, obj
    # } else {
    #     if ((-not (Get-Command node -ErrorAction SilentlyContinue)) -or (-not(Get-Command npm -ErrorAction SilentlyContinue))) {
    #         $ltsOrLatest = $(Write-Host "❔ NodeJS not found. Install LTS (y) or latest (n)? "-ForegroundColor Cyan -NoNewline; Read-Host)
    #         if ($ltsOrLatest.ToUpper() -eq 'Y') {
    #             nvm install lts
    #         } else {
    #             nvm install latest
    #         }
    #         nvm use newest
    #         corepack enable
    #         corepack prepare pnpm@latest --activate
    #         npm install npm@latest
    #         npm config set userconfig="$env:USERPROFILE\.config\npm\.npmrc" --global
    #     }
    #     Install-NPM-Packages -pnpm -List $npmGlobalPackages
    # }

    # Bat
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "BAT THEME BUILD"
        gum spin --title="Building bat theme..." -- bat cache --clear
        gum spin --title="Building bat theme..." -- bat cache --build
        Write-PrettyInfo -Message "Bat config file can be found at" -Info "$PSScriptRoot\config\bat\config"
    }

    # Eza
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "EZA CONFIG ENVIRONMENT VARIABLE"
        Set-EnvironmentVariable -Value "EZA_CONFIG_DIR" -Path "$Env:USERPROFILE\.config\eza"
        Start-Sleep -Seconds 1
    }

    # BTOP
    if (Get-Command btop -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "BTOP THEMES SETUP"
        $btopThemeDir = "$scoopDir\apps\btop\current\themes"
        $catppuccinThemes = @('catppuccin_frappe', 'catppuccin_latte', 'catppuccin_macchiato', 'catppuccin_mocha')
        foreach ($theme in $catppuccinThemes) {
            if (!(Test-Path -PathType Leaf -Path "$btopThemeDir\$theme.theme")) {
                Download-File -Directory $btopThemeDir -Url "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme"
                Write-PrettyOutput -Process "btop" -Entry "theme:" -Entry2 "$theme" -Message "installed successfully." -Extra
            } else {
                Write-PrettyOutput -Process "btop" -Entry "theme:" -Entry2 "$theme" -Message "already installed! Skipping..." -Extra
            }
        }
        Remove-Variable catppuccinThemes, btopThemeDir
        Start-Sleep -Seconds 1
    }

    # flow launcher
    if (Test-Path -PathType Container -Path "$env:LOCALAPPDATA\FlowLauncher") {
        Write-PrettyTitle "FLOW LAUNCHER THEMES SETUP"
        $flowThemeDir = "$env:APPDATA\FlowLauncher\Themes"
        $catppuccinThemes = @('Frappe', 'Latte', 'Macchiato', 'Mocha')
        foreach ($theme in $catppuccinThemes) {
            $themePath = "$flowThemeDir\Catppuccin $theme.xaml"
            if (!(Test-Path -Path "$themePath")) {
                Download-File -Directory $flowThemeDir -Url "https://raw.githubusercontent.com/catppuccin/flow-launcher/refs/heads/main/themes/Catppuccin%20$theme.xaml"
                Write-PrettyOutput -Process "FlowLauncher" -Entry "theme:" -Entry2 "Catppuccin $theme" -Message "installed successfully." -Extra
            }

            else {
                Write-PrettyOutput -Process "FlowLauncher" -Entry "theme:" -Entry2 "Catppuccin $theme" -Message "already installed. Skipping..." -Extra
            }
        }
        Remove-Variable flowThemeDir, catppuccinThemes
        Start-Sleep -Seconds 1
    }

    # spicetify
    if (Get-Command spicetify -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "SPICETIFY MARKETPLACE"
        $customAppsFolder = "$env:APPDATA\spicetify\CustomApps"
        if (Test-Path -PathType Container -Path $customAppsFolder) {
            if (!(Test-Path -PathType Container -Path "$customAppsFolder\marketplace")) {
                Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1" | Invoke-Expression | Out-Null
                Write-PrettyOutput -Process "spicetify" -Entry "custom app:" -Entry2 "marketplace" -Message "installed successfully." -Extra
            } else {
                Write-PrettyOutput -Process "spicetify" -Entry "custom app:" -Entry2 "marketplace" -Message "already installed." -Extra
            }
        }
        Start-Sleep -Seconds 1
    }

    if (Get-Command yazi -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "YAZI SETUP"
        # yazi environment variables
        $GitInstalledDir = Split-Path "$(Get-Command git.exe | Select-Object -ExpandProperty Definition)" | Split-Path
        $GitFileExePath = "$GitInstalledDir\usr\bin\file.exe"
        Set-EnvironmentVariable -Value "YAZI_FILE_ONE" -Path "$GitFileExePath"
        Set-EnvironmentVariable -Value "YAZI_CONFIG_HOME" -Path "$Env:USERPROFILE\.config\yazi"
        Remove-Variable GitInstalledDir, GitFileExePath
        Start-Sleep -Seconds 1
        # yazi plugins
        gum spin --title="Installing yazi plugins..." -- ya pack -i
        #gum spin --title="Updating yazi plugins..." -- ya pack -u
        Write-PrettyInfo -Message "Installed Yazi packages can be found at" -Info "$PSScriptRoot\config\yazi\package.toml"
        Start-Sleep -Seconds 1
    }

    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "KOMOREBI SETUP WITH WHKD"

        # komorebi environment variable
        Set-EnvironmentVariable -Value "KOMOREBI_CONFIG_HOME" -Path "$Env:USERPROFILE\.config\komorebi"
        Start-Sleep -Seconds 1

        # start komorebi
        $komorebiProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
        if ($null -eq $komorebiProcess) {
            $startKomorebi = $(Write-Host "❔ Komorebi found. Run Komorebi now (y) or later (n)? " -ForegroundColor Cyan -NoNewline; Read-Host)
            if ($startKomorebi -eq 'y') {
                & komorebic start --whkd > $null 2>&1
                Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "started."
            } else {
                Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "skipped."
            }
        } else {
            Write-PrettyOutput -Process "komorebi" -Entry "komorebi with WHKD" -Message "already running..."
        }
        Start-Sleep -Seconds 1
    }

    if (Get-Command yasb -ErrorAction SilentlyContinue) {
        Write-PrettyTitle "YASB STATUS BAR"
        $yasbProcess = Get-Process -Name yasb -ErrorAction SilentlyContinue
        if ($null -eq $yasbProcess) {
            $yasbShortcutPath = Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Windows\Start Menu\Programs\Yasb.lnk"
            $confirmYasbRun = $(Write-Host "❔ Found Yasb. Run Yasb now? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
            if ($confirmYasbRun -eq 'y') {
                if (Test-Path $yasbShortcutPath) {
                    Start-Process -FilePath $yasbShortcutPath > $null 2>&1
                    Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "started."
                } else {
                    Write-PrettyOutput -Process "yasb" -Entry "$yasbShortcutPath" -Message "not found to run!"
                }
            } else {
                Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "skipped."
            }
        } else {
            Write-PrettyOutput -Process "yasb" -Entry "status bar" -Message "already running..."
        }
        Start-Sleep -Seconds 1
    }

    # vagrant
    # if (Get-Command vagrant -ErrorAction SilentlyContinue) {
    #     Write-PrettyTitle "VAGRANT PLUGINS"
    #     $VagrantPlugins = @('sahara', 'vagrant-disksize', 'vagrant-docker-compose', 'vagrant-reload', 'vagrant-winnfsd')
    #     Install-Vagrant-Plugins -List $VagrantPlugins
    # }

    ""
}

Install

Start-Sleep -Seconds 3

""
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
