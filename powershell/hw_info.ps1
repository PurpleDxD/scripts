function Convert-ToGB {
    param (
        [double]$sizeInBytes
    )

    [math]::Round($sizeInBytes / 1GB)
}

$cpuInfo = Get-WmiObject Win32_Processor | Select-Object @{Name='Name';Expression={$_.Name.Trim()}}, MaxClockSpeed, Manufacturer

$gpuInfo = Get-WmiObject Win32_VideoController | Select-Object Caption, AdapterRAM

$vramGB = Convert-ToGB $gpuInfo.AdapterRAM

$ramInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum | Select-Object @{Name='TotalMemory';Expression={Convert-ToGB($_.Sum)}}

$motherboardInfo = Get-WmiObject Win32_BaseBoard | Select-Object Manufacturer, Product

$diskInfo = Get-WmiObject Win32_DiskDrive | Select-Object Model, @{Name='Size';Expression={Convert-ToGb($_.Size)}}, InterfaceType

$table = @{
    'CPU'             = "$($cpuInfo.Manufacturer) $($cpuInfo.Name) ($($cpuInfo.MaxClockSpeed)MHz)"
    'GPU'             = "$($gpuInfo.Caption) ($($vramGB)GB VRAM)"
    'RAM'             = "$($ramInfo.TotalMemory)GB"
    'Motherboard'     = "$($motherboardInfo.Manufacturer) $($motherboardInfo.Product)"
    'Disk Drives'     = $diskInfo | ForEach-Object { "$($_.Model) $($_.InterfaceType) ($($_.Size)GB)" }
}

$table | Format-List