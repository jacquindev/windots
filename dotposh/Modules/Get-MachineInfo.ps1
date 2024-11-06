function Get-BIOSInfo {
    Write-Host "----------------- " -ForegroundColor "Yellow"
    Write-Host "BIOS Information: " -ForegroundColor "Yellow" 
    Write-Host "----------------- " -ForegroundColor "Yellow"
    $details = Get-CimInstance -ClassName Win32_BIOS
    $result = [PSCustomObject]@{
        Model        = $details.Name.Trim()
        Version      = $details.Version
        SerialNumber = $details.SerialNumber
        Manufacturer = $details.Manufacturer
        ReleaseDate  = $details.ReleaseDate
    }
    return $result | Format-List
}

function Get-CPUInfo {
    Write-Host "---------------- " -ForegroundColor "Yellow"
    Write-Host "CPU Information: " -ForegroundColor "Yellow" 
    Write-Host "---------------- " -ForegroundColor "Yellow"
    $details = Get-WmiObject -Class Win32_Processor
    $celsius = Get-CPUTemperature
    $result = [PSCustomObject]@{
        CpuName     = $details.Name.Trim()
        Arch        = "$env:PROCESSOR_ARCHITECTURE"
        DeviceID    = $($details.DeviceID)
        Socket      = "$($details.SocketDesignation)"
        Speed       = "$($details.MaxClockSpeed) MHz"
        Temperature = "$($celsius)°C"
    }
    return $result | Format-List
}

function Get-GPUInfo {
    Write-Host "---------------- " -ForegroundColor "Yellow"
    Write-Host "GPU Information: " -ForegroundColor "Yellow" 
    Write-Host "---------------- " -ForegroundColor "Yellow"
    $details = Get-WmiObject Win32_videocontroller
    $result = [PSCustomObject]@{
        Model          = $details.Caption
        RAMSize        = "$($($details.AdapterRAM) / 1MB)" + " MB"
        Pixel          = "$($details.CurrentHorizontalResolution)" + "x" + "$($details.CurrentVerticalResolution)" + " pixels"
        BitsPerPixel   = "$($details.CurrentBitsPerPixel)" + "-bit"
        RefreshRate    = "$($details.CurrentRefreshRate)" + " Hz"
        MaxRefreshRate = "$($details.MaxRefreshRate)" + " Hz"
        DriverVersion  = $details.DriverVersion
        Status         = $details.Status
    }
    return $result | Format-List
}

function Get-MotherBoardInfo {
    Write-Host "------------------------ " -ForegroundColor "Yellow"
    Write-Host "Motherboard Information: " -ForegroundColor "Yellow" 
    Write-Host "------------------------ " -ForegroundColor "Yellow"
    $details = Get-WmiObject Win32_BaseBoard
    $result = [PSCustomObject]@{
        Model        = $details.Product
        SerialNumber = $details.SerialNumber
        Manufacturer = $details.Manufacturer
    }
    return $result | Format-List
}

function Get-OSInfo {
    Write-Host "----------------------------- " -ForegroundColor "Yellow"
    Write-Host "Operating System Information: " -ForegroundColor "Yellow" 
    Write-Host "----------------------------- " -ForegroundColor "Yellow"
    $details = Get-WmiObject -Class Win32_OperatingSystem
    $result = [PSCustomObject]@{
        OSName       = $details.Caption
        Arch         = $details.OSArchitecture
        Version      = $details.Version
        BuildNo      = $details.BuildNumber
        SerialNumber = $details.SerialNumber
        InstallDate  = $details.InstallDate
        ProductKey   = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault).BackupProductKeyDefault
    }
    return $result | Format-List
}

function Get-RAMInfo {
    Write-Host "---------------- " -ForegroundColor "Yellow"
    Write-Host "RAM Information: " -ForegroundColor "Yellow" 
    Write-Host "---------------- " -ForegroundColor "Yellow"
    $objs = Get-WmiObject -Class Win32_PhysicalMemory
    $objSum = $objs | Measure-Object -Property Capacity -Sum
    foreach ($obj in $objs) {
        $result = [PSCustomObject]@{
            Type           = Get-RAMType $obj.SMBIOSMemoryType
            Size           = "$($obj.Capacity / 1GB)" + " GB"
            TotalSize      = "$($objSum.Sum / 1GB)" + " GB"
            InstalledSlots = "$($objSum.Count)" + "/" + "$((Get-WmiObject -Class Win32_PhysicalMemoryArray).MemoryDevices)" + " slots"
            Speed          = "$($obj.Speed)" + " MHz"
            Voltage        = "$($obj.ConfiguredVoltage / 1000.0)" + "V"
            Location       = "$($obj.BankLabel) / $($obj.DeviceLocator)"
            PartNumber     = $obj.PartNumber
            Manufacturer   = $obj.Manufacturer
        }
    }
    return $result | Format-List
}

function Get-SwapSpaceInfo {
    Write-Host "----------------------- " -ForegroundColor "Yellow"
    Write-Host "Swap Space Information: " -ForegroundColor "Yellow"
    Write-Host "----------------------- " -ForegroundColor "Yellow"
    $details = Get-WmiObject -Class Win32_PageFileUsage -Namespace "root/CIMV2" -ComputerName "localhost"
    [int]$total = [int]$used = 0
    foreach ($item in $details) {
        $total += $item.AllocatedBaseSize
        $used += $item.CurrentUsage
    }
    [int]$free = $total - $used
    [int]$percent = ($used * 100) / $total

    $result = [PSCustomObject]@{
        TotalSize = "$total" + " MB"
        UsedSize  = "$used" + " MB"
    }
    $result | Format-List
    Write-Host "==> Swap Space Used: " -ForegroundColor "Blue" -NoNewline
    Write-Host "$percent% " -ForegroundColor "Yellow" -NoNewline
    Write-Host "(Free: " -ForegroundColor "Blue" -NoNewline
    Write-Host "$free MB" -ForegroundColor "Yellow" -NoNewline
    Write-Host ")" -ForegroundColor "Blue" 
}

function Get-CPUTemperature {
    $objects = Get-WmiObject -Query "SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation" -Namespace "root/CIMV2"
    foreach ($object in $objects) {
        $highPrec = $object.HighPrecisionTemperature
        $temperature = [math]::round($highPrec / 100.0, 1)
    }
    return $temperature
}

function Get-RAMType {
    param ([int]$Type)
    switch ($Type) {
        20 { return "DDR" }
        21 { return "DDR2" }
        24 { return "DDR3" }
        26 { return "DDR4" }
        34 { return "DDR5" }
        default { return "RAM" }
    }
}