# File name: Remove-VMHostCoredumpLocation.ps1
# Description: This script removes a core dump file for the particular ESXi host.
#
# 11/03/2019 - Version 1.0
#     - Initial Release
#
# Author: Roman Dronov (c)


# Define common functions
function ex {exit}


# Get the host name and check it is valid

$vmhosts = Get-VMHost | ? {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | ForEach-Object {$_.Name.Split('.')[0]}

$vmhost = (Read-Host -Prompt "`n Please type in the ESXi host name").Split('.')[0]

While ($vmhosts.Contains("$vmhost") -ne "True") {

  Write-Host "`n Checking the host exists..." -NoNewline

  Write-Host " The host is not reachable." -ForegroundColor Yellow

  $vmhost = Read-Host -Prompt "`n Please type in the host name correctly"

}

$vmhost = $vmhost + "*"


# Get the system configuration
$esxcli2 = Get-EsxCli -VMHost $vmhost -V2


# Activate the current coredump (this is to identify it properly later in this script)
Write-Host "`n Searching for a coredump file and trying to activat it..." -NoNewline

$arguments = $esxcli2.system.coredump.file.set.CreateArgs()
$arguments.Item('enable') = $true
$arguments.Item('smart') = $true

Try {
    $activation = $esxcli2.system.coredump.file.set.Invoke($arguments)
}
Catch [Exception]{
    Write-Host " File doen't exist!" -ForegroundColor Yellow
}


# Get the current coredump configuration
$dumpConfigured = $esxcli2.system.coredump.file.get.Invoke().Configured


# Prompt for the coredump removal
If ($dumpConfigured -ne ''){
    Write-Host " File exists." -ForegroundColor Green
    Write-Host "`n Current configuration: $dumpConfigured"
         
    $choice = $null

    While ("Yes","No" -notcontains $choice) {
        $choice = Read-Host -Prompt "`n Would you like to remove this file? (Yes/No)"
    }
    
    Switch ($choice){
        
        "Yes" {
            # Remove the coredump file
            Write-Host " Removing the old coredump file..." -NoNewline

            $arguments = $esxcli2.system.coredump.file.remove.CreateArgs()
            $arguments.Item('force') = $true
            $arguments.Item('file') = "$dumpConfigured"

            $remove = $esxcli2.system.coredump.file.remove.Invoke($arguments)

            Write-Host " Done!" -ForegroundColor Green
        }
        
        "No" {
            # Exit this script
            Write-Host "`n Exiting..."
            ex
        }
    }
}

Write-Host "`n Exiting..."
