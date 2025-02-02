# Sources:
# - https://github.com/artiga033/PwshComplete

function Get-KeyCompletions {
	$o = gpg --list-keys --keyid-format LONG

	# uids
	$m = $o | Select-String -Pattern "^uid.*]\s(?<username>.*)\s<(?<email>.*@.*)>"
	$set = New-Object System.Collections.Generic.HashSet[String] # uids may repeat, we do not want this
	foreach ($i in $m) {
		$g = $i.Matches[0].Groups
		[void]$set.Add( $g["username"].Value)
		[void]$set.Add( $g["email"].Value)
	}
	$set | ForEach-Object { $_ }
	# keyids
	$m = $o | Select-String -Pattern "^pub.*/(?<keyid>[0-9,A-Z]*) "
	foreach ($i in $m) { $i.Matches[0].Groups["keyid"].Value }
}

Register-ArgumentCompleter -CommandName gpg -Native -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)

	$prev = Get-PrevAst $commandAst $cursorPosition

	switch ($prev) {
		("--export" , "--sign-key" , "--lsign-key" , "--nrsign-key" , "--nrlsign-key" , "--edit-key", "--recipient", "-r", "--local-user", "-u" | Select-String -Pattern $prev -SimpleMatch -CaseSensitive ) {
			Get-KeyCompletions | Sort-Object | Where-Object {	$_ -like "$wordToComplete*" }
		}
	}

	if ($wordToComplete -like "-*" -or $prev -like "gpg*") {
		$gpgShortOpts = @("-a", "-b", "-c", "-d", "-e", "-i", "-k", "-K", "-n", "-o", "-q", "-r", "-s", "-u", "-v", "-z")
		$gpgLongOpts = @(& gpg --dump-options | Sort-Object)
		$gpgShortOpts + $gpgLongOpts | Where-Object {	$_ -like "$wordToComplete*" } | ForEach-Object {	$_ }
	}
}
Register-ArgumentCompleter -CommandName gpgv -Native -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)

	if ($wordToComplete -like "-*") {
		$gpgvShortOpts = "-o", "-q", "-v"
		$gpgvLongOpts = "--ignore-time-conflict", "--keyring", "--output", "--quiet", "--status-fd", "--weak-digest"
		$gpgvShortOpts + $gpgvLongOpts | Where-Object {	$_ -like "$wordToComplete*" } | ForEach-Object { $_ }
	}
}
