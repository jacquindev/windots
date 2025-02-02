Register-ArgumentCompleter -Native -CommandName @('pskill', 'pskill.exe', 'pskill64.exe') -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorPosition)

	$prev = Get-PrevAst $commandAst $cursorPosition

	$options = "-t", "$env:LOGONSERVER", "-u", "-p", "-h", "-?", "-nobanner"

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
