#requires -Version 7

<#
.SYNOPSIS
    Script to setup dotfiles repo and install apps on windows machine.
.DESCRIPTION
#>

###################################################################################
###                                     MAIN SCRIPT                             ###
###################################################################################

function Main {
    # Set working directory
    Set-Location $PSScriptRoot
    [Environment]::CurrentDirectory = $PSScriptRoot

    #-------------------------------------#
    ###             WINGET              ###
    #-------------------------------------#
    ''
    Write-Host "------------------------" -ForegroundColor "Cyan"
    Write-Host "Install WinGet Packages:" -ForegroundColor "Cyan"
    Write-Host "------------------------" -ForegroundColor "Cyan"
    # Winget packages
    $WingetAppList = @(
        # TODO: Add/Remove your preferred applications here:
        # Dev Tools:
        @{ Name = "chrisant996.Clink"; Source = "winget" },
        @{ Name = "gerardog.gsudo"; Source = "winget" },
        @{ Name = "Git.Git"; Source = "winget" },
        @{ Name = "GitHub.GitHubDesktop"; Source = "winget" },
        @{ Name = "ImageMagick.ImageMagick"; Source = "winget" },
        @{ Name = "JanDeDobbeleer.OhMyPosh"; Source = "winget" },
        @{ Name = "Microsoft.PowerShell"; Source = "winget" },
        @{ Name = "Microsoft.VisualStudioCode"; Source = "winget" },
        # @{ Name = "Notepad++.Notepad++"; Source = "winget" },

        # Browser:
        # @{ Name = "Mozilla.FireFox"; Source = "winget" },
        @{ Name = "Proton.ProtonVPN"; Source = "winget" },
        @{ Name = "Spotify.Spotify"; Source = "winget" },

        # Windows Tweak Applications:
        @{ Name = "Rainmeter.Rainmeter"; Source = "winget" },
        @{ Name = "Stardock.Start11"; Source = "winget" },
        # @{ Name = "glzr-io.glazewm"; Source = "winget" },
        @{ Name = "LGUG2Z.komorebi"; Source = "winget" },
        @{ Name = "LGUG2Z.whkd"; Source = "winget" }
    )

    Install-WingetApps -AppList $WingetAppList

    #---------------------------------------#
    #           GSUDO CACHE MODE            #
    #---------------------------------------#
    ''
    Start-Sleep -Milliseconds 20
    Set-GsudoCacheMode -on

    #--------------------------------------#
    ###              SCOOP               ###
    #--------------------------------------#
    ''
    Write-Host "-----------------------" -ForegroundColor "Cyan"
    Write-Host "Install Scoop Packages:" -ForegroundColor "Cyan"
    Write-Host "-----------------------" -ForegroundColor "Cyan"
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
    
    # TODO: Add/Remove your preferred applications here:
    $ScoopApps = @(
        # Priority
        'innounp', 'wixtoolset', 'aria2', 'scoop-completion',
        # CLI Tools
        'bat', 'btop', 'eza', 'jq', 'yazi', 'zoxide', 'spicetify-cli', 
        # Git helpers
        'bfg', 'gh', 'git-sizer', 'git-lfs', 'git-filter-repo', 'lazygit', 
        # Apps
        'flow-launcher', 'secureuxtheme'
    )
    $ScoopGlobalApps = @(
        '7zip', 'fastfetch', 'fd', 'fzf', 'ripgrep', 
        'openjdk', 'sed', 'wget',
        # sysinternals
        'pskill', 'pslist', 'procmon'
    )

    scoop update | Out-Null
    Enable-Bucket -Bucket extras
    foreach ($app in $ScoopApps) { Install-ScoopApp -Package $app }
    Enable-Bucket -Bucket java
    Enable-Bucket -Bucket sysinternals
    foreach ($app in $ScoopGlobalApps) { Install-ScoopAppGlobal -Package $app }

    #---------------------------------------------#
    ###                 SYMLINKS                ###
    #---------------------------------------------#
    ''
    Write-Host "----------------------" -ForegroundColor "Cyan"
    Write-Host "Create Symbolic Links:" -ForegroundColor "Cyan"
    Write-Host "----------------------" -ForegroundColor "Cyan"
    $SymLinks = @{
        $PROFILE.CurrentUserAllHosts                                                                  = ".\Profile.ps1"
        "$Env:USERPROFILE\.config\eza"                                                                = ".\config\eza"
        "$Env:USERPROFILE\.config\fastfetch"                                                          = ".\config\fastfetch"
        "$Env:USERPROFILE\.config\komorebi"                                                           = ".\config\komorebi"
        "$Env:USERPROFILE\.config\whkdrc"                                                             = ".\config\whkdrc"
        "$Env:USERPROFILE\.config\yazi"                                                               = ".\config\yazi"
        # "$Env:USERPROFILE\.glzr\glazewm\config.yaml"                                                  = ".\config\glazewm\config.yaml"
        "$Env:APPDATA\bat"                                                                            = ".\config\bat"
        "$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
        "$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
        "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
        "$Env:USERPROFILE\.gitconfig"                                                                 = ".\home\.gitconfig"
    }

    New-SymbolicLinks -Symlinks $SymLinks

    #-----------------------------------------#
    ###                 BAT                 ###
    #-----------------------------------------#
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        ''
        Write-Host "-----------------------" -ForegroundColor "Cyan"
        Write-Host "Setup Bat Cache Themes:" -ForegroundColor "Cyan"
        Write-Host "-----------------------" -ForegroundColor "Cyan"
        bat cache --clear
        bat cache --build
    }

    #-------------------------------------------------#
    ###         BTOP: ADD CATPPUCCIN THEMES         ###
    #-------------------------------------------------#
    if (Get-Command btop -ErrorAction SilentlyContinue) {
        ''
        Write-Host "------------------------------" -ForegroundColor "Cyan"
        Write-Host "Add Catppuccin Theme for BTOP:" -ForegroundColor "Cyan"
        Write-Host "------------------------------" -ForegroundColor "Cyan"
        # !! Since we installed btop with scoop, so the themes folder would be:
        $scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
        $btopThemeDir = "$scoopDir\apps\btop\current\themes"
        if (Test-Path -PathType Container $btopThemeDir) {
            $catppuccinThemes = (Get-ChildItem -Path $btopThemeDir -Recurse | Where-Object { $_.FullName -match 'catppuccin' }).Name
            if (!($catppuccinThemes)) {
                $catppuccinThemeNames = @('catppuccin_frappe', 'catppuccin_latte', 'catppuccin_macchiato', 'catppuccin_mocha')
                foreach ($theme in $catppuccinThemeNames) {
                    Write-Host "Btop: Catppuccin Theme: " -ForegroundColor "Blue" -NoNewline
                    Write-Host "$theme " -ForegroundColor "Yellow" -NoNewline
                    Write-Host "is being installed..."
                    if (Get-Command wget.exe -ErrorAction SilentlyContinue) {
                        & wget.exe --quiet -P "$btopThemeDir" "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme"
                    }
                    else {
                        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/$theme.theme" -OutFile "$btopThemeDir\$theme.theme"
                    }
                }
            }
            else {
                Write-Host "Btop: " -ForegroundColor "Blue" -NoNewline
                Write-Host "Catppuccin Themes " -ForegroundColor "Yellow" -NoNewline
                Write-Host "already installed! Skipping..."
            }
        }
    }

    #-------------------------------------------#
    ###           VSCODE EXTENSIONS           ###
    #-------------------------------------------#
    if (Get-Command code -ErrorAction SilentlyContinue) {
        ''
        Write-Host "------------------------------" -ForegroundColor "Cyan"
        Write-Host "Visual Studio Code Extensions:" -ForegroundColor "Cyan"
        Write-Host "------------------------------" -ForegroundColor "Cyan"
        $extensionList = Get-Content -Path "$PSScriptRoot\vscode\extensions.list"
        foreach ($extension in $extensionList) {
            code --install-extension $extension | Out-Null
            Write-Host "VSCode Extension: " -ForegroundColor "Blue" -NoNewline
            Write-Host "$extension " -ForegroundColor "Yellow" -NoNewline
            Write-Host "installed"
        }
    }

    #----------------------------------------------#
    ###         POWERSHELL MODULES               ###
    #----------------------------------------------#
    ''
    Write-Host "---------------------------" -ForegroundColor "Cyan"
    Write-Host "Install PowerShell Modules:" -ForegroundColor "Cyan"
    Write-Host "---------------------------" -ForegroundColor "Cyan"
    $PoshModules = @(
        # TODO: Add/Remove your preferred modules
        # "BetterCredentials",
        "BurntToast",
        "CompletionPredictor",
        "DotNetVersionLister",
        # "Microsoft.PowerShell.Crescendo",
        "Microsoft.PowerShell.SecretManagement",
        "Microsoft.PowerShell.SecretStore",
        "posh-alias",
        "posh-git",
        "powershell-yaml",
        # "PoshRSJob",
        "PSFzf",
        "PSParseHTML",
        "PSProfiler",
        "PSScriptTools",
        # "PSWebSearch",
        "Terminal-Icons"
    )
    foreach ($module in $PoshModules) {
        Install-PoshModule -Module $module
    }
    # Start Update-Help to run in the background to ensure helpfiles are always up to date
    # Update-Help will only run once per day and will require -Force to override this behaviour
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/update-help?view=powershell-7.4
    Start-Process pwsh -WindowStyle Hidden -ArgumentList "-NoProfile -Command Update-Help -Scope CurrentUser"
    Write-ModuleLockFile

    #---------------------------------------------#
    ###          Environment Variables          ###
    #---------------------------------------------#
    ''
    Write-Host "----------------------------" -ForegroundColor "Cyan"
    Write-Host "Setup Environment Variables:" -ForegroundColor "Cyan"
    Write-Host "----------------------------" -ForegroundColor "Cyan"

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

    #---------------------------------------------#
    ###                  GIT                    ###
    #---------------------------------------------#
    ''
    Write-Host "---------------------------" -ForegroundColor "Cyan"
    Write-Host "Setup Git Name & Git Email:" -ForegroundColor "Cyan"
    Write-Host "---------------------------" -ForegroundColor "Cyan"


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

    ''
    Write-Host "#################################################################################" -ForegroundColor "Green"
    Write-Host "#                                                                               #" -ForegroundColor "Green"
    Write-Host "#                           ALL DONE! THANK YOU!                                #" -ForegroundColor "Green"
    Write-Host "#                                                                               #" -ForegroundColor "Green"
    Write-Host "#################################################################################" -ForegroundColor "Green"
    ''
}


###############################################################################
###                              HELPER FUNCTIONS                           ###
###############################################################################
function Install-WingetApps {
    param ([array]$AppList)
    foreach ($app in $AppList) {
        $appName = $app.Name
        $appSource = $app.Source

        $installedApp = winget list --exact --accept-source-agreements -q $appName
        if (![String]::Join("", $installedApp).Contains($appName)) {
            Write-Host "WinGet: " -NoNewline -ForegroundColor "Blue"
            Write-Host "Installing " -NoNewline
            Write-Host "$appName " -NoNewline -ForegroundColor "Yellow"
            Write-Host "from source $appSource" 
            winget install --exact --silent --accept-source-agreements --accept-package-agreements $appName --source $appSource | Out-Null
        }
        else {
            winget upgrade $appName | Out-Null
            Write-Host "WinGet: " -ForegroundColor "Blue" -NoNewline
            Write-Host "$appName " -ForegroundColor "Yellow" -NoNewline
            Write-Host "already installed. Skipping..."
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

function Test-DeveloperMode {
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path -Path $RegistryKeyPath)) { return $False }
}

function New-SymbolicLinks {
    param([hashtable]$Symlinks)

    foreach ($symlink in $Symlinks.GetEnumerator()) {
        Write-Host "Symlink: " -ForegroundColor "Blue" -NoNewline
        Write-Host "added for $($symlink.Key)" -ForegroundColor "Gray"
        Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
        Start-Sleep -Seconds 1
    }
}

function Enable-Bucket {
    param([string]$Bucket)
    if (!($(scoop bucket list).Name) -eq "$Bucket") {
        Write-Host "Scoop Bucket: " -ForegroundColor "Blue" -NoNewline
        Write-Host "adding " -NoNewline
        Write-Host "$Bucket" -ForegroundColor "Yellow"
        scoop bucket add $Bucket
    }
    else {
        Write-Host "Scoop Bucket: " -NoNewline -ForegroundColor "Blue"
        Write-Host "$Bucket " -NoNewline -ForegroundColor "Yellow"
        Write-Host "already added. Skipping..." 
    }
}

function Install-ScoopApp {
    param ([string]$Package)
    
    if (!(scoop info $Package).Installed) {
        Write-Host "Scoop: " -ForegroundColor "Blue" -NoNewline
        Write-Host "Installing " -NoNewline
        Write-Host "$Package" -ForegroundColor "Yellow"
        scoop install $Package | Out-Null
    }
    else {
        Write-Host "Scoop: " -NoNewline -ForegroundColor "Blue"
        Write-Host "$Package " -NoNewline -ForegroundColor "Yellow"
        Write-Host "already installed. Skipping..." -ForegroundColor "Gray"
    }
}

function Install-ScoopAppGlobal {
    param([string]$Package)
    if (!(scoop info $Package).Installed) {
        Write-Host "Scoop: " -NoNewline -ForegroundColor "Blue"
        Write-Host "$Package " -NoNewline -ForegroundColor "Yellow"
        Write-Host "installing globally"
        if ($(gsudo status IsElevated) -eq $False) {
            gsudo scoop install $Package --global | Out-Null
        }
        else {
            scoop install $Package --global | Out-Null
        }
    }
    else {
        Write-Host "Scoop: " -ForegroundColor "Blue" -NoNewLine
        Write-Host "$Package " -NoNewline -ForegroundColor "Yellow"
        Write-Host "already installed globally. Skipping..." -ForegroundColor "Gray"
    }
}

function Install-PoshModule {
    param([string]$Module)

    if (!(Get-Module -ListAvailable -Name $Module -ErrorAction SilentlyContinue)) {
        Write-Host "Module: " -ForegroundColor "Blue" -NoNewline
        Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
        Write-Host "is being installed" 
        Install-Module -Name $Module -AllowClobber -Scope CurrentUser -Force
    }
    else {
        Write-Host "Module: " -ForegroundColor "Blue" -NoNewline
        Write-Host "$Module " -ForegroundColor "Yellow" -NoNewline
        Write-Host "already installed. Skipping..."
    }
}

function Write-ModuleLockFile {
    Get-InstalledModule |
    Select-Object Name, Version, Author, InstalledDate, Description |
    ConvertTo-Json -Depth 100 |
    Out-File "$PSScriptRoot\modules.lock.json" -Encoding utf8 -Force
}

function Set-EnvironmentVariable {
    param ([string]$Value, [string]$Path)

    if (!([System.Environment]::GetEnvironmentVariable("$Value"))) {
        Write-Host "Environment Variable: " -ForegroundColor "Blue" -NoNewline
        Write-Host "adding $Value with Path: $Path" -ForegroundColor "Gray"
        [System.Environment]::SetEnvironmentVariable("$Value", "$Path", "User")
    }
    else {
        Write-Host "Environment Variable: " -ForegroundColor "Blue" -NoNewline
        Write-Host "$Value " -NoNewline -ForegroundColor "Yellow"
        Write-Host "already set! Skipping..." -ForegroundColor "Gray"
    }
}

function Write-GitConfigLocal {
    $localGitConfig = "$Env:USERPROFILE\.gitconfig-local"
    $currentGitName = $(Write-Host "Enter your Git Name: " -NoNewline -ForegroundColor "Blue"; Read-Host)
    $currentGitEmail = $(Write-Host "Enter your Git Email: " -NoNewline -ForegroundColor "Blue"; Read-Host)
    "[user]" >> "$localGitConfig"
    "   name = $currentGitName" >> "$localGitConfig"
    "   email = $currentGitEmail" >> "$localGitConfig"
}

#########################################################################################################
Main