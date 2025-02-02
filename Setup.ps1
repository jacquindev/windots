
<#PSScriptInfo

.VERSION 1.0.1

.GUID ccb5be4c-ea07-4c45-a5b4-6310df24e2bc

.AUTHOR jacquindev@outlook.com

.COMPANYNAME

.COPYRIGHT 2024 Jacquin Moon. All rights reserved.

.TAGS windots dotfiles

.LICENSEURI https://github.com/jacquindev/windots/blob/main/LICENSE

.PROJECTURI https://github.com/jacquindev/windots

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Version 7
#Requires -RunAsAdministrator

<#

.DESCRIPTION
	Setup script for Windows 11 Machine.

#>
Param()

$VerbosePreference = "SilentlyContinue"

########################################################################################################################
###																											HELPER FUNCTIONS																						 ###
########################################################################################################################
function Add-ScoopBucket {
	param ([string]$BucketName, [string]$BucketRepo)

	$scoopDir = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
	if (!(Test-Path "$scoopDir\buckets\$BucketName" -PathType Container)) {
		if ($BucketRepo) {
			scoop bucket add $BucketName $BucketRepo
		} else {
			scoop bucket add $BucketName
		}
	}
}

function Install-ScoopApp {
	param ([string]$Package, [switch]$Global, [array]$AdditionalArgs)
	if (!(scoop info $Package).Installed) {
		$scoopCmd = "scoop install $Package"
		if ($Global) { $scoopCmd += " -g" }
		if ($AdditionalArgs.Count -ge 1) {
			$AdditionalArgs = $AdditionalArgs -join ' '
			$scoopCmd += " $AdditionalArgs"
		}
		Invoke-Expression "$scoopCmd"
	}
}

function Install-WinGetApp {
	param ([string]$PackageID, [array]$AdditionalArgs, [string]$Source)

	winget list --exact -q $PackageID | Out-Null
	if (!$?) {
		$wingetCmd = "winget install $PackageID"
		if ($AdditionalArgs.Count -ge 1) {
			$AdditionalArgs = $AdditionalArgs -join ' '
			$wingetCmd += " $AdditionalArgs"
		}
		if ($Source -eq "msstore") { $wingetCmd += " --source msstore" }
		else { $wingetCmd += " --source winget" }
		Invoke-Expression "$wingetCmd"
	}
}

function Install-ChocoApp {
	param ([string]$Package, [string]$Version, [array]$AdditionalArgs)

	$chocoList = choco list $Package
	if ($chocoList -like "0 packages installed.") {
		$chocoCmd = "choco install $Package"
		if ($Version) {
			$pkgVer = "--version=$Version"
			$chocoCmd += " $pkgVer"
		}
		if ($AdditionalArgs.Count -ge 1) {
			$AdditionalArgs = $AdditionalArgs -join ' '
			$chocoCmd += " $AdditionalArgs"
		}
		Invoke-Expression "$chocoCmd"
	}
}

function Install-PowerShellModule {
	param ([string]$Module, [array]$AdditionalArgs)

	if (!(Get-InstalledModule -Name $Module -ErrorAction SilentlyContinue)) {
		if ($AdditionalArgs.Count -ge 1) {
			$AdditionalArgs = $AdditionalArgs -join ' '
			Invoke-Expression "Install-Module $Module $AdditionalArgs"
		} else { Invoke-Expression "Install-Module $Module" }
	}
}

function Install-AppFromGitHub {
	param ([string]$RepoName, [string]$FileName)

	$release = "https://api.github.com/repos/$RepoName/releases"
	$tag = (Invoke-WebRequest $release | ConvertFrom-Json)[0].tag_name
	$downloadUrl = "https://github.com/$RepoName/releases/download/$tag/$FileName"
	$downloadPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
	$downloadFile = "$downloadPath\$FileName"
	(New-Object System.Net.Client).DownloadFile($downloadUrl, $downloadFile)

	switch ($FileName.Split('.') | Select-Object -Last 1) {
		"exe" {
			Start-Process -FilePath "$downloadFile" -Wait
		}
		"msi" {
			Start-Process -FilePath "$downloadFile" -Wait
		}
		"zip" {
			$dest = "$downloadPath\$($FileName.Split('.'))"
			Expand-Archive -Path "$downloadFile" -DestinationPath "$dest"
		}
		"7z" {
			7z x -o"$downloadPath" -y "$downloadFile" | Out-Null
		}
		Default { break }
	}
	Remove-Item "$downloadFile" -Force -Recurse -ErrorAction SilentlyContinue
}

function Install-OnlineFile {
	param ([string]$OutputDir, [string]$Url)
	Invoke-WebRequest -Uri $Url -OutFile $OutputDir
}

function Refresh ([int]$Time) {
	if (Get-Command choco -ErrorAction SilentlyContinue) {

		switch -regex ($Time.ToString()) {
			'1(1|2|3)$' { $suffix = 'th'; break }
			'.?1$' { $suffix = 'st'; break }
			'.?2$' { $suffix = 'nd'; break }
			'.?3$' { $suffix = 'rd'; break }
			default { $suffix = 'th'; break }
		}

		if (!(Get-Module -ListAvailable -Name "chocoProfile" -ErrorAction SilentlyContinue)) {
			$chocoModule = "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1"
			if (Test-Path $chocoModule -PathType Leaf) {
				Import-Module $chocoModule
			}
		}
		Write-Verbose -Message "Refreshing environment variables from registry ($Time$suffix attempt)"
		refreshenv | Out-Null
	}
}

function Write-LockFile {
	param (
		[ValidateSet('winget', 'choco', 'scoop', 'modules')]
		[Alias('s', 'p')][string]$PackageSource,
		[Alias('f')][string]$FileName,
		[Alias('o')][string]$OutputPath = "$($(Get-Location).Path)"
	)

	$dest = "$OutputPath\$FileName"

	switch ($PackageSource) {
		"winget" {
			if (!(Get-Command winget -ErrorAction SilentlyContinue)) { return }
			winget export -o $dest | Out-Null
			if ($?) {
				Write-Host "Packages installed by WinGet are exported at " -NoNewline -ForegroundColor Green
				Write-Host "$dest" -ForegroundColor Yellow
			}
			Start-Sleep -Seconds 1
		}
		"choco" {
			if (!(Get-Command choco -ErrorAction SilentlyContinue)) { return }
			choco export $dest | Out-Null
			if ($?) {
				Write-Host "Packages installed by Chocolatey are exported at " -NoNewline -ForegroundColor Green
				Write-Host "$dest" -ForegroundColor Yellow
			}
			Start-Sleep -Seconds 1
		}
		"scoop" {
			if (!(Get-Command scoop -ErrorAction SilentlyContinue)) { return }
			scoop export -c > $dest
			if ($?) {
				Write-Host "Packages installed by Scoop are exported at " -NoNewline -ForegroundColor Green
				Write-Host "$dest" -ForegroundColor Yellow
			}
			Start-Sleep -Seconds 1
		}
		"modules" {
			Get-InstalledModule | Select-Object -Property Name, Version | ConvertTo-Json -Depth 100 | Out-File $dest
			if ($?) {
				Write-Host "PowerShell Modules installed are exported at " -NoNewline -ForegroundColor Green
				Write-Host "$dest" -ForegroundColor Yellow
			}
			Start-Sleep -Seconds 1
		}
	}
}

########################################################################################################################
###																					  						MAIN SCRIPT 		  																				 ###
########################################################################################################################
# set current working directory location
$currentLocation = "$($(Get-Location).Path)"

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

$i = 1

########################################################################################################################
###																												NERD FONTS																								 ###
########################################################################################################################
# install nerd fonts
''
Write-Verbose "Installing Nerd Fonts"
Write-Host "The following fonts are highly recommended: " -ForegroundColor Green
Write-Host "(Please skip this step if you already installed Nerd Fonts)" -ForegroundColor DarkGray
Write-Output "  ● Cascadia Code Nerd Font"
Write-Output "  ● FantasqueSansM Nerd Font"
Write-Output "  ● FiraCode Nerd Font"
Write-Output "  ● JetBrainsMono Nerd Font"
''
$installNerdFonts = $(Write-Host "[RECOMMENDED] Install NerdFont now? (y/N): " -NoNewline -ForegroundColor Magenta; Read-Host)
if ($installNerdFonts.ToUpper() -eq 'Y') {
	& ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Scope AllUsers -Confirm:$False
	Refresh ($i++)
} else { Write-Host "Skipped installing Nerd Fonts..." -ForegroundColor DarkGray; '' }

########################################################################################################################
###																											WINGET PACKAGES 																						 ###
########################################################################################################################
# Retrieve information from json file
$json = Get-Content "$PSScriptRoot\appList.json" -Raw | ConvertFrom-Json

# Winget Packages
$wingetItem = $json.installSource.winget
$wingetPkgs = $wingetItem.packageList
$wingetArgs = $wingetItem.additionalArgs
$wingetInstall = $wingetItem.autoInstall

if ($wingetInstall -eq $True) {
	if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
		# https://github.com/asheroto/winget-install
		Write-Verbose -Message "Installing winget-cli"
		&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
	}

	# Configure winget settings for better performance
	# Note that this will always overwrite existed winget settings file whenever you run this script
	$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
	$settingsJson = @'
{
		"$schema": "https://aka.ms/winget-settings.schema.json",

		// For documentation on these settings, see: https://aka.ms/winget-settings
		// "source": {
		//    "autoUpdateIntervalInMinutes": 5
		// },
		"visual": {
				"enableSixels": true,
				"progressBar": "rainbow"
		},
		"telemetry": {
				"disable": true
		},
		"experimentalFeatures": {
				"configuration03": true,
				"configureExport": true,
				"configureSelfElevate": true,
				"experimentalCMD": true
		},
		"network": {
				"downloader": "wininet"
		}
}
'@
	$settingsJson | Out-File $settingsPath -Encoding utf8

	# Download packages
	foreach ($pkg in $wingetPkgs) {
		$pkgId = $pkg.packageId
		$pkgSource = $pkg.packageSource
		if ($null -ne $pkgSource) {
			Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs -Source $pkgSource
		} else {
			Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs
		}
	}
	Write-LockFile -PackageSource winget -FileName wingetfile.json -OutputPath $PSScriptRoot
	Refresh ($i++)
}

########################################################################################################################
###																										CHOCOLATEY PACKAGES 											  									 ###
########################################################################################################################
# Chocolatey Packages
$chocoItem = $json.installSource.choco
$chocoPkgs = $chocoItem.packageList
$chocoArgs = $chocoItem.additionalArgs
$chocoInstall = $chocoItem.autoInstall

if ($chocoInstall -eq $True) {
	if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Verbose -Message "Installing chocolatey"
		if ((Get-ExecutionPolicy) -eq "Restricted") { Set-ExecutionPolicy AllSigned }
		Set-ExecutionPolicy Bypass -Scope Process -Force
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	}
	foreach ($pkg in $chocoPkgs) {
		$chocoPkg = $pkg.packageName
		$chocoVer = $pkg.packageVersion
		if ($null -ne $chocoVer) {
			Install-ChocoApp -Package $chocoPkg -Version $chocoVer -AdditionalArgs $chocoArgs
		} else {
			Install-ChocoApp -Package $chocoPkg -AdditionalArgs $chocoArgs
		}
	}
	Write-LockFile -PackageSource choco -FileName chocolatey.config -OutputPath $PSScriptRoot
	Refresh ($i++)
}

########################################################################################################################
###																					 						SCOOP PACKAGES 	 							 															 ###
########################################################################################################################
# Scoop Packages
$scoopItem = $json.installSource.scoop
$scoopBuckets = $scoopItem.bucketList
$scoopPkgs = $scoopItem.packageList
$scoopArgs = $scoopItem.additionalArgs
$scoopInstall = $scoopItem.autoInstall

if ($scoopInstall -eq $True) {
	if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
		# follow https://github.com/ScoopInstaller/Install#for-admin
		Write-Verbose -Message "Installing scoop"
		Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
	}

	# Configure aria2c task
	if (!(Get-Command aria2c -ErrorAction SilentlyContinue)) { scoop install aria2 }
	if (!($(scoop config aria2-enabled) -eq $True)) { scoop config aria2-enabled true }
	if (!($(scoop config aria2-warning-enabled) -eq $False)) { scoop config aria2-warning-enabled false }
	if (!(Get-ScheduledTaskInfo -TaskName "Aria2RPC" -ErrorAction Ignore)) {
		$scoopDir = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
		$Action = New-ScheduledTaskAction -Execute "$scoopDir\apps\aria2\current\aria2c.exe" -Argument "--enable-rpc --rpc-listen-all" -WorkingDirectory "$Env:USERPROFILE\Downloads"
		$Trigger = New-ScheduledTaskTrigger -AtStartup
		$Principal = New-ScheduledTaskPrincipal -UserID "$Env:USERDOMAIN\$Env:USERNAME" -LogonType S4U
		$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
		Register-ScheduledTask -TaskName "Aria2RPC" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
	}

	foreach ($bucket in $scoopBuckets) {
		$bucketName = $bucket.bucketName
		$bucketRepo = $bucket.bucketRepo
		if ($null -ne $bucketRepo) {
			Add-ScoopBucket -BucketName $bucketName -BucketRepo $bucketRepo
		} else {
			Add-ScoopBucket -BucketName $bucketName
		}
	}
	foreach ($pkg in $scoopPkgs) {
		$pkgName = $pkg.packageName
		$pkgScope = $pkg.packageScope
		if (($null -ne $pkgScope) -and ($pkgScope -eq "global")) { $Global = $True } else { $Global = $False }
		if ($null -ne $scoopArgs) {
			Install-ScoopApp -Package $pkgName -Global:$Global -AdditionalArgs $scoopArgs
		} else {
			Install-ScoopApp -Package $pkgName -Global:$Global
		}
	}
	Write-LockFile -PackageSource scoop -FileName scoopfile.json -OutputPath $PSScriptRoot
	Refresh ($i++)
}

########################################################################################################################
###																										POWERSHELL MODULES 																						 ###
########################################################################################################################
# Powershell Modules
$moduleItem = $json.powershellModule
$moduleList = $moduleItem.moduleList
$moduleArgs = $moduleItem.additionalArgs
$moduleInstall = $moduleItem.install
if ($moduleInstall -eq $True) {
	foreach ($module in $moduleList) { Install-PowerShellModule -Module $module -AdditionalArgs $moduleArgs }
	Write-LockFile -PackageSource modules -FileName modules.json -OutputPath $PSScriptRoot
	Refresh ($i++)
}

########################################################################################################################
###																												GIT SETUP																									 ###
########################################################################################################################
# Configure git
if (Get-Command git -ErrorAction SilentlyContinue) {
	$gitUserName = (git config user.name)
	$gitUserMail = (git config user.email)

	if ($null -eq $gitUserName) { $gitUserName = $(Write-Host "Input your git name: " -NoNewline -ForegroundColor Magenta; Read-Host) }
	if ($null -eq $gitUserMail) { $gitUserMail = $(Write-Host "Input your git email: " -NoNewline -ForegroundColor Magenta; Read-Host) }

	git submodule update --init --recursive
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
	if (!(gh auth status)) { gh auth login }
}

########################################################################################################################
###																													SYMLINKS 																								 ###
########################################################################################################################
# symlinks
$symlinks = @{
	$PROFILE.CurrentUserAllHosts                                                                  = ".\Profile.ps1"
	"$Env:APPDATA\bat"                                                                            = ".\config\bat"
	"$Env:APPDATA\Code\User\keybindings.json"                                                     = ".\vscode\keybindings.json"
	"$Env:APPDATA\Code\User\settings.json"                                                        = ".\vscode\settings.json"
	"$Env:LOCALAPPDATA\fastfetch"                                                                 = ".\config\fastfetch"
	"$Env:LOCALAPPDATA\lazygit"                                                                   = ".\config\lazygit"
	"$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows\settings.json"
	"$HOME\.bash_profile"                                                                         = ".\home\.bash_profile"
	"$HOME\.bashrc"                                                                               = ".\home\.bashrc"
	"$HOME\.config\bash"                                                                          = ".\config\bash"
	"$HOME\.config\delta"                                                                         = ".\config\delta"
	"$HOME\.config\eza"                                                                           = ".\config\eza"
	"$HOME\.config\gh-dash"                                                                       = ".\config\gh-dash"
	"$HOME\.config\komorebi"                                                                      = ".\config\komorebi"
	"$HOME\.config\npm"                                                                           = ".\config\npm"
	"$HOME\.config\spotify-tui"                                                                   = ".\config\spotify-tui"
	"$HOME\.config\whkdrc"                                                                        = ".\config\whkdrc"
	"$HOME\.config\yasb"                                                                          = ".\config\yasb"
	"$HOME\.config\yazi"                                                                          = ".\config\yazi"
	"$HOME\.czrc"                                                                                 = ".\home\.czrc"
	"$HOME\.gitconfig"                                                                            = ".\home\.gitconfig"
	"$HOME\.inputrc"                                                                              = ".\home\.inputrc"
	"$HOME\.wslconfig"                                                                            = ".\home\.wslconfig"
}

# add symlinks
foreach ($symlink in $symlinks.GetEnumerator()) {
	Write-Verbose -Message "Creating symlink for $(Resolve-Path $symlink.Value) --> $($symlink.Key)"
	Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}
Refresh ($i++)

# Set the right git name and email for the user after symlinking
if (Get-Command git -ErrorAction SilentlyContinue) {
	git config --global user.name $gitUserName
	git config --global user.email $gitUserMail
}

########################################################################################################################
###																									ENVIRONMENT VARIABLES																						 ###
########################################################################################################################
# add environment variables
$envVars = $json.environmentVariables
foreach ($env in $envVars) {
	$envCommand = $env.commandName
	$envKey = $env.environmentKey
	$envValue = $env.environmentValue
	if (Get-Command $envCommand -ErrorAction SilentlyContinue) {
		if (![System.Environment]::GetEnvironmentVariable("$envKey")) {
			Write-Verbose "Set environment variable of $envCommand`: $envKey -> $envValue"
			try {
				[System.Environment]::SetEnvironmentVariable("$envKey", "$envValue", "User")
			} catch {
				Write-Error -ErrorAction Stop "An error occurred: $_"
			}
		}
	}
}
Refresh ($i++)

########################################################################################################################
###																		SETUP NODEJS / INSTALL NVM (Node Version Manager)															 ###
########################################################################################################################
if (!(Get-Command nvm -ErrorAction SilentlyContinue)) {
	$installNvm = $(Write-Host "Install NVM? (y/N) " -ForegroundColor Magenta -NoNewline; Read-Host)
	if ($installNvm.ToUpper() -eq 'Y') {
		Write-Verbose "Installing NVM from GitHub Repo"
		Install-AppFromGitHub -RepoName "coreybutler/nvm-windows" -FileName "nvm-setup.exe"
	}
	Refresh ($i++)
}

if (Get-Command nvm -ErrorAction SilentlyContinue) {
	if (!(Get-Command node -ErrorAction SilentlyContinue)) {
		$whichNode = $(Write-Host "Install LTS (y) or latest (N) Node version? " -ForegroundColor Magenta -NoNewline; Read-Host)
		if ($whichNode.ToUpper() -eq 'Y') {	nvm install lts }
		else { nvm install latest }
		nvm use newest
		npm install -g npm@latest yarn@latest pnpm@latest bun@latest npm-check-updates@latest
	}
}


########################################################################################################################
###																										ADDONS / PLUGINS																							 ###
########################################################################################################################
# plugins / extensions / addons
$pluginItems = $json.package_plugins
foreach ($plugin in $pluginItems) {
	$p = [PSCustomObject]@{
		CommandName   = $plugin.command_name
		InvokeCommand = $plugin.invoke_command
		CheckCommand  = $plugin.check_command
		List          = [array]$plugin.plugins
		InstallOrNot  = $plugin.install
	}

	if ($p.InstallOrNot -eq $True) {
		if (Get-Command "$($p.CommandName)" -ErrorAction SilentlyContinue) {
			foreach ($pkg in $($p.List)) {
				if (!(Invoke-Expression "$($p.CheckCommand)" | Select-String "$pkg")) {
					Write-Verbose "Executing: $($p.InvokeCommand) $pkg"
					Invoke-Expression "$($p.InvokeCommand) $pkg"
				}
			}
		}
	}
}
Refresh ($i++)

########################################################################################################################
###																										VSCODE EXTENSIONS																							 ###
########################################################################################################################
# VSCode Extensions
if (Get-Command code -ErrorAction SilentlyContinue) {
	$extensionList = Get-Content "$PSScriptRoot\vscode\extensions.list"
	foreach ($ext in $extensionList) {
		if (!(code --list-extensions | Select-String "$ext")) {
			Write-Verbose -Message "Installing VSCode Extension: $ext"
			Invoke-Expression "code --install-extension $ext"
		}
	}
}

########################################################################################################################
###																										CATPPUCCIN THEMES 								 														 ###
########################################################################################################################
# Catppuccin Themes
$catppuccinThemes = @('Frappe', 'Latte', 'Macchiato', 'Mocha')

# FLowlauncher themes
$flowLauncherDir = "$env:LOCALAPPDATA\FlowLauncher"
if (Test-Path "$flowLauncherDir" -PathType Container) {
	$flowLauncherThemeDir = "$flowLauncherDir\Themes"
	$catppuccinThemes | ForEach-Object {
		if (!(Test-Path "$flowLauncherThemeDir\Catppuccin $_.xaml" -PathType Leaf)) {
			Write-Verbose "Adding file: `"Catppuccin $_.xaml`" to $flowLauncherThemeDir."
			Install-OnlineFile -OutputDir "$flowLauncherThemeDir" -Url "https://raw.githubusercontent.com/catppuccin/flow-launcher/refs/heads/main/themes/Catppuccin%20$_.xaml"
		}
	}
}

# add btop theme
# since we install btop by scoop, then the application folder would be in scoop directory
if (Get-Command btop -ErrorAction SilentlyContinue) {
	$scoopDir = (Get-Command scoop.ps1).Source | Split-Path | Split-Path
	$btopThemeDir = "$scoopDir\apps\btop\current\themes"
	$catppuccinThemes = $catppuccinThemes.ToLower()
	$catppuccinThemes | ForEach-Object {
		if (!(Test-Path "$btopThemeDir\catppuccin_$_.theme" -PathType Leaf)) {
			Write-Verbose "Adding file: catppuccin_$_.theme to $btopThemeDir."
			Install-OnlineFile -OutputDir "$btopThemeDir" -Url "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/catppuccin_$_.theme"
		}
	}
}

########################################################################################################################
###																										START KOMOREBI + YASB																					 ###
########################################################################################################################
# start komorebi
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
	if ((!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) -and (!(Get-Process -Name whkd -ErrorAction SilentlyContinue))) {
		Write-Verbose "Starting Komorebi with WHKD"
		Invoke-Expression "komorebic start --whkd"
	}
}

# start yasb
if (Get-Command yasb -ErrorAction SilentlyContinue) {
	if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
		Write-Verbose "Starting YASB Status Bar"
		# Ensure the correct path to `yasb.exe` file
		$yasbPath = (Get-Command yasb -ErrorAction SilentlyContinue).Source
		if (Get-Command yasbc -ErrorAction SilentlyContinue) {
			Invoke-Expression "yasbc start"
		} elseif (Test-Path -Path "$yasbPath") {
			Start-Process -FilePath $yasbPath -Wait
		}
	}
}

# yazi plugins
if (Get-Command ya -ErrorAction SilentlyContinue) {
	Write-Verbose "Installing yazi plugins / themes"
	ya pack -i >$null 2>&1
	ya pack -u >$null 2>&1
}

# bat build theme
if (Get-Command bat -ErrorAction SilentlyContinue) {
	Write-Verbose "Building bat theme"
	bat cache --clear >$null 2>&1
	bat cache --build >$null 2>&1
}

########################################################################################################################
###																								WINDOWS SUBSYSTEMS FOR LINUX																			 ###
########################################################################################################################
if (!(Get-Command wsl -CommandType Application -ErrorAction Ignore)) {
	Write-Verbose -Message "Installing Windows SubSystems for Linux..."
	Start-Process -FilePath "PowerShell" -ArgumentList "wsl", "--install" -Verb RunAs -Wait -WindowStyle Hidden
}


########################################################################################################################
###																												END SCRIPT																								 ###
########################################################################################################################
Set-Location $currentLocation
Start-Sleep -Seconds 5

''
Write-Host "┌────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "│        █████╗ ██╗     ██╗         ██████╗  ██████╗ ███╗   ██╗███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██╗██║     ██║         ██╔══██╗██╔═══██╗████╗  ██║██╔════╝ ██║      │" -ForegroundColor "Green"
Write-Host "│       ███████║██║     ██║         ██║  ██║██║   ██║██╔██╗ ██║█████╗   ██║      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██║██║     ██║         ██║  ██║██║   ██║██║╚██╗██║██╔══╝   ╚═╝      │" -ForegroundColor "Green"
Write-Host "│       ██║  ██║███████╗███████╗    ██████╔╝╚██████╔╝██║ ╚████║███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═╝      │" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "└────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor "Green"

''
Write-Host "For more information, please visit: " -NoNewline
Write-Host "https://github.com/jacquindev/windots" -ForegroundColor Blue
Write-Host "- Submit an issue via: " -NoNewline -ForegroundColor DarkGray
Write-Host "https://github.com/jacquindev/windots/issues/new" -ForegroundColor Blue
Write-Host "- Contact me via email: " -NoNewline -ForegroundColor DarkGray
Write-Host "jacquindev@outlook.com" -ForegroundColor Blue
