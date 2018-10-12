# File name: Get-VMVideoCard3DEnabled.ps1
# Description: This script checks the 3D support enabled for virtual machines. This is
#              related to https://www.vmware.com/security/advisories/VMSA-2018-0025.html.
#
# 12/10/2018 - Version 1.0
#     - Initial Release
#
# Author: Roman Dronov (c)


# Check the video card 3D support enabled for virtual machines

Write-Host "`n3D support status:`r" -ForegroundColor Green 

ForEach ($vm in $(Get-VM)) {

  $videocard = $vm.ExtensionData.Config.Hardware.Device | ? {$_.GetType().Name -eq "VirtualMachineVideoCard" }
  
  $videocard | ? {$_.Enable3DSupport -eq "True"} | Select `
    @{N='VM Name';E={$vm.Name}},@{N='3D Support Enabled';E={$_.Enable3DSupport}}

}

Clear-Variable vm,videocard -Scope Global
