if (-not (Get-Module -ListAvailable -Name "DockerCompletion" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PowerShell Module: DockerCompletion" -ForegroundColor "Green"
    Install-Module -Name "DockerCompletion" -AcceptLicense -Scope CurrentUser -Force
}
Set-Alias -Name 'd' -Value 'docker'
Import-Module DockerCompletion -Global

