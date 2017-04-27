

<#
.SYNOPSIS

Should be run off of a USB device, but can be run locally. Make sure to run it on the domain controller

To run this script make sure you set the execution policy to unrestricted. Ex: set-execution policy unrestricted

This script is used to obtain the SYSTEM and ntds.dit file from the DC.
When running this script make sure you specify where to save the information you pull from the DC by using the -path parameter.
.PARAMETER path

(Optional) Defaults to current working directory. This parameter allows you to set the out location of the domain backup files.

.EXAMPLE
.\Get-Ntdsfiles.ps1 -path [location for files from DC]

.EXAMPLE
.\Get-Ntdsfiles.ps1
#>

# Setting default for command line parameters
param (
  [string]$path = $pwd.psobject.baseobject
  )
# Grabs the domain backup
try {
  ntdsutil “activate instance ntds” ifm “create sysvol Full $path” q q q
}
# Invalid command
catch {
write-host "Either the path you entered is not empty or does not exist." -ForegroundColor Red
break
}
"Exiting"
