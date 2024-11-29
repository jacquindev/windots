# cSpell:disable

# function runsetup {
#     gsudo "$env:DOTFILES\Setup.ps1"
# }

# function Update-Windots {
#     # Check if `gum` command exists, else exit
#     if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
#         Write-Warning "Command not found: gum. Exiting..."
#         return
#     }

#     $currentDir = "$(Get-Location)"

#     Set-Location "$env:DOTFILES"

#     # Update local profile with GitHub repository
#     gum spin --title="Stashing GitHub repo..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- git stash
#     gum spin --title="Pulling latest updates..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- git pull
#     gum spin --title="Updating local windots..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- git stash pop

#     # WinGet
#     # gum spin --title="Updating WinGet packages..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- winget update --all --accept-package-agreements --accept-source-agreements

#     # scoop
#     # gum spin --title="Updating scoop packages..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- scoop update --all

#     # Clearing oh-my-posh cache files
#     # gum spin --title="Clearing oh-my-posh cache..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- oh-my-posh cache clear

#     # Updating wsl
#     # gum spin --title="Updating WSL..." --title.foreground="#b4befe" --spinner.foreground="#cba6f7" --show-error -- wsl --update --pre-release

#     # Write-Verbose "Capturing any new dependencies"
#     # if (Get-Command gsudo -ErrorAction SilentlyContinue) {
#     #     gsudo .\Setup.ps1
#     # }
#     # else {
#     #     Start-Process pwsh -ArgumentList ".\Setup.ps1" -Verb RunAs -WindowStyle Hidden -Wait
#     # }

#     Set-Location $currentDir
    
#     Write-Verbose "Reloading PowerShell profile" 
#     . $PROFILE.CurrentUserAllHosts
# }

# Set-Alias -Name 'dotupdate' -Value 'Update-Windots'

function Update-Windots {
    $currentDir = "$(Get-Location)"

    . "$env:DOTFILES\Functions.ps1"
    
    # Update local profile with GitHub repository
    Set-Location "$env:DOTFILES"
    gum spin --title="Stashing GitHub repo..." --show-error -- git stash
    gum spin --title="Pulling latest updates..." --show-error -- git pull
    gum spin --title="Updating local windots..." --show-error -- git stash pop

    # Update winget packages
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        gum spin --title="Updating winget packages..." -- winget update --all
    }

    # Update scoop packages
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        gum spin --title="Updating scoop apps..." -- scoop update --all
    }

    # Update vscode extensions
    if (Get-Command code -ErrorAction SilentlyContinue) {
        gum spin --title="Updating vscode extensions..." -- code --update-extensions
    }

    # Update github cli extensions
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        gum spin --title="Updating gh extensions..." -- gh extension upgrade --all
    }

    Set-Location "$currentDir"

    Write-Verbose "Reloading PowerShell profile" 
    . $PROFILE.CurrentUserAllHosts
}

Set-Alias -Name 'dotupdate' -Value 'Update-Windots'