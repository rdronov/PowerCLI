# File name: New-VMHostSystemSwapLocation.ps1
# Description: This script creates a system swap file for the ESXi host on a desired datastore.
#
# 08/10/2018 - Version 1.0
#     - Initial Release (based on https://code.vmware.com/forums/2530/vsphere-powercli#534332)
#
# Author: Roman Dronov (c)


# Get the host name and check it is valid

$vmhosts = Get-VMHost | ? {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | ForEach-Object {$_.Name.Split('.')[0]}

$vmhost = Read-Host -Prompt "`n Please type in the ESXi host name"

while ($vmhosts.Contains("$vmhost") -ne "True") {

  Write-Host "`n Checking the host exists..." -NoNewline

  Write-Host " The host is not reachable." -ForegroundColor Yellow

  $vmhost = Read-Host -Prompt "`n Please type in the host name correctly"

}


# Get the datastore name and check it is valid

$datastores = $(Get-Datastore | ? {$_.State -eq "Available"}).Name

$datastore = Read-Host -Prompt "`nPlease type in the datastore name"

while ($datastores.Contains($datastore) -ne "True") {

  Write-Host "`n Checking the datastore exists..." -NoNewline

  Write-Host " The datastore is not reachable." -ForegroundColor Yellow

  $datastore = Read-Host -Prompt "`nPlease type in the datastore name correctly"

}


# Check the host has access to the datastore

$vmhost = $vmhost + "*"

$vmhost = $(Get-VMHost | ? {$_.Name -like "$vmhost"}).Name

$lookup = $(Get-VMHost | ? {$_.Name -like $vmhost} | Get-Datastore).Name

if ($lookup.Contains($datastore) -ne "True") {

  Write-Host "`n The datastore is not reachable by the host." -ForegroundColor Yellow

}
else {

  # Create the system swap file on the provided datastore

  $esxcli2 = Get-EsxCli -VMHost $vmhost -V2

  $arguments = $esxcli2.sched.swap.system.set.CreateArgs()
  $arguments.datastorename = $datastore
  $arguments.datastoreenabled = "true"

  $esxcli2.sched.swap.system.set.Invoke($arguments) | Out-Null

  # Print out the results

  Write-Host "`nSystem swap location:`r" -ForegroundColor Green

  $esxcli2.sched.swap.system.get.Invoke() | Select `
    @{N='Host Name';E={$vmhost}}, `
    @{N='Datastore Name';E={$_.DatastoreName}}, `
    @{N='Active';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreActive)}}, `
    @{N='Enabled';E={(Get-Culture).TextInfo.ToTitleCase($_.DatastoreEnabled)}}

}

Clear-Variable vmhost,vmhosts,datastore,datastores,esxcli2,arguments -Scope Global | Out-Null
