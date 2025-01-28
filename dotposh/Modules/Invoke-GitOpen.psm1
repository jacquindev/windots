<#
.SYNOPSIS
	Open Git Repository in Web Browser
.DESCRIPTION
	Open GitHub Repository in browser
	`https://github.com/{USERNAME}/{REPO}/tree/{branch}`
.PARAMETER Path
	Local path to the Git Repository
.EXAMPLE
	> Invoke-GitOpen
	Open github repo in current working directory

	> Invoke-GitOpen -Path C:\Users\{username}\dotfiles
	Open github repo of local git folder C:\Users\{username}\dotfiles
#>

function Invoke-GitOpen {
	[CmdletBinding()]
	[alias('git-open')]
	param (
		[string]$Path = "$($(Get-Location).Path)"
	)

	$currentLocation = "$($(Get-Location).Path)"

	# Exit immediately if `Path` is not a git repo
	$workingDir = (Resolve-Path $Path).Path
	if (!(Test-Path "$workingDir/.git" -PathType Container)) {
		Write-Warning "not a git repository (or any of the parent directories): .git"
		break
	}

	# Get git branch
	$branch = git -C $workingDir symbolic-ref -q --short HEAD

	# Use `gh` to open github repo
	if (Get-Command gh -ErrorAction SilentlyContinue) {
		Set-Location "$Path"
		gh repo view --branch $branch --web
		Set-Location $currentLocation
	}
	# Find the exact url to open github repo
	else {
		$remote = git -C $workingDir config "branch.$branch.remote"
		$gitUrl = git -C $workingDir remote get-url "$remote"

		if ($gitUrl -match '^[a-z\+]+://.*') {
			$gitProtocol = $gitUrl.Replace('://.*', '')
			$uri = $gitUrl -replace '.*://', ''
			$urlPath = $uri.Split('/', 2)[1]
			$domain = $uri.Split('/', 2)[0]

			if ($gitProtocol -ne 'https' -and $gitProtocol -ne 'http') {
				$domain = $domain -replace ':.*', ''
			}
		} else {
			$uri = $gitUrl -replace '.*@', ''
			$domain = $uri -replace ':.*', ''
			$urlPath = $uri -replace '.*?:', ''
		}

		$urlPath = $urlPath.TrimStart('/').TrimEnd('.git')
		if ($gitProtocol -eq 'http') { $protocol = 'http' }
		else { $protocol = 'https' }

		$openUrl = "${protocol}://$domain/$urlPath/tree/$branch"

		Write-Output "Opening $openUrl in your browser."
		Start-Process "$openUrl"
	}
}

Export-ModuleMember -Function Invoke-GitOpen -Alias git-open
