function Add-ToPath {
    param (
        [string]$Path
    )
    $EnvPath = [System.Environment]::GetEnvironmentVariable('path', "User")
    if ($EnvPath | Where-Object { $_ -like "*$Path*" } ) {
        Write-Host "Path: $Path already added to PATH."
    }
    else {
        [System.Environment]::SetEnvironmentVariable('path', "$Path;" + [System.Environment]::GetEnvironmentVariable('path', "User"), "User")
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Path: $Path added to PATH successfully."
        }
        else {
            Write-Host "Path: $Path added to PATH failed."
        }
    }
}