#requires -Version 7
#requires -RunAsAdministrator

$VerbosePreference = "SilentlyContinue"

Write-Host "Start setup process..." -ForegroundColor Blue
$currentLocation = "$($(Get-Location).Path)"

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
			scoop export > $dest
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

# set current working directory location
Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

$i = 1
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
$wingetArgs = $wingetItem.additional_args
$wingetInstall = $wingetItem.auto_install

$scoopItem = $json.package_source.scoop
$scoopBuckets = $scoopItem.buckets
$scoopPkgs = $scoopItem.packages
$scoopArgs = $scoopItem.additional_args
$scoopInstall = $scoopItem.auto_install

$chocoItem = $json.package_source.choco
$chocoPkgs = $chocoItem.packages
$chocoArgs = $chocoItem.additional_args
$chocoInstall = $chocoItem.auto_install

$moduleItem = $json.powershell_modules
$moduleList = $moduleItem.modules
$moduleArgs = $moduleItem.additional_args
$moduleInstall = $moduleItem.install

if ($wingetArgs.Count -ge 1) { $wingetArgs = $wingetArgs -join ' ' } else { $wingetArgs = $null }
if ($scoopArgs.Count -ge 1) { $scoopArgs = $scoopArgs -join ' ' } else { $scoopArgs = $null }
if ($chocoArgs.Count -ge 1) { $chocoArgs = $chocoArgs -join ' ' } else { $chocoArgs = $null }
if ($moduleArgs.Count -ge 1) { $moduleArgs = $moduleArgs -join ' ' } else { $moduleArgs = $null }

$tasks = @()

if (Get-Command git -ErrorAction SilentlyContinue) {
	$gitUserName = (git config --global user.name)
	$gitUserMail = (git config --global user.email)

	if ($null -eq $gitUserName) { $gitUserName = $(Write-Host "Input your git name: " -NoNewline -ForegroundColor Magenta; Read-Host) }
	if ($null -eq $gitUserMail) { $gitUserMail = $(Write-Host "Input your git email: " -NoNewline -ForegroundColor Magenta; Read-Host) }

	git submodule update --init --recursive
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
	if (!(gh auth status)) { gh auth login }
}

# install nerd fonts
''
Write-Host "The following fonts are highly recommended: " -ForegroundColor Green
Write-Host "(Please skip this step if you already installed Nerd Fonts)" -ForegroundColor DarkGray
Write-Output "  ● Cascadia Code Nerd Font"
Write-Output "  ● FantasqueSansM Nerd Font"
Write-Output "  ● FiraCode Nerd Font"
Write-Output "  ● JetBrainsMono Nerd Font"
''
$installNerdFonts = $(Write-Host "[RECOMMENDED] Install NerdFont now? (Y/n): " -NoNewline -ForegroundColor Magenta; Read-Host)
if ($installNerdFonts.ToUpper() -eq 'Y') {
	& ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Scope AllUsers -Confirm:$False
	Refresh ($i++)
} else { Write-Host "Skipped installing Nerd Fonts" -ForegroundColor DarkGray; '' }

if (!(Get-Command nvm -ErrorAction SilentlyContinue)) {
	$installNvm = $(Write-Host "Install NVM? (Y/n) " -ForegroundColor Magenta -NoNewline; Read-Host)
	if ($installNvm.ToUpper() -eq 'Y') {
		$repo = "coreybutler/nvm-windows"
		$file = "nvm-setup.exe"
		$releases = "https://api.github.com/repos/$repo/releases"
		$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
		$downloadUrl = "https://github.com/$repo/releases/download/$tag/$file"
		$downloadPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

		Write-Verbose -Message "Downloading nvm-setup.exe from $downloadUrl"
		$downloadPath = "$downloadPath\$file"
		(New-Object System.Net.Client).DownloadFile($downloadUrl, $downloadPath)
		Start-Process -FilePath "$downloadPath"
	}
}

if (Get-Command nvm -ErrorAction SilentlyContinue) {
	if (!(Get-Command node -ErrorAction SilentlyContinue)) {
		$tasks += "nvm install lts"
		$tasks += "nvm use lts"
		$tasks += "npm install -g npm@latest"
		$tasks += "corepack prepare --activate pnpm@latest"
		$tasks += "corepack prepare --activate yarn@latest"
		$tasks += "corepack enable"
	}
	if (!(Get-Command bun -ErrorAction SilentlyContinue)) {
		$useBun = $(Write-Host "Install 'bun'? (Y/n): " -ForegroundColor Magenta -NoNewline; Read-Host)
		if ($useBun.ToUpper() -eq 'Y') { $tasks += "pnpm install -g bun" }
	}
}

# add symlinks
foreach ($symlink in $symlinks.GetEnumerator()) {
	Write-Verbose -Message "Creating symlink for $(Resolve-Path $symlink.Value) --> $($symlink.Key)"
	Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

# add environment variables
$envVar = $json.environment_variables
foreach ($env in $envVar) {
	if (Get-Command $($env.command) -ErrorAction SilentlyContinue) {
		if (!([System.Environment]::GetEnvironmentVariable("$($env.name)"))) {
			Write-Verbose -Message "Setting up environment variable for $($env.name) --> $($env.value)"
			[System.Environment]::SetEnvironmentVariable("$($env.name)", "$($env.value)", "User")
			if ($LASTEXITCODE -ne 0) { Write-Error -ErrorAction Stop "An error occurred while creating environment variable with value $($env.value)" }
		}
	}
}

$totalPkgs = @()
switch ($True) {
	($wingetInstall -eq $True) {
		if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
			# https://github.com/asheroto/winget-install
			Write-Verbose -Message "Installing winget-cli"
			&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
		}
		$totalPkgs += $wingetPkgs
	}
	($chocoInstall -eq $True) {
		if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
			# https://chocolatey.org/install
			Write-Verbose -Message "Installing chocolatey"
			if ((Get-ExecutionPolicy) -eq "Restricted") { Set-ExecutionPolicy AllSigned }
			Set-ExecutionPolicy Bypass -Scope Process -Force
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
		}
		$totalPkgs += $chocoPkgs
	}
	($scoopInstall -eq $True) {
		if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
			# follow https://github.com/ScoopInstaller/Install#for-admin
			Write-Verbose -Message "Installing scoop for admin https://github.com/ScoopInstaller/Install#for-admin"
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
		}
		$totalPkgs += $scoopBuckets + $scoopPkgs
	}
	($moduleInstall -eq $True) {	$totalPkgs += $moduleList }
	Default { continue }
}

foreach ($pkg in $totalPkgs) {
	switch ($True) {
		($pkg -in $wingetPkgs) {
			if (!(winget list --exact --accept-source-agreements -q "$pkg" | Select-String "$pkg")) {
				if ($null -ne $wingetArgs) { $tasks += "winget install $wingetArgs $pkg --source winget" }
				else { $tasks += "winget install $pkg --source winget" }
			}
		}
		($pkg -in $chocoPkgs) {
			if (!(choco list | Select-String "$pkg")) {
				if ($null -ne $chocoArgs) { $tasks += "choco install $pkg $chocoArgs" }
				else { $tasks += "choco install $pkg" }
			}
		}
		($pkg -in $scoopBuckets) {
			if ($scoopBuckets.Count -ge 1) {
				$scoopDir = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
				if (!(Test-Path "$scoopDir\buckets\$pkg" -PathType Container)) {
					$tasks += "scoop bucket add $pkg"
				}
			}
		}
		($pkg -in $scoopPkgs) {
			if (!(scoop info $pkg).Installed) {
				if ($null -ne $scoopArgs) { $tasks += "scoop install $pkg $scoopArgs" }
				else { $tasks += "scoop install $pkg" }
			}
		}
		($pkg -in $moduleList) {
			if (!(Get-InstalledModule -Name $pkg -ErrorAction SilentlyContinue)) {
				if ($null -ne $moduleArgs) { $tasks += "Install-Module $pkg $moduleArgs" }
				else { $tasks += "Install-Module $pkg" }
			}
		}
		Default { continue }
	}
}

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
			foreach ($pg in $($p.List)) {
				if (!(Invoke-Expression "$($p.CheckCommand)" | Select-String "$pg")) {
					$tasks += "$($p.InvokeCommand) $pg"
				}
			}
		}
	}
}

# Export lock files
''
Write-LockFile -PackageSource winget -FileName wingetfile.json -OutputPath $PSScriptRoot
Write-LockFile -PackageSource scoop -FileName scoopfile.json -OutputPath $PSScriptRoot
Write-LockFile -PackageSource choco -FileName chocolatey.config -OutputPath $PSScriptRoot
Write-LockFile -PackageSource modules -FileName modules.json -OutputPath $PSScriptRoot


if (Get-Command code -ErrorAction SilentlyContinue) {
	$extensionList = Get-Content "$PSScriptRoot\vscode\extensions.list"
	foreach ($ext in $extensionList) {
		if (!(code --list-extensions | Select-String "$ext")) {
			Write-Verbose -Message "Installing VSCode Extension: $ext"
			$tasks += "code --install-extension $ext"
		}
	}
}

if (Get-Command spicetify -ErrorAction SilentlyContinue) {
	if (!(Test-Path "$env:APPDATA\spicetify\CustomApps\marketplace")) {
		$marketplaceInstallUrl = "https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1"
		$tasks += "Invoke-WebRequest -UseBasicParsing $marketplaceInstallUrl"
	}
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
	$tasks += "bat cache --clear"
	$tasks += "bat cache --build"
}

# Catppuccin Themes: https://github.com/catppuccin/catppuccin
$catppuccinThemes = @('Frappe', 'Latte', 'Macchiato', 'Mocha')
# add flowlauncher themes
$flowLauncherDir = "$env:LOCALAPPDATA\FlowLauncher"
if (Test-Path "$flowLauncherDir" -PathType Container) {
	$flowLauncherThemeDir = "$flowLauncherDir\Themes"
	$catppuccinThemes | ForEach-Object {
		if (!(Test-Path "$flowLauncherThemeDir\Catppuccin $_.xaml" -PathType Leaf)) {
			$flowLauncherThemeUrl = "https://raw.githubusercontent.com/catppuccin/flow-launcher/refs/heads/main/themes/Catppuccin%20$_.xaml"
			$tasks += Invoke-WebRequest -Uri $flowLauncherThemeUrl -OutFile $flowLauncherThemeDir
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
			$btopThemeUrl = "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/catppuccin_$_.theme"
			$tasks += "Invoke-WebRequest -Uri $btopThemeUrl -OutFile $btopThemeDir"
		}
	}
}

# start komorebi
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
	if ((!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) -and (!(Get-Process -Name whkd -ErrorAction SilentlyContinue))) {
		$tasks += "komorebic start --whkd"
	}
}

# start yasn
if (Get-Command yasb -ErrorAction SilentlyContinue) {
	if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
		$yasbPath = "$Env:ProgramFiles\Yasb\yasb.exe"
		if (Test-Path -Path "$yasbPath") { $tasks += "Start-Process -FilePath $yasbPath" }
	}
}

##### RUN TASKS #####
$t = 1
$totalTasks = $tasks.Count
foreach ($task in $tasks) {
	try {
		Write-Verbose -Message "Invoking command: $task"
		Invoke-Expression $task | Out-Null
		Refresh ($i++)
	} catch {
		Write-Error -ErrorAction Stop "An error occurred: $_"
	}
	[long]$percent = ($t / $totalTasks) * 100
	Write-Progress -Activity "Setting up Windows" -Status "$percent% $task" -PercentComplete $percent
	$t++
}

# reload git
if (Get-Command git -ErrorAction SilentlyContinue) {
	git config --global --unset user.email >$null 2>&1
	git config --global --unset user.name >$null 2>&1
	git config --global user.name $gitUserName >$null 2>&1
	git config --global user.email $gitUserMail >$null 2>&1
}

# yazi plugins
if (Get-Command ya -ErrorAction SilentlyContinue) {
	Write-Verbose -Message "Installing and updating yazi plugins"
	ya pack -i >$null 2>&1
	ya pack -u >$null 2>&1
}

# wsl enable
if ((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" }).State -eq "Disabled") {
	Write-Verbose -Message "Enable Windows Feature: Windows Subsystem for Linux"
	Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
}
if ((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "VirtualMachinePlatform" }).State -eq "Disabled") {
	Write-Verbose -Message "Enable Windows Feature: Virtual Machine Platform"
	Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
}

# Export lock files (packages installed)
function Write-LockFile {
	param (
		[ValidateSet('winget', 'choco', 'scoop')]
		[Alias('s', 'p')][string]$PackageSource,
		[Alias('f')][string]$FileName,
		[Alias('o')][string]$OutputPath = "$($(Get-Location).Path)"
	)

	$dest = "$OutputPath\$FileName"

	switch ($PackageSource) {
		"winget" {
			if (!(Get-Command winget -ErrorAction SilentlyContinue)) { return }
			winget export -o $dest | Out-Null
		}
		"choco" {
			if (!(Get-Command choco -ErrorAction SilentlyContinue)) { return }
			choco export $dest | Out-Null
		}
		"scoop" {
			if (!(Get-Command scoop -ErrorAction SilentlyContinue)) { return }
			scoop export > $dest
		}
	}
}
Write-LockFile -PackageSource winget -FileName winget.lock.json -OutputPath $PSScriptRoot

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
