# File name: Get-DirectPathIOStatus.ps1
# Description: HWv11 Virtual Machines - Network DirectPath I/O Status
# VMware KB: https://kb.vmware.com/kb/2145889
# 
# Author: Roman Dronov (c)

# Initial variables
$OutputCollection = @()

# Clear screen and add in the PowerCLI CMDLET
Clear-Host
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

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
