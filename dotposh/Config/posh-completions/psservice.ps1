Register-ArgumentCompleter -Native -CommandName @('PsService', 'PsService.exe') -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorPosition)

	$prev = Get-PrevAst $commandAst $cursorPosition

	switch ($prev) {
		"query" { "service", "group", "type", "state", "-g", "-t", "-s" | Where-Object { $_ -like "$wordToComplete*" } }
		("-t", "type" | Select-String -Pattern $prev -SimpleMatch) { "driver", "service", "interactive", "all" | Where-Object { $_ -like "$wordToComplete*" } }
		("-s", "state" | Select-String -Pattern $prev -SimpleMatch) { "active", "inactive", "all" | Where-Object { $_ -like "$wordToComplete*" } }
		("start", "cont" | Select-String -Pattern $prev -SimpleMatch) {
			psservice query -s inactive | Select-String 'SERVICE_NAME' | Sort-Object -Unique | ForEach-Object { ($_ -split ' ')[1] } | Where-Object { $_ -like "$wordToComplete*" }
		}
		("stop", "restart", "pause" | Select-String -Pattern $prev -SimpleMatch) {
			psservice query -s active | Select-String 'SERVICE_NAME' | Sort-Object -Unique | ForEach-Object { ($_ -split ' ')[1] } | Where-Object { $_ -like "$wordToComplete*" }
		}
		("config", "setconfig", "depend", "find", "security" | Select-String -Pattern $prev -SimpleMatch) {
			psservice query -s all | Select-String 'SERVICE_NAME' | Sort-Object -Unique | ForEach-Object { ($_ -split ' ')[1] } | Where-Object { $_ -like "$wordToComplete*" }
		}
	}

	if ($wordToComplete -like "-*" -or $prev -like "psservice*") {
		$psserviceCmds = 'query', 'config', 'setconfig', 'start', 'stop', 'restart', 'pause', 'cont', 'depend', 'find', 'security'
		$psserviceShortCmds = "$env:LOGONSERVER", '-u', '-p', '-nobanner', '-h', '-?'
		$psserviceCmds + $psserviceShortCmds | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object | ForEach-Object { $_ }
	}
}
