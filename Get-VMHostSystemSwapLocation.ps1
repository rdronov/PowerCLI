# File name: Get-VMHostSystemSwapLocation.ps1
# Description: This script provides information about datastore usage.
#
# 08/10/2018 - Version 1.0
#     - Initial Release (based on https://code.vmware.com/forums/2530/vsphere-powercli#534332)
#
# Author: Roman Dronov (c)


Clear-Variable vhost -Scope Global

ForEach ($vhost in $(Get-VMHost | sort Name)) {

  $esxcli2 = Get-EsxCli -VMHost $vhost -V2

  $esxcli2.sched.swap.system.get.Invoke() | Select `
  @{N='Host Name';E={$vhost.Name}}, `
  @{N='Datastore Active';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreActive)}}, `
  @{N='Datastore Enabled';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreEnabled)}}, `
  @{N='Datastore Name';E={$_.DatastoreName}}

}

Clear-Variable vhost,esxcli2 -Scope Global
