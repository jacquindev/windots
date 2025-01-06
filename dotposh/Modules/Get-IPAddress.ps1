#requires -Module BurntToast

function Get-IPAddress {
    <#
    .SYNOPSIS
        Show current public or private IP address of the machine.
    .DESCRIPTION
        Function that enumerate the current public or private IP address.
    .PARAMETER public
        Return the Public (External) IP Address of the current workstation.
    .PARAMETER private
        Return the Private (Internal) IP Address of the current workstation.
    .EXAMPLE
        Get-IpAddress -Public

        --> Print Public IP Address onto the console.
    .EXAMPLE
        Get-IpAddress -Public -Interactive

        --> Show Public IP Address in Windows notification.
    .LINK
        https://github.com/Windos/BurntToast
        https://www.technewstoday.com/powershell-get-ip-address/
    .NOTES
        Filename: Get-IPAddress.ps1
        Author: Jacquin Moon
        Date: October 15th, 2024
    #>

    [CmdletBinding()]
    param (
        [Alias('external', 'global', 'g')][switch]$Public,
        [Alias('internal', 'local', 'l')][switch]$Private,
        [Alias('i')][switch]$Interactive
    )

    $LogoPath = "$PSScriptRoot\Assets\global-network.png"
    $PublicIp = (Invoke-WebRequest "http://icanhazip.com" -UseBasicParsing -DisableKeepAlive).Content.Trim()
    $PrivateIp = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $null -ne $_.DHCPEnabled -and $null -ne $_.DefaultIPGateway }).IPAddress | Select-Object -First 1

    if ($Public) {
        if ($Interactive) { New-BurntToastNotification -AppLogo $LogoPath -Silent -Text "Public IP Address: ", "`u{1F60A}  $PublicIp" }
        else { Write-Host "Public IP Address: " -ForegroundColor Green; Write-Host "`u{1F310}  $PublicIp" }
    }

    elseif ($Private) {
        if ($Interactive) { New-BurntToastNotification -AppLogo $LogoPath -Silent -Text "Private IP Address: ", "`u{1F60A}  $PrivateIp" }
        else { Write-Host "Private IP Address: " -ForegroundColor Green; Write-Host "`u{1F310}  $PrivateIp" }
    }

    else {
        $ToastButton = New-BTButton -Dismiss -Content 'Close'
        New-BurntToastNotification -AppLogo $LogoPath -Button $ToastButton -Silent -Text "Public IP:  $PublicIp", "Private IP:  $PrivateIp"
    }
}

Set-Alias -Name 'ip' -Value 'Get-IPAddress'
