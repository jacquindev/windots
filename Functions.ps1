#requires -Version 7

function Test-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-DeveloperMode {
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if ((Test-Path $RegistryKeyPath) -and (Get-ItemProperty -Path $RegistryKeyPath | Select-Object -ExpandProperty AllowDevelopmentWithoutDevLicense)) {
        return $true
    } else {
        return $false
    }
}

function Set-GsudoCacheMode {
    param([switch]$on, [switch]$off)
    if (Get-Command gsudo -ErrorAction SilentlyContinue) {
        if ($on) {
            # Write-PrettyTitle "Enable Gsudo CacheMode"
            Start-Sleep -Seconds 5
            & gsudo cache on
        }
        if ($off) {
            # Write-PrettyTitle "Disable Gsudo CacheMode"
            Start-Sleep -Seconds 5
            & gsudo cache off
        }
    }
}

###################################################################################################
###                                         OUTPUT FUNCTIONS                                    ###
###################################################################################################
function Write-PrettyTitle {
    param ([string]$Title)

    $charCount = $Title.Length
    $line = ""
    for ($i = 0; $i -lt $charCount; $i++) {
        $line = $line.Insert($i, '―')
    }
    ''
    Write-Host "$line" -ForegroundColor Blue
    Write-Host "$Title" -ForegroundColor Blue
    Write-Host "$line" -ForegroundColor Blue
}

function Write-PrettyOutput {
    param (
        [Alias('p')][string]$Process,
        [Alias('e')][string]$Entry,
        [Alias('x')][switch]$Extra,
        [Alias('s')][string]$Entry2,
        [Alias('m')][string]$Message
    )

    if ($Extra) {
        Write-Host "$Process" -ForegroundColor Green -NoNewline
        Write-Host "  ▏ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$Entry" -ForegroundColor Magenta -NoNewline
        Write-Host " $Entry2 " -ForegroundColor Yellow -NoNewline
        Write-Host "$Message"
    } else {
        Write-Host "$Process" -ForegroundColor Green -NoNewline
        Write-Host "  ▏ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$Entry" -ForegroundColor Yellow -NoNewline
        Write-Host " $Message"
    }
}

function Write-PrettyInfo {
    param (
        [Alias('m')][string]$Message,
        [Alias('i')][string]$Info
    )
    ""
    Write-Host "==>" -ForegroundColor Cyan -NoNewline
    Write-Host " $Message " -NoNewline
    Write-Host "$Info" -ForegroundColor Magenta
}

###################################################################################################
###                                        INSTALL FUNCTIONS                                    ###
###################################################################################################
# Winget
function Install-WingetApps {
    param ([array]$List)

    foreach ($app in $List) {
        $installed = winget list --exact --accept-source-agreements -q $app
        if (![String]::Join("", $installed).Contains($app)) {
            gum spin --title="Installing $app..." -- winget install --exact --silent --accept-package-agreements --accept-source-agreements $app -s winget
            Write-PrettyOutput -Process "winget" -Entry "$app" -Message "installed successfully."
        } else {
            Write-PrettyOutput -Process "winget" -Entry "$app" -Message "already installed! Skipping..."
        }
    }
}

function Enable-ScoopBuckets {
    param ([array]$List)
    $scoopBucketDir = "$(Split-Path (Get-Command scoop.ps1).Source | Split-Path)\buckets"
    foreach ($bucket in $List) {
        if (!(Test-Path -PathType Container -Path "$scoopBucketDir\$bucket")) {
            gum spin --title="Adding $bucket to Scoop..." -- scoop bucket add $bucket
            Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Entry2 "$bucket" -Message "added for scoop." -Extra
        } else {
            Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Entry2 "$bucket" -Message "already added! Skipping..." -Extra
        }
    }
}

# Scoop
function Install-ScoopApps {
    param (
        [array]$List,
        [ValidateSet('AllUsers', 'CurrentUser')][string]$Scope = 'CurrentUser'
    )

    foreach ($app in $List) {
        if (!(scoop info $app).Installed) {
            if ($Scope -eq 'AllUsers') {
                if ($(gsudo status IsElevated) -eq $False) {
                    gum spin --title="Installing $app globally..." -- gsudo scoop install $app --global
                } else {
                    gum spin --title="Installing $app globally..." -- scoop install $app --global
                }
                Write-PrettyOutput -Process "scoop" -Entry "app:" -Entry2 "$app" -Message "globally installed successfully." -Extra
            } else {
                gum spin --title="Installing $app..." -- scoop install $app
                Write-PrettyOutput -Process "scoop" -Entry "app:" -Entry2 "$app" -Message "installed successfully." -Extra
            }
        } else {
            Write-PrettyOutput -Process "scoop" -Entry "app:" -Entry2 "$app" -Message "already installed! Skipping..." -Extra
        }
    }
}

function Install-Modules {
    param ([array]$List)

    foreach ($module in $List) {
        if (!(Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
            Install-Module -Name $module -AllowClobber -Scope CurrentUser -Force
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Entry2 "$module" -Message "installed successfully." -Extra
        } else {
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Entry2 "$module" -Message "already installed! Skipping..." -Extra
        }
    }
}

function Update-Modules {
    param ([array]$List)

    foreach ($module in $List) {
        if (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue) {
            Update-Module -Name $module -Scope CurrentUser -Force -PassThru | Out-Null
        }
    }
}

function Install-VSCode-Extensions {
    param ([array]$List)

    $installed = (code --list-extensions)
    foreach ($ext in $List) {
        if (-not ($installed | Select-String $ext)) {
            gum spin --title="Installing extension $ext..." -- code --install-extension $ext --force
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Entry2 "$ext" -Message "installed successfully." -Extra
        } else {
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Entry2 "$ext" -Message "already installed. Skipping..." -Extra
        }
    }
}


function Install-GitHub-Extensions {
    param ([array]$List)

    $installed = (gh extension list)
    foreach ($ext in $List) {
        $extName = $ext.Name
        $extRepo = $ext.Repo
        if (-not ($installed | Select-String "$extRepo")) {
            gum spin --title="Installing extension $extName..." -- gh extension install "$extRepo" --force
            Write-PrettyOutput -Process "github" -Entry "extension:" -Entry2 "$extName" -Message "installed successfully." -Extra
        } else {
            Write-PrettyOutput -Process "github" -Entry "extension:" -Entry2 "$extName" -Message "already installed. Skipping..." -Extra
        }
    }
}

function Install-NPM-Packages {
    param (
        [switch]$pnpm,
        [array]$List
    )

    foreach ($pkg in $List) {
        $command = $pkg.Command
        $packages = $pkg.Packages
        if (!(Get-Command $command -ErrorAction SilentlyContinue)) {
            foreach ($package in $packages) {
                if ($pnpm) {
                    pnpm add -g $package
                    Write-PrettyOutput -Process "nvm" -Entry "pnpm:" -Entry2 "$package" -Message "installed successfully." -Extra
                } else {
                    npm install --global --silent $package
                    Write-PrettyOutput -Process "nvm" -Entry "npm:" -Entry2 "$package" -Message "installed successfully." -Extra
                }
            }
        } else {
            foreach ($package in $packages) {
                if ($pnpm) {
                    Write-PrettyOutput -Process "nvm" -Entry "pnpm:" -Entry2 "$package" -Message "already installed. Skipping..." -Extra
                } else {
                    Write-PrettyOutput -Process "nvm" -Entry "npm:" -Entry2 "$package" -Message "already installed. Skipping..." -Extra
                }
            }
        }
    }
}

function Install-Vagrant-Plugins {
    param ([array]$List)

    $installed = (vagrant plugin list)
    foreach ($plugin in $List) {
        if (!($installed | Select-String "$plugin")) {
            gum spin --title="Installing plugin $plugin..." -- vagrant plugin install $plugin
            Write-PrettyOutput -Process "vagrant" -Entry "plugin:" -Entry2 "$plugin" -Message "installed successfully." -Extra
        } else {
            Write-PrettyOutput -Process "vagrant" -Entry "plugin:" -Entry2 "$plugin" -Message "already installed. Skipping..." -Extra
        }
    }
}

function Install-NerdFonts {
    param (
        [array]$List
    )
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $installedFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families
    foreach ($font in $List) {
        $fontName = $font.DisplayName
        $fontShortName = $font.ShortName
        if (!($installedFonts | Select-String "$fontName")) {
            & ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Confirm:$false -Scope AllUsers -Name $fontShortName
            Write-PrettyOutput -Process "nerd font" -Entry "$fontName" -Message "installed successfully."
        } else {
            Write-PrettyOutput -Process "nerd font" -Entry "$fontName" -Message "already installed. Skipping..."
        }
    }
}


function Set-Symlinks {
    param ([hashtable]$Symlinks)

    foreach ($link in $Symlinks.GetEnumerator()) {
        $symlinkKey = $link.Key
        $symlinkFile = Get-Item -Path $symlinkKey -ErrorAction SilentlyContinue
        $symlinkTarget = Resolve-Path $link.Value

        if (Test-Path -Path $symlinkTarget) {
            $symlinkFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            if (((Test-DeveloperMode) -eq $False) -and ((Test-IsElevated) -eq $False)) {
                gsudo { New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null }
            } else {
                New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null
            }
            Write-PrettyOutput "symlink" -Entry "$symlinkKey" -Entry2 "=> $symlinkTarget" -Message "added." -Extra
        }
    }
}

function Set-EnvironmentVariable {
    param ([string]$Value, [string]$Path)

    if (!([System.Environment]::GetEnvironmentVariable("$Value"))) {
        [System.Environment]::SetEnvironmentVariable("$Value", "$Path", "User")
        Write-PrettyOutput -Process "env" -Entry "$Value" -Entry2 "=> $Path" -Message "added." -Extra
    } else {
        Write-PrettyOutput -Process "env" -Entry "$Value" -Entry2 "=> $Path" -Message "already set." -Extra
    }
}

function Download-File {
    param (
        [string]$Directory,
        [string]$Url
    )
    if (Get-Command wget.exe -ErrorAction SilentlyContinue) {
        & wget.exe --quiet -P "$Directory" "$Url"
    } else {
        Invoke-WebRequest -Uri "$Url" -OutFile "$Directory"
    }
}

###################################################################################################
###                                      UNINSTALL FUNCTIONS                                    ###
###################################################################################################
