function Get-PrevAst {
	param ($commandAst, $cursorPosition)
	$c = $commandAst.ToString()
	$prev = $commandAst.CommandElements[-1].ToString()
	if ($cursorPosition -le $c.Length) {
		$r = $c.LastIndexOf(" ", $cursorPosition)
		$l = $c.LastIndexOf(" ", $r - 1)
		while ($c[$r - 1] -eq ' ') {
			$r = $r - 1
		}
		$prev = $c.Substring($l + 1, $r - $l - 1)
	}
	return $prev
}
