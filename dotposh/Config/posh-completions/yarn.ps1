
<#PSScriptInfo

.VERSION 1.0

.GUID ff987cff-a0c5-47fd-9262-112bf0b883f8

.AUTHOR jacquinmoon@outlook.com

.COMPANYNAME

.COPYRIGHT 2025 Jacquin Moon. All rights reserved.

.TAGS

.LICENSEURI https://github.com/jacquindev/windots/blob/main/LICENSE

.PROJECTURI https://github.com/jacquindev/windots

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<#

.DESCRIPTION
  PowerShell Tab Completion for `yarn` cli version `4.6.0`

#>
Param()

Register-ArgumentCompleter -Native -CommandName yarn -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorColumn)

	$yarnCommands = 'add', 'bin', 'cache', 'config', 'constraints', 'dedupe', 'dlx', 'exect', 'explain', 'info', 'init', 'install', 'link', 'node', 'npm', 'pack', 'patch-commit', 'plugin', 'rebuild', 'remove', 'run', 'search', 'set', 'stage', 'unlink', 'unplug', 'up', 'upgrade-interactive', 'workspace', 'workspaces', 'why', '-h', '--help'

	$yarnShortParams = @{
		add                   = 'F E T C D P O i h'
		bin                   = 'v h'
		config                = 'h'
		constraints           = 'h'
		dedupe                = 's c h'
		explain               = 'h'
		exec                  = 'h'
		dlx                   = 'p q h'
		info                  = 'A R X h'
		init                  = 'p w i n h'
		install               = 'h'
		link                  = 'A p r h'
		pack                  = 'n o h'
		patch                 = 'u h'
		"patch-commit"        = 's h'
		rebuild               = 'h'
		remove                = 'A h'
		run                   = 'T B h'
		search                = 'h'
		stage                 = 'c r n h'
		unlink                = 'A h'
		unplug                = 'A R h'
		up                    = 'i F E T C R h'
		"upgrade-interactive" = 'h'
		version               = 'd i h'
		workspace             = 'h'
		why                   = 'R h'
	}

	$yarnLongParams = @{
		add                   = 'json fixed exact tilde caret dev peer optional prefer-dev interactive cached mode help'
		bin                   = 'verbose json help'
		config                = 'no-defaults json help'
		constraints           = 'fix json help'
		dedupe                = 'strategy check json mode help'
		dlx                   = 'package quiet help'
		explain               = 'json help'
		info                  = 'all recursive extra cache dependents manifest name-only virtuals json help'
		init                  = 'private workspace install name help'
		install               = 'json immutable immutable-cache refresh-lockfile check-cache check-resolutions inline-builds mode help'
		link                  = 'all private relative help'
		pack                  = 'install-if-needed dry-run json out help'
		patch                 = 'update json help'
		"patch-commit"        = 'save help'
		rebuild               = 'help'
		remove                = 'all mode help'
		run                   = 'inspect inspect-brk top-level binaries-only require help'
		search                = 'help'
		stage                 = 'commit reset dry-run help'
		unlink                = 'all help'
		unplug                = 'all recursive json help'
		up                    = 'interactive fixed exact tilde caret recursive mode help'
		"upgrade-interactive" = 'help'
		version               = 'deferred immediate help'
		workspace             = 'help'
		why                   = 'recursive json peers help'
	}

	$yarnSubCommands = @{
		cache       = 'clean'
		config      = 'get', 'set', 'unset'
		constraints = 'query', 'source'
		explain     = 'peer-requirements'
		npm         = 'audit', 'info', 'login', 'logout', 'publish', 'tag add', 'tag list', 'tag remove', 'whoami'
		plugin      = 'check', 'import', 'list', 'remove'
		set         = 'resolution', 'version', 'version_from_sources'
		version     = 'apply', 'check'
		workspaces  = 'focus', 'foreach', 'list'
	}

	$yarnSubCommandShortParams = @{
		config      = @{
			set   = 'H h'
			unset = 'H h'
		}
		constraints = @{
			source = 'v h'
		}
		npm         = @{
			audit  = 'A R h'
			info   = 'f h'
			login  = 's h'
			logout = 's A h'
			whoami = 's h'
		}
		set         = @{
			'version from sources' = 'n f h'
		}
		plugin      = @{
			'import from sources' = 'f h'
		}
		version     = @{
			apply = 'R h'
			check = 'i h'
		}
		workspaces  = @{
			focus   = 'A h'
			foreach = 'A R W v p i j t n h'
			list    = 'R v h'
		}
	}

	$yarnSubCommandLongParams = @{
		cache       = @{ clean = 'mirror all help' }
		config      = @{
			get   = 'why json no-redacted help'
			set   = 'json home help'
			unset = 'home help'
		}
		constraints = @{
			query  = 'json help'
			source = 'verbose help'
		}
		npm         = @{
			audit        = 'all recursive environment json no-deprecations severity exclude ignore help'
			info         = 'fields json help'
			login        = 'scope publish always-auth help'
			logout       = 'scope publish all help'
			publish      = 'access tag tolerate-republish otp help'
			"tag add"    = 'help'
			"tag remove" = 'help'
			"tag list"   = 'json help'
			whoami       = 'scope publish help'
		}
		set         = @{
			version                = 'yarn-path only-if-needed help'
			"version from sources" = 'path repository branch plugin dry-run no-minify force skip-plugins help'
		}
		plugin      = @{
			check                 = 'json help'
			import                = 'checksums help'
			"import from sources" = 'path repository branch no-minify force help'
			list                  = 'json help'
			runtime               = 'json help'
		}
		version     = @{
			apply = 'all dry-run prerelease recursive json help'
			check = 'interactive help'
		}
		workspaces  = @{
			focus   = 'json production all help'
			foreach = 'from all recursive worktree verbose parallel interlaced jobs topological topological-dev include exclude no-private since dry-run help'
			list    = 'since recursive no-private verbose json help'
		}
	}

	$yarnCommandsShortParamValues = $yarnShortParams.Keys -join '|'
	$yarnCommandsLongParamValues = $yarnLongParams.Keys -join '|'
	$yarnSubcommandsShortParamValues = $yarnSubCommandShortParams.Keys -join '|'
	$yarnSubcommandsLongParamValues = $yarnSubCommandLongParams.Keys -join '|'


	function YarnExpandCmdParams($commands, $command, $filter) {
		$commands.$command | Where-Object { $_ -like "$filter*" }
	}
	function YarnExpandCmd($filter) {
		$yarnCommands -like "$filter*" | Sort-Object
	}
	function YarnExpandLongParams($cmd, $filter) {
		$yarnLongParams[$cmd] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
	}
	function YarnExpandShortParams($cmd, $filter) {
		$yarnShortParams[$cmd] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("-", $_) }
	}
	function YarnExpandSubcmdLongParams($cmd, $subcmd, $filter) {
		$yarnSubCommandLongParams[$cmd][$subcmd] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
	}
	function YarnExpandSubcmdShortParams($cmd, $subcmd, $filter) {
		$yarnSubCommandShortParams[$cmd][$subcmd] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("-", $_) }
	}

	function YarnTabExpansion($lastBlock) {
		switch -Regex ($lastBlock) {
			"^(?<cmd>$YarnSubcommandsLongParamValues).* (?<subcmd>.*) --(?<param>.+)$" {
				if ($yarnSubCommandLongParams[$matches['cmd']][$matches['subcmd']]) {
					return YarnExpandSubcmdLongParams $matches['cmd'] $matches['subcmd'] $matches['param']
				}
			}
			"^(?<cmd>$YarnSubcommandsShortParamValues).* (?<subcmd>.*) -(?<param>.+)$" {
				if ($yarnSubCommandShortParams[$matches['cmd']][$matches['subcmd']]) {
					return YarnExpandSubcmdShortParams $matches['cmd'] $matches['subcmd'] $matches['param']
				}
			}
			"^(?<cmd>$($yarnSubCommands.Keys -join '|'))\s+(?<op>\S*)$" {
				return YarnExpandCmdParams $yarnSubCommands $matches['cmd'] $matches['op']
			}
			"^(?<cmd>\S*)$" {
				return YarnExpandCmd $matches['cmd'] $true
			}
			"^(?<cmd>$yarnCommandsLongParamValues).* --(?<param>\S*)$" {
				return YarnExpandLongParams $matches['cmd'] $matches['param']
			}
			"^(?<cmd>$yarnCommandsShortParamValues).* -(?<shortparam>\S*)$" {
				return YarnExpandShortParams $matches['cmd'] $matches['shortparam']
			}
		}
	}

	$ownCommandLine = [string] $commandAst
	$ownCommandLine = $ownCommandLine.Substring(0, [Math]::Min($ownCommandLine.Length, $cursorColumn))
	$argList = (($ownCommandLine -replace '^\S+\s*') + ' ' * ($cursorColumn - $ownCommandLine.Length)).TrimStart()

	YarnTabExpansion $argList

}
