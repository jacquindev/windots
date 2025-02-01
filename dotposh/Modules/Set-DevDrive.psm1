function Get-DevDrive {
	<#
	.SYNOPSIS
		Function to check if a drive is a Dev Drive
	.LINK
		https://github.com/ran-dall/Dev-Drive/blob/main/SetupDevDrive.ps1
	#>
	$devDrives = Get-Volume | Where-Object { $_.FileSystemType -eq 'ReFS' -and $_.DriveType -eq 'Fixed' }
	$devDriveLetters = @()

	foreach ($drive in $devDrives) {
		$driveLetter = "$($drive.DriveLetter):"
		$devDriveLetters += $driveLetter
	}

	switch ($devDriveLetters.Count) {
		0 {	Write-Warning "No Dev Drive found on the system.";	return $null }
		1 {	return $devDriveLetters[0] }
		Default {
			Write-Host "Multiple Dev Drives found:" -ForegroundColor Green
			for ($i = 0; $i -lt $devDriveLetters.Count; $i++) {
				Write-Host "[$i] $($devDriveLetters[$i])"
			}
			while ($true) {
				$selection = $(Write-Host "Please select the drive you want to configure by entering the corresponding number: " -ForegroundColor Magenta -NoNewline; Read-Host)
				if ($selection -match '^\d+$' -and [int]$selection -lt $devDriveLetters.Count) {	return $devDriveLetters[$selection] }
				else {	Write-Warning "Invalid selection. Please enter a valid number."	}
			}
		}
	}
}

function New-DirIfNotExist {
	param ([string]$Path)
	if (!(Test-Path -PathType Container -Path $Path)) {
		New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

		if ($LASTEXITCODE -ne 0) {	Write-Error -Message "An error occurred while creating the directory $Path" }
		else { Write-Host "Created directory $Path." -ForegroundColor Green }
	} else { Write-Host "Directory $Path already exists." -ForegroundColor Blue }
}

function New-EnvVarIfNotExists {
	param ([string]$Name, [string]$Value)

	if (!([System.Environment]::GetEnvironmentVariable($Name))) {
		[System.Environment]::SetEnvironmentVariable($Name, $Value, "User")
		if ($LASTEXITCODE -ne 0) {	Write-Error -Message "An error occurred while creating the environment variable $Name with value $Value" }
		else {	Write-Host "Environment variable $Name was set with $Value." -ForegroundColor Green }
	} else { Write-Host "Environment variable $Name already exists." -ForegroundColor Blue }
}

function Add-ToPath {
	param ([string]$Path)

	$paths = [System.Environment]::GetEnvironmentVariable("Path", "User").Split(";")
	if ($paths -notcontains $Path) {
		[System.Environment]::SetEnvironmentVariable("Path", "$Path;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
		if ($LASTEXITCODE -ne 0) {	Write-Error -Message "An error occurred while adding $Path to PATH."	}
		else {	Write-Host "Added $Path to PATH." -ForegroundColor Green }
	} else { Write-Host "$Path already exists in PATH." -ForegroundColor Blue }
}

function Move-CacheContents {
	param ([string]$ContentPath, [string]$Destination)

	if (Test-Path -PathType Container -Path $ContentPath) {
		Move-Item -Path "$ContentPath\*" -Destination "$Destination" -Force -ErrorAction SilentlyContinue
		if ($LASTEXITCODE -ne 0) { Write-Error -Message "An error occurred while moving the contents of $ContentPath to $Destination." }
		else { Write-Host "Moved the contents of $ContentPath to $Destination." -ForegroundColor Green }
	} else { Write-Warning -Message "No contents found in $ContentPath." }
}

function Set-DevDrive {
	<#
	.SYNOPSIS
		Set DevDrive environment variables and packages' cache locations
	.DESCRIPTION
		Create chosen environment variables if not exist.
		Move cache contents from original location to DevDrive's destination
	.EXAMPLE
		Set-DevDrive
	.LINK
		https://github.com/ran-dall/Dev-Drive/blob/main/SetupDevDrivePackageCache.ps1
	#>

	[CmdletBinding()]

	$selectedDrive = Get-DevDrive
	if ($selectedDrive) {
		Write-Host "Selected Dev Drive: " -ForegroundColor Green -NoNewline
		Write-Host "$selectedDrive`n" -ForegroundColor Yellow
	} else {
		Write-Host "No valid Dev Drive selected. Exiting script..." -ForegroundColor DarkGray
		exit 1
	}

	$cachePath = "$selectedDrive\packages"

	# https://learn.microsoft.com/en-us/windows/dev-drive/#storing-package-cache-on-dev-drive
	$cacheSettings = @(
		@{ Name = "npm_config_cache"; Value = "$cachePath\npm"; Sources = @("$env:APPDATA\npm-cache", "$env:LOCALAPPDATA\npm-cache") },
		@{ Name = "YARN_CACHE_FOLDER"; Value = "$cachePath\npm"; Sources = @("$env:LOCALAPPDATA\Yarn\Cache") },
		@{ Name = "DENO_DIR"; Value = "$cachePath\deno"; Sources = @("$env:LOCALAPPDATA\deno") },
		@{ Name = "PIP_CACHE_DIR"; Value = "$cachePath\pip"; Sources = @("$env:APPDATA\pip\Cache") },
		@{ Name = "PIPX_HOME"; Value = "$cachePath\pipx"; Sources = @("$env:USERPROFILE\pipx") },
		@{ Name = "POETRY_CACHE_DIR"; Value = "$cachePath\poetry"; Sources = @("$env:LOCALAPPDATA\pypoetry\Cache") },
		@{ Name = "RYE_HOME"; Value = "$cachePath\rye"; Sources = @("$env:USERPROFILE\.rye") },
		@{ Name = "UV_CACHE_DIR"; Value = "$cachePath\uv"; Sources = @("$env:LOCALAPPDATA\uv\cache") },
		@{ Name = "NUGET_PACKAGES"; Value = "$cachePath\.nuget\packages"; Sources = @("$env:USERPROFILE\.nuget\packages") },
		@{ Name = "VAGRANT_HOME"; Value = "$selectedDrive\.vagrant.d"; Sources = @("$env:USERPROFILE\.vagrant.d") },
		@{ Name = "VCPKG_DEFAULT_BINARY_CACHE"; Value = "$cachePath\vcpkg"; Sources = @("$env:LOCALAPPDATA\vcpkg\archives", "$env:APPDATA\vcpkg\archives") },
		@{ Name = "CARGO_HOME"; Value = "$cachePath\cargo"; Sources = @("$env:USERPROFILE\.cargo") },
		@{ Name = "GRADLE_USER_HOME"; Value = "$cachePath\gradle"; Sources = @("$env:USERPROFILE\.gradle") },
		@{ Name = "MAVEN_OPTS"; Value = "$cachePath\maven"; Sources = @("$env:USERPROFILE\.m2\repository") }
	)

	$envNames = gum choose --no-limit --header="Choose Environment Variables to set:" $($cacheSettings.Name)

	foreach ($setting in $cacheSettings) {
		foreach ($name in $envNames) {
			if ($name -eq $setting.Name) {
				Write-Host "`nSetting up $name" -ForegroundColor Magenta
				New-DirIfNotExist -Path $setting.Value
				if ($name -ne "MAVEN_OPTS") {	New-EnvVarIfNotExists -Name $setting.Name -Value $setting.Value }
				else {	New-EnvVarIfNotExists -Name $setting.Name -Value "-Dmaven.repo.local=$($setting.Value)"	}
				foreach ($source in $setting.Sources) {
					Move-CacheContents -ContentPath $source -Destination $setting.Value
				}
			}
		}
	}
}

Export-ModuleMember -Function Set-DevDrive
