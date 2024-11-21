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

function Write-Success {
    param (
        [string]$Entry1,
        [string]$Entry2,
        [string]$Entry3,
        [string]$Text
    )
    Write-Host "$Entry1 " -ForegroundColor "Green" -NoNewline
    Write-Host ": " -ForegroundColor "DarkGray" -NoNewline
    Write-Host "$Entry2 " -ForegroundColor "Yellow" -NoNewline
    Write-Host "$Text"
}

function Write-Error {
    param (
        [string]$Entry1,
        [string]$Entry2,
        [string]$Text
    )
    Write-Host "$Entry1" -ForegroundColor "Red" -NoNewline
    Write-Host ": " -ForegroundColor "DarkGray" -NoNewline
    Write-Host "$Entry2 " -ForegroundColor "DarkYellow" -NoNewline
    Write-Host "$Text"
}

function New-DirectoryIfNotExist {
    param ([string]$Path)
    if (!(Test-Path -PathType Container -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success -Entry1 "Directory" -Entry2 "$Path" -Text "created successfully."
        }
        else {
            Write-Error -Entry1 "Directory" -Entry2 "$Path" -Text "failed to create."
        }
    }
    else {
        Write-Error -Entry1 "Directory" -Entry2 "$Path" -Text "already exists. Skipping..."
    }
}

function Set-EnvironmentVariableIfNotExist {
    param (
        [string]$Name,
        [string]$Value
    )
    if (!([System.Environment]::GetEnvironmentVariable("$Name"))) {
        [System.Environment]::SetEnvironmentVariable("$Name", "$Value", "User")
        if ($LASTEXITCODE -eq 0) {
            Write-Success -Entry1 "Environment Variable" -Entry2 "$Name ==> $Value" -Text "was set."
        }
        else {
            Write-Error -Entry1 "Environment Variable" -Entry2 "$Name ==> $Value" -Text "failed to set."
        }
    }
    else {
        Write-Error -Entry1 "Environment Variable" -Entry2 "$Name ==> $Value" -Text "already set. Skipping..."
    }
}

function Move-CacheContents {
    param (
        [string]$ContentPath,
        [string]$Destination
    )
    if (Test-Path -PathType Container -Path $ContentPath) {
        Move-Item -Path "$ContentPath\*" -Destination "$Destination" -Force
        if ($LASTEXITCODE -eq 0) {
            Write-Success -Entry1 "Contents" -Entry2 "$ContentPath ==> $Destination" -Text "moved."
        }
        else {
            Write-Error -Entry1 "Contents" -Entry2 "$ContentPath ==> $Destination" -Text "failed to moved."
        }
        Remove-Item -Path $ContentPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    else { 
        Write-Error -Entry1 "Contents" -Entry2 "$ContentPath ==> $Destination" -Text "already moved / no content to move."
    }
}

function Set-DevDriveEnvironments {
    $devDrive = Get-DevDrive
    $packagePath = "$devDrive\packages"
    $cacheSettings = @(
        @{ Command = "npm"; Value = "npm_config_cache"; ValuePath = "$packagePath\npm"; SourcePaths = @("$env:APPDATA\npm-cache". "$env:LOCALAPPDATA\npm-cache") },
        @{ Command = "yarn"; Value = "YARN_CACHE_FOLDER"; ValuePath = "$packagePath\npm"; SourcePaths = @("$env:LOCALAPPDATA\Yarn\Cache") },
        @{ Command = "pnpm"; Value = "PNPM_HOME"; ValuePath = "$packagePath\pnpm"; SourcePaths = @("$env:LOCALAPPDATA\pnpm\store") },
        @{ Command = "pip"; Value = "PIP_CACHE_DIR"; ValuePath = "$packagePath\pip"; SourcePaths = @("$env:LOCALAPPDATA\pip\cache") },
        @{ Command = "pipx"; Value = "PIPX_HOME"; ValuePath = "$packagePath\pipx"; SourcePaths = @("$env:USERPROFILE\pipx") },
        @{ Command = "cargo"; Value = "CARGO_HOME"; ValuePath = "$packagePath\cargo"; SourcePaths = @("$env:USERPROFILE\.cargo") },
        @{ Command = "rustup"; Value = "RUSTUP_HOME"; ValuePath = "$packagePath\rustup"; SourcePaths = @("$env:USERPROFILE\.rustup") },
        @{ Command = "gradle"; Value = "GRADLE_USER_HOME"; ValuePath = "$packagePath\gradle"; SourcePaths = @("$env:USERPROFILE\.gradle") },
        @{ Command = "nuget"; Value = "NUGET_PACKAGES"; ValuePath = "$packagePath\nuget\packages"; SourcePaths = @("$env:USERPROFILE\.nuget\packages") },
        @{ Command = "vcpkg"; Value = "VCPKG_DEFAULT_BINARY_CACHE"; ValuePath = "$packagePath\vcpkg"; SourcePaths = @("$env:LOCALAPPDATA\vcpkg\archives", "$env:APPDATA\vcpkg\archives") }
    )

    New-DirectoryIfNotExist -Path $packagePath

    foreach ($setting in $cacheSettings) {
        $command = $setting.Command
        $name = $setting.Value
        $value = $setting.ValuePath
        $sources = $setting.SourcePaths

        if (Get-Command $command -ErrorAction SilentlyContinue) {
            # Create a directory if it doesn't exist
            New-DirectoryIfNotExist -Path $value
            # Set an environment variable
            Set-EnvironmentVariableIfNotExist -Name $name -Value $value
            # Move contents from the old directory to new directory
            foreach ($source in $sources) {
                Move-CacheContents -ContentPath $source -Destination $value
            }
        }
    }

    # Extras
    # pipx
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        $extraPipxSettings = @(
            @{ Value = "PIPX_BIN_DIR"; ValuePath = "$packagePath\pipx\bin" },
            @{ Value = "PIPX_MAN_DIR"; ValuePath = "$packagePath\pipx\man" }
        )
        foreach ($pipxSetting in $extraPipxSettings) {
            Set-EnvironmentVariableIfNotExist -Name $($pipxSetting.Value) -Value $($pipxSetting.ValuePath)
        }
    }

    # maven
    if (Get-Command mvn -ErrorAction SilentlyContinue) {
        $mavenRepoLocal = "$packagePath\maven"
        $mavenOpts = [System.Environment]::GetEnvironmentVariable('MAVEN_OPTS', [System.EnvironmentVariableTarget]::User)
        $escapedMavenRepoLocal = [regex]::Escape($mavenRepoLocal)
        $mavenPath = "$Env:USERPROFILE\.m2\repository"

        New-DirectoryIfNotExist -Path $mavenRepoLocal

        if ($mavenOpts -notmatch "-Dmaven\.repo\.local=$escapedMavenRepoLocal") {
            $newMavenOpts = "-Dmaven.repo.local=$mavenRepoLocal $mavenOpts"
            Set-EnvironmentVariableIfNotExist -Name "MAVEN_OPTS" -Value $newMavenOpts
        }
        Move-CacheContents -ContentPath $mavenPath -Destination $mavenRepoLocal
    }
}