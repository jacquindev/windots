Register-ArgumentCompleter -Native -CommandName @('procdump64.exe', 'procdump.exe', 'procdump') -ScriptBlock {
	param ($wordToComplete, $commandAst, $cursorPosition)

	$prev = Get-PrevAst $commandAst $cursorPosition

	$processPIDs = (Get-Process -ErrorAction SilentlyContinue).Id | Sort-Object -Unique
	$processNames = (Get-Process -ErrorAction SilentlyContinue).ProcessName | Sort-Object -Unique
	$serviceNames = (Get-Service -ErrorAction SilentlyContinue).Name | Sort-Object -Unique

	$options = "-mm", "-ma", "-mt", "-mp", "-mc", "-md", "-mk"
	$generalOptions = "-n", "-s", "-m", "-ml", "-p", "-pl", "-l", "-t", "-f", "-fx", "-dc", "-o", "-at", "-wer", "-64", "-x", "-u", "-?", "-h", "-nobanner"

	switch ($prev) {
		("-c", "-cl" | Select-String -Pattern $prev -SimpleMatch) { "-u" | Where-Object { $_ -like "$wordToComplete*" } }
		"-cancel" { $processPIDs | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { $_ } }
		"-i" { $options, "-r", "-at", "-k", "-wer" | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { $_ } }
		"-e" { "1", "-g", "-b", "-ld", "-ud", "-ct", "-et" | Where-Object { $_ -like "$wordToComplete*" } }
		"-r" { "1", "2", "3", "4", "5", "-a" | Where-Object { $_ -like "$wordToComplete*" } }
		"-w" {	$processNames, $serviceNames, $processPIDs | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { $_ } }
		Default {}
	}

	if ($wordToComplete -like "-*" -or $prev -like "procdump*") {
		$options + $generalOptions | Sort-Object
	}
}
