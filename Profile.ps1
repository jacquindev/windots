# 👾 Encoding UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 🔆 Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 🌏 Environment Variables
# -----------------------------------------------------------------------------------------
$Env:DOTFILES = Split-Path (Get-ChildItem $PSScriptRoot | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts).Target
$Env:DOTPOSH = Join-Path -Path "$Env:DOTFILES" -ChildPath "dotposh"

# 🧩 FastFetch
# -----------------------------------------------------------------------------------------
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}

# ⏳ Asynchronous Processes (Boost PowerShell performance)
# -----------------------------------------------------------------------------------------
# Original idea is from: https://matt.kotsenas.com/posts/pwsh-profiling-async-startup
function prompt {
    # oh-my-posh will override this prompt, however because we're loading it async we want to communicate that the
    # real prompt is still loading.
    "[async]:: $($executionContext.SessionState.Path.CurrentLocation) :: $(Get-Date -Format "HH:mm tt") $('❯' * ($nestedPromptLevel + 1)) "
}

# Load modules asynchronously to reduce shell startup time
[System.Collections.Queue]$__initQueue = @(
    {
        if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
            oh-my-posh init pwsh --config "$Env:DOTPOSH\posh-zen.toml" | Invoke-Expression
            $Env:POSH_GIT_ENABLED = $true
        }
    },
    {
        # posh-git
        if (Get-Module -ListAvailable -Name posh-git -ErrorAction SilentlyContinue) {
            Set-Alias -Name 'g' -Value 'git' -Scope Global -Force
            Import-Module posh-git -Global
        }

        # lazygit alias
        if (Get-Command lazygit -ErrorAction SilentlyContinue) {
            Set-Alias -Name 'lg' -Value 'lazygit' -Scope Global -Force
        }
    },
    {
        # git-aliases
        if (Get-Module -ListAvailable -Name git-aliases -ErrorAction SilentlyContinue) {
            Import-Module git-aliases -Global -DisableNameChecking
        }
    },
    {
        # GitHub CLI
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            # gh completion
            Invoke-Expression -Command $(gh completion -s powershell | Out-String)
        }
    },
    {
        # Fast scoop search drop-in replacement 🚀
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            if ((scoop info scoop-search).Installed) {
                New-Module -Name scoop-search -ScriptBlock {
                    Invoke-Expression (&scoop-search --hook)
                } | Import-Module -Global
            }
        }
    },
    {
        # chocolatey: `refreshenv`
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 -Global
        }
    },
    {
        # gsudo module
        if (Get-Command gsudo -ErrorAction SilentlyContinue) {
            $gsudoPath = Split-Path (Get-Command gsudo.exe).Path
            Import-Module "$gsudoPath\gsudoModule.psd1" -Global
        }
    },
    {
        if (Get-InstalledModule -Name "powershell-yaml" -ErrorAction SilentlyContinue) {
            Import-Module -Name powershell-yaml -Global
        }
    },
    {
        if (Get-InstalledModule -Name "Microsoft.PowerShell.SecretManagement" -ErrorAction SilentlyContinue) {
            Import-Module -Name Microsoft.PowerShell.SecretManagement -Global
        }
    },
    {
        if (Get-InstalledModule -Name "Microsoft.PowerShell.SecretStore" -ErrorAction SilentlyContinue) {
            Import-Module -Name Microsoft.PowerShell.SecretStore -Global
        }
    },
    {
        if (Get-InstalledModule -Name "Terminal-Icons" -ErrorAction SilentlyContinue) {
            Import-Module -Name Terminal-Icons -Global
        }
    },
    {
        # Default editor: VSCode
        if (Get-Command code -ErrorAction SilentlyContinue) {
            $Env:EDITOR = "code"
        }
    },
    {
        # Python encoding
        if (Get-Command python -ErrorAction SilentlyContinue) {
            $Env:PYTHONIOENCODING = "utf-8"
        }
    },
    {
        # UV settings
        if (Get-Command uv -ErrorAction SilentlyContinue) {
            $Env:UV_LINK_MODE = "copy"
        }
    },
    {
        # Pipenv settings
        if (Get-Command pipenv -ErrorAction SilentlyContinue) {
            $Env:PIPENV_VENV_IN_PROJECT = $true
            $Env:PIPENV_NO_INHERIT = $true
            $Env:PIPENV_IGNORE_VIRTUALENVS = $true
        }
    },
    {
        # yazi
        if (Get-Command yazi -ErrorAction SilentlyContinue) {
            New-Module -ScriptBlock {
                function y {
                    $tmp = [System.IO.Path]::GetTempFileName()
                    yazi $args --cwd-file="$tmp"
                    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
                        Set-Location -LiteralPath $cwd
                    }
                    Remove-Item -Path $tmp
                }
            } | Import-Module -Global
        }
    },
    {
        # zoxide
        if (Get-Command zoxide -ErrorAction SilentlyContinue) {
            $Env:_ZO_DATA_DIR = "$Env:DOTFILES"
            Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
        }
    }
)

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -SupportEvent -Action {
    if ($__initQueue.Count -gt 0) {
        & $__initQueue.Dequeue()
    } else {
        Unregister-Event -SubscriptionId $EventSubscriber.SubscriptionId -Force
        Remove-Variable -Name '__initQueue' -Scope Global -Force
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

# 🎲 DOTPOSH Configuration + Completion + Custom Modules
# -----------------------------------------------------------------------------------------
foreach ($module in $((Get-ChildItem -Path "$env:DOTPOSH\Modules\*" -Include *.psm1).FullName )) {
    Import-Module "$module" -Global
}
foreach ($file in $((Get-ChildItem -Path "$env:DOTPOSH\Config\*" -Include *.ps1 -Recurse | Sort-Object -Property Directory).FullName)) {
    . "$file"
}
