# File name: Set-EFIFirmware.ps1
#
# Description: This script checks and sets the firmware type to EFI for a particular VM
#
# 25/07/2018 - Version 1.0.1
#     - Initial release with minor changes
#
# Author: Roman Dronov (c)


# Clear the screen

Clear-Host


# Set the function

function Set-Firmware {
    [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$true, Position=0)]
            [string]$Argument
        )
    
    $choice = Read-Host "`n Would you like to set the firmware type to EFI? (Yes/No)"

    while ("Yes","No" -notcontains $choice){
        
        $choice = Read-Host "`n Would you like to set the firmware type to EFI? (Yes/No)"
    }
    
    switch ($choice){
        "Yes" {
            Write-Host " Checking the VM power state..." -NoNewline

            if ($vm.PowerState -eq 'PoweredOff'){
                Write-Host " The VM is powered off." -ForegroundColor Green
                Write-Host " Setting the firmware type..." -NoNewline
                
                if ($Argument -eq '0'){
                    Get-VM -Name $vmName | New-AdvancedSetting -Name 'firmware' -Value 'efi' -Confirm:$false | Out-Null
                }
                elseif ($Argument -eq '1'){
                    Get-VM -Name $vmName | Get-AdvancedSetting -Name 'firmware' | Set-AdvancedSetting -Value 'efi' -Confirm:$false | Out-Null
                }

                Write-Host " Completed successfully!" -ForegroundColor Green
            }
            else {
                Write-Host " $vm is powered on!" -ForegroundColor Red
                Write-Host " Please shutdown the VM and run this script again." -ForegroundColor Yellow
            }
            
            Write-Host "`n Exiting..."
        }
        "No" {
            Write-Host " Cancelled by the user." -ForegroundColor Yellow
            Write-Host "`n Exiting..."
        }
    }
}


# Promp for the VM name

$vmName = $null

while ($vmName -eq $null){
    
    $vmName = Read-Host -Prompt "`n Input the VM name"
    
    if ($vmName -eq '' -or -not (Get-VM -Name $vmName -ErrorAction SilentlyContinue)){
        Write-Host " Invalid VM name, please re-enter." -ForegroundColor Yellow
        $vmName = $null
    }
}


# Check the firmware advanced setting

$vmName = $vmName.ToUpper()
$vm = Get-VM -Name $vmName
$vmFirmware = Get-AdvancedSetting -Entity $vm -Name 'firmware'

Write-Host "`n Checking the firmware advanced setting for $vmName..."

if (-not $vmFirmware){
    
    Write-Host " Parameter not exist." -ForegroundColor Yellow


    # Set the firmware advanced setting to EFI

    Set-Firmware -Argument 0

}
elseif ($vmFirmware.Value -ieq 'efi'){
    Write-Host " $vmName has the firmware type set to EFI already." -ForegroundColor Green
    Write-Host "`n Exiting..."
}
else {
    $vmFirmwareValue = $vmFirmware.Value
    $vmFirmwareValue = $vmFirmwareValue.ToUpper()
    
    Write-Host " $vmName has the firmware type set to $vmFirmwareValue." -ForegroundColor Yellow


    # Set the firmware advanced setting to EFI
    
    Set-Firmware -Argument 1
}
