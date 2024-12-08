# powershell completion for nvm-for-windows

if (Get-Command nvm -ErrorAction SilentlyContinue) {
	# nvm powershell completion start
	$script:NvmCommands = @(
		'arch', 'current', 'debug', 'install', 'list', 'ls', 'on', 'off', 'proxy', 'node_mirror', 'npm_mirror', 'uninstall', 'use', 'root', 'v', 'version'
	)

	$script:NvmSubcommands = @{
		arch = '32 64'
		list = 'available'
		ls   = 'available'
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
		$versions += Get-ChildItem -Filter '*v*' -Path "$env:NVM_HOME\nodejs" -Directory -Name | Where-Object { $_ -like "$filter*" }
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

	Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
		Register-ArgumentCompleter -Native -CommandName @('nvm', 'nvm.exe') -ScriptBlock {
			param($wordToComplete, $commandAst, $cursorPosition)
			$rest = $commandAst.CommandElements[1..$commandAst.CommandElements.Count] -join ' '
			if ($rest -ne "" -and $wordToComplete -eq "") {
				$rest += " "
			}
			NvmTabExpansion $rest
		}
	} | Out-Null
	# nvm powershell completion end
}