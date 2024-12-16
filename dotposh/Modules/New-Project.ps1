<#
.SYNOPSIS
Initialize new project in DevDrive Folder with specified settings.
.DESCRIPTION
- Initialize your project with tools:
		- Node (npm | pnpm | yarn)
		- Python (poetry | PDM | hatch | rye) & activate virtual environment
		- Rust (cargo)
- Create new GitHub repo (private) with your project name
- Add .gitignore file with template source from: https://www.toptal.com/developers/gitignore
- Add LICENSE for your project
- Add README.md for your project
- Open your project directory in VSCode
.PARAMETER Project
Alias: -p, -n
- Specify your project's name. This will be the name of your project's folder and GitHub Repo
.PARAMETER Language
Alias: -l
- Specify your project's main language. This will add common related language files for your project
- Initialize your project will tools as above (see DESCRIPTION)
.PARAMETER GitHub
Alias: -g
- Whether or not to project GitHub Repository
.PARAMETER VSCode
Alias: -v
- Whether or not to open the project in Visual Studio Code Editor
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
		LINK: https://github.com/jacquindev/windots/blob/main/dotposh/Modules/Set-DevDriveEnvironments.ps1
- PSToml -> PowerShell Module
		LINK: https://github.com/jborean93/PSToml
- gum -> Better command interaction
		LINK: https://github.com/charmbracelet/gum

- For README.md file, required 'readme-template.md' file, locally stored in 'dotposh/Modules/Assets/'
		LINK: https://raw.githubusercontent.com/jacquindev/windots/refs/heads/main/dotposh/Modules/Assets/readme-template.md

																	** INTERNET CONNECTION IS ALSO REQUIRED **
.NOTES
	Author: Jacquin Moon
	Email: jacquindev@outlook.com
	Created date: December 11, 2024
	Link: https://github.com/jacquindev/windots/blob/main/dotposh/Modules/New-Project.ps1
#>

function Convert-NamingConventionCase {
	<#
	.EXAMPLE
		Convert-NamingConventionCase -inputString "camelCaseToSnakeCase" -snake
		Convert-NamingConventionCase -inputString "kebab-case-to-Pascal-case" -pascal
		Convert-NamingConventionCase -inputString "snake_case_to_camel_Case" -camel
	#>
	[CmdletBinding()]
	param (
		[string]$inputString,
		[switch]$camel,
		[switch]$pascal,
		[switch]$snake,
		[switch]$kebab
	)

	switch -regex ($inputString) {
		"^[a-z]+(?:[A-Z][a-z]+)*$" {
			# camelCase
			if ($snake) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '_').ToLower() }	# 'camelCase' => 'snake_case'
			elseif ($kebab) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '-').ToLower() } # 'camelCase' => 'kebab-case'
			elseif ($pascal) { return $inputString.Substring(0, 1).ToUpper() + $inputString.Substring(1) } # 'camelCase' => 'PascalCase'
			else { return $inputString }
		}
		"^[A-Z][a-z]+(?:[A-Z][a-z]+)*$" {
			# PascalCase
			if ($snake) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '_').ToLower() } # 'PascalCase' => 'snake_case'
			elseif ($kebab) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '-').ToLower() }  # 'PascalCase' => 'kebab-case'
			elseif ($camel) { return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) }  # 'PascalCase' => 'camelCase'
			else { return $inputString }
		}
		"^[a-z]+(?:_[a-z]+)*$" {
			# snake_case
			if ($kebab) { return ($inputString -replace '_', '-').ToLower() } # 'snake_case' => 'kebab-case'
			elseif ($camel) { $inputString = [regex]::replace($inputString.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper() }); return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) } # 'snake_case' => 'camelCase'
			elseif ($pascal) { return [regex]::replace($inputString.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper() }) } # 'snake_case' => 'PascalCase'
			else { return $inputString }
		}
		"^[a-z]+(?:-[a-z]+)*$" {
			# kebab-case
			if ($snake) { return ($inputString -replace '-', '_').ToLower() } # 'kebab-case' => 'snake_case'
			elseif ($camel) { $inputString = [regex]::replace($inputString.ToLower(), '(^|-)(.)', { $args[0].Groups[2].Value.ToUpper() }); return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) } # 'kebab-case' => 'camelCase'
			elseif ($pascal) { return [regex]::replace($inputString.ToLower(), '(^|-)(.)', { $args[0].Groups[2].Value.ToUpper() }) } # 'kebab-case' => 'PascalCase'
			else { return $inputString }
		}
	}
}

function Initialize-ProjectGit {
	param (
		[string]$projectName,
		[string]$author,
		[string]$desc,
		[string]$license,
		[string]$userId,
		[switch]$ghRepo
	)

	# Make sure you are in right directory
	$projectsRoot = "$(Get-DevDrive)\projects"
	Set-Location "$projectsRoot"

	$gitRepoLocalPaths = (Get-ChildItem -Filter '.git' -Recurse -Directory -Hidden -Depth 2 -ErrorAction SilentlyContinue).Parent.FullName
	$gitRepoRemote = (gh repo list | Select-String "$userId/$projectName")
	$gitRepoLocal = ($gitRepoLocalPaths | Select-String "$projectName")

	function Write-GhRepoCreateInformation {
		''
		Write-Host "Your project is currently in " -ForegroundColor DarkGray -NoNewline
		Write-Host "private " -ForegroundColor Yellow -NoNewline
		Write-Host "mode. " -ForegroundColor DarkGray
		Write-Host "If your are ready to " -ForegroundColor DarkGray -NoNewline
		Write-Host "public " -ForegroundColor Yellow -NoNewline
		Write-Host "your project, use the following command:" -ForegroundColor DarkGray
		Write-Host "gh repo edit --visibility public --accept-visibility-change-consequences" -ForegroundColor Green
		''
	}

	if ($ghRepo) {
		switch ($true) {
			{ ($gitRepoRemote -and $gitRepoLocal) } {
				Write-Success -Entry1 "OK" -Entry2 "https://github.com/$userId/$projectName.git" -Text "exists."
				Write-Success -Entry1 "OK" -Entry2 "$projectsRoot\$projectName" -Text "exists & initialized with git."
			}
			{ ((!$gitRepoRemote) -and (!$gitRepoLocal)) } {
				mkcd "$projectsRoot\$projectName"
				git init -q; git branch -M main
				gh repo create $projectName --private --source=. --remote=origin --description="$desc"
				Write-GhRepoCreateInformation
			}
			{ ((!$gitRepoRemote) -and ($gitRepoLocal)) } {
				gh repo create $projectName --private --source=. --remote=origin --description="$desc"
				Write-GhRepoCreateInformation
			}
			{ ($gitRepoRemote -and (!$gitRepoLocal)) } {
				gum spin --title="Cloning GitHub Repo $projectName to local machine..." -- gh repo clone "$userId/$projectName" "$projectsRoot\$projectName"
			}
		}
	} else {
		switch ($true) {
			{ ($gitRepoRemote -and $gitRepoLocal) } {
				Write-Success -Entry1 "OK" -Entry2 "https://github.com/$userId/$projectName.git" -Text "exists."
				Write-Success -Entry1 "OK" -Entry2 "$projectsRoot\$projectName" -Text "exists & initialized with git."
			}
			{ (!$gitRepoRemote -and $gitRepoLocal) } {
				Set-Location "$projectsRoot\$projectName"
				if (!(Test-Path -PathType Container -Path "$projectsRoot\$projectName\.git")) { git init -q }
				if (!($(git symbolic-ref --short HEAD) -eq "main")) { git branch -M main }
			}
			{ ((!$gitRepoLocal -and $gitRepoRemote) -or ((!$gitRepoLocal) -and (!$gitRepoRemote))) } {
				Write-Host "Create new project repository " -NoNewline
				Write-Host "$projectName" -ForegroundColor Cyan -NoNewline
				Write-Host " at location " -NoNewline
				Write-Host "$projectsRoot" -ForegroundColor Magenta
				mkcd "$projectsRoot\$projectName"
				git init -q; git branch -M main
			}
		}
	}

	if (!(Get-Command 'git-crypt' -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: git-crypt. Please install to use this feature."; return }

	# Create a multi-project keys repository
	$keyDir = "$projectsRoot\.git-crypt-keys"
	if (!(Test-Path $keyDir -PathType Container)) {
		Write-Host "KeyPath not found: $keyDir " -ForegroundColor Yellow -NoNewline; Write-Host "(default)" -ForegroundColor DarkGray
		$keyDirPrompt = $(Write-Host "Create (default) KeyPath Location (y) or (custom) KeyPath Location (n)? " -NoNewline -ForegroundColor Cyan; Read-Host)
		if ($keyDirPrompt.ToUpper() -eq 'Y') {
			New-Item -ItemType Directory -Path $keyDir -Force -ErrorAction SilentlyContinue | Out-Null
			Write-Success -Entry1 "SUCCESS" -Entry2 "$keyDir" -Text "(default) created successfully."
		} else {
			$customKeyDir = (gum input --prompt="Input the absolute path to your Keys Directory: ").Trim()
			if (!(Test-Path $customKeyDir -PathType Container)) {
				Write-Host "You set KeyPath: " -NoNewline
				Write-Host "$customKeyDir" -ForegroundColor Yellow -NoNewline
				Write-Host " (custom). This will be used to store all off your projects' git-crypt keys."

				try {
					gum confirm "Proceed now? (y/n) " && (New-Item -ItemType Directory -Path $customKeyDir -Force -ErrorAction SilentlyContinue | Out-Null) || Exit 0
					$keyDir = "$customKeyDir"
				} catch {
					Write-Error "$_"; Exit 1
				}
			}
		}
	}

	$perProjectKey = "$keyDir\$projectName"
	$perProjectKeyFile = Test-Path "$perProjectKey" -PathType Leaf
	$perProjectKeyInit = Test-Path "$projectsRoot\$projectName\.git\git-crypt" -PathType Container

	Set-Location "$projectsRoot\$projectName"

	switch ($true) {
		{ ($perProjectKeyInit -and $perProjectKeyFile) } { git stash >$null 2>&1; git pull -u origin main >$null 2>&1 ; git-crypt unlock "$perProjectKey" }
		{ (!$perProjectKeyFile -and $perProjectKeyInit) } { git-crypt export-key "$perProjectKey" }
		{ (!$perProjectKeyInit -and $perProjectKeyFile) } { git-crypt init; git-crypt unlock "$perProjectKey" }
		{ ((!$perProjectKeyFile) -and (!$perProjectKeyInit)) } { git-crypt init; git-crypt export-key "$perProjectKey" }
	}

	$gitAttributesExists = (Test-Path "$projectsRoot\$projectName\.gitattributes" -PathType Leaf)
	if (!$gitAttributesExists) {
		New-Item -Path "$projectsRoot\$projectName\.gitattributes" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
		@"
*.env filter=git-crypt diff=git-crypt
*.key filter=git-crypt diff=git-crypt
"@ | Set-Content "$projectsRoot\$projectName\.gitattributes"
	}
}

function Initialize-ProjectGitignore {
	param (
		[string]$projectName,
		[ValidateSet('powershell', 'python', 'node', 'rust')][string]$lang,
		[switch]$force
	)

	$projectsRoot = "$(Get-DevDrive)\projects"
	$gitignoreFile = "$projectsRoot\$projectName\.gitignore"
	$gitignoreExists = Test-Path "$gitignoreFile" -PathType Leaf

	if ($gitignoreExists) {
		if ($force) { Remove-Item "$gitignoreFile" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null }
		else { Write-Host "File .gitignore already exists at the project root."; return }
	}

	New-Item -Path "$gitignoreFile" -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null

	switch ($lang) {
		"node" { $gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/node").Content }
		"python" { $gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/python").Content }
		"powershell" { $gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/powershell").Content	}
		"rust" {	$gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/rust-analyzer,rust").Content }
	}
	Set-Content "$gitignoreFile" -Value "$gitignoreContent"
}

function Initialize-ProjectReadme {
	param ([string]$projectName, [switch]$force)

	$projectsRoot = "$(Get-DevDrive)\projects"
	$readmeTemplate = "$env:DOTPOSH\Modules\Assets\readme-template.md"

	if ($force) {
		if (Test-Path "$projectsRoot\$projectName\README*" -PathType Leaf) {
			Remove-Item "$projectsRoot\$projectName\README*" -Force -ErrorAction SilentlyContinue | Out-Null
		}
	}
	Copy-Item "$readmeTemplate" -Destination "$projectsRoot\$projectName\README.md" -ErrorAction SilentlyContinue

	$readmeFile = "$projectsRoot\$projectName\README.md"
	$md = Get-Content -Path "$readmeFile"
	$md -replace 'jacquindev', "$UserID" | Set-Content "$readmeFile"
	$md -replace 'Jacquin Moon', "$Author" | Set-Content "$readmeFile"
	$md -replace 'NewProject', "$Project" | Set-Content "$readmeFile"
	Write-Host "README.md file created/overwritten at project root." -ForegroundColor Green
}

function Open-ProjectDirInVSCode {
	param ([string]$projectName)

	$projectsRoot = "$(Get-DevDrive)\projects"

	if (!(Get-Command 'code' -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: code. Please install to use this feature."
		return
	} else {
		Write-Host "Open project folder in VSCode" -ForegroundColor Magenta
		Set-Location "$projectsRoot\$projectName"
		code .
	}
}

function Initialize-ProjectPerLangNode {
	param ([string]$projectName, [switch]$tailwind, [switch]$typescript)

	$projectsRoot = "$(Get-DevDrive)\projects"
	$frameworks = (gum choose --header="Choose a Framework:" "Astro" "Angular" "NextJS" "Laravel" "Remix" "Parcel" "Svelte" "Vite" "Unknown").Trim()
	$pkgManager = (gum choose --header="Choose a Package Manager:" "bun" "npm" "pnpm" "yarn").Trim()

	switch ($pkgManager) {
		"bun" { if (!(Get-Command 'bun' -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: bun. Please install to use this feature."; break } }
		"npm" { if (!(Get-Command 'npm' -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: npm. Please install to use this feature."; break } }
		"pnpm" { if (!(Get-Command 'pnpm' -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: pnpm. Please install to use this feature."; break } }
		"yarn" { if (!(Get-Command 'yarn' -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: yarn. Please install to use this feature."; break } }
	}

	Set-Location "$projectsRoot"

	switch ($frameworks) {
		"Astro" {
			Set-Location "$projectsRoot"
			switch ($pkgManager) {
				"bun" { $cmd = "bunx create astro $projectsName --git --fancy --install" }
				"npm" { $cmd = "npx create-astro@latest $projectsName --git --fancy --install -y" }
				"pnpm" { $cmd = "pnpm create astro@latest $projectsName --git --fancy --install" }
				"yarn" { $cmd = "yarn create astro $projectsName --git --fancy --install" }
			}
			if ($tailwind) { if ($pkgManager -eq 'npm') { $cmd += " -- --add tailwind" } else { $cmd += " --add tailwind" } }

			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			switch ($pkgManager) {
				"bun" { bun add -d $types/bun; bunx astro add mdx astro-auto-import astro-icon --yes }
				"npm" { npx astro add mdx astro-auto-import astro-icon --yes }
				"pnpm" { pnpm astro add mdx astro-auto-import astro-icon --yes }
				"yarn" { yarn astro add mdx astro-auto-import astro-icon --yes }
			}

			if ($typescript) {
				switch ($pkgManager) {
					"bun" { bun add -d @types/bun; bun add @astrojs/ts-plugin }
					"npm" { npm install @astrojs/ts-plugin }
					"pnpm" { pnpm add @astrojs/ts-plugin }
					"yarn" { yarn add @astrojs/ts-plugin }
				}
				$tsconfig = "$projectLocation\tsconfig.json"
				$json = Get-Content $tsconfig | ConvertFrom-Json
				if (!$json.compilerOptions -or !$json.compilerOptions.plugins) {
					$json | Add-Member -MemberType NoteProperty -Name "compilerOptions" -Value ([PSCustomObject]@{
							plugins              = [array]@( @{ name = "@astrojs/ts-plugin" } )
							verbatimModuleSyntax = $true
						})
				}
				Set-Content "$tsconfigJson" -Value ($json | ConvertTo-Json -Depth 100)
				Remove-Variable tsconfigJson
			}
			''
			Write-Host "For more information, see https://docs.astro.build/en/getting-started/" -ForegroundColor Blue
			Remove-Variable cmd
		}

		"Angular" {
			if (!(Get-Command ng -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: ng. Please install to use this feature."; return }

			Set-Location "$projectsRoot"

			$cmd = ng new "$projectName"

			switch ($pkgManager) {
				"bun" { $cmd += " --package-manager bun" }
				"npm" { $cmd += " --package-manager npm" }
				"pnpm" { $cmd += " --package-manager pnpm" }
				"yarn" { $cmd += " --package-manager yarn" }
			}

			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			if ($tailwind) {
				switch ($pkgManager) {
					"bun" { bun add -d tailwindcss postcss autoprefixer; bunx tailwindcss init }
					"npm" { npm install --save-dev tailwindcss postcss autoprefixer; npx tailwindcss init }
					"pnpm" { pnpm add -D tailwindcss postcss autoprefixer; npx tailwindcss init }
					"yarn" { yarn add -D tailwindcss postcss autoprefixer; yarn tailwindcss init }
				}
			}

			''
			Write-Host "For more information, see https://angular.dev/overview" -ForegroundColor Blue
			Remove-Variable cmd
		}

		"NextJS" {
			$cmd = "npx create-next-app@latest $projectName --eslint"
			if ($typescript) { $cmd += " --typescript" }
			if ($tailwind) { $cmd += " --tailwind-css" }

			switch ($pkgManager) {
				"bun" { $cmd += " --use-bun" }
				"npm" { $cmd += " --use-npm" }
				"pnpm" { $cmd += " --use-pnpm" }
				"yarn" { $cmd += " --use-yarn" }
			}

			Set-Location "$projectsRoot"
			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			''
			Write-Host "For more information, see https://nextjs.org/docs" -ForegroundColor Blue
			Remove-Variable cmd
		}

		"Laravel" {
			# Check of commands
			@('php', 'composer', 'laravel') | ForEach-Object {
				if (!(Get-Command $_ -ErrorAction SilentlyContinue)) {
					Write-Warning "Command not found: $_. Please install to use this feature."; return
				}
			}

			Set-Location "$projectsRoot"

			$cmd = "laravel new $projectName"

			$laravelStarterKit = (gum choose --limit=1 --header="Choose a Starter Kit:" "None" "Breeze" "Jetstream").Trim()
			$laravelTestFramework = (gum choose --limit=1 --header="Choose a Testing Framework:" "Pest" "PHPUnit").Trim()
			$laravelDatabase = (gum choose --limit=1 --header="Choose a Database Type:" "SQLite" "MySQL" "MariaDB" "PostgreSQL" "SQL Server").Trim()

			switch ($laravelStarterKit) {
				"None" { $cmd += " --git" }
				"Breeze" {
					$cmd += " --git --breeze --dark"
					$laravelBreezeStack = (gum choose --limit=1 --header="Choose a Breeze Stack:" "Blade with Alpine" "Livewire (Volt Class API) with Alpine" "Livewire (Volt Functional API) with Alpine" "React with Inertia" "Vue with Inertia" "API Only").Trim()
					switch ($laravelBreezeStack) {
						"Blade with Alpine" { $cmd += " --stack=blade" }
						"Livewire (Volt Class API) with Alpine" { $cmd += " --stack=livewire" }
						"Livewire (Volt Functional API) with Alpine" { $cmd += " --stack=livewire-functional" }
						"React with Inertia" { $cmd += " --stack=react" }
						"Vue with Inertia" { $cmd += " --stack=vue" }
						"API Only" { $cmd += " --stack=api" }
					}
				}
				"Jetstream" {
					$cmd += " --git --jet --dark"
					$laravelJetStack = (gum choose --limit=1 --header="Choose a Jetstream Stack:" "Livewire" "Vue with Inertia").Trim()
					switch ($laravelJetStack) {
						"Livewire" { $cmd + " --stack=livewire" }
						"Vue with Inertia" { $cmd += " --stack=inertia" }
					}
				}
			}

			switch ($laravelTestFramework) {
				"Pest" { $cmd += " --pest" }
				"PHPUnit" { $cmd += " --phpunit" }
			}

			switch ($laravelDatabase) {
				"SQLite" { $cmd += " --database=sqlite" }
				"MySQL" { $cmd += " --database=mysql" }
				"MariaDB" { $cmd += " --database=mariadb" }
				"PostgreSQL" { $cmd += " --database=pgsql" }
				"SQL Server" { $cmd += " --database=sqlsrv" }
			}

			if ($typescript -and ($laravelStarterKit -eq 'Breeze')) {	$cmd += " --typescript" }

			$cmd += " --no-interaction"

			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			if ($typescript -and (-not ($laravelStarterKit -eq 'Breeze'))) {
				switch ($pkgManager) {
					"bun" { bun add -d @types/bun @types/node ts-loader typescript }
					"npm" { npm install --save-dev @types/node ts-loader typescript }
					"pnpm" { pnpm add -D @types/node ts-loader typescript }
					"yarn" { yarn add -D @types/node ts-loader typescript }
				}
				if (!(Test-Path "$projectLocation\tsconfig.json")) {
					switch ($pkgManager) {
						"bun" { bunx tsc --init }
						"npm" { npx tsc --init }
						"pnpm" { npx tsc --init }
						"yarn" { yarn tsc --init }
					}
				}

				$tsconfigJson = "$projectLocation\tsconfig.json"
				$json = Get-Content $tsconfigJson | ConvertFrom-Json
				$json.compilerOptions = [PSCustomObject]@{
					target            = "EsNext"
					module            = "EsNext"
					jsx               = "preserve"
					strict            = $true
					sourceMap         = $true
					resolveJsonModule = $true
					esModuleInterop   = $true
					allowJs           = $true
					lib               = [array]@("esnext", "dom")
					types             = [array]@("@types/node")
					paths             = @{ "@/*" = [array]@("./resources/js/*") }
					outDir            = "./public/build/assets"
				}
				$json.typeRoots = [array]@("./node_modules/@types", "resources/js/types")
				$json.include = [array]@(
					"resources/js/**/*.ts",
					"resources/js/**/*.d.ts",
					"resources/js/**/*.vue"
				)
				$json.exclude = [array]@("node_modules", "public")
				if ($null -eq $($json.compilerOptions)) { $json | Add-Member -Name "compilerOptions" -Value "$($json.compilerOptions)" -MemberType NoteProperty }
				if ($null -eq $($json.typeRoots)) { $json | Add-Member -Name "typeRoots" -Value "$($json.typeRoots)" -MemberType NoteProperty }
				if ($null -eq $($json.include)) { $json | Add-Member -Name "include" -Value "$($json.include)" -MemberType NoteProperty }
				if ($null -eq $($json.exclude)) { $json | Add-Member -Name "exclude" -Value "$($json.exclude)" -MemberType NoteProperty }
				Set-Content "$tsconfigJson" -Value ($json | ConvertTo-Json -Depth 100)

				Get-ChildItem -Path "$projectLocation\resources\js" -Filter *.js -ErrorAction SilentlyContinue | Rename-Item -NewName { $_.Name -replace '.js', '.ts' }

				$viteConfigJs = Get-Content "$projectLocation\vite.config.js"
				$viewsPhp = Get-Content "$projectLocation\resources\views\*.php"
				if ($viteConfigJs -match 'resources/js/app.js') { $viewConfiJs -replace 'resources/js/app.js', 'resources/js/app.ts' | Set-Content "$projectLocation\vite.config.js" }
				if ($viewsPhp -match 'resources/js/app.js') { $viewsPhp -replace 'resouces/js/app.js', 'resources/js/app.ts' | Set-Content "$projectLocation\resources\views\*.php" }
			}

			''
			Write-Host "For more information, see https://laravel.com/docs/11.x" -ForegroundColor Blue
			Remove-Variable cmd
		}

		"Remix" {
			Set-Location "$projectsRoot"

			switch ($pkgManager) {
				"bun" { $cmd = "bunx create remix $projectName --install --git-init --yes" }
				"npm" { $cmd = "npx create-remix@latest $projectName --install --git-init --yes" }
				"pnpm" { $cmd = "pnpm create remix $projectName --install --git-init --yes" }
				"yarn" { $cmd = "yarn create remix $projectName --install --git-init --yes" }
			}

			if (!($typescript)) {
				$cmd += " --template remix-run/remix/templates/remix-javascript"
			}

			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			if ($tailwind) {
				switch ($pkgManager) {
					"bun" {
						bun add -d tailwindcss postcss autoprefixer
						if ($typescript) { bunx tailwindcss init --ts -p } else { bunx tailwindcss init -p }
					}
					"npm" {
						npm install --save-dev tailwindcss postcss autoprefixer
						if ($typescript) { npx tailwindcss init --ts -p } else { npx tailwindcss init -p }
					}
					"pnpm" {
						pnpm add -D tailwindcss postcss autoprefixer
						if ($typescript) { npx tailwindcss init --ts -p } else { npx tailwindcss init -p }
					}
					"yarn" {
						yarn add -D tailwindcss postcss autoprefixer
						if ($typescript) { yarn tailwindcss init --ts -p } else { yarn tailwindcss init -p }
					}
				}
			}

			''
			Write-Host "For more information, see https://remix.run/docs/en/main" -ForegroundColor Blue
			Remove-Variable cmd
		}

		"Parcel" {
			Set-Location "$projectsRoot"
			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				New-Item -Path "$projectsRoot\$projectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
			}

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			switch ($pkgManager) {
				"bun" {
					bun init; bun add -d parcel
					if ($typescript) { bun add -d @types/bun typescript }
					if ($tailwind -and $typescript) { bun add -d tailwindcss postcss; bunx tailwindcss init --ts -p }
					if ($tailwind -and (!$typescript)) { bun add -d tailwindcss postcss; bunx tailwindcss init -p }
				}
				"npm" {
					npm init -y; npm install --save-dev parcel
					if ($typescript) { npm install --save-dev typescript }
					if ($tailwind -and $typescript) { npm install --save-dev tailwindcss postcss; npx tailwindcss init --ts -p }
					if ($tailwind -and (!$typescript)) { npm install --save-dev tailwindcss postcss; npx tailwindcss init -p }
				}
				"pnpm" {
					pnpm init; pnpm add -D parcel
					if ($typescript) { pnpm add -D typescript }
					if ($tailwind -and $typescript) { pnpm add -D tailwindcss postcss; npx tailwindcss init --ts -p }
					if ($tailwind -and (!$typescript)) { pnpm add -D tailwindcss postcss; npx tailwindcss init -p }
				}
				"yarn" {
					yarn init -2; yarn add -D parcel
					if ($typescript) { yarn add -D typescript }
					if ($tailwind -and $typescript) { yarn add -D tailwindcss postcss; yarn tailwindcss init --ts -p }
					if ($tailwind -and (!$typescript)) { yarn add -D tailwindcss postcss; yarn tailwindcss init -p }
				}
			}

			if ($tailwind) {
				if (!(Test-Path "$projectLocation\.postcssrc" -PathType Leaf)) {
					New-Item -Path "$projectLocation\.postcssrc" -ItemType File -ErrorAction SilentlyContinue | Out-Null
				}
				$postcss = @"
{
	"plugins": {
		"tailwindcss": {}
	}
}
"@
				Set-Content "$projectLocation\.postcssrc" -Value $postcss
			}

			''
			Write-Host "For more information, see https://parceljs.org/docs/" -ForegroundColor Blue
		}

		"Svelte" {
			Set-Location "$projectsRoot"
			$cmd = "npx sv create $projectName"
			$svelteTemplate = (gum choose --limit=1 --header="Choose a Template to Scaffold:" "minimal" "demo" "library").Trim()
			switch ($svelteTemplate) {
				"minimal" { $cmd += " --template minimal" }
				"demo" { $cmd += " --template demo" }
				"library" { $cmd += " --template library" }
			}
			if ($typescript) { $cmd += " --types ts" }
			$cmd += " --no-add-ons --no-install"
			Invoke-Expression $cmd

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			if ($tailwind) {
				$cmd1 = "npx sv add --tailwindcss"
				$tailwindPlugins = (gum choose --no-limit --header="Choose TailwindCSS Plugins:" "none" "typography" "forms" "container-queries").Trim()
				switch ($tailwindPlugins) {
					"none" { $cmd1 = "$cmd1" }
					"typography" { $cmd1 += " typography" }
					"forms" { $cmd1 += " forms" }
					"container-queries" { $cmd1 += " container-queries" }
				}
				$cmd1 += " --no-install"
				Invoke-Expression $cmd1
			}

			switch ($pkgManager) {
				"bun" { bun install --silent }
				"npm" { npm install -q }
				"pnpm" { pnpm install -s }
				"yarn" { yarn install }
			}

			# Svelte Integrations
			$additionalIntegrations = $(Write-Host "Set up your Svelte Project with Additional Integrations? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			if ($additionalIntegrations.ToUpper() -eq 'Y') {
				$index = (gum choose --no-limit --header="Choose Additional Integrations Topics" "1. Builtin SvelteKit Adders" "2. Svelte Packages" "3. svelte-preprocess").Trim()
				switch ($index) {
					{ $_ -match "1. Builtin SvelteKit Adders" } {
						''
						Write-Host "Builtin SvelteKit Adders" -ForegroundColor Green
						Write-Host "------------------------" -ForegroundColor Green
						$addersCmd = "npx sv add"
						$adders = (gum choose --no-limit --header="Choose SvelteKit Integrations:" "prettier" "eslint" "vitest" "playwright" "lucia" "drizzle" "paraglide" "mdsvex" "storybook").Trim()
						switch ($adders) {
							{ $_ -match "prettier" } { $addersCmd += " prettier" }
							{ $_ -match "eslint" } { $addersCmd += " eslint" }
							{ $_ -match "vitest" } { $addersCmd += " vitest" }
							{ $_ -match "playwright" } { $addersCmd += " playwright" }
							{ $_ -match "lucia" } {
								$demoIncluded = (gum choose --limit=1 --header="Lucia: Include a demo?" "Yes" "No").Trim()
								if ($demoIncluded -eq 'Yes') { $addersCmd += " --lucia demo" }
								else { $addersCmd += " --lucia no-demo" }
							}
							{ $_ -match "drizzle" } {
								$dbCmd = " --drizzle"
								$databaseType = (gum choose --limit=1 --header="Choose a Database Type:" "PostgreSQL" "MySQL" "SQLite").Trim()
								$useDocker = (gum choose --limit=1 --header="Integrate Database with Docker?" "Yes" "No").Trim()
								switch ($databaseType) {
									"PostgreSQL" {
										$dbCmd += " postgresql"
										$databaseClient = (gum choose --limit=1 --header="Choose a PostgreSQL Client:" "Postgres.JS" "Neon").Trim()
										switch ($databaseClient) {
											"Postgres.JS" { $dbCmd += " postgres.js" }
											"Neon" { $dbCmd += " neon" }
										}
									}
									"MySQL" {
										$dbCmd += " mysql"
										$databaseClient = (gum choose --limit=1 --header="Choose a MySQL Client:" "mysql2" "PlanetScale").Trim()
										switch ($databaseClient) {
											"mysql2" { $dbCmd += " mysql2" }
											"PlanetScale" { $dbCmd += " planetscale" }
										}
									}
									"SQLite" {
										$dbCmd += " sqlite"
										$databaseClient = (gum choose --limit=1 --header="Choose a SQLite Client:" "better-sqlite3" "libSQL" "Turso").Trim()
										switch ($databaseClient) {
											"better-sqlite3" { $dbCmd += " better-sqlite3" }
											"libSQL" { $dbCmd += " libsql" }
											"Turso" { $dbCmd += " turso" }
										}
									}
								}
								if ($useDocker -eq 'Yes') { $dbCmd += " docker" } else { $dbCmd += " no-docker" }
								$addersCmd += "$dbCmd"
							}
							{ $_ -match "paraglide" } {
								$demoIncluded = (gum choose --limit=1 --header="Paraglide: Include a demo?" "Yes" "No").Trim()
								if ($demoIncluded -eq 'Yes') { $addersCmd += " --paraglide demo" }
								else { $addersCmd += " --paraglide no-demo" }
							}
							{ $_ -match "mdsvex" } { $addersCmd += " mdsvex" }
							{ $_ -match "storybook" } { $addersCmd += " storybook" }
						}
						$addersCmd += " --no-install"
						Invoke-Expression $addersCmd
					}

					{ $_ -match "2. Svelte Packages" } {
						''
						Write-Host "Svelte Packages" -ForegroundColor Green
						Write-Host "---------------" -ForegroundColor Green
						$sveltePackages = @()
						$pkgs = (gum choose --no-limit --header="Some available Svelte Packages:" "auto-animate" "embla-carousel-svelte" "enhanced-img" "lucide-icons" "svelte-datatable" "svelte-flicking"  "Svelte Flow" "Tanstack Table" "Tanstack Query" "Tanstack Virtual").Trim()
						switch ($pkgs) {
							{ $_ -match "AutoAnimate" } { $sveltePackages += '@formkit/auto-animate' } # https://auto-animate.formkit.com/#usage-svelte
							{ $_ -match "embla-carousel-svelte" } { $sveltePackages += 'embla-carousel-svelte' } # https://www.embla-carousel.com/get-started/
							{ $_ -match "enhanced-img" } { $sveltePackages += '@sveltejs/enhanced-img' } # https://svelte.dev/docs/kit/images#sveltejs-enhanced-img
							{ $_ -match "lucide-icons" } { $sveltePackages += 'lucide-svelte' } # https://lucide.dev/guide/packages/lucide-svelte
							{ $_ -match "svelte-datatable" } { $sveltePackages += '@radar-azdelta/svelte-datatable' } # https://github.com/RADar-AZDelta/azd-radar-data-datatable
							{ $_ -match "svelte-flicking" } { $sveltePackages += '@egjs/svelte-flicking' } # https://github.com/naver/egjs-flicking/blob/master/packages/svelte-flicking/README.md
							{ $_ -match "Svelte Flow" } { $sveltePackages += '@xyflow/svelte' } # https://svelteflow.dev/learn
							{ $_ -match "Tanstack Table" } { $sveltePackages += '@tanstack/svelte-table' } # https://tanstack.com/table/v8/docs/framework/svelte/svelte-table
							{ $_ -match "Tanstack Virtual" } { $sveltePackages += '@tanstack/svelte-virtual' } # https://tanstack.com/virtual/latest/docs/framework/svelte/svelte-virtual
							{ $_ -match "Tanstack Query" } { $sveltePackages += '@tanstack/svelte-query' } # https://tanstack.com/query/latest/docs/framework/svelte/overview
						}
						switch ($pkgManager) {
							"bun" { bun add $sveltePackages }
							"npm" { npm install $sveltePackages }
							"pnpm" { pnpm add $sveltePackages }
							"yarn" { yarn add $sveltePackages }
						}
						Remove-Variable sveltePackages
					}

					{ $_ -match "3. svelte-preprocess" } {
						''
						Write-Host "svelte-preprocess" -ForegroundColor Green
						Write-Host "-----------------" -ForegroundColor Green
						$sveltePackages = @()
						$deps = (gum choose --no-limit --header="svelte-preprocess - Choose language-specific dependencies:" "Babel" "CoffeeScript" "PostCSS" "SugarSS" "Less" "Sass" "Pug" "Stylus")
						switch ($deps) {
							{ $_ -match "Babel" } { $sveltePackages += @('@babel/core', '@babel/preset-...') }
							{ $_ -match "CoffeeScript" } { $sveltePackages += @('coffeescript') }
							{ $_ -match "PostCSS" } { $sveltePackages += @('postcss', 'postcss-load-config') }
							{ $_ -match "SugarSS" } { $sveltePackages += @('postcss', 'sugarss') }
							{ $_ -match "Less" } { $sveltePackages += @('less') }
							{ $_ -match "Sass" } { $sveltePackages += @('sass') }
							{ $_ -match "Pug" } { $sveltePackages += @('pug') }
							{ $_ -match "Stylus" } { $sveltePackages += @('stylus') }
						}
						$sveltePackages += @('autoprefixer')
						if ($typescript) { $sveltePackages += @('typescript', '@rollup/plugin-typescript') }

						switch ($pkgManager) {
							"bun" { bun add -d $sveltePackages }
							"npm" { npm i -D $sveltePackages }
							"pnpm" { pnpm add -D $sveltePackages }
							"yarn" { yarn add -D $sveltePackages }
						}
						''
						Write-Host "Extra steps are required to setup, please see " -NoNewline
						Write-Host "https://github.com/sveltejs/svelte-preprocess/blob/main/docs/getting-started.md" -ForegroundColor Blue
					}
				}
			}

			''
			Write-Host "For more information, see https://svelte.dev/docs/kit/introduction" -ForegroundColor Blue
		}

		"Vite" {
			Set-Location "$projectsRoot"

			if ($typescript) {
				$viteTemplates = gum choose "Choose a Vite Template:" "vanilla" "vue" "react" "preact" "lit" "svelte" "solid" "qwik"
			} else {
				$viteTemplates = gum choose "Choose a Vite Template:" "vanilla-ts" "vue-ts" "react-ts" "preact-ts" "lit-ts" "svelte-ts" "solid-ts" "qwik-ts"
			}

			switch ($pkgManager) {
				"bun" { bun create vite $projectName --template $viteTemplates }
				"npm" { npm create vite@latest $projectName -- --template $viteTemplates }
				"pnpm" { pnpm create vite $projectName --template $viteTemplates }
				"yarn" { yarn create vite $projectName --template $viteTemplates }
			}

			Set-Location "$projectsRoot\$projectName"
			''
			Write-Host "For more information, see https://vite.dev/guide/" -ForegroundColor Green
		}

		"Unknown" {
			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				New-Item "$projectsRoot\$projectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
			}

			$projectLocation = "$projectsRoot\$projectName"
			Set-Location "$projectLocation"

			switch ($pkgManager) {
				"bun" { bun init >$null 2>&1 }
				"npm" { npm init -y >$null 2>&1 }
				"pnpm" { pnpm init >$null 2>&1 }
				"yarn" { yarn init -2 >$null 2>&1 }
			}

			''
			Write-Success -Entry1 "OK" -Text "Initilized $projectName at $projectsRoot"
		}
	}
}

function Initialize-ProjectPerLangPython {
	param ([string]$projectName, [switch]$flask, [switch]$django)

	if (!(Get-Command python -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: python. Please install to use this feature."; return
	}

	$projectsRoot = "$(Get-DevDrive)\projects"
	$projectManager = (gum choose --limit=1 --header="Choose a Project Manager:" "Poetry" "PDM" "Rye" "UV").Trim()

	$pipxExists = Get-Command pipx -ErrorAction SilentlyContinue
	$poetryExists = Get-Command poetry -ErrorAction SilentlyContinue
	$uvExists = Get-Command uv -ErrorAction SilentlyContinue
	$uvxExists = Get-Command uvx -ErrorAction SilentlyContinue
	$ryeExists = Get-Command rye -ErrorAction SilentlyContinue
	$cargoExists = Get-Command cargo -ErrorAction SilentlyContinue
	$pdmExists = Get-Command pdm -ErrorAction SilentlyContinue

	switch -regex ($projectName) {
		"^[a-z]+(-[a-z]+)*$" { $subProjectName = (Convert-NamingConventionCase -inputString "$projectName" -snake).Trim() }
		"^[a-z]+(?:_[a-z]+)*$" { $subProjectName = "$projectName" }
		"^[A-Z][a-z]+(?:[A-Z][a-z]+)*$" {	$subProjectName = $projectName.ToLower() }
	}

	switch ($projectManager) {
		"Poetry" {
			if (!$poetryExists) {
				if ($pipxExists) { pipx install poetry }
				else { Write-Warning "Command not found: pipx. Could not install 'poetry'. Please install it manually"; break }
			}

			# Poetry Plugins
			$poetryPlugins = @()
			$plugin = (gum choose --no-limit --header="Choose Poetry Plugins:" "poetry-bumpversion" "poetry-dotenv-plugin" "poetry-dynamic-versioning" "poetry-multiproject-plugin" "poetry-plugin-bundle" "poetry-plugin-export").Trim()
			switch ($plugin) {
				{ $_ -match "poetry-bumpversion" } { $poetryPlugins += @('poetry-bumpversion') }
				{ $_ -match "poetry-dotenv-plugin" } { $poetryPlugins += @('poetry-dotenv-plugin') }
				{ $_ -match "poetry-dynamic-versioning" } { $poetryPlugins += @('poetry-dynamic-versioning') }
				{ $_ -match "poetry-multiproject-plugin" } { $poetryPlugins += @('poetry-multiproject-plugin') }
				{ $_ -match "poetry-plugin-export" } { $poetryPlugins += @('poetry-plugin-export') }
			}

			if (pipx list | Select-String 'poetry.exe') { $cmd = "pipx inject poetry" }
			elseif (pip list | Select-String 'poetry') { $cmd = "pip install" }
			else { $cmd = "poetry self add" }

			foreach ($p in $poetryPlugins) {
				if (!(poetry self show plugins | Select-String "$p" )) {
					$cmd += " $p"
				}
			}
			Invoke-Expression $cmd
			Remove-Variable cmd p poetryPlugin

			# New poetry project
			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				Set-Location "$projectsRoot"
				poetry new "$projectName"
			}

			Set-Location "$projectsRoot\$projectName"

			if (!(Test-Path "$projectsRoot\$projectName\$subProjectName" -PathType Container)) {
				New-Item -Path "$projectsRoot\$projectName\$subProjectName" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
			}

			# Frameworks
			if ($flask) { poetry add  --quiet }
			if ($django) {
				poetry add django --quiet
				if (Test-Path "$projectsRoot\$projectName\$subProjectName\__init__.py") {
					Remove-Item "$projectsRoot\$projectName\$subProjectName\__init__.py" -Force -ErrorAction SilentlyContinue | Out-Null
				}
				poetry run django-admin startproject $subProjectName .
			}

			# Activate virtual environment for Poetry Project
			$venvName = (($(poetry env list) -split '\n')[0] -split ' ')[0]

			& ((poetry env info --path) + "\Scripts\activate.ps1")
			Write-Success -Entry1 "Virtual Environment $venvName in" -Entry2 "$(poetry env info --path | Split-Path)" -Text "activated."
		}

		"PDM" {
			if (!$pdmExists) {
				if ($pipxExists) { pipx install pdm }
				else { Write-Warning "Command not found: pipx. Could not install 'pdm'. Please install it manually"; break }
			}

			# if (($uvExists) -and (pdm config | Select-String 'use_uv = False') -and (!(pdm config | Select-String 'use_uv = True'))) {
			# 	pdm config use_uv true
			# }

			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				New-Item -Path "$projectsRoot\$projectName" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
			}
			Set-Location "$projectsRoot\$projectName"
			pdm init -n

			if ($flask) { pdm add flask }
			if ($django) { pdm add django; pdm run django-admin startproject $subProjectName }

			pdm sync

			& (pdm venv activate)
			Write-Success -Entry1 "Virtual Environment .venv in" -Entry2 "$projectsRoot\$projectName" -Text "activated."
		}

		"UV" {
			if ((!$uvExists) -and (!$uvxExists)) {
				if ($pipxExists) { pipx install uv }
				else { Write-Warning "Command not found: pipx. Could not install 'uv'. Please install it manually"; break }
			}

			# New uv project
			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				Set-Location "$projectsRoot"
				uv init "$projectName"
			}
			Set-Location "$projectsRoot\$projectName"

			if ($django) {
				if (Test-Path "$projectsRoot\$projectName\hello.py") { Remove-Item "$projectsRoot\$projectName\hello.py" -ErrorAction SilentlyContinue }
				uv add django --quiet
				uv run django-admin startproject $subProjectName .
			}
			if ($flask) { uv add flask --quiet }

			uv sync

			& ("$projectsRoot\$projectName\.venv\Scripts\activate.ps1")
			Write-Success -Entry1 "Virtual Environment .venv in" -Entry2 "$projectsRoot\$projectName" -Text "activated."
		}

		"Rye" {
			if (!$ryeExists) {
				if ($cargoExists) { cargo install --git 'https://github.com/astral-sh/rye' rye }
				else { Write-Warning "Command not found: cargo. Could not install 'rye'. Please install it manually"; break }
			}

			if (!(Test-Path "$projectsRoot\$projectName" -PathType Container)) {
				rye init $projectName
			}

			Set-Location "$projectsRoot\$projectName"

			if ($flask) { rye add flask --quiet }
			if ($django) {
				if (Test-Path "$projectsRoot\$projectName\src\$subProjectName" -PathType Container) {
					Remove-Item "$projectsRoot\$projectName\src\$subProjectName" -Force -Recurse -ErrorAction SilentlyContinue
				}
				rye add django --quiet
				rye run django-admin startproject $subProjectName src
			}

			rye sync

			# Virtual environment
			& ("$projectsRoot\$projectName\.venv\Scripts\activate.ps1")
			Write-Success -Entry1 "Virtual Environment .venv in" -Entry2 "$projectsRoot\$projectName" -Text "activated."
		}
	}
}

function Initialize-Project {
	#requires -Module PSToml

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Define the name of your project')]
		[Alias('n', 'p')][string]$Project,

		[Parameter(Mandatory = $true, HelpMessage = 'Define main language of your project. Available options: [powershell | node | rust | python]')]
		[ArgumentCompletions('powershell', 'node', 'rust', 'python')]
		[Alias('l')][string]$Language,

		[Parameter(HelpMessage = 'Whether or not to project GitHub Repository')]
		[Alias('g')][switch]$GitHub,

		[Parameter(HelpMessage = 'Whether or not to open the project in Visual Studio Code Editor')]
		[Alias('v')][switch]$VSCode
	)

	# Prerequisites
	# Use DevDrive to store projects directories
	$mainProjectsDir = "$(Get-DevDrive)\projects"
	if (-not (Test-Path -Path $mainProjectsDir -PathType Container)) { New-Item -ItemType Directory -Path "$mainProjectsDir" -Force -ErrorAction SilentlyContinue | Out-Null }

	# gum
	$gumExists = Get-Command gum -ErrorAction SilentlyContinue
	if (-not $gumExists) { Write-Warning "Command not found: gum. Please install to use this function."; return }
	Remove-Variable gumExists

	# github cli
	$ghExists = Get-Command gh -ErrorAction SilentlyContinue
	if (-not $ghExists) { Write-Warning "Command not found: gh. Please install to use this function."; return }
	Remove-Variable ghExists

	# Login into GitHub account with GitHub CLI
	if (!(Test-Path "$env:APPDATA\GitHub CLI\hosts.yml")) { gh auth login }

	# Main variables
	$Author = (git config user.name).Trim()
	$Description = (gum input --prompt="Description for your $Project project: ").Trim()
	$License = (gum choose --header="Choose a License:" "AGPL-3.0" "Apache-2.0" "BSD-2-Clause" "BSD-3-Clause" "BSL-1.0" "CC0-1.0" "EPL-2.0" "GPL-2.0" "GPL-3.0" "LGPL-2.1" "MIT" "MPL-2.0" "Unlicense").Trim()
	$UserID = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()

	# print table
	$tableHeading = (gum style --bold --italic --border="rounded" --padding="0 4" --align="center" --foreground="#cba6f7" --border-foreground="#89b4fa" "PROJECT'S BASIC SETTINGS CONFIGURATION")
	$tableHeading
	$table = New-Object System.Data.DataTable
	[void]$table.Columns.Add("ENTRY")
	[void]$table.Columns.Add("VALUE")
	[void]$table.Rows.Add("Name", "$Project")
	[void]$table.Rows.Add("Language", "$Language")
	[void]$table.Rows.Add("License", "$License")
	[void]$table.Rows.Add("Author", "$Author")
	[void]$table.Rows.Add("UserID", "$UserID")
	[void]$table.Rows.Add("Description", "$Description")
	$table | Format-Table
	Write-Host "-----------------------------------------------" -ForegroundColor DarkGray

	switch ($Language) {
		'node' {
			$invokeNode = "Initialize-ProjectPerLangNode -projectName $Project"
			$settings = (gum choose --no-limit --header="Choose Project's Settings:" "Typescript" "TailwindCSS").Trim()
			switch ($settings) {
				{ $_ -match 'Typescript' } { $invokeNode += " -typescript" }
				{ $_ -match 'TailwindCSS' } { $invokeNode += " -tailwind" }
			}
			Invoke-Expression $invokeNode

			# .gitignore
			if (Test-Path "$mainProjectsDir\$Project" -PathType Container) {
				$overWrite = $(Write-Host "Overwrite existing .gitignore file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($overWrite.ToUpper() -eq 'Y') { Initialize-ProjectGitignore -projectName $Project -lang node -force }
			} else {
				Initialize-ProjectGitignore -projectName $Project -lang node
			}
		}

		'python' {
			$invokePy = "Initialize-ProjectPerLangPython -projectName $Project"
			$settings = (gum choose --no-limit --header="Choose Project's Settings:" "Django" "Flask")
			switch ($settings) {
				{ $_ -match 'Django' } { $invokePy += " -django" }
				{ $_ -match 'Flask' } { $invokePy += " -flask" }
			}
			Invoke-Expression $invokePy

			# .gitignore
			if (Test-Path "$mainProjectsDir\$Project" -PathType Container) {
				$overWrite = $(Write-Host "Overwrite existing .gitignore file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($overWrite.ToUpper() -eq 'Y') { Initialize-ProjectGitignore -projectName $Project -lang python -force }
			} else {
				Initialize-ProjectGitignore -projectName $Project -lang python
			}
		}

		'powershell' {
			Set-Location "$mainProjectsDir"
			if (!(Test-Path "$mainProjectsDir\$Project" -PathType Container)) {
				New-Item -Path "$mainProjectsDir\$Project" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
			}

			$projectLocation = "$mainProjectsDir\$Project"
			Set-Location "$projectLocation"

			if (!(Get-Module -ListAvailable -Name 'PSScriptAnalyzer' -ErrorAction SilentlyContinue)) {
				Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -AllowClobber
			}

			# .gitignore
			if (Test-Path "$mainProjectsDir\$Project" -PathType Container) {
				$overWrite = $(Write-Host "Overwrite existing .gitignore file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($overWrite.ToUpper() -eq 'Y') { Initialize-ProjectGitignore -projectName $Project -lang powershell -force }
			} else {
				Initialize-ProjectGitignore -projectName $Project -lang powershell
			}
		}

		'rust' {
			if (!(Get-Command cargo -ErrorAction SilentlyContinue)) { Write-Warning "Command not found: cargo. Please install to use this feature."; break }
			Set-Location "$mainProjectsDir"

			cargo new $Project
			Set-Location "$mainProjectsDir\$Project"

			# Cargo.toml
			$cargoToml = "$mainProjectsDir\$Project\Cargo.toml"
			$cargo = Get-Content $cargoToml | ConvertFrom-Toml
			$cargo.package.description = "$Description"
			$cargo.package.license = "$License"
			$cargo.package.homepage = "https://github.com/$UserID/$Project"
			$cargo.package.authors = [array]@("$Author <$(git config user.email)>")
			$cargo.package.include = [array]@("src/**/*", "*.md")
			Set-Content "$cargoToml" -Value ($cargo | ConvertTo-Toml -Depth 100)

			# .gitignore
			if (Test-Path "$mainProjectsDir\$Project" -PathType Container) {
				$overWrite = $(Write-Host "Overwrite existing .gitignore file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($overWrite.ToUpper() -eq 'Y') { Initialize-ProjectGitignore -projectName $Project -lang rust -force }
			} else {
				Initialize-ProjectGitignore -projectName $Project -lang rust
			}
		}

		Default { Write-Warning "Language $Language does not support for this function. Exiting..."; break }
	}

	# git
	$invokeGit = "Initialize-ProjectGit -projectName $Project -author $Author -desc $Description -license $License -userid $UserID"
	if ($GitHub) { $invokeGit += " -ghRepo" }
	Invoke-Expression $invokeGit

	$newReadme = "Initialize-ProjectReadme -projectName $Project"
	$readme = "$mainProjectsDir\$Project\README.md"
	if (Test-Path "$mainProjectsDir\$Project\README*") {
		if (Get-Command 'bat' -ErrorAction SilentlyContinue) { gum confirm "Found README.md in your project root. Show now? (y/n) " && bat $readme }
		else { gum confirm "Found README.md in your project root. Show now? (y/n) " && Get-Content $readme }

		$prompt = $(Write-Host "Overwrite current README.md file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($prompt.ToUpper() -eq 'Y') {
			$newReadme += " -force"
		}
	}
	Invoke-Expression $newReadme


	# vscode
	if ($VSCode) { Open-ProjectDirInVSCode -projectName $Project }
}

Set-Alias -Name 'New-Project' -Value 'Initialize-Project'
Set-Alias -Name 'proj' -Value 'Initialize-Project'
