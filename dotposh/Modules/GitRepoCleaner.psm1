<#
.SYNOPSIS
	Remove large files / unwanted secrets of your git repository
.DESCRIPTION
	- Must have `BFG`, `JAVA` and `GitHub CLI` installed.
	- `Remove-GitLargeFiles` should and only should be used within your personal git repo.
.NOTES
	Filename: GitRepoCleaner.psm1
	Author: Jacquin Moon
	Email: jacquindev@outlook.com
	Date: January 26th, 2025

#>

function bfg {
	# Assume that you installed bfg somewhere in user's `HOME` directory
	$bfgFile = (Get-ChildItem -Path "$Env:USERPROFILE" -Recurse -Filter "bfg.jar" -ErrorAction SilentlyContinue).FullName

	if (Test-Path "$bfgFile" -PathType Leaf) {
		java -jar $bfgFile $args
	} else {
		Write-Warning "File not found: bfg.jar. Please install 'BFG' to continue."
		Write-Host "Exiting..." -ForegroundColor DarkGray
		return
	}
}

function Remove-GitUnwantedData {
	[alias('git-unwanted')]
	param (
		[Parameter(Mandatory = $True, Position = 0)]
		[string]$RepoName,

		[Alias('lf')][switch]$LargeFiles,
		[string]$Size = "100M",

		[Alias('sd')][switch]$SensitiveData,
		[string]$FileName,
		[switch]$FolderName
	)

	$VerbosePreference = "SilentlyContinue"

	$currentLocation = "$($(Get-Location).Path)"
	$gitRepo = "$RepoName.git"
	$backupDate = Get-Date -Format "dd/MM/yyyy_HH:mm:ss"

	Write-Verbose "Clone a fresh copy of your $RepoName (bare repo)"
	gh repo clone $RepoName -- --mirror

	Write-Verbose "Make backup for bare $RepoName to $gitRepo_$backupDate.bak"
	Copy-Item -Path "$currentLocation/$gitRepo" -Destination "$currentLocation/$gitRepo_$backupDate.bak" -Recurse -Force -ErrorAction SilentlyContinue

	if ($LargeFiles) {
		Write-Verbose "Clean repo $RepoName using BFG"
		bfg --strip-blobs-bigger-than $Size $gitRepo
	} elseif ($SensitiveData) {
		Write-Verbose "Remove sensitive data from Git repo"
		$bfgArg = ""
		if ($FileName) { $bfgArg += " --delete-files $FileName" }
		if ($FolderName) { $bfgArgs += " --delete-folders $FolderName" }
		if (!$FileName -and !$FolderName) { return }
		bfg $bfgArg $gitRepo
	}

	Set-Location "$currentLocation/$gitRepo"
	Write-Verbose "Examine the repo to make sure history has been updated."
	git reflog expire --expire=now --all

	Write-Verbose "Use 'git gc' command to strip out the unwanted dirty data"
	git gc --prune=now --aggressive

	$updateRefs = $(Write-Host "Are you happy with the updated state of current $repoDir? (y/N) " -ForegroundColor Magenta -NoNewline; Read-Host )
	if ($updateRefs.ToUpper() -eq 'Y') {
		Write-Host "Pushing new updates for all refs on your remote repository server..." -ForegroundColor Blue
		git push
	}

	Set-Location "$currentLocation"

}

Export-ModuleMember -Function Remove-GitUnwantedData -Alias git-unwanted
