<#
.SYNOPSIS
    Located devdrives location on the system.
.LINK
    https://github.com/ran-dall/Dev-Drive
#>

# Check if a drive is DevDrive
function Get-DevDrive {
    $devDrives = Get-Volume | Where-Object { $_.FileSystemType -eq 'ReFS' -and $_.DriveType -eq 'Fixed' }
    $devDriveLetters = @()

    foreach ($drive in $devDrives) {
        $driveLetter = "$($drive.DriveLetter):"
        $devDriveLetters += $driveLetter
    } 

    if ($devDriveLetters.Count -eq 0) { return $null }
    elseif ($devDriveLetters.Count -eq 1) { return $devDriveLetters[0] }
    else {
        Write-Host "Multiple Dev Drives found:"
        for ($i = 0; $i -lt $devDriveLetters.Count; $i++) {
            Write-Host "[$i] $($devDriveLetters[$i])"
        }
        $selection = Read-Host "Please select the drive you want to configure by entering the corresponding number"
        if ($selection -match '^\d+$' -and [int]$selection -lt $devDriveLetters.Count) {
            return $devDriveLetters[$selection]
        }
        else { return $null }
    }
}

function Set-DevDriveEnvironmentVariable {
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$Value
    )
    $currentValue = [System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::User)
    if (!($currentValue -eq $Value)) {
        try {
            $output = setx $Name $Value
            if ($output -match "SUCCESS: Specified value was saved.") {
                Write-Host "SUCCESS: Environment variable '$Name' was set to '$Value'." -ForegroundColor "Green"
            }
        }
        catch {
            Write-Error "Access to the registry path is denied for environment variable '$Name'."
        }
    }
}

# Function to move contents from one directory to another
function Move-CacheContents {
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )
    if (Test-Path -Path $SourcePath) {
        Move-Item -Path "$SourcePath\*" -Destination $DestinationPath -Force
        Remove-Item -Path $SourcePath -Recurse -Force
    }
}

####################################################
###                 MAIN SCRIPT                  ###
####################################################

$devDrive = Get-DevDrive

$packagePath = "$devDrive\packages"
$projectPath = "$devDrive\projects"
$repoPath = "$devDrive\repos"
    
foreach ($path in @($packagePath, $projectPath, $repoPath)) {
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}


### Dev Drive Settings ###
# $devPathSettings = @(
#     @{ Command = "npm"; PackagePath = "$packagePath\npm"; EnvName = "npm_config_cache"; SourcePaths = @("$env:APPDATA\npm-cache", "$env:LOCALAPPDATA\npm-cache") },
#     @{ Command = "yarn"; PackagePath = "$packagePath\npm"; EnvName = "YARN_CACHE_FOLDER"; SourcePaths = @() },
#     @{ Command = "pip"; PackagePath = "$packagePath\pip"; EnvName = "PIP_CACHE_DIR"; SourcePaths = @("$env:LOCALAPPDATA\pip\Cache") },
#     @{ Command = "cargo"; PackagePath = "$packagePath\cargo"; EnvName = "CARGO_HOME"; SourcePaths = @("$env:USERPROFILE\.cargo") },
#     @{ Command = "vcpkg"; PackagePath = "$packagePath\vcpkg"; EnvName = "VCPKG_DEFAULT_BINARY_CACHE"; SourcePaths = @("$env:LOCALAPPDATA\vcpkg\archives", "$env:APPDATA\vcpkg\archives") },
#     @{ Command = "gradle"; PackagePath = "$packagePath\gradle"; EnvName = "GRADLE_USER_HOME"; SourcePaths = @("$env:USERPROFILE\.gradle") }
# )

# foreach ($setting in $devPathSettings) {
#     if (Get-Command -Name $($setting.Command) -ErrorAction SilentlyContinue) {
#         if (-not (Test-Path -PathType Container -Path $($setting.PackagePath))) {
#             New-Item -Path $($setting.PackagePath) -ItemType Directory -Force | Out-Null
#         }
#         Set-DevDriveEnvironmentVariable -Name $($setting.EnvName) -Value $($setting.PackagePath)
#         foreach ($source in $setting.SourcePaths) {
#             if ($null -ne $source) { Move-CacheContents -SourcePath $source -DestinationPath $setting.PackagePath }
#         }
#     }
# }


# ### Maven Setup ###
# if (Get-Command "mvn" -ErrorAction SilentlyContinue) {
#     $mavenRepoLocal = "$packagePath\maven"
#     if (!(Test-Path -PathType Container -Path $mavenRepoLocal)) { New-Item -Path $mavenRepoLocal -ItemType Directory -Force | Out-Null }
#     $mavenOpts = [System.Environment]::GetEnvironmentVariable('MAVEN_OPTS', [System.EnvironmentVariableTarget]::User)
#     $escapedMavenRepoLocal = [regex]::Escape($mavenRepoLocal)
#     if ($mavenOpts -notmatch "-Dmaven\.repo\.local=$escapedMavenRepoLocal") {
#         $newMavenOpts = "-Dmaven.repo.local=$mavenRepoLocal $mavenOpts"
#         Set-DevDriveEnvironmentVariable -Name "MAVEN_OPTS" -Value $newMavenOpts
#     }
#     Move-CacheContents -SourcePath "$env:USERPROFILE\.m2\repository" -DestinationPath $mavenRepoLocal
# }


### Quick Jump Aliases ###
Add-Alias packages "Set-Location $packagePath"
Add-Alias projects "Set-Location $projectPath"
Add-Alias repos "Set-Location $repoPath"

Remove-Variable path, devDrive, packagePath, projectPath, repoPath