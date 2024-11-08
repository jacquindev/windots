# Encoding UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# To communicate that real prompt is still loading while loading asynchronously
function prompt {
    "[async init]::> "
}

# Environment Variables
$Env:DOTFILES = Split-Path (Get-ChildItem $PSScriptRoot | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts).Target
$Env:DOTPOSH = "$Env:DOTFILES\dotposh"
$Env:EDITOR = "code"
$Env:_ZO_DATA_DIR = "$Env:DOTFILES"

# Asynchrous processes
# Oh-my-posh prompt
if (Get-Command 'oh-my-posh' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'omp' -Value 'oh-my-posh'
    oh-my-posh completion powershell | Out-String | Invoke-Expression
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        oh-my-posh init pwsh --config "$Env:DOTPOSH\posh-zen.toml" | Invoke-Expression
    } | Out-Null
}

# Posh Modules
$PoshModules = @('posh-git', 'powershell-yaml', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore', 'Terminal-Icons')
foreach ($module in $PoshModules) {
    if (Get-Module -ListAvailable -Name "$module" -ErrorAction SilentlyContinue) {
        Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module "$module" -Global } | Out-Null
    }
}

# gsudo Module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    $gsudoPath = Split-Path (Get-Command gsudo.exe).Path
    Import-Module "$gsudoPath\gsudoModule.psd1" 
}

# Import Dotposh Modules
foreach ($function in $(Get-ChildItem -Path "$env:DOTPOSH\Modules\*.ps1" -File).Name) {
    Import-Module "$env:DOTPOSH\Modules\$function" -Global -ErrorAction SilentlyContinue
} 
Remove-Variable function

# Source config files
foreach ($file in $(Get-ChildItem -Path "$env:DOTPOSH\Config\*" -Include *.ps1 -Recurse)) {
    . "$file"
}

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
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}