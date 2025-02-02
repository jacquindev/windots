# References:
# -  https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html

Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)
	$env:COMP_LINE = $wordToComplete
	if ($env:COMP_LINE.Length -lt $cursorPosition) {
		$env:COMP_LINE = $env:COMP_LINE + " "
	}
	$env:COMP_POINT = $cursorPosition
	aws_completer.exe | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
	Remove-Item Env:\COMP_LINE
	Remove-Item Env:\COMP_POINT
}
