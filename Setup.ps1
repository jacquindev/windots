#requires -Version 7
#requires -RunAsAdministrator

Write-Host "Start setup process..." -ForegroundColor DarkGray
$currentLocation = "$($(Get-Location).Path)"

# set current working directory location
Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

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

# Retrieve information from json file
$json = Get-Content "$PSScriptRoot\appList.json" -Raw | ConvertFrom-Json

$wingetItem = $json.package_source.winget
$wingetPkgs = $wingetItem.packages
$wingetInstall = $wingetItem.auto_install

$scoopItem = $json.package_source.scoop
$scoopBuckets = $scoopItem.buckets
$scoopPkgs = $scoopItem.packages
$scoopInstall = $scoopItem.auto_install

$chocoItem = $json.package_source.choco
$chocoPkgs = $chocoItem.packages
$chocoInstall = $chocoItem.auto_install

$moduleItem = $json.powershell_modules
$moduleList = $moduleItem.modules
$moduleInstall = $moduleItem.install

# Apps installation
$totalPkgs = @()
switch ($true) {
	{ $wingetInstall } {
		$wingetExists = Get-Command winget -ErrorAction SilentlyContinue
		if (!$wingetExists) {
			&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
		}
		$totalPkgs += $wingetPkgs
	}
	{ $scoopInstall } {
		$scoopExists = Get-Command scoop -ErrorAction SilentlyContinue
		if (!$scoopExists) {
			# follow https://github.com/ScoopInstaller/Install#for-admin
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
		}
		$totalPkgs += $scoopPkgs + $scoopBuckets
	}
	{ $chocoInstall } {
		$chocoExists = Get-Command choco -ErrorAction SilentlyContinue
		if (!$chocoExists) {
			# instructions on: https://chocolatey.org/install
			Set-ExecutionPolicy Bypass -Scope Process -Force
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
		}
		$totalPkgs += $chocoPkgs
	}
	{ $moduleInstall } { $totalPkgs += $moduleList }
}

$i = 1
$totalCount = $totalPkgs.Count
foreach ($pkg in $totalPkgs) {
	switch ($true) {
		{ $pkg -in $wingetPkgs } {
			if (!(winget list --exact --accept-source-agreements -q "$pkg" | Select-String "$pkg")) {
				try {	winget install --exact --silent --accept-package-agreements --accept-source-agreements "$pkg" --source winget > $null 2>&1 }
				catch {	Write-Error -ErrorAction Stop "An error occurred while installing $pkg"	}
			}
		}

		{ $pkg -in $scoopBuckets } {
			$bucketPath = "$HOME\scoop\buckets"
			if (!(Test-Path "$bucketPath\$pkg" -PathType Container)) {
				try {	scoop bucket add $pkg >$null 2>&1 }
				catch { Write-Error -ErrorAction Stop "An error occurred while adding $pkg" }
			}
		}
		{ $pkg -in $scoopPkgs } {
			if (!(scoop info $pkg).Installed) {
				try { scoop install $pkg >$null 2>&1	}
				catch { Write-Error -ErrorAction Stop "An error occurred while installing $pkg" }
			}
		}

		# Chocolatey packages
		{ $pkg -in $chocoPkgs } {
			if (!(choco list | Select-String "$pkg")) {
				try {	choco install $pkg -y >$null 2>&1	}
				catch { Write-Error -ErrorAction Stop "An error occurred while installing $pkg" }
			}
		}

		{ $pkg -in $moduleList } {
			if (!(Get-Module -ListAvailable -Name $pkg -ErrorAction SilentlyContinue)) {
				try {	Install-Module -Name $pkg -Scope CurrentUser -AllowClobber -Force }
				catch { Write-Error -ErrorAction Stop "An error occurred while installing module $pkg" }
			}
		}
	}

	[int]$percent = ($i / $totalCount) * 100
	Write-Progress -Activity "Installing packages" -Status "$percent% Complete: $pkg" -PercentComplete $percent
	$i++
}

# setup git
if (Get-Command git -ErrorAction SilentlyContinue) {
	$gitUserName = (git config --global user.name)
	$gitUserMail = (git config --global user.email)

	if ($null -eq $gitUserName) { $gitUserName = $(Write-Host "Input your git name: " -NoNewline -ForegroundColor Green; Read-Host) }
	if ($null -eq $gitUserMail) { $gitUserMail = $(Write-Host "Input your git email: " -NoNewline -ForegroundColor Green; Read-Host) }
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
	if (!(Test-Path "$env:APPDATA\GitHub CLI\hosts.yml")) { gh auth login }
}

# install nerd fonts
''; $installNerdFonts = $(Write-Host "[RECOMMENDED] Install NerdFont now? (Y/n): " -NoNewline -ForegroundColor Magenta; Read-Host)
if ($installNerdFonts.ToUpper() -eq 'Y') {
	& ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Scope AllUsers
}

# add symlinks
foreach ($symlink in $symlinks.GetEnumerator()) {
	Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

# environment variables
foreach ($env in $envVars) {
	$envVarCmd = $env.command
	$envVarValue = $env.value
	$envVarPath = $env.path

	if (Get-Command $envVarCmd -ErrorAction SilentlyContinue) {
		if (!([System.Environment]::GetEnvironmentVariable("$envVarValue"))) {
			[System.Environment]::SetEnvironmentVariable("$envVarValue", "$envVarPath", "User")
			if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while creating environment variable with value $envVarValue" }
		}
	}
}

# refresh environment (from chocolatey)
if (Test-Path "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1" -PathType Leaf) {
	Import-Module "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1"
	refreshenv | Out-Null
	if ($LASTEXITCODE -eq 0) { ''; Write-Host -ErrorAction Stop "Refreshed environment variables from the registry. (1st try)" }
}

# reload git
if (Get-Command git -ErrorAction SilentlyContinue) {
	git submodule update --init --recursive
	git config --global --unset user.email >$null 2>&1
	git config --global --unset user.name >$null 2>&1
	git config --global user.name $gitUserName >$null 2>&1
	git config --global user.email $gitUserMail >$null 2>&1
}

# install nodejs & bun
if ((Get-Command nvm -ErrorAction SilentlyContinue)) {
	if (!(Get-Command node -ErrorAction SilentlyContinue)) {
		nvm install lts >$null 2>&1
		nvm use lts
	}
	if (!(Get-Command bun -ErrorAction SilentlyContinue)) {
		$useBun = $(Write-Host "Install 'bun'? (Y/n): " -ForegroundColor Magenta -NoNewline; Read-Host)
		if ($useBun.ToUpper() -eq 'Y') { npm install -g bun }
	}
}

# reload bat configuration
if (Get-Command bat -ErrorAction SilentlyContinue) {
	bat cache --clear >$null 2>&1
	bat cache --build >$null 2>&1
}

# add-ons
$pluginItems = $json.package_plugins
foreach ($plugin in $pluginItems) {
	$p = [PSCustomObject]@{
		CommandName   = $plugin.name
		InvokeCommand = $plugin.invoke_command
		CheckCommand  = $plugin.check_command
		List          = [array]$plugin.plugins.plugin_full_name
		InstallOrNot  = $plugin.install
	}

	if ($p.InstallOrNot -eq $True) {
		if (!(Get-Command $($p.CommandName) -ErrorAction SilentlyContinue)) {
			Write-Warning "Command not found: $($p.CommandName). Please install to continue."; return
		}

		foreach ($plug in $($p.List)) {
			if (!(Invoke-Expression "$($p.CheckCommand)" | Select-String "$plug")) {
				Invoke-Expression "$($p.InvokeCommand) $plug"
				if ($LASTEXITCODE -ne 0) { Write-Error -Entry1 "$plug" -Text "is unable to install." }
			}
		}
	}
}

# add spicetify marketplace for spotify
if (Get-Command spicetify -ErrorAction SilentlyContinue) {
	if (!(Test-Path "$env:APPDATA\spicetify\CustomApps\marketplace")) {
		for ($i = 1; $i -le 100; $i++) {
			Write-Progress -Activity "Installing spicetify marketplace" -Status "$i% Complete:" -PercentComplete $i
			Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1" | Invoke-Expression | Out-Null
			if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while installing spicetify's marketplace." }
		}
	}
}

# vscode extensions
if (Get-Command code -ErrorAction SilentlyContinue) {
	$extensionList = Get-Content "$PSScriptRoot\vscode\extensions.list"
	$e = 1
	$extCount = $extensionList.Count
	foreach ($ext in $extensionList) {
		if (!(code --list-extensions | Select-String "$ext")) {
			code --install-extension $ext >$null 2>&1
			if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while install vscode's extension $ext." }
		}
		[int]$epercent = ($e / $extCount) * 100
		Write-Progress -Activity "Installing VS Code extensions" -Status "$epercent% Complete: $ext" -PercentComplete $epercent
		$e++
	}
}

# wsl enable
if ((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" }).State -eq "Disabled") {
	Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
}
if ((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "VirtualMachinePlatform" }).State -eq "Disabled") {
	Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
}

# start komorebi
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
	if (!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) {
		& komorebic start --whkd >$null 2>&1
		if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while starting komorebi with whkd." }
	}
}

# start yasb
if (Get-Command yasb -ErrorAction SilentlyContinue) {
	if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
		$yasbPath = "$Env:ProgramFiles\Yasb\yasb.exe"
		if (Test-Path -Path "$yasbPath") {
			Start-Process -FilePath $yasbPath > $null 2>&1
			if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while starting YASB." }
		}
	}
}

# refresh environment (from chocolatey)
if (Test-Path "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1" -PathType Leaf) {
	Import-Module "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1"
	refreshenv | Out-Null
	if ($LASTEXITCODE -eq 0) { ''; Write-Host -ErrorAction Stop "Refreshed environment variables from the registry. (2st try)" }
}


''; Start-Sleep -Seconds 3; Set-Location $currentLocation

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
