<#
.SYNOPSIS
    Display mountpoints and drives
.DESCRIPTION
    Output detailed information about mountpoints

    References:
    - https://lifeofageekadmin.com/display-mount-points-drives-using-powershell/
#>

function Get-Mountpoints {
    [alias('mnts')]
    param()

    $Capacity = @{Name = "Capacity(GB)"; Expression = { [math]::round(($_.Capacity / 1073741824)) } }
    $FreeSpace = @{Name = "FreeSpace(GB)"; Expression = { [math]::round(($_.FreeSpace / 1073741824), 1) } }
    $Usage = @{
        Name       = "Usage"
        Expression = {
            -join ([math]::round(100 - ((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0), '%')
        }
        Alignment  = "Right"
    }

    $volumes = if ($IsCoreCLR) {
        Get-CimInstance -ClassName Win32_Volume
    } else {
        Get-WmiObject -Class Win32_Volume
    }

    $volumes |
    Where-Object Name -notlike '\\?\Volume*' |
    Format-Table DriveLetter, Label, FileSystem, $Capacity, $FreeSpace, $Usage, PageFilePresent, IndexingEnabled, Compressed -AutoSize
}

Export-ModuleMember -Function Get-Mountpoints -Alias mnts
