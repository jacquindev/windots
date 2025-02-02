Register-ArgumentCompleter -Native -CommandName @('pslist', 'pslist64.exe', 'pslist.exe') -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorPosition)

	$prev = Get-PrevAst $commandAst $cursorPosition

	$options = "$env:LOGONSERVER", '-d', '-m', '-x', '-t', '-s', '-r', '-u', '-p', '-e', '-h', '-?', '-nobanner'

	$processPIDs = (Get-Process).Id | Sort-Object -Unique
	$processNames = (Get-Process).ProcessName | Sort-Object -Unique

	switch -Regex ($prev) {
		("^[0-9].*" | Select-String -Pattern $prev -SimpleMatch) { $processPIDS | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { $_ } }
		("^[a-zA-Z].*" | Select-String -Pattern $prev -SimpleMatch ) { $processNames | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { $_ } }
	}

	if ($wordToComplete -like "-*") {
		$options
	} else {
		$processPIDs + $processNames | Where-Object { $_ -like "$wordToComplete*" }
	}
}
