# File name: Get-DirectPathIOStatus.ps1
# Description: VMXNET3 - Network DirectPath I/O Status
# VMware KB: https://kb.vmware.com/kb/2145889
#
# 06/07/2018 - Version 1.1
#     - Added the PowerCLI version check
#     - Improved the host connection block
#     - Added an export to CSV
# 26/04/2017 - Version 1.0
#     - Initial Release
#
# Author: Roman Dronov (c)


# Initial variables
$outputCollection = @()
$newModule = "VMware.PowerCLI"
$oldModule = "VMware.VimAutomation.Core"


# Check the PowerCLI module availability
Clear-Host
Write-Host "`n Checking if the VMware PowerCLI modules are loaded...`r"

if ($(Get-InstalledModule | ? {$_.Name -like $newModule}) -eq $null) {
    
    if ($(Get-Module | ? {$_.Name -like $oldModule}) -eq $null -and $(Get-Module -Name $oldModule -ListAvailable -ErrorAction Ignore) -eq $null) {
        Write-Host "`n  You need to install the VMware PowerCLI module to run this script. Exiting...`r" -ForegroundColor Yellow
        exit
    }
    else {
        Import-Module -Name $oldModule -ErrorAction Ignore -WarningAction Ignore
        $moduleVersion = $(Get-Module -Name $oldModule).Version
        Write-Host "`n  The VMware PowerCLI module version $moduleVersion is loaded successfuly.`r" -ForegroundColor Green
    }   
}
else {
    $moduleVersion = $(Get-InstalledModule -Name $newModule).Version
    Write-Host "`n  The VMware PowerCLI module version $moduleVersion is detected.`r" -ForegroundColor Green
}


# Set the VIServer connection mode to Multiple
$connectionMode = $(Get-PowerCLIConfiguration -Scope Session).DefaultVIServerMode

if ($connectionMode -like 'Single') {
    Set-PowerCLIConfiguration -Scope Session -DefaultVIServerMode Multiple -Confirm:$false | Out-Null
}


# Connect to the host(s)
function Enter-Credentials {
    $defaultUser = $env:USERDOMAIN + "\" + $env:USERNAME
    if ($(Read-Host "`n Username [default: $($defaultUser)]") -eq '') {
        $viUser = $defaultUser
    }
    else {
        $viUser
    }
    $viPassword = Read-Host " Password" -AsSecureString
    $script:viCredential = New-Object System.Management.Automation.PSCredential ($viUser,$viPassword)
}

function Verify-ViServer {
    $viServer = Read-Host -Prompt "`n Input the host name and then press Enter"
    
    Write-Host "`n  Checking connection to ""$viServer""..." -ForegroundColor Green       
    while ($(Test-Connection -ComputerName $viServer -Count 2 -ErrorAction Ignore) -eq $null) {
        Write-Host "`n  Host ""$viServer"" is not reachable." -ForegroundColor Yellow
        $viServer = Read-Host -Prompt "`n Input the correct host name and then press Enter"
    }
    $script:viServer = $viServer
}

if ($global:DefaultVIServers.Count -ne '0'){
    
    Write-Host "`n Connection has already established with the following host(s):"
    $vcsaConnections = $global:DefaultVIServers
    foreach ($vcsaServer in $vcsaConnections) {
        Write-Host "`t*  $vcsaServer`r" -ForegroundColor Yellow
    }
    
    $userAnswer = Read-Host "`n Would you like to continue using current connection(s)? [Yes/No]"
    while ("Yes","No" -notcontains $userAnswer) {
        $userAnswer = Read-Host "`n Please choose correct answer [Yes/No]"
    }
    
    if ($userAnswer -eq 'No') {
        Verify-ViServer
        Enter-Credentials
        
        Write-Host "`n  Connecting to ""$viServer""..." -ForegroundColor Green
        Connect-VIServer -Server $viServer -Credential $viCredential -ErrorAction Ignore -WarningAction Ignore | Out-Null
    }
    else {
        continue
    }
}
else {
    Verify-ViServer
    Enter-Credentials
    
    Write-Host "`n  Connecting to ""$viServer""..." -ForegroundColor Green
    Connect-VIServer -Server $viServer -Credential $viCredential -ErrorAction Ignore -WarningAction Ignore | Out-Null
}


# Read all VMs that have VMXNET3 
$vmNetworks = Get-VM | Get-NetworkAdapter | Where-Object {$_.Type -eq 'Vmxnet3'}


# Get information about the network card
for ($i=0; $i -lt $vmNetworks.Count; $i++) {
    $vm = $vmNetworks[$i].Parent
    $vmNetworkName = $vmNetworks[$i].NetworkName
    $vmNetworkAdapter = $vmNetworks[$i].ExtensionData.DeviceInfo.Label
    $vmNetworkAdapterDPIOStatus = $vmNetworks[$i].ExtensionData.UptCompatibilityEnabled

    if ($vmNetworkAdapterDPIOStatus -ne 'True') {
        $dpioStatus = "Disabled"
    }
    else {
        $dpioStatus = "Enabled"
    }

    $properties = @{'Virtual Machine' = $vm.Name;
                    'HW Version' = $vm.Version;
                    'Network Adapter' = $vmNetworkAdapter;
                    'Network Name' = $vmNetworkName;
                    'DPIO Status' = $dpioStatus}

    $object = New-Object –TypeName PSObject –Property $properties

    $outputCollection += $object
    }


# Disconnect from the host(s) and clear the screen
Disconnect-VIServer * -Confirm:$false
Clear-Host


# Print out the results
$dpioResults = $outputCollection | Sort-Object -Property "Virtual Machine" | select Virtual*,*Version,*Adapter,*Name,*Status

Write-Host "`n DirectPath I/O status`r"
$dpioResults


# Save results to CSV
$csvPath = $env:TEMP + "\DPIOStatus-" + $(Get-Date -Format 'ddMMyyyy') + ".csv"
$dpioResults | Export-CSV -Path $csvPath -NoTypeInformation -Force -Confirm:$false
Invoke-Item $csvPath
