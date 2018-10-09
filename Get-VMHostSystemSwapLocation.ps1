# File name: Get-VMHostSystemSwapLocation.ps1
# Description: This script provides information about the system swap location for ESXi hosts.
#
# 08/10/2018 - Version 1.0
#     - Initial Release (based on https://code.vmware.com/forums/2530/vsphere-powercli#534332)
#
# Author: Roman Dronov (c)


# Get information about the system swap location for ESXi hosts

Write-Host "`nSystem swap location:`r" -ForegroundColor Green

ForEach ($vmhost in $(Get-VMHost | sort Name)) {

  $esxcli2 = Get-EsxCli -VMHost $vmhost -V2

  $esxcli2.sched.swap.system.get.Invoke() | Select `
  @{N='Host Name';E={$vmhost.Name}}, `
  @{N='Datastore Name';E={$_.DatastoreName}}, `
  @{N='Datastore Active';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreActive)}}, `
  @{N='Datastore Enabled';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreEnabled)}}

}

Clear-Variable vmhost,esxcli2 -Scope Global
