# docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "DockerCompletion" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell Module: DockerCompletion" -ForegroundColor "Green"
        Install-Module -Name "DockerCompletion" -AcceptLicense -Scope CurrentUser -Force
    }
    Set-Alias -Name 'd' -Value 'docker'
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module DockerCompletion -Global } | Out-Null
}
