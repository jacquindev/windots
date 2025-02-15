
# eza
# ----------------------------------------------------------------------------------- #
if (!(Get-Command eza -ErrorAction SilentlyContinue)) { return }

function Invoke-Eza {
	[alias('ls')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first @Path
}
function Invoke-EzaAll {
	[alias('la')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -al --time-style=relative --sort=modified @Path
}
function Invoke-EzaDir {
	[alias('ld')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lDa --show-symlinks @Path
}
function Invoke-EzaFile {
	[alias('lf')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lfa --show-symlinks @Path
}
function Invoke-EzaList {
	[alias('ll')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lbhHigUmuSa @Path
}
function Invoke-EzaTtree {
	[alias('lt')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lT @Path
}
function Invoke-EzaTree {
	[alias('tree')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first --tree @Path
}

