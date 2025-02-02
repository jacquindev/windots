# Sources:
# - https://github.com/artiga033/PwshComplete

function Get-SshConfigHosts {
	$configfile = "$HOME/.ssh/config"
	if (Get-Item $configfile -ErrorAction SilentlyContinue) {
		$config = Get-Content $configfile
		$m = $config | Select-String "Host\s+(?<name>.*$)"
		$m.Matches | ForEach-Object { $_.Groups["name"].Value }
	}
}
function Get-SshKnownHosts {
	$knownhostsfile = "$HOME/.ssh/known_hosts"
	if (Get-Item $knownhostsfile -ErrorAction SilentlyContinue) {
		$knownhosts = Import-Csv $knownhostsfile -Delimiter " " -Header "H"
		foreach ($h in $knownhosts.H) {	$h -split ',' }
	}
}

Register-ArgumentCompleter -CommandName ssh -Native -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)

	$options = "-4", "-6", "-A", "-a", "-C", "-f", "-G", "-g", "-K", "-k", "-M", "-N", "-n", "-q", "-s", "-T", "-t", "-V", "-v", "-X", "-x", "-Y", "-y", "-B", "-b", "-c", "-D", "-E", "-e", "-F", "-I", "-i", "-J", "-L", "-l", "-m", "-O", "-o", "-p", "-Q", "-R", "-S", "-W", "-w"
	$prev = Get-PrevAst $commandAst $cursorPosition

	switch -CaseSensitive ($prev) {
		"-b" {	Get-NetIPAddress | ForEach-Object { $_.IPAddress } | Where-Object { $_.IPAddress -like "$wordToComplete*" } }
		"-c" { ssh -Q cipher | Where-Object { $_ -like "$wordToComplete*" } }
		"-l" { Get-LocalUser | ForEach-Object { $_.Name } | Where-Object { $_ -like "$wordToComplete*" } }
		"-m" { ssh -Q mac | Where-Object { $_ -like "$wordToComplete*" } }
		"-O" { "check" , "forward" , "cancel", "exit" , "stop" | Where-Object { $_ -like "$wordToComplete*" } }
		"-w" { Get-NetIPInterface | ForEach-Object { $_.InterfaceAlias } | Where-Object { $_ -like "$wordToComplete*" } }
		Default {}
	}

	if ($wordToComplete -eq "-") {
		$options | Sort-Object -CaseSensitive
	} else {
		$c = Get-SshConfigHosts | Sort-Object -Unique
		$k = Get-SshKnownHosts | Sort-Object -Unique

		$all = $c + $k

		$atIndex = $wordToComplete.IndexOf('@')
		if ($atIndex -ne -1) {
			$prefix = $wordToComplete.SubString(0, $atIndex + 1)
			$all = $all | ForEach-Object { "$prefix$_" }
		}
		$all | Where-Object { $_ -like "$($wordToComplete)*" }
	}
}

Register-ArgumentCompleter -CommandName scp -Native -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	if ($wordToComplete -eq "-") {}
	else {
		$c = Get-SshConfigHosts | Sort-Object -Unique
		$k = Get-SshKnownHosts | Sort-Object -Unique
		$c + $k | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { "${_}:" }
	}
}
