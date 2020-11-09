# check_cpu.ps1
#
# Nagios plugin to report basic CPU and OS info for Windows servers
#
# Example output:
#
#   2 x 6-Core x 2-Threads 2400MHz Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz / 65536MB RAM / Windows Server 2012 R2 Standard Edition Build 9600
#
# Author: Phil Randal
#
# Get total RAM
$mb=(Get-WMIObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1mb
$procinfo=Get-WMIObject CIM_Processor | Select Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
$numcpus=$procinfo.count
if ($numcpus -gt 1) {
  $procinfo=$procinfo[0]
}
$numcores=$procinfo.NumberofCores
$numthreadspercore=$procinfo.NumberOfLogicalProcessors / $numcores
$speed=$procinfo.MaxClockSpeed
$cpuname=$procinfo.Name
# strip off the leading "Microsoft" in line with KixTart's handling of @productversion
$os=(Get-WMIObject Win32_OperatingSystem).Caption.trim()
if ($os -match "Microsoft (.*)") {
  $os = $matches[1]
}
# Fix for broken Windows 2008 RTM broken caption
if ($os -match ".*2008 (.*)") {
  $os = "Windows Server 2008 $($matches[1].tostring())"
}
# get the OS build number
$build=[System.Environment]::OSVersion.Version.Build
$cp=""
if ($numcpus -gt 1) {
  $cp="$numcpus x "
}
$thrd=""
if ($numthreadspercore -gt 1) {
  $thrd=" x $numthreadspercore-Threads"
}
write-host "$cp$numcores-Core$thrd $($speed)MHz $cpuname / $($mb)MB RAM / $os Edition Build $Build"
