# File name: Get-DatastoreUsage.ps1
# Description: This script provides information about datastore usage.
#
# 17/07/2018 - Version 1.0
#     - Initial Release (based on https://code.vmware.com/forums/2530/vsphere-powercli#576268)
#
# Author: Roman Dronov (c)

Get-Datastore | select Name,`
    @{N='Capacity (GB)';E={[math]::Round($_.ExtensionData.Summary.Capacity/1GB,2)}},`
    @{N='Consumed (GB)';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,2)}},`
    @{N='Provisioned (GB)';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2)}},`
    @{N='Over-Provisioning Ratio';E={[math]::Round((($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/$_.ExtensionData.Summary.Capacity),2)}} |`
Format-Table -AutoSize
