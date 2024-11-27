function Test-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

function Test-InternetConnection {
    $testconnection = Test-Connection -ComputerName www.google.com -Count 1 -Quiet -ErrorAction Stop 
    if ($testconnection -eq $False) {
        Write-Host "―――――――――――――――――――――――――――――――――" -ForegroundColor "Yellow"
        Write-Warning "NO INTERNET CONNECTION AVAILABLE!"
        Write-Host "―――――――――――――――――――――――――――――――――" -ForegroundColor "Yellow"
        Write-Host "Please recheck your internet connection and rerun this script." -ForegroundColor "Red"
        Write-Host "Exiting..."
        Start-Sleep -Seconds 1
        Break
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

function Write-PrettyTitle {
    param([string]$Title)

    $charCount = $Title.Length
    $line = ""
    for ($i = 0; $i -lt $charCount; $i++) {
        $line = $line.Insert($i, '―')
    }
    ""
    Write-Host "$line" -ForegroundColor "Blue"
    Write-Host "$Title" -ForegroundColor "Blue"
    Write-Host "$line" -ForegroundColor "Blue"
}

function Write-PrettyOutput {
    param(
        [string]$Process,
        [string]$Entry,
        [switch]$Extra,
        [string]$Entry2,
        [string]$Message
    )

    if ($Extra) {
        Write-Host "$Process" -ForegroundColor "Green" -NoNewline
        Write-Host "  ▏ " -ForegroundColor "DarkGray" -NoNewline
        Write-Host "$Entry" -ForegroundColor "Magenta" -NoNewline
        Write-Host " $Entry2 " -ForegroundColor "Yellow" -NoNewline
        Write-Host "$Message"
    }
    else {
        Write-Host "$Process" -ForegroundColor "Green" -NoNewline
        Write-Host "  ▏ " -ForegroundColor "DarkGray" -NoNewline
        Write-Host "$Entry" -ForegroundColor "Yellow" -NoNewline
        Write-Host " $Message"
    }

}

function Write-PrettyInfo {
    param (
        [string]$Message,
        [string]$Info
    )
    Write-Host ""
    Write-Host "==> " -NoNewline -ForegroundColor "Cyan"
    Write-Host "$Message " -NoNewline
    Write-Host "$Info" -ForegroundColor "Cyan" 
}

function Install-WingetApps {
    param (
        [array]$AppList
    )

    foreach ($app in $AppList) {
        $installed = winget list --exact --accept-source-agreements -q $app
        if (![String]::Join("", $installed).Contains($app)) {
            winget install --exact --silent --accept-source-agreements --accept-package-agreements $app --source winget
        }
        else {
            Write-PrettyOutput -Process "winget" -Entry "$app" -Message "already installed."
        }
    }
}

function Remove-WingetApps {
    param (
        [array]$AppList
    )

    foreach ($app in $AppList) {
        $installed = winget list --exact --accept-source-agreements -q $app
        if ([String]::Join("", $installed).Contains($app)) {
            winget uninstall --exact --silent  $app --source winget 
        }
        else {
            Write-PrettyOutput -Process "winget" -Entry "$app" -Message "is not available to uninstall."
        }
    }
}

function Install-ScoopApps {
    param (
        [array]$AppList,
        [ValidateSet('AllUsers', 'CurrentUser')][string]$Scope = "CurrentUser"
    )
    foreach ($app in $AppList) {
        if (!(scoop info $app).Installed) {
            if ($Scope -eq 'CurrentUser') {
                scoop install $app | Out-Null
            }
            elseif ($Scope -eq 'AllUsers') {
                if ($(gsudo status IsElevated) -eq $False) {
                    gsudo scoop install $app --global | Out-Null
                }
                else {
                    scoop install $app --global | Out-Null
                }
            }
        }
        else {
            Write-PrettyOutput -Process "scoop" -Entry "app:" -Extra "$app" -Message "already installed."
        }
    }
}

function Remove-ScoopApps {
    param (
        [array]$AppList,
        [ValidateSet('AllUsers', 'CurrentUser')][string]$Scope = "CurrentUser"
    )
    foreach ($app in $AppList) {
        if ((scoop info $app).Installed) {
            if ($Scope -eq 'CurrentUser') {
                scoop uninstall $app | Out-Null
            }
            elseif ($Scope -eq 'AllUsers') {
                if ($(gsudo status IsElevated) -eq $False) {
                    gsudo scoop uninstall $app --global | Out-Null
                }
                else {
                    scoop uninstall $app --global | Out-Null
                }
            }
        }
        else {
            Write-PrettyOutput -Process "scoop" -Entry "app:" -Extra "$app" -Message "is not available to uninstall."
        }
    }
}

function Enable-ScoopBucket {
    param ([string]$Bucket)
    $scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
    $BucketDir = "$scoopDir\buckets"
    if (!(Test-Path -PathType Container -Path "$BucketDir\$Bucket")) {
        scoop bucket add $Bucket | Out-Null
        Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Extra "$Bucket" -Message "added for scoop."
    }
    else {
        Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Extra "$Bucket" -Message "already for scoop."
    }
}

function Disable-ScoopBucket {
    param ([string]$Bucket)
    $scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
    $BucketDir = "$scoopDir\buckets"
    if (Test-Path -PathType Container -Path "$BucketDir\$Bucket") {
        scoop bucket remove $Bucket | Out-Null
        Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Extra "$Bucket" -Message "removed for scoop."
    }
    else {
        Write-PrettyOutput -Process "scoop" -Entry "bucket:" -Extra "$Bucket" -Message "is not available to remove."
    }
}

function Install-PoshModules {
    param ([array]$ModuleList)
    foreach ($module in $ModuleList) {
        if (!(Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
            Install-Module -Name $module -AllowClobber -Scope CurrentUser -Force
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Extra "$Module" -Message "installed."
        }
        else {
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Extra "$Module" -Message "already installed."
        }
    }
}

function Remove-PoshModules {
    param ([array]$ModuleList)
    foreach ($module in $ModuleList) {
        if (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue) {
            Uninstall-Module -Name $module 
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Extra "$Module" -Message "uninstalled."
        }
        else {
            Write-PrettyOutput -Process "pwsh" -Entry "module:" -Extra "$Module" -Message "is not available to uninstall."
        }
    }
}

function Install-CodeExtensions {
    param ([array]$ExtensionList)
    $installed = (code --list-extensions)
    foreach ($extension in $ExtensionList) {
        if (-not ($installed | Select-String $extension)) {
            code --install-extension $extension | Out-Null
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Extra "$extension" -Message "installed."
        }
        else {
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Extra "$extension" -Message "already installed."
        }
    }
}

function Remove-CodeExtensions {
    param ([array]$ExtensionList)
    $installed = (code --list-extensions)
    foreach ($extension in $ExtensionList) {
        if ($installed | Select-String $extension) {
            code --uninstall-extension $extension | Out-Null
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Extra "$extension" -Message "uninstalled."
        }
        else {
            Write-PrettyOutput -Process "vscode" -Entry "extension:" -Extra "$extension" -Message "is not available to uninstall."
        }
    }
}

function Set-SymbolicLinks {
    param ([hashtable]$Symlinks)

    foreach ($symlink in $Symlinks.GetEnumerator()) {
        $symlinkFile = Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
        $symlinkKey = $symlink.Key
        $symLinkTarget = Resolve-Path $symlink.Value
        if (Test-Path -Path $symlinkTarget) {
            $symlinkFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            if (((Test-DeveloperMode) -eq $False) -and ((Test-IsElevated) -eq $False)) {
                gsudo { New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null }
            }
            else {
                New-Item -ItemType SymbolicLink -Path $symlinkKey -Target $symLinkTarget -Force | Out-Null
            }
            Write-PrettyOutput -Process "symlink" -Entry "$symlinkKey" -Message "added."
        }
    }
}

function Remove-SymbolicLinks {
    param ([hashtable]$Symlinks)
    foreach ($symlink in $Symlinks.GetEnumerator()) {
        $symlinkFile = Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
        $symlinkKey = $symlink.Key
        $symLinkTarget = Resolve-Path $symlink.Value
        if (Test-Path -Path $symlinkTarget) {
            $symlinkFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-PrettyOutput -Process "symlink" -Entry "$symlinkKey" -Message "removed."
        }
        else {
            Write-PrettyOutput -Process "symlink" -Entry "$symlinkKey" -Message "is not available to remove."
        }
    }
}

# git config
function Write-GitConfigLocal {
    $gitUserName = $(Write-Host "Input Git Name: " -ForegroundColor Magenta -NoNewline; Read-Host)
    $gitUserMail = $(Write-Host "Input Git Email: " -ForegroundColor Magenta -NoNewline; Read-Host)
    $file = "$Env:USERPROFILE\.gitconfig-local"

    Write-Output "[user]" > "$file"
    Write-Output "  $gitUserName" > "$file"
    Write-Output "  $gitUserMail" > "$file"
    Write-PrettyInfo -Message "Git Email and Name set successfully in" -Info "$Env:USERPROFILE\.gitconfig-local"
}

function Set-EnvironmentVariable {
    param ([string]$Value, [string]$Path)

    if (!([System.Environment]::GetEnvironmentVariable("$Value"))) {
        [System.Environment]::SetEnvironmentVariable("$Value", "$Path", "User")
        Write-PrettyOutput -Process "env" -Entry "$Value =>" -Extra "$Path" -Message "added."
    }
    else {
        Write-PrettyOutput -Process "env" -Entry "$Value =>" -Extra "$Path" -Message "already set."
    }
}

function Remove-EnvironmentVariable {
    param ([string]$Value)
    if ([System.Environment]::GetEnvironmentVariable("$Value")) {
        [System.Environment]::SetEnvironmentVariable("$Value", $null, "User")
        Write-PrettyOutput -Process "env" -Entry "$Value" -Message "removed."
    }
    else {
        Write-PrettyOutput -Process "env" -Entry "$Value" -Message "is not available to remove."
    }
}

function Install-NerdFonts {
    param (
        [ValidateSet('CurrentUser', 'AllUsers')]
        [string]$Scope = 'CurrentUser',

        [switch]$Scoop,
        [switch]$Script
    )
    if ($Scoop) {
        foreach ($font in $nerdFonts) {
            $fontDisplayName = $font.DisplayName
            $fontScoopName = $font.ScoopName
            foreach ($fontName in $($fontScoopName)) {
                if (!(scoop info $fontName).Installed) {
                    if ($Scope -eq 'AllUsers') {
                        if ((Test-IsElevated) -eq $False) {
                            gsudo scoop install $fontName --global | Out-Null
                        }
                        else { scoop install $fontName --global | Out-Null }
                    }
                    else {
                        scoop install $fontName
                    }
                }
            }
            Write-PrettyOutput -Process "Nerd Font" -Entry "$fontFullName" -Extra -Entry2 "using scoop" -Message "installed."
        }
    }
    elseif ($Script) {
        foreach ($font in $nerdFonts) {
            $fontName = $font.ShortName
            $fontFullName = $font.DisplayName
            if ($Scope -eq 'AllUsers') {
                Start-Process -FilePath pwsh -ArgumentList "& ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Name $fontName -Scope AllUsers -Confirm:$false" -Verb RunAs -Wait -WindowStyle Hidden
            }
            else {
                Start-Process -FilePath pwsh -ArgumentList "&([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Name $fontName -Confirm:$false" -Wait -WindowStyle Hidden
            }
            Start-Sleep -Seconds 1
            Write-PrettyOutput -Process "Nerd Font" -Entry "$fontFullName" -Extra -Entry2 "using Script" -Message "installed."
        }
    }
}