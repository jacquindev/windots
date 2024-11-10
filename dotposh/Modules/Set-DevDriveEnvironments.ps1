# Source: https://github.com/ran-dall/Dev-Drive/blob/main/SetupDevDrivePackageCache.ps1

function Set-DevDriveEnvironments {

    . "$PSScriptRoot\private\DevDrive\Get-DevDrive.ps1"
    . "$PSScriptRoot\private\DevDrive\Set-DevDriveEnvironmentVariables.ps1"

    $devDrive = Get-DevDrive
    $packagePath = "$devDrive\packages"
    $cacheSettings = @(
        # TODO: Add/Remove your DevDrive's package cache settings here:
        @{ Command = "npm"; Name = "npm_config_cache"; Value = "$packagePath\npm"; SourcePaths = @("$env:APPDATA\npm-cache", "$env:LOCALAPPDATA\npm-cache") },
        @{ Command = "yarn"; Name = "YARN_CACHE_FOLDER"; Value = "$packagePath\npm"; SourcePaths = @("$env:LOCALAPPDATA\Yarn\Cache") },
        @{ Command = "pnpm"; Name = "PNPM_HOME"; Value = "$packagePath\pnpm"; SourcePaths = @("$env:LOCALAPPDATA\pnpm\store") },
        @{ Command = "nuget"; Name = "NUGET_PACKAGES"; Value = "$packagePath\nuget\packages"; SourcePaths = @("$env:USERPROFILE\.nuget\packages") },
        @{ Command = "vcpkg"; Name = "VCPKG_DEFAULT_BINARY_CACHE"; Value = "$packagePath\vcpkg"; SourcePaths = @("$env:LOCALAPPDATA\vcpkg\archives", "$env:APPDATA\vcpkg\archives") },
        @{ Command = "pip"; Name = "PIP_CACHE_DIR"; Value = "$packagePath\pip"; SourcePaths = @("$env:LOCALAPPDATA\pip\Cache") },
        @{ Command = "pipx"; Name = "PIPX_HOME"; Value = "$packagePath\pipx"; SourcePaths = @("$env:USERPROFILE\pipx") },
        @{ Command = "cargo"; Name = "CARGO_HOME"; Value = "$packagePath\cargo"; SourcePaths = @("$env:USERPROFILE\.cargo") },
        @{ Command = "rustup"; Name = "RUSTUP_HOME"; Value = "$packagePath\rustup"; SourcePaths = @("$env:USERPROFILE\.rustup") },
        @{ Command = "gradle"; Name = "GRADLE_USER_HOME"; Value = "$packagePath\gradle"; SourcePaths = @("$env:USERPROFILE\.gradle") }
    )

    New-DirectoryIfNotExist -Path $packagePath

    foreach ($setting in $cacheSettings) {
        $command = $setting.Command
        $packagePath = $setting.Value
        $envName = $setting.Name
        $sourcePath = $setting.SourcePaths
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            # Create a directory if it doesn't exist
            New-DirectoryIfNotExist -Path $packagePath
            # Set an environment variable 
            Set-EnvironmentVariableIfNotExist -Name $envName -Value $packagePath

            # Move contents from the old directory to new directory
            foreach ($path in $sourcePath) {
                Move-CacheContents -ContentPath $path -Destination $packagePath
            }
        }
    }

    # Extra pipx
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        $extraPipxSettings = @(
            @{Name = "PIPX_BIN_DIR"; Value = "$packagePath\pipx\bin" }
            @{Name = "PIPX_MAN_DIR"; Value = "$packagePath\pipx\man" }
        )
        foreach ($setting in $extraPipxSettings) {
            Set-EnvironmentVariableIfNotExist -Name $($setting.Name) -Value $($setting.Value)
        }
    }

    # Extra NuGet
    if (Get-Command nuget -ErrorAction SilentlyContinue) {
        $nugetDir = "$packagePath\nuget"
        New-DirectoryIfNotExist -Path $nugetDir

        $extraNuGetSettings = @(
            @{ Name = "NUGET_HTTP_CACHE_PATH"; Value = "$nugetDir\v3-cache"; SourcePath = "$env:LOCALAPPDATA\NuGet\v3-cache" },
            @{ Name = "NUGET_PLUGINS_CACHE_PATH"; Value = "$nugetDir\plugins-cache"; SourcePath = "$env:LOCALAPPDATA\NuGet\plugins-cache" }
        )
        foreach ($setting in $extraNuGetSettings) {
            New-DirectoryIfNotExist -Path $($setting.Value)
            Set-EnvironmentVariableIfNotExist -Name $($setting.Name) -Value $($setting.Value)
            Move-CacheContents -ContentPath $($setting.SourcePath) -Destination $($setting.Value)
        }
    }

    # Maven Settings
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