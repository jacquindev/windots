# Source: https://github.com/ran-dall/Dev-Drive/blob/main/SetupDevDrivePackageCache.ps1

function New-DevDriveFolders {
    . "$PSScriptRoot\Get-DevDrive.ps1"

    # TODO: Add your preferred DevDrive's Folder here:
    $DevDriveFolders = @(
        "packages",
        "projects",
        "repos"
    )
    $selectedDrive = Get-DevDrive
    if (-not $selectedDrive) {
        Write-Host "No valid DevDrive selected. Exiting..." -ForegroundColor "Red"
        Start-Sleep -Seconds 3
        Break
    }
    foreach ($folder in $DevDriveFolders) {
        if (-not (Test-Path -Path "$selectedDrive\$folder")) {
            New-Item -Path "$selectedDrive\$folder" -ItemType Directory -Force -ErrorAction SilentlyContinue
            Write-Host "Directory created: " -NoNewline
            Write-Host "$selectedDrive\$folder" -ForegroundColor "Green" 
        }
        else {
            Write-Host "Directory already existed: " -NoNewline
            Write-Host "$selectedDrive\$folder" -ForegroundColor "Green"
        }
    }
}