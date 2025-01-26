# npm (nodejs)
if (Get-Command npm -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "npm-completion" -ErrorAction SilentlyContinue)) {
        Install-Module -Name "npm-completion" -AcceptLicense -Scope CurrentUser -Force
    }
    Import-Module npm-completion -Global
}
