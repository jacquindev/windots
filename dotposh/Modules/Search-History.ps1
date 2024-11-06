function Search-History {
    [CmdletBinding()]
    param (
        [string]$SearchTerm,
        [switch]$g, # global search
        [switch]$s  # session search
    )

    #requires -Module PSReadLine

    if ($PSBoundParameters.Count -eq 0 ) {
        $result = Get-Content (Get-PSReadlineOption).HistorySavePath | Get-Unique
        return $result
    }

    if ($g) {
        $result = Get-Content (Get-PSReadlineOption).HistorySavePath |
        Where-Object { $_ -like "*$SearchTerm*" } | Get-Unique
        return $result
    }

    if ($s) {
        $Table = @(
            @{Expression = "Id" },
            @{Expression = "CommandLine"; Label = "Invoked Commands" },
            @{Expression = "Duration" },
            @{Expression = "StartExecutionTime"; Label = "Executed Time" }
        )

        $result = Get-History | Where-Object { $_.CommandLine -like "*$SearchTerm*" } |
        Format-Table -Property $Table -Wrap -AutoSize
        return $result
    }
}

function Clear-PSHistory {
    Get-PSReadLineOption | 
    Select-Object -ExpandProperty HistorySavePath | 
    Remove-Item -Force -Recurse
}

Set-Alias -Name 'hist' -Value 'Search-History'
Set-Alias -Name 'clr-hist' -Value 'Clear-PSHistory'