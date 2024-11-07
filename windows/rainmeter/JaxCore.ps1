function Set-IdleStyle {
    Write-Warning "For IdleStyle Module working properly, you would need 'ffplay'."
    $confirm = $(Write-Host "INSTALL 'ffplay.exe' (y/n)? " -ForegroundColor "Green" -NoNewline; Read-Host)
    if ($confirm -eq 'y') {
        $url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
        $downloadFolder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
        $downloadFile = "$downloadFolder\ffmpeg-master-latest-win64-gpl.zip"
        Invoke-WebRequest -Uri "$url" -OutFile "$downloadFile"
        Expand-Archive -LiteralPath $downloadFile -DestinationPath "$downloadFolder\ffmpeg"
        Move-Item "$downloadFolder\ffmpeg\ffmpeg-master-latest-win64-gpl\bin\ffplay.exe" "$env:USERPROFILE\Documents\Rainmeter\CoreData\IdleStyle\ffplay.exe"
        Write-Host "Please Reload Rainmeter to take effect!"
        Start-Sleep -Seconds 1
    }
}

. "$PSScriptRoot\skins\install-jaxcore.ps1"

$idlestylePath = "$Env:USERPROFILE\Documents\Rainmeter\CoreData\IdleStyle"
if (Test-Path -Path $idlestylePath) {
    if (!(Test-Path "$idlestylePath\ffplay.exe")) {
        Set-IdleStyle
    }
    else {
        Start-Sleep -Seconds 3
        Write-Warning "ffplay.exe already installed! Exiting..." 
    }
    Start-Sleep -Seconds 1
}

''
Write-Host "--------------------------------------------------------------------" -ForegroundColor "DarkGray"
Write-Host "For more information, please visit: " -NoNewline
Write-Host "https://wiki.jaxcore.app/modules" -ForegroundColor "Blue"
Break