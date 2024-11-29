# azure
if (Get-Module -ListAvailable -Name Azure -ErrorAction SilentlyContinue) {
    if ($($PSVersionTable.PSEdition) -like "Core") {
        if (-not (Get-Module -ListAvailable -Name "Az.Tools.Predictor" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing PowerShell Module: Az.Tools.Predictor" -ForegroundColor "Green"
            Install-Module -Name "Az.Tools.Predictor" -AcceptLicense -Scope CurrentUser -Force
        }
        Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module Az.Tools.Predictor -Global } | Out-Null
    }
}