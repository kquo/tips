# Windows
Microsoft Windows tips.

1. [Manage ActiveDirectory from PowerShell](#manage-activedirectory-from-powershell)
2. [Update PATH](#update-path)
3. [Windows SubSystem for Linux (WSL)](#windows-subsystem-for-linux-wsl)
4. [ROBOCOPY](#robocopy)


## Manage ActiveDirectory from PowerShell
Make sure you have the right module installed
```
Import-Module ActiveDirectory      # If 'ActiveDirectory' isn't listed, proceed to next step to install it

Install-Module -name AzureAD -scope CurrentUser

OTHER SCRIPTS

# get-members groupName domainName
param($groupName='default-name', $domainName='defDomainName')
Get-ADGroup -Identity $groupName -Server $domainName -Properties member).member

CREATE NEW APP REGISTRATION
$New-AzureADApplication -displayname NAME
$Secret = New-AzureADApplicationPasswordCredential -objectid <ObjectID_from_above>
$Secret.value
```


## Update PATH
To view `PATH` variable fro the __system__:
```
reg query "HKLM\CurrentControlSet\Control\Session Manager\Environment" /v Path
```

To only update my own separate user's `PATH`:
```
setx PATH "c:\ProgramData\etc;c:\users\user1\bin;blah;blah"
```
Note there's a 1024 characters limit.

To view the combined __system + user__ `PATH`:
```
echo %PATH    # Regular Prompt
$env:path     # PowerShell
```


## Windows SubSystem for Linux (WSL)
```
As an Local Admin, enable the "Windows Subsystem for Linux" optional feature and reboot
Created C:\linux directory and cd to it
curl -Lo ubuntu-1804.zip https://aka.ms/wsl-ubuntu-1804
Extract ubuntu-1804.zip under C:\linux directory
Double Click on C:\linux\ubuntu-1804\ubuntu-1804.exe and follow prompts to install this distro
Pin C:\linux\ubuntu-1804\ubuntu-1804.exe to Start or Taskbar for easy access
Common  
wslconfig /l          # List installed distros
wslconfig /s DISTRO   # Set DISTRO as default distro
wslconfig /u DISTRO   # Remove DISTRO

UDPATE WSL UBUNTU CERTS
sudo apt update
sudo apt -y upgrade
sudo mkdir /usr/local/share/ca-certificates/extra
sudo cp root.cert.pem /usr/local/share/ca-certificates/extra/root.cert.crt
sudo update-ca-certificates
```


## ROBOCOPY
```
@ECHO OFF
:: datasync.cmd
SET _source=c:\users\user1\data 
SET _dest=h:\data
SET _what=/MIR /XD exclude
:: /MIR :: Mirror copy all (deletes stuff on _dest UNLESS explicitly excluded!)
:: /XD <Directory>[...] :: excludes directories that match the specified names and paths 
:: /XF <FileName>[...] :: excludes files that match the specified names or paths. Note that FileName can include wildcard characters (* and ?) 
SET _options=/LOG:C:\temp\datasync-log.txt /R:2 /W:2
:: /R:n :: number of Retries 
:: /W:n :: Wait time between retries 
:: /LOG :: Output log file 
ROBOCOPY %_source% %_dest% %_what% %_options%
```
