# powershell completion for nvm-for-windows
# nvm powershell completion start
$script:NvmCommands = @(
	'arch',
	'current',
	'debug',
	'install',
	'list',
	'ls',
	'on',
	'off',
	'proxy',
	'node_mirror',
	'npm_mirror',
	'uninstall',
	'reinstall',
	'subscribe',
	'unsubscribe',
	'use',
	'root',
	'v',
	'version'
)

$script:NvmSubcommands = @{
	install     = 'latest lts'
	arch        = '32 64'
	list        = 'available'
	ls          = 'available'
	use         = 'latest lts newest'
	subscribe   = 'lts current nvm4w author'
	unsubscribe = 'lts current nvm4w author'
}

function script:NvmExpandCmdParams($cmds, $cmd, $filter) {
	$cmds.$cmd -split ' ' | Where-Object { $_ -like "$filter*" }
}

function script:NvmExpandCmd($filter) {
	$cmdList = @()
	$cmdList += $NvmCommands
	$cmdList -like "$filter*" | Sort-Object
}

function script:NvmExpandParamValues($cmd, $param, $filter) {
	$NvmParamValues[$cmd][$param] -split ' ' |
	Where-Object { $_ -like "$filter*" } |
	Sort-Object
}

function script:NvmVersions($filter, $use) {
	$versions = @()
	if ($use) {
		$versions += $NvmSubcommands["use"] -split ' '
	}
	$versions += (Get-ChildItem -Recurse -Filter '*v*' -Path "$env:NVM_HOME" -Directory -ErrorAction SilentlyContinue |
		Where-Object { $_.FullName -notmatch 'node_modules' }).Name

	$versions -like "$filter*"
}

function script:NvmAvailableVersions($filter, $install) {
	$versions = @()
	if ($install) {
		$versions += $NvmSubcommands["install"] -split ' '
	}
	$versions += Invoke-WebRequest -UseBasicParsing -Uri https://nodejs.org/dist/index.json | ConvertFrom-Json | ForEach-Object { $_.version }
	$versions -like "$filter*"
}

function script:NvmTabExpansion($lastBlock) {
	switch -regex ($lastBlock) {
		# nvm uninstall <version>
		"^uninstall\s+(?:.+\s+)?(?<version>[\w][\-\.\w]*)?$" {
			return NvmVersions $matches['version'] $false
		}

		# nvm use <version>
		"^use\s+(?:.+\s+)?(?<version>[\w][\-\.\w]*)?$" {
			return NvmVersions $matches['version'] $true
		}

		# nvm install <version>
		"^install\s+(?:.+\s+)?(?<version>[\w][\-\.\w]*)?$" {
			return NvmAvailableVersions $matches['version'] $true
		}

		# nvm <cmd> <subcommand>
		"^(?<cmd>$($NvmSubcommands.Keys -join '|'))\s+(?<op>\S*)$" {
			return NvmExpandCmdParams $NvmSubcommands $matches['cmd'] $matches['op']
		}

		# nvm <cmd>
		"^(?<cmd>\S*)$" {
			return NvmExpandCmd $matches['cmd'] $true
		}
	}
}

Register-ArgumentCompleter -Native -CommandName @('nvm', 'nvm.exe') -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	$rest = $commandAst.CommandElements[1..$commandAst.CommandElements.Count] -join ' '
	if ($rest -ne "" -and $wordToComplete -eq "") {
		$rest += " "
	}
	NvmTabExpansion $rest
}
# nvm powershell completion end
