<#
.SYNOPSIS
    Script to autogenerate pictures to README.md
.DESCRIPTION
    Since I'm too lazy to edit by hand and I don't know any tools to autogenerate this folder's README.md
#>

$readmeFile = "$PSScriptRoot\README.md"
$picturesPath = "$PSScriptRoot\pics"
$pictures = (Get-ChildItem -Path "$picturesPath").Name

if (Test-Path -Path "$readmeFile") {
    Remove-Item "$readmeFile" -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path "$readmeFile"
}

function Write-ToFile {
    param ([string]$content)
    Add-Content -Path "$PSScriptRoot\README.md" -Value $content
}

Write-ToFile '<div align="center">'
Write-ToFile '  <h1>📷 Wallpapers ✨</h1>'
Write-ToFile ''
Write-ToFile '<table>'
Write-ToFile ''

foreach ($pic in $pictures) {
    $picAlt = $pic.Split('.')[0]
    $picContent = @"
<tr>
  <td>
    <img alt="$picAlt" src="./pics/$pic" width="780" height="450"/>
  </td>
</tr>
"@

    Write-ToFile $picContent
}

Write-ToFile '</table>'
Write-ToFile '</div>'
Write-ToFile ''
Write-ToFile '<h2 id="credits">🎉 Credits</h2>'
Write-ToFile ''
Write-ToFile 'Big thanks to:'
Write-ToFile ''
Write-ToFile "- [Matt-FTW's wallpapers](https://github.com/Matt-FTW/dotfiles/tree/main/.config/hypr/theme/walls): Most of the pictures in this folder are from him!"
Write-ToFile "- [ashish0kumar's windots](https://github.com/ashish0kumar/windots): Awesome repo for inspiration"