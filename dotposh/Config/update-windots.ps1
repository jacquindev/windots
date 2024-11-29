# cSpell:disable

function Update-Windots {
    $currentDir = "$(Get-Location)"

    Set-Location "$env:DOTFILES"
    
    Write-Host "Updating GitHub repository of local windots..." -ForegroundColor DarkGray
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        gum spin --title="Stashing GitHub repo..." --title.foreground="" -- git stash
        gum spin --title="Pulling latest updates..." --title.foreground="" -- git pull
    }
    else {
        git stash | Out-Null
        git pull | Out-Null
    }

    git stash pop --quiet
    
    Write-Host "Capturing any new dependencies..." -ForegroundColor DarkGray
    Start-Process pwsh -ArgumentList ".\Setup.ps1" -Verb RunAs -WindowStyle Hidden -Wait

    Write-Host "Reloading PowerShell profile..." -ForegroundColor DarkGray
    Set-Location $currentDir
    . $PROFILE.CurrentUserAllHosts
}

Set-Alias -Name 'dotupdate' -Value 'Update-Windots'