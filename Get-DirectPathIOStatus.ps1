# File name: Get-DirectPathIOStatus.ps1
# Description: VMXNET3 - Network DirectPath I/O Status
# VMware KB: https://kb.vmware.com/kb/2145889
#
# 06/07/2018 - Version 1.0.1 - Minor changes to check PowerCLI version
# 26/04/2017 - Version 1.0 - Initial Release
#
# Author: Roman Dronov (c)


# Initial variables
$OutputCollection = @()
$newModule = "VMware.PowerCLI"
$oldModule = "VMware.VimAutomation.Core"


# Check the PowerCLI module availability
Clear-Host
Write-Host "`n  Checking if the VMware PowerCLI module exists...`r"

if($(Get-InstalledModule | ? {$_.Name -like $newModule}) -eq $null) {
    
    if ($(Get-Module | ? {$_.Name -like $oldModule}) -eq $null -and $(Get-Module -Name $oldModule -ListAvailable -ErrorAction SilentlyContinue) -eq $null) {
        Write-Host "`n  You need to install the VMware PowerCLI module to run this script. Exiting...`r" -ForegroundColor Yellow
        exit
    }
    else {
        Import-Module -Name $oldModule -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        $moduleVersion = $(Get-Module -Name $oldModule).Version
        Write-Host "`n  The VMware PowerCLI module version $moduleVersion is loaded successfuly.`r" -ForegroundColor Green
    }   
}
else {
    $moduleVersion = $(Get-InstalledModule -Name $newModule).Version
    Write-Host "`n  The VMware PowerCLI module version $moduleVersion is detected.`r" -ForegroundColor Green
}


# Connect to the vCenter server
$VIServer = Read-Host -Prompt " Input the vCenter server name and then press Enter"
Connect-VIServer -Server $VIServer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null

# Read all VMs that have VMXNET3 
$VMNetworks = Get-VM | Get-NetworkAdapter | Where-Object {$_.Type -eq "Vmxnet3"}

# Get information about the network card
For ($i=0; $i -lt $VMNetworks.Count; $i++) {
    $VM = $VMNetworks[$i].Parent
    $VMNetworkName = $VMNetworks[$i].NetworkName
    $VMNetworkAdapter = $VMNetworks[$i].ExtensionData.DeviceInfo.Label
    $VMNetworkAdapterDPIOStatus = $VMNetworks[$i].ExtensionData.UptCompatibilityEnabled

    If ($VMNetworkAdapterDPIOStatus -ne "True") {$DPIOStatus = "Disabled"}
    Else {$DPIOStatus = "Enabled"}

        $Properties = @{'Virtual Machine' = $VM.Name;
                        'HW Version' = $VM.Version;
                        'Network Adapter' = $VMNetworkAdapter;
                        'Network Name' = $VMNetworkName
                        'DPIO Status' = $DPIOStatus
                        }

    $Object = New-Object –TypeName PSObject –Prop $Properties

    $OutputCollection += $Object
    }

# Disconnect from vCenter Server and clear the screen
Disconnect-VIServer -Server $VIServer -Confirm:$false
Clear-Host

# Print out the results
Write-Host "`n`tDirectPath I/O status`n"
$OutputCollection | Sort-Object -Property "Virtual Machine" | Format-Table Virtual*,*Version,*Adapter,*Name,*Status -AutoSize
