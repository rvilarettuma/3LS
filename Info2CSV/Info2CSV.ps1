# Richard Vilaret-Tuma
<#
    .SYNOPSIS
    Gathers system data and puts it into a CSV

    .DESCRIPTION
    This script gathers basic system hardware specs and exports a CSV file for auditing purposes
#>

# Output File
$systemInformation = ".\SystemInformation.csv"

Write-Host "Gathering system information..."
$system = Get-CimInstance CIM_ComputerSystem
$sku = Get-CimInstance Win32_BIOS | Select-Object SerialNumber -ExpandProperty SerialNumber
$cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*" -ExpandProperty Name | Out-String
$cpu | ForEach-Object {
    $cpu_temp = $cpu_temp + $_
}
$cpu = $cpu_temp
$gpu = Get-CimInstance Win32_VideoController | Select-Object Name -ExpandProperty Name | Out-String
$gpu | ForEach-Object {
    $gpu_temp = $gpu_temp + $_
}
$gpu = $gpu_temp
$hdd = Get-Disk | Where-Object -FilterScript {$_.Bustype -ne "USB"} | Select-Object Model -ExpandProperty Model | Out-String
$hdd | ForEach-Object {
    $hdd_temp = $hdd_temp + $_
}
$hdd = $hdd_temp

$sysinfo = [PSCustomObject]@{
    Model = $system.Model
    SKU   = $sku
    CPU   = $cpu
    GPU   = $gpu
    HDD   = $hdd
    RAM   = ("{0:N2}" -f ($system.TotalPhysicalMemory / 1GB) + "GB")
}

try { 
    Write-Host "Exporting CSV..."
    $sysinfo | Export-Csv -Path $systemInformation -Delimiter ',' -NoTypeInformation -Append
    Write-Host -ForegroundColor green "Operation complete!"
}
catch {
    Write-Host -ForegroundColor red "An error occurred: "
    Write-Host -ForegroundColor red $_
}

$seconds = 5
do {
    Write-Host "Closing in $seconds seconds...`r" -NoNewline
    Start-Sleep 1
    $seconds--
} while ($seconds -gt 0)
