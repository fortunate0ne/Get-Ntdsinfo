

<#
.SYNOPSIS

This script uses the output of Get-Ntdsfiles.ps1 to grab user info and output this info to csv and hashcat by default. This script was created by fortunate and and Nicholas Schuchhardt as a class project for Dakota State University and Secure Banking Solutions.
.DESCRIPTION

This Script has some pre-requisites:1. Install Powershell 5 or higher. 2.From an administrative powershell run "install-module -name DSInternals. 3. Set-executionpolicy  unrestricted. This script should work from that point on. If the database is corrupt then run "esentutl /d ntds.dit" from the same directory as ntds.dit to clean it up. 
.PARAMETER filepath

(Optional) defaults to current working directory. This parameter allows you to set the folder location of the required SYSTEM hive and NTDS.dit created by the Get-Ntdsfiles
.PARAMETER hashlist

(Optional) defaults to hashcat output. This parameter allows you to change the output for different types of hash cracking programs. The options are: No, HashcatNT, HashcatLM, JohnNT, JohnLM, Ophcrack
.PARAMETER hashlist

(Optional) defaults to current working directory. This parameter allows you to set the out location of the user and hash files.
.EXAMPLE

Get-Ntdsinfo.ps1 -hashlist no
.EXAMPLE

Get-Ntdsinfo.ps1
.EXAMPLE

Get-Ntdsinfo.ps1 -hashlist ophcrack
#>

#Set defaults for command line arguments
param (
  [string]$filepath = $pwd.psobject.baseobject,
  [string]$hashlist = 'hashcatnt',
  [string]$outpath =  $pwd.psobject.baseobject
  )

#import DSInternals module made by Michael Grafnetter, www.dsinternals.com
import-module DSInternals


#Finding important files within user defined file structure
$systempath = Get-ChildItem -Path $filepath -Recurse -filter system | Select-Object -First 1
$ntdspath = Get-ChildItem -Path $filepath -Recurse -filter ntds.dit | Select-Object -First 1


#Pull bootkey out of SYSTEM hive file
$key = Get-BootKey -SystemHivePath $systempath.FullName


#Pull data out of NTDS.dit using the bootkey to decrypt. Writes info to file
Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | export-csv "$filepath\userinfo.csv"


#Decide how to output hashes if at all.
if ($hashlist.ToLower() -eq "no"){
    break
}
elseif($hashlist.ToLower() -eq "hashcatnt"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View HashcatNT | Out-File "$filepath\hashes.txt" -Encoding ASCII
}
elseif($hashlist.ToLower() -eq "hashcatlm"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View HashcatLM | Out-File "$filepath\hashes.txt" -Encoding ASCII
}
elseif($hashlist.ToLower() -eq "johnnt"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View JohnNT | Out-File "$filepath\hashes.txt" -Encoding ASCII
}
elseif($hashlist.ToLower() -eq "johnlm"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View johnlm | Out-File "$filepath\hashes.txt" -Encoding ASCII
}
elseif($hashlist.ToLower() -eq "ophcrack"){
    Get-ADDBAccount -All -DBPath $ntdspath.FullName -BootKey $key.psobject.BaseObject | Format-Custom -View Ophcrack | Out-File "$filepath\hashes.txt" -Encoding ASCII
}
else{
    write-host "The Hash file type spcified is incorrect. Valid options are: HashcatNT, HashcatLM, JohnNT, JohnLM, Ophcrack " -ForegroundColor Red
}
