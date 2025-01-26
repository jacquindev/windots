if (Get-Command yarn -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name 'yarn-completion' -ErrorAction SilentlyContinue)) {
        Install-Module yarn-completion -AcceptLicense -Scope CurrentUser -Force
    }
    Import-Module yarn-completion -Global
}
