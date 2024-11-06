function Get-Dirstats {
    <#
    .SYNOPSIS
        Outputs file system directory statistics.
    .DESCRIPTION
        Recursively correlate directory structures, file counts, directory counts, largest files, and total directory size.
    .LINK
        https://github.com/CyberCondor/Get-DirStats/blob/main/Get-DirStats.ps1
    .PARAMETER Dir
        Specifies a directory other than the current working directory.
    .PARAMETER Format
        Specifies the format of file size calculated and displayed.
    .EXAMPLE
        PS C:\> Get-DirStats -Dir ~\ -Format GB
    .EXAMPLE
        PS C:\> Get-DirStats -Format KB
    .NOTES
        Author: CyberCondor
        Link: https://github.com/CyberCondor/Get-DirStats
    #>
    param(
        [Alias('d')]
        [string]$Dir,

        [Alias('f')]
        [string]$Format
    )

    $CurrDir = (Get-Location).Path

    if (($Dir) -and (Test-Path $Dir)) { Set-Location $Dir; $AllItemsInCurrDir = Get-Item ./* }
    else { $AllItemsInCurrDir = Get-Item ./* }

    $FormatAndPath = New-Object -TypeName PSObject -Property @{Path = "$((Get-Location).Path)" }

    if (($Format -eq "KB") -or ($Format -eq "GB") -or ($Format -eq "TB")) {
        $FormatAndPath | Add-Member -NotePropertyMembers @{Format = $Format }
    }
    else { $FormatAndPath | Add-Member -NotePropertyMembers @{Format = "MB" } }

    $FormatAndPath | Select-Object Format, Path | Format-List

    $Index = 0
    $TotalIndex = ($AllItemsInCurrDir).count
    foreach ($ThisDir in $AllItemsInCurrDir) {
        $Index++
        $ContentsOfThisDir = Get-ChildItem $ThisDir.Name -Recurse -Force -ErrorAction Ignore
        $ContentsCount = ($ContentsOfThisDir).count
        $ContentsIndex = 1
        $TotalDirCount = 0
        $TotalFileCount = 0
        $TotalLength = 0
        $LargestItemSize = 0
        $LargestItemDir = $null
        foreach ($Item in $ContentsOfThisDir) {
            Write-Progress -id 1 -Activity "Collecting Stats for -> $($ThisDir.Name) ( $([int]$Index) / $($TotalIndex) )" -Status "$(($ContentsIndex++/$ContentsCount).ToString("P")) Complete"
            if ($Item.Mode -like "d*") {
                $TotalDirCount++
            }
            elseif ($Item.Mode -NotLike "d*") {
                $TotalFileCount++
            }
            if ($Item.Length) {
                $TotalLength += ($Item).Length
                if ($LargestItemSize -lt ($Item).Length) {
                    $LargestItemSize = ($Item).Length
                    $LargestItemDir = $Item.VersionInfo.FileName
                }
            }
        }
        $ThisDir | Add-Member -NotePropertyMembers @{Contents = $ContentsOfThisDir }
        $ThisDir | Add-Member -NotePropertyMembers @{DirCount = $TotalDirCount }
        $ThisDir | Add-Member -NotePropertyMembers @{FileCount = $TotalFileCount }
        $ThisDir | Add-Member -NotePropertyMembers @{LargestItem = $LargestItemDir }
        if ($Format -eq "KB") { $ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize = [math]::round($LargestItemSize / 1KB, 8) } ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize = [math]::round($TotalLength / 1KB, 8) } }
        elseif ($Format -eq "MB") { $ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize = [math]::round($LargestItemSize / 1MB, 8) } ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize = [math]::round($TotalLength / 1MB, 8) } }
        elseif ($Format -eq "GB") { $ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize = [math]::round($LargestItemSize / 1GB, 8) } ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize = [math]::round($TotalLength / 1GB, 8) } }
        elseif ($Format -eq "TB") { $ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize = [math]::round($LargestItemSize / 1TB, 8) } ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize = [math]::round($TotalLength / 1TB, 8) } }
        else { $ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize = [math]::round($LargestItemSize / 1MB, 8) } ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize = [math]::round($TotalLength / 1MB, 8) } } #Set to MB by default
    }
    Write-Progress -id 1 -Completed -Activity "Complete"
    $AllItemsInCurrDir | Select-Object Mode, LastWriteTime, Name, DirCount, FileCount, TotalSize, LargestItemSize, LargestItem, Contents | 
    Sort-Object TotalSize, FileCount, DirCount, Mode, Contents |
    Format-Table -AutoSize

    if ($Dir) { Set-Location $CurrDir }
}

Set-Alias -Name 'dirstats' -Value 'Get-Dirstats'