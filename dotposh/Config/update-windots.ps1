# cSpell:disable

function Update-Windots {
    [CmdletBinding()]
    $currentDir = "$(Get-Location)"

    Set-Location "$env:DOTFILES"
    git stash | Out-Null
    git pull | Out-Null
    git stash pop | Out-Null

    if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $False) {
        if (Get-Command gsudo -ErrorAction SilentlyContinue) {
            gsudo .\Setup.ps1
        }
        else {
            Start-Process pwsh -ArgumentList ".\Setup.ps1" -Verb RunAs -WindowStyle Hidden -Wait
        }
    }

    Set-Location $currentDir
    . $PROFILE.CurrentUserAllHosts
}

Set-Alias -Name 'dotupdate' -Value 'Update-Windots'