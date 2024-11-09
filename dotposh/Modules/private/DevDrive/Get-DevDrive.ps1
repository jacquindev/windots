# Source: https://github.com/ran-dall/Dev-Drive

function Get-DevDrive {
    $devDrives = Get-Volume | Where-Object { $_.FileSystemType -eq 'ReFS' -and $_.DriveType -eq 'Fixed' }
    $devDriveLetters = @()
    
    foreach ($drive in $devDrives) {
        $driveLetter = "$($drive.DriveLetter):"
        $devDriveLetters += $driveLetter
    }
    
    if ($devDriveLetters.Count -eq 0) {
        Write-Output "No Dev Drive found on the system."
        return $null
    }
    elseif ($devDriveLetters.Count -eq 1) {
        return $devDriveLetters[0]
    }
    else {
        Write-Host "Multiple Dev Drives found:"
        for ($i = 0; $i -lt $devDriveLetters.Count; $i++) {
            Write-Host "[$i] $($devDriveLetters[$i])"
        }
        $selection = Read-Host "Please select the drive you want to configure by entering the corresponding number"
        if ($selection -match '^\d+$' -and [int]$selection -lt $devDriveLetters.Count) {
            return $devDriveLetters[$selection]
        }
        else {
            Write-Output "Invalid selection. Exiting script."
            return $null
        }
    }
}
