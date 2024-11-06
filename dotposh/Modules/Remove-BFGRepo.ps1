function Remove-BFGRepo {
    <#
    .DESCRIPTION
        This function requires you installed java and bfg-repo-cleaner to work properly.
        BFG will update your commits and all branches and tags so they are clean.
    .LINK
        https://rtyley.github.io/bfg-repo-cleaner/
    .EXAMPLE
        git clone --mirror git://example.com/some-repo.git
        Remove-BFGRepo -repo some-repo.git -size 50M
    #>
    [CmdletBinding()]
    param(
        [Alias('path')][string]$repo,
        [string]$size = '100M'
    )

    $currentDir = "$($PWD)"
    if (Test-Path $repo) {
        $scoopDir = Split-Path (Get-Command scoop.ps1).Source | Split-Path
        $bfgJarFile = (Get-ChildItem -Path "$scoopDir" -Recurse -Filter "bfg.jar" -ErrorAction SilentlyContinue).FullName
        java -jar $bfgJarFile --strip-blobs-bigger-than $size $repo
        Set-Location $repo
        git reflog expire --expire=now --all && git gc --prune=now --aggressive
        git push
        Set-Location $currentDir
    }
    else {
        Write-Error "Repository '$repo' not found."
    }
}

Set-Alias -Name 'bfg-clean' -Value 'Remove-BFGRepo'