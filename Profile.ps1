# Encoding UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# To communicate that real prompt is still loading while loading asynchronously
function prompt {
    "[async]::❯ "
}

# Environment Variables
$Env:DOTFILES = Split-Path (Get-ChildItem $PSScriptRoot | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts).Target
$Env:DOTPOSH = "$Env:DOTFILES\dotposh"
$Env:EDITOR = "code"
$Env:_ZO_DATA_DIR = "$Env:DOTFILES"
$Env:UV_LINK_MODE = "copy"
$Env:PIPENV_VENV_IN_PROJECT = $true
$Env:PIPENV_NO_INHERIT = $true
$Env:PIPENV_IGNORE_VIRTUALENVS = $true

# Asynchrous processes
# Oh-my-posh prompt
if (Get-Command 'oh-my-posh' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'omp' -Value 'oh-my-posh'
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        oh-my-posh init pwsh --config "$Env:DOTPOSH\posh-zen.toml" | Invoke-Expression
        oh-my-posh completion powershell | Out-String | Invoke-Expression
    } | Out-Null
}


# Posh Modules
$PoshModules = @('powershell-yaml', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore', 'Terminal-Icons')
foreach ($module in $PoshModules) {
    if (Get-Module -ListAvailable -Name "$module" -ErrorAction SilentlyContinue) {
        Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module "$module" -Global } | Out-Null
    }
}

# gsudo Module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        $gsudoPath = Split-Path (Get-Command gsudo.exe).Path
        Import-Module "$gsudoPath\gsudoModule.psd1"
    } | Out-Null
}

# Import Dotposh Modules
foreach ($function in $(Get-ChildItem -Path "$env:DOTPOSH\Modules\*.ps1" -File).Name) {
    Import-Module "$env:DOTPOSH\Modules\$function" -Global -ErrorAction SilentlyContinue
}
Remove-Variable function

# chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
}

# Source config files
foreach ($file in $(Get-ChildItem -Path "$env:DOTPOSH\Config\*" -Include *.ps1 -Recurse)) {
    . "$file"
}
Remove-Variable file

# PowerShell completions
foreach ($completion in $(Get-ChildItem -Path "$env:DOTPOSH\Config\posh-completions\*" -Include *.ps1 -Recurse)) {
    . "$completion"
}
Remove-Variable completion

# Fast scoop search drop-in replacement 🚀
# https://github.com/shilangyu/scoop-search
Invoke-Expression (&scoop-search --hook)

# yazi
if (Get-Command yazi -ErrorAction SilentlyContinue) {
    function y {
        $tmp = [System.IO.Path]::GetTempFileName()
        yazi $args --cwd-file="$tmp"
        if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
            Set-Location -LiteralPath $cwd
        }
        Remove-Item -Path $tmp
    }
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}

# fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}
