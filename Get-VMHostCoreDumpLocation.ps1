# File name: Get-VMHostCoredumpLocation.ps1
# Description: This script checks the core dump location for ESXi hosts.
#
# 11/10/2018 - Version 1.0
#     - Initial Release
#
# Author: Roman Dronov (c)


# Get information about the core dump file location for ESXi hosts

Write-Host "`nCore Dump Settings:`r" -ForegroundColor Green

ForEach ($vmhost in $(Get-VMHost | sort Name)) {

  $esxcli2 = Get-EsxCli -VMHost $vmhost -V2

  $esxcli2.system.coredump.file.get.Invoke() | Select @{N='Host Name';E={$vmhost}},@{N='Active Core Dump File';E={$_.Active}} #| Format-List
  
}

Clear-Variable vmhost,esxcli2 -Scope Global
