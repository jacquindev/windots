# scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "scoop-completion" -ErrorAction SilentlyContinue)) {
        if (!($(scoop bucket list).Name -eq "extras")) { scoop bucket add extras }
        scoop install scoop-completion
    }
    Import-Module scoop-completion -Global
}
