function Get-WifiPassword {
    <#
    .SYNOPSIS
        Function to get wifi password
    .DESCRIPTION
        Prints password to the console
    .PARAMETER WifiName
        Determine the name of the Wi-Fi
    .EXAMPLE
        Get-WifiPassword
    .EXAMPLE
        Get-WifiPassword -name WIFINAME
    #>

    [CmdletBinding()]
    param ([Alias('n', 'name')][string]$WifiName)

    if (!$WifiName) {
        $wifiList = netsh wlan show profiles | Select-String -Pattern "All User Profile\s+:\s+(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }

        if (Get-Command gum -ErrorAction SilentlyContinue) {
            $WifiName = gum choose --header="Choose an available Wi-Fi name:" $wifiList
        }

        elseif (Get-Command fzf -ErrorAction SilentlyContinue) {
            $WifiName = $wifiList | fzf --prompt="Select Wi-Fi >  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
        }

        else {
            for ($i = 0; $i -lt $wifiList.Count; $i++) {
                Write-Host "[$i] $($wifiList[$i])"
            }
            $index = $(Write-Host "Enter the corresponding number of Wi-Fi name: " -ForegroundColor Magenta -NoNewline; Read-Host)
            if ($null -ne $index) {
                if ($index -match '^\d+$' -and [int]$index -lt $wifiList.Count) {
                    $WifiName = $wifiList[$index]
                } else { return }
            }
        }
    }

    $WifiPassword = netsh wlan show profile name="$WifiName" key=clear | Select-String -Pattern "Key Content\s+:\s+(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }

    if (!$WifiPassword) { Write-Warning "No password available for Wi-Fi $WifiName"; return }
    else {
        Write-Verbose "Prints password for Wi-Fi $WifiName"
        Write-Output $WifiPassword
    }
}

Set-Alias -Name 'wifipass' -Value 'Get-WifiPassword'
