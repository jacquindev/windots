# ----------------------------------------------------------------------------------- #
# Completions:                                                                        #
# ----------------------------------------------------------------------------------- #

# dotnet
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# azure
if (Get-Module -ListAvailable -Name Azure -ErrorAction SilentlyContinue) {
    if ($($PSVersionTable.PSEdition) -like "Core") {
        if (-not (Get-Module -ListAvailable -Name "Az.Tools.Predictor" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing PowerShell Module: Az.Tools.Predictor" -ForegroundColor "Green"
            Install-Module -Name "Az.Tools.Predictor" -AcceptLicense -Scope CurrentUser -Force
        }
        Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module Az.Tools.Predictor -Global } | Out-Null
    }
}

# scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "scoop-completion" -ErrorAction SilentlyContinue)) {
        if (!($(scoop bucket list).Name -eq "extras")) { scoop bucket add extras }
        scoop install scoop-completion
    }
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module scoop-completion -Global } | Out-Null
}

# npm (nodejs)
if (Get-Command npm -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "npm-completion" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell Module: npm-completion" -ForegroundColor "Green"
        Install-Module -Name "npm-completion" -AcceptLicense -Scope CurrentUser -Force
    }
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module npm-completion -Global } | Out-Null
}

# docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name "DockerCompletion" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell Module: DockerCompletion" -ForegroundColor "Green"
        Install-Module -Name "DockerCompletion" -AcceptLicense -Scope CurrentUser -Force
    }
    Set-Alias -Name 'd' -Value 'docker'
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action { Import-Module DockerCompletion -Global } | Out-Null
}

# kubectl
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        kubectl completion powershell | Out-String | Invoke-Expression
        Set-Alias -Name 'k' -Value 'kubectl'
        Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
    } | Out-Null
}