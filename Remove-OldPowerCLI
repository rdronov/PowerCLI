# File name: Remove-OldPowerCLI
# Description: This script removes the old versions of VMware.PowerCLI and its dependencies
#
# 21/12/2018 - Version 1.0
#     - Initial Release (based on https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/14934876-update-module-needs-flag-to-remove-previous-versio)
#
# Author: Roman Dronov (c)

$modules = @((Get-Module -ListAvailable | ? {$_.Name -like "VMware*"}).Name | Get-Unique)

foreach ($module in $modules){
    $latest = Get-InstalledModule -Name $module

    Get-InstalledModule -Name $module -AllVersions | ? {$_.Version -ne $latest.Version} | Uninstall-Module -Verbose
}
