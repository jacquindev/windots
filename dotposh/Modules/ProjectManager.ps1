<#
.SYNOPSIS
	Create/Initialize a project.
.DESCRIPTION
	- Create new GitHub repo (private) with your project name
	- Clone your project repo locally
	- Initialize your project with tools:
		- Node (npm | pnpm | yarn)
		- Python (poetry | PDM | hatch | rye) & activate virtual environment
		- Rust (cargo)
	- Add .gitignore file with template source from: https://www.toptal.com/developers/gitignore
	- Add LICENSE for your project
	- Add README.md for your project
	- Open your project directory in VSCode
.PARAMETER ProjectName
	Alias (-n | --name)
	- Specify your project's name. This will be the name of your project's folder and GitHub Repo
.PARAMETER Language
	Alias (-l | --lang)
	- Specify your project's main language. This will add common related language files for your project
	- Initialize your project will tools as above (see DESCRIPTION)
.PARAMETER AuthorName
	Alias (-a | --author)
	- Default value is your global gitconfig user.name
.EXAMPLE
	> Initialize-Project -ProjectName MyNewProject -Language python

	This will create a private GitHub repository named 'MyNewProject' and add it to your DevDrive's projects folder.
	Use python tools (see DESCRIPTION) to initialize 'MyNewProject'
	(Optional) Open 'MyNewProject' in VSCode
.EXAMPLE
	> Initialize-Project -ProjectName my-new-project -Language node

	This will create a private GitHub repository named 'my-new-project' and add it to your DevDrive's projects folder.
	Use node tools (see DESCRIPTION) to initialize 'my-new-project'
	(Optional) Open 'my-new-project' in VSCode
.NOTES
	!! REQUIREMENTS !!
	- Git -> https://git-scm.com/downloads
	- GitHub CLI -> https://github.com/cli/cli
	- NodeJS -> I use `NVM for Windows` to install nodejs and its packages
		LINK: https://github.com/coreybutler/nvm-windows
	- Python:
		-> I use `pyenv-win` to install python
		LINK: https://pyenv-win.github.io/pyenv-win/docs/installation.html
		-> `pipx`
		LINK: https://pipx.pypa.io/latest/installation
	- Rust: cargo
		-> I use `rustup` to install
		LINK: https://rustup.rs/
		-> (Optional but recommended): `cargo-binstall`
	- Get-DevDrive -> Custom PowerShell function
		LINK: https://github.com/jacquindev/windots/blob/main/dotposh/Modules/Set-DevDriveEnvironments.ps1)
	- PSToml -> PowerShell Module
		LINK: https://github.com/jborean93/PSToml
	- gum -> Better command interaction
		LINK: https://github.com/charmbracelet/gum

	- For README.md file, required 'readme-template.md' file, locally stored in (dotposh/Modules/Assets/)
		LINK: https://raw.githubusercontent.com/jacquindev/windots/refs/heads/main/dotposh/Modules/Assets/readme-template.md

	** INTERNET CONNECTION IS ALSO REQUIRED **
#>

function Initialize-Project {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Define the name of your project')]
		[Alias('n', '-name')]
		[string]$ProjectName,

		[Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Define main language of your project [powershell|node|rust|python|other]')]
		[ValidateSet('powershell', 'node', 'rust', 'python', 'other')]
		[Alias('l', '-lang')]
		[string]$Language,

		[Alias('a', '-author')]
		[string]$AuthorName = $(git config user.name)
	)

	# Use DevDrive to store projects
	$devDrive = Get-DevDrive
	$projectsDir = "$devDrive/projects"

	# Login into GitHub account with GitHub CLI
	if (!(Test-Path -Path "$env:APPDATA/GitHub CLI/hosts.yml")) { gh auth login }

	# Git related variables
	$gitUserId = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()
	$gitIgnore = "$projectsDir/$ProjectName/.gitignore"

	# Test Available Files/Folders
	$projectExists = Test-Path -Path "$projectsDir/$ProjectName" -PathType Container
	$githubRepoExists = (gh repo list | Select-String "$gitUserId/$ProjectName")
	$gitInitExists = Test-Path "$projectsDir/$ProjectName/.git" -PathType Leaf
	$gitignoreExists = Test-Path -Path "$gitIgnore" -PathType Leaf
	$licenseExists = Test-Path -Path "$projectsDir/$ProjectName/LICENSE*" -PathType Leaf

	# Check if PSToml installed or not, if not then install
	if (!(Get-Module -ListAvailable -Name PSToml -ErrorAction SilentlyContinue)) {
		Install-Module PSToml -Scope CurrentUser -Force
	}

	''
	# Create GitHub Repo and clone locally
	if ($githubRepoExists) {
		if (-not ($projectExists)) {
			gum spin --title="Cloning GitHub Repo $ProjectName..." -- gh repo clone "$gitUserId/$ProjectName" "$projectsDir/$ProjectName"
		} else {
			Write-Host "$ProjectName already exists in $projectsDir." -ForegroundColor Green
		}
	} else {
		# License
		$projectLicense = gum choose --header="Choose a License:" "AGPL-3.0" "Apache-2.0" "BSD-2-Clause" "BSD-3-Clause" "BSL-1.0" "CC0-1.0" "EPL-2.0" "GPL-2.0" "GPL-3.0" "LGPL-2.1" "MIT" "MPL-2.0" "Unlicense"
		# Description
		$projectDesc = gum input --prompt="Description for your $ProjectName> "
		if (-not ($projectExists)) {
			Set-Location "$projectsDir"
			gum spin --title="Creating GitHub Repo $ProjectName..." -- gh repo create "$ProjectName" --private --license=$projectLicense --description=$projectDesc --clone
		} else {
			Set-Location "$projectsDir/$ProjectName"
			gum spin --title="Creating GitHub Repo - $ProjectName..." -- gh repo create $ProjectName --private --source=. --remote=origin --description=$description
			if (-not ($gitInitExists)) { git init -q }
			if (($(git symbolic-ref --short HEAD) -notmatch "main") -or ($(git branch --show-current) -notmatch "main")) { gh repo edit --default-branch=main }
		}
	}

	$projectLocation = "$projectsDir/$ProjectName"
	Set-Location "$projectLocation"
	if (-not ($gitInitExists)) { git init -q }
	if (-not ($gitignoreExists)) { New-Item -Path "$gitIgnore" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null }
	if (-not ($licenseExists)) {
		if (!(gh extension list | Select-String "Shresht7/gh-license")) { gh extension install "Shresht7/gh-license" }
		gum spin --title="Adding LICENSE for $ProjectName..." -- gh license create $projectLicense --author "$AuthorName" --project "$ProjectName"
	}
	if ($(git symbolic-ref --short HEAD) -notmatch "main") { gh repo edit "$gitUserId/$ProjectName" --default-branch main }

	Remove-Variable projectExists, githubRepoExists, gitInitExists, gitignoreExists

	# PerLanguage settings
	switch ($Language) {
		# node
		"node" {
			# .gitignore
			$gitignoreNode = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/node").Content
			Add-Content -Path "$gitIgnore" -Value "$gitignoreNode"
			Remove-Variable gitignoreNode

			# Initialize project with package manager
			$pkgManager = gum choose --header="Choose a Package Manager:" "npm" "pnpm" "yarn"
			switch ($pkgManager) {
				"yarn" { &yarn init -2 | Out-Null; &yarn dlx @yarnpkg/sdks vscode | Out-Null; &npm init -y | Out-Null }
				"npm" { &npm init -y | Out-Null }
				"pnpm" { &pnpm init | Out-Null }
			}

			# package.json file
			$jsonPackage = "$projectLocation/package.json"
			if (Test-Path $jsonPackage -PathType Leaf) {
				$jsonContent = Get-Content "$jsonPackage" | ConvertFrom-Json
				$jsonContent.author = "$AuthorName"
				$jsonContent.license = "$projectLicense"
				$jsonContent.description = "$projectDesc"
				$jsonString = $jsonContent | ConvertTo-Json
				Set-Content "$jsonPackage" -Value $jsonString
			}
		}
		# powershell
		"powershell" {
			$gitignorePowershell = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/powershell").Content
			Add-Content -Path "$gitIgnore" -Value "$gitignorePowershell"
			Remove-Variable gitignorePowershell

			if (!(Get-Module -ListAvailable -Name 'PSScriptAnalyzer' -ErrorAction SilentlyContinue)) {
				Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -AllowClobber
			}
		}
		# python
		"python" {
			$gitignorePython = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/python").Content
			Add-Content -Path "$gitIgnore" -Value "$gitignorePython"
			Remove-Variable gitignorePython

			if (!(Get-Command pipx -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: pipx. Please install and rerun this script"; break }

			$projectManager = gum choose --header="Choose a Project Manager:" "Poetry" "PDM" "Hatch" "Rye"
			$projectToml = "$projectLocation/pyproject.toml"

			switch ($projectManager) {
				"Poetry" {
					if (!(Get-Command 'poetry' -ErrorAction SilentlyContinue)) { gum spin --title="Installing Poetry..." -- pipx install poetry }
					if (Get-Command 'pyenv' -ErrorAction SilentlyContinue) {
						$poetryConfig = "$env:APPDATA/pypoetry/config.toml"
						if (Test-Path $poetryConfig -PathType Leaf) {
							$poetryContent = Get-Content "$poetryConfig" | ConvertFrom-Toml
							if (($null -eq $poetryContent.virtualenvs) -or $poetryContent -eq $false) {
								poetry config virtualenvs.prefer-active-python true
							}
						}
					}
					# Initialize python project using poetry
					poetry init --no-interaction

					# pyproject.toml
					if (Test-Path -Path $projectToml -PathType Leaf) {
						$tomlContent = Get-Content "$projectToml" | ConvertFrom-Toml
						$tomlContent.tool.poetry.license = "$projectLicense"
						$tomlContent.tool.poetry.description = "$projectDesc"
						$tomlString = $tomlContent | ConvertTo-Toml -Depth 3
						Set-Content "$projectToml" -Value $tomlString
					}

					# Activate virtual environment
					poetry env use python
					. "$(poetry env info --path)/Scripts/activate.ps1"
					$poetryEnvName = (((poetry env list | rg 'Activated').Split(' ') -split '\s+')[0]).Trim()
					Write-Host "python virtual environment activate - $poetryEnvName" -ForegroundColor Green
				}
				"PDM" {
					if (!(Get-Command 'pdm' -ErrorAction SilentlyContinue)) { gum spin --title="Installing PDM..." -- pipx install pdm }
					# Initialize python project using pdm
					pdm init --non-interactive

					# pyproject.toml
					if (Test-Path -Path $projectToml -PathType Leaf) {
						$tomlContent = (Get-Content "$projectToml")
						$tomlContent -replace "Default template for PDM package", "$projectDesc" | Set-Content $projectToml
						$tomlContent -replace "MIT", "$projectLicense" | Set-Content $projectToml
					}

					# Activate virtual environment
					. "$projectLocation/.venv/Scripts/activate.ps1"
					Write-Host "python virtual environment activate - $ProjectName" -ForegroundColor Green
				}
				"Hatch" {
					if (!(Get-Command 'hatch' -ErrorAction SilentlyContinue)) { gum spin --title="Installing Hatch..." -- pipx install hatch }
					# Initialize python project using hatch
					hatch new --init

					# pyproject.toml
					if (Test-Path -Path $projectToml -PathType Leaf) {
						$tomlContent = (Get-Content "$projectToml")
						$tomlContent -replace "MIT", "$projectLicense" | Set-Content "$projectToml"
						$tomlContent -replace "$AuthorName", "$gitUserId" | Set-Content "$projectToml"
						hatch fmt "$projectToml" | Out-Null
					}

					$hatchConfig = "$env:LOCALAPPDATA/hatch/config.toml"
					if (Test-Path -Path $hatchConfig -PathType Leaf) {
						$hatchContent = (Get-Content "$hatchConfig" | ConvertFrom-Toml)
						if ($hatchContent.shell -notmatch "pwsh") { $hatchContent.shell = "pwsh" }
						if ($null -eq ($hatchContent.shell.dirs.env)) { $hatchContent.dirs.env = @{virtual = ".venv" } }
						$hatchString = $hatchContent | ConvertTo-Toml -Depth 3
						Set-Content "$hatchConfig" -Value $hatchString
						hatch fmt "$hatchConfig" | Out-Null
					}
				}
				"Rye" {
					if (!(Get-Command 'rye' -ErrorAction SilentlyContinue)) {
						if (Get-Command 'cargo' -ErrorAction SilentlyContinue) { gum spin --title="Installing rye..." -- cargo install --git "https://github.com/astral-sh/rye" rye }
						else { Write-Warning "Command not found: cargo. Please install and rerun this script."; break }
					}
					# Initialize python project using rye
					rye init

					# pyproject.toml
					if (Test-Path -Path $projectToml -PathType Leaf) {
						$tomlContent = (Get-Content "$projectToml")
						$tomlContent -replace "Add your description here", "$projectDesc" | Set-Content $projectToml
						rye fmt "$projectToml"
					}
					. "$projectLocation/.venv/Scripts/activate.ps1"
					Write-Host "python virtual environment activate - $ProjectName" -ForegroundColor Green
				}
			}
		}
		# rust
		"rust" {
			$gitignoreRust = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/rust,rust-analyzer").Content
			Add-Content -Path "$gitIgnore" -Value "$gitignoreRust"
			Remove-Variable gitignoreRust

			$tomlCargo = "$projectLocation/Cargo.toml"
			if (!(Test-Path $tomlCargo)) { cargo init }

			# Cargo.toml
			if (Test-Path -Path $tomlCargo -PathType Leaf) {
				$tomlContent = Get-Content "$tomlCargo" | ConvertFrom-Toml
				$tomlContent.package.author = @( "$AuthorName <$(git config user.email)>" )
				$tomlContent.package.license = "$projectLicense"
				$tomlContent.package.description = "$projectDesc"
				$tomlContent.package.repository = "https://github.com/$gitUserId/$ProjectName"
				$tomlContent.package.readme = "README.md"
				$tomlString = $tomlContent | ConvertTo-Toml
				Set-Content "$tomlCargo" -Value $tomlString
			}
		}
		"other" {}
	}

	$readmeExists = Test-Path -Path "$projectsDir/$ProjectName/README*" -PathType Leaf
	if (-not ($readmeExists)) {
		Copy-Item -Path "$env:DOTPOSH/Modules/Assets/readme-template.md" -Destination "$projectLocation/README.md"

		$readmeFile = "$projectLocation/README.md"
		$readmeContent = (Get-Content -Path $readmeFile)
		$readmeContent -replace "jacquindev", "$gitUserId" | Set-Content "$readmeFile"
		$readmeContent -replace "NewProject", "$ProjectName" | Set-Content "$readmeFile"
		Write-Host "Created a README.md file at project root - $ProjectName" -ForegroundColor Green

	} else {
		Write-Host "Current Project's README.md content " -ForegroundColor Magenta
		if (Get-Command 'bat' -ErrorAction SilentlyContinue) { gum confirm "View current README.md file? " && bat --plain --language="markdown" "$projectLocation/README.md" }
		else { gum confirm "View current README.md file? " && Get-Content "$projectLocation/README.md" }

		$overwriteReadme = $(Write-Host "README.md already exists. Overwrite? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
		if ($overwriteReadme.ToUpper() -eq 'Y') {
			Remove-Item "$projectLocation/README.md" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
			Copy-Item -Path "$env:DOTPOSH/Modules/Assets/readme-template.md" -Destination "$projectLocation/README.md"

			$readmeFile = "$projectLocation/README.md"
			$readmeContent = (Get-Content -Path $readmeFile)
			$readmeContent -replace "jacquindev", "$gitUserId" | Set-Content "$readmeFile"
			$readmeContent -replace 'Jacquin Moon', "$AuthorName" | Set-Content "$readmeFile"
			$readmeContent -replace "NewProject", "$ProjectName" | Set-Content "$readmeFile"
			Write-Host "Overwrited new README.md file at project root - $ProjectName" -ForegroundColor Green
		}
	}
	Remove-Variable readmeExists

	if (gh repo list --visibility private | Select-String "$gitUserId/$ProjectName") {
		''
		Write-Host "Your Project is currently in " -ForegroundColor DarkGray -NoNewline
		Write-Host "private " -ForegroundColor Yellow -NoNewline
		Write-Host "mode." -ForegroundColor DarkGray
		Write-Host "If you are ready to " -ForegroundColor DarkGray -NoNewline
		Write-Host "public " -ForegroundColor Yellow -NoNewline
		Write-Host "project $ProjectName, input the command:" -ForegroundColor DarkGray
		Write-Host "gh repo edit --visibility public --accept-visibility-change-consequences" -ForegroundColor Blue
		''
	}
	Start-Sleep -Seconds 1

	if (Get-Command 'code' -ErrorAction SilentlyContinue) {
		$openInVscode = $(Write-Host "Open project folder in VSCode? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
		if ($openInVscode.ToUpper() -eq 'Y') {
			Write-Host "Open project folder $ProjectName in VSCode" -ForegroundColor Green
			code "$projectLocation"
		}
	}
}

Set-Alias -Name 'proj' -Value 'Initialize-Project'

<#
.SYNOPSIS
	Remove a project locally and remotely
.DESCRIPTION
	This function will remove a project in DevDrive/projects/[project folder] and delete its github repo
	! Please use with consideration !
#>
function Remove-Project {
	param (
		[CmdletBinding()]
		[Parameter(Mandatory = $true, HelpMessage = 'Define the name of your project')]
		[Alias('n', '-name')]
		[string]$ProjectName
	)

	$devDrive = Get-DevDrive
	$projectsDir = "$devDrive/projects"

	# Git related variables
	$gitUserId = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()

	if (Test-Path "$projectsDir/$ProjectName" -PathType Container) {
		if ((Get-Command python -ErrorAction SilentlyContinue).Source | Select-String '.venv') { deactivate }
		if ((Get-Command python -ErrorAction SilentlyContinue).Source | Select-String 'virtualenvs') { deactivate }
		Remove-Item "$projectsDir/$ProjectName" -Force -Recurse -ErrorAction SilentlyContinue
	}
	if (gh repo list | Select-String "$gitUserId/$ProjectName") {
		gh repo delete $ProjectName --yes
	}
}
