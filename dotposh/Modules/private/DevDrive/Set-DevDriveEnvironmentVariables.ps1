function New-DirectoryIfNotExist {
    param ([string]$Path)
    if (!(Test-Path -PathType Container -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Directory: " -ForegroundColor "Green" -NoNewline
        Write-Host "$Path " -ForegroundColor "Yellow" -NoNewline
        Write-Host "created successfully."
    }
    else {
        Write-Host "Directory: " -ForegroundColor "Red" -NoNewline
        Write-Host "$Path " -ForegroundColor "Yellow" -NoNewline
        Write-Host "already exists. Skipping..."
    }
}

function Set-EnvironmentVariableIfNotExist {
    param (
        [string]$Name,
        [string]$Value
    )
    if (!([System.Environment]::GetEnvironmentVariable("$Name"))) {
        [System.Environment]::SetEnvironmentVariable("$Name", "$Value", "User")
        Write-Host "Environment variable set: " -ForegroundColor "Green" -NoNewline
        Write-Host "'$Name' " -ForegroundColor "Yellow" -NoNewline
        Write-Host "==> " -NoNewline
        Write-Host "'$Value'" -ForegroundColor "Yellow"
    }
    else {
        Write-Host "Environment variable: " -ForegroundColor "Red" -NoNewline
        Write-Host "'$Name' " -ForegroundColor "Yellow" -NoNewline
        Write-Host "already set to" -NoNewline
        Write-Host "'$Value'" -ForegroundColor "Yellow"
    }
}

function Move-CacheContents {
    param (
        [string] $ContentPath,
        [string] $Destination
    )
    if (Test-Path -PathType Container -Path $ContentPath) {
        Move-Item -Path "$ContentPath\*" -Destination "$Destination" -Force
        Remove-Item -Path $ContentPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Contents:" -ForegroundColor "Green" -NoNewline
        Write-Host "moved from " -NoNewline
        Write-Host "'$ContentPath' " -ForegroundColor "Yellow" -NoNewline
        Write-Host "==> " -NoNewline
        Write-Host "'$Destination'" -ForegroundColor "Yellow"
    }
    else { 
        Write-Host "Contents: " -ForegroundColor "Red" -NoNewline
        Write-Host "No contents to move from " -NoNewline
        Write-Host "$ContentPath" -ForegroundColor "Yellow"
    }
}
