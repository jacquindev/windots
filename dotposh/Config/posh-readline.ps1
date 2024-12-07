#requires -Module PSReadline
#requires -Module PSFzf
#requires -Module CompletionPredictor

<#
    .SYNOPSIS
        PSReadLine & PSFzf Configuration File.
    .DESCRIPTION
        This script is automatically sourced by PowerShell and setup PSReadLine & PSFzf Settings
        into current process.
    .NOTES
        !! This script is already included in my PowerShell profile (.ps1), not executed directly.
#>

# Catppuccin (syntax highlighting)
# -----------------------------------------------------------------
# Install Catppuccin PowerShell module if not already installed
if (-not (Get-Module -ListAvailable -Name Catppuccin -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PowerShell Module Catppuccin..." -ForegroundColor "Green"
    git clone "https://github.com/catppuccin/powershell.git" "$env:USERPROFILE\Documents\PowerShell\Modules\Catppuccin"
}

Import-Module Catppuccin
$Flavor = $Catppuccin['Mocha']

# PSReadline
# ----------------------------------------------------------------
$PSReadLineOptions = @{
    BellStyle                     = "None"
    Colors                        = @{
        ContinuationPrompt     = $Flavor.Teal.Foreground()
        Emphasis               = $Flavor.Red.Foreground()
        Selection              = $Flavor.Surface0.Background()
        InlinePrediction       = $Flavor.Overlay0.Foreground()
        ListPrediction         = $Flavor.Mauve.Foreground()
        ListPredictionSelected = $Flavor.Surface0.Background()
        Command                = $Flavor.Blue.Foreground()
        Comment                = $Flavor.Overlay0.Foreground()
        Default                = $Flavor.Text.Foreground()
        Error                  = $Flavor.Red.Foreground()
        Keyword                = $Flavor.Mauve.Foreground()
        Member                 = $Flavor.Rosewater.Foreground()
        Number                 = $Flavor.Peach.Foreground()
        Operator               = $Flavor.Sky.Foreground()
        Parameter              = $Flavor.Pink.Foreground()
        String                 = $Flavor.Green.Foreground()
        Type                   = $Flavor.Yellow.Foreground()
        Variable               = $Flavor.Lavender.Foreground()
    }
    ExtraPromptLineCount          = $True
    HistoryNoDuplicates           = $True
    HistorySearchCursorMovesToEnd = $True
    MaximumHistoryCount           = 4096
    PredictionSource              = "HistoryAndPlugin"
    PredictionViewStyle           = "ListView"
    PromptText                    = ''
    ShowToolTips                  = $True
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# F1 for help on the command line
$parameters = @{
    Key              = "F1"
    BriefDescription = "Command Help"
    LongDescription  = "Invoke the help window for the current command or prompt."
    ScriptBlock      = {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $commandAst = $ast.FindAll( {
                $node = $args[0]
                $node -is [CommandAst] -and
                $node.Extent.StartOffset -le $cursor -and
                $node.Extent.EndOffset -ge $cursor
            }, $true) | Select-Object -Last 1

        if ($commandAst -ne $null) {
            $commandName = $commandAst.GetCommandName()
            if ($commandName -ne $null) {
                $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
                if ($command -is [AliasInfo]) {
                    $commandName = $command.ResolvedCommandName
                }

                if ($commandName -ne $null) {
                    Get-Help $commandName -ShowWindow
                }
            }
        }
    }
}
Set-PSReadLineKeyHandler @parameters

# Reference: copy from
# - https://ianmorozoff.com/2023/01/10/predictive-intellisense-on-by-default-in-powershell-7-3/#keybinding
$parameters1 = @{
    Key              = "F4"
    BriefDescription = "Toggle PSReadLineOption PredictionSource"
    LongDescription  = "Toggle PSReadLineOption PredictionSource option between 'None' and 'HistoryAndPlugin'"
    ScriptBlock      = {
        # Get the current state of PredictionSource
        $state = (Get-PSReadLineOption).PredictionSource

        # Toggle between None and HistoryAndPlugin
        switch ($state) {
            "None" { Set-PSReadLineOption -PredictionSource HistoryAndPlugin }
            "History" { Set-PSReadLineOption -PredictionSource None }
            "Plugin" { Set-PSReadLineOption -PredictionSource None }
            "HistoryAndPlugin" { Set-PSReadLineOption -PredictionSource None }
            Default { Write-Host "Current PSReadlineOption PredictionSource is Unknown" -ForegroundColor "Cyan" }
        }

        # Trigger autocomplete to appear without changing the line
        # InvokePrompt() does not cause ListView style suggestions to disappear when toggling off
        # [Microsoft.PowerShell.PSConsole.ReadLine]::InvokePrompt()

        # Trigger autocomplete to appear or disappear while preserving the current input
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
    }
}
Set-PSReadLineKeyHandler @parameters1

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
$parameters2 = @{
    Key              = "F7"
    BriefDescription = "Toggle History"
    LongDescription  = "Show Command History"
    ScriptBlock      = {
        $pattern = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
        if ($pattern) { $pattern = [regex]::Escape($pattern) }

        $history = [System.Collections.ArrayList]@(
            $last = ''
            $lines = ''
            foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
                if ($line.EndsWith('`')) {
                    $line = $line.Substring(0, $line.Length - 1)
                    $lines = if ($lines) { "$lines`n$line" } else { $line }
                    continue
                }
                if ($lines) { $line = "$lines`n$line"; $lines = '' }
                if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) { $last = $line; $line }
            }
        )
        $history.Reverse()

        $command = $history | Out-GridView -Title History -PassThru
        if ($command) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
        }
    }
}
Set-PSReadLineKeyHandler @parameters2

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
$parameters3 = @{
    Key              = 'Alt+('
    BriefDescription = "Parenthesize Selection"
    LongDescription  = "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis"
    ScriptBlock      = {
        param($key, $arg)
        $selectionStart = $null
        $selectionLength = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($selectionStart -ne 1) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        }
    }
}
Set-PSReadLineKeyHandler @parameters3

# Each time you press Alt+', this key handler will change the token
# under or before the cursor.  It will cycle through single quotes, double quotes, or
# no quotes each time it is invoked.
$parameters4 = @{
    Key              = "Alt+'"
    BriefDescription = "Toggle Quote Argument"
    LongDescription  = "Toggle quotes on the argument under the cursor"
    ScriptBlock      = {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $tokenToChange = $null
        foreach ($token in $tokens) {
            $extent = $token.Extent
            if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
                $tokenToChange = $token

                # If the cursor is at the end (it's really 1 past the end) of the previous token,
                # we only want to change the previous token if there is no token under the cursor
                if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
                    $nextToken = $foreach.Current
                    if ($nextToken.Extent.StartOffset -eq $cursor) {
                        $tokenToChange = $nextToken
                    }
                }
                break
            }
        }

        if ($tokenToChange -ne $null) {
            $extent = $tokenToChange.Extent
            $tokenText = $extent.Text
            if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
                # Switch to no quotes
                $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
            } elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
                # Switch to double quotes
                $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
            } else {
                # Add single quotes
                $replacement = "'" + $tokenText + "'"
            }

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacement)
        }
    }
}
Set-PSReadLineKeyHandler @parameters4

# This example will replace any aliases on the command line with the resolved commands.
$parameters5 = @{
    Key              = "Alt+%"
    BriefDescription = "Expand Aliases"
    LongDescription  = "Replace any aliases on the command line with the resolved commands"
    ScriptBlock      = {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $startAdjustment = 0
        foreach ($token in $tokens) {
            if ($token.TokenFlags -band [TokenFlags]::CommandName) {
                $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
                if ($alias -ne $null) {
                    $resolvedCommand = $alias.ResolvedCommandName
                    if ($resolvedCommand -ne $null) {
                        $extent = $token.Extent
                        $length = $extent.EndOffset - $extent.StartOffset
                        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                            $extent.StartOffset + $startAdjustment,
                            $length,
                            $resolvedCommand)

                        # Our copy of the tokens won't have been updated, so we need to
                        # adjust by the difference in length
                        $startAdjustment += ($resolvedCommand.Length - $length)
                    }
                }
            }
        }
    }
}
Set-PSReadLineKeyHandler @parameters5


# PSFzf
# ----------------------------------------------------------------
$ENV:FZF_DEFAULT_OPTS = @"
--color=bg+:$($Flavor.Surface0),bg:$($Flavor.Base),spinner:$($Flavor.Rosewater)
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
--border="rounded" --border-label="" --preview-window="border-rounded" --padding="2"
--margin="3" --prompt="➽ " --marker="❯ " --pointer="✦ "
--separator="─" --scrollbar="❚" --layout="reverse" --info="right"
"@

$commandOverride = [ScriptBlock] { param($Location) Write-Host $Location }
$PSFzfOptions = @{
    AltCCommand                   = $commandOverride
    PSReadlineChordProvider       = "Ctrl+t"
    PSReadlineChordReverseHistory = "Ctrl+r"
    GitKeyBindings                = $True
    TabExpansion                  = $True
    EnableAliasFuzzyKillProcess   = $True
}
Set-PsFzfOption @PSFzfOptions

# Instead of using default aliases of PSFzf Helper Functions, I preferred my own aliases
Set-Alias -Name 'fze' -Value 'Invoke-FuzzyEdit'
Set-Alias -Name 'fzg' -Value 'Invoke-FuzzyGitStatus'
Set-Alias -Name 'fzh' -Value 'Invoke-FuzzyHistory'
Set-Alias -Name 'fzd' -Value 'Invoke-FuzzySetLocation'
Set-Alias -Name 'fzs' -Value 'Invoke-FuzzyScoop'

# Helper functions for fzf
function _fzf_open_path {
    param (
        [Parameter(Mandatory = $True)]
        [string]$InputPath
    )
    if ($InputPath -match "^.*:\d+:.*$") {
        $InputPath = ($InputPath -split ":")[0]
    }
    if (-not (Test-Path $InputPath)) { Return }

    $Cmds = @{
        'bat'    = { bat $InputPath }
        'cat'    = { Get-Content $InputPath }
        'cd'     = {
            if (Test-Path $InputPath -PathType Leaf) { $InputPath = Split-Path $InputPath -Parent }
            Set-Location $InputPath
        }
        'vim'    = { vim $InputPath }
        'remove' = { Remove-Item -Recurse -Force $InputPath }
        'echo'   = { Write-Output $InputPath }
    }
    $Cmd = $Cmds.Keys | fzf --prompt 'Select Command> '
    & $Cmds[$Cmd]
}

function _fzf_get_path_using_fd {
    $InputPath = fd --type file --follow --hidden --exclude .git |
    fzf --prompt 'Files> ' `
        --header-first `
        --header 'CTRL-T: Switch between Files/Directories' `
        --bind 'ctrl-t:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
        --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --colour=always --icons=always {})'
    return $InputPath
}

function _fzf_get_path_using_rg {
    $INITIAL_QUERY = "${*:-}"
    $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
    $InputPath = "" |
    fzf --ansi --disabled --query "$INITIAL_QUERY" `
        --bind "start:reload:$RG_PREFIX {q}" `
        --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
        --bind 'ctrl-t:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& type %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& type %TEMP%\rg-fzf-f)' `
        --color 'hl:-1:underline,hl+:-1:underline:reverse' `
        --delimiter ':' `
        --prompt '1. ripgrep> ' `
        --preview-label 'Preview' `
        --header 'CTRL-T: Switch between ripgrep/fzf' `
        --header-first `
        --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
        --preview-window 'up,60%,border-bottom,+{2}+3/3'
    return $InputPath
}

function fdz { _fzf_open_path $(_fzf_get_path_using_fd) }
function rgz { _fzf_open_path $(_fzf_get_path_using_rg) }

Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdz")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgz")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
