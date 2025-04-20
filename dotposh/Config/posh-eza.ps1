
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
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -al --sort=modified @Path
}
function Invoke-EzaDir {
	[alias('lD')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lDa --show-symlinks --time-style=relative @Path
}
function Invoke-EzaFile {
	[alias('lF')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lfa --show-symlinks --time-style=relative @Path
}
function Invoke-EzaList {
	[alias('ll')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first -lbhHigUmuSa --time-style=relative --sort=modified --reverse @Path
}
function Invoke-EzaOneline {
	[alias('lo')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first --oneline @Path
}
function Invoke-EzaTree {
	[alias('tree')]
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]]$Path
	)
	eza.exe --icons --header --hyperlink --group --git -I='*NTUSER.DAT*|*ntuser.dat*' --group-directories-first --tree @Path
}

