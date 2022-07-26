# DNS
Useful DNS tips.

## Configure NextDNS on pfSense
There are *several options*, but using the [NextDNS CLI client (DoH Proxy)](https://github.com/nextdns/nextdns) is the easiest.

To install it, do the following:

1. As per instructions at <https://github.com/nextdns/nextdns/wiki/Installer>, just open a shell and:
```
sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
```
then follow the prompts.

2. Then, via web UI, go to _Services / DNS Resolver_ and make sure it is **NOT Enabled**!

3. Next, go to _System / General Setup / DNS Server Settings_ 
- Ensure **DNS Servers** boxes are both empty/blank
- Uncheck **DNS Server Override**
- Set **DNS Resolution Behavior** to _Use local DNS (127.0.0.1), ignore remote DNS Servers_ 

4. Additional interfaces to listen on
There are times when listening on `localhost:53` is not enough and you have to add all other interfaces on the router. See <https://help.nextdns.io/t/x2hft9v/pfsense-v2-5>
```
nextdns stop 
vi /usr/local/etc/nextdns.conf  # and update/add below lines
setup-router false   # From 'true'
listen localhost:53  # Should already be there
listen 10.10.1.1:53  # Sample 3 additions
listen 10.10.2.1:53
listen 10.10.3.1:53
nextdns start
```

## PowerShell DNS Command Commands
```
# Show A record
Get-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName mydomain.com -Name myhost

# Show PTR
Get-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "10.in-addr.arpa" -Node "8.8.10" -RRType "PTR"
Get-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "10.10.in-addr.arpa" -Node "8.8" -RRType "PTR"
Get-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "8.10.10.in-addr.arpa" -Node "8" -RRType "PTR"

# Show TXT
Get-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "mydomain.com" -RRType "TXT" -Name _acme-challenge

# Create A
Add-DnsServerResourceRecordA -ComputerName ns1.mydomain.com -TimeToLive 00:05:00 -ZoneName mydomain.com -Name host1 -IPv4Address 10.10.8.8 [-CreatePtr] (Creates it in the 10.in-addr.arpa zone)
  Use -Name "." to update the apex domain

# CREATE PTR
Add-DnsServerResourceRecordPtr -ComputerName ns1.mydomain.com -TimeToLive 00:05:00 -ZoneName "10.in-addr.arpa" -Name "8" -PtrDomainName "host1.mydomain.com"

# CREATE CNAME
Add-DnsServerResourceRecordCName -ComputerName ns1.mydomain.com -TimeToLive 00:05:00 -ZoneName mydomain.com -Name host1 -HostNameAlias "srv1.contoso.com"

# CREATE TXT
Add-DnsServerResourceRecord -Txt -ComputerName ns1.mydomain.com -TimeToLive 00:05:00 -ZoneName mydomain.com -Name "." -DescriptiveText "value=SomeText"

# REMOVE A 
Remove-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "mydomain.com" -RRType "A" -Name "host1" -Force

# REMOVE CNAME
Remove-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "mydomain.com" -RRType "CNAME" -Name "host1" -Force

# REMOVE PRT
Remove-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "10.in-addr.arpa" -RRType "PTR" -Name "8.8.10" -Force
# You should also remove other PTRs if they exist

# REMOVE TXT
Remove-DnsServerResourceRecord -ComputerName ns1.mydomain.com -ZoneName "mydomain.com" -RRType "TXT" -Name "."
```

## PowerShell DNS Scripts
PowerShell scripts to perform several different functions on DNS zone records hosted in AD. These scripts need to be moved to a repo.

- Input file:
```
# FQDN,IP
eth3-12-450-acbj-campus-z1wtc20c02.mydomain.com,10.19.0.179
eth4-3-450-acbj-core-z1wtc20c01.mydomain.com,10.19.0.172
lo8-acbj-campus-z1wtc20c01.mydomain.com,10.19.0.28
po1-450-acbj-core-z1wtc20c01.mydomain.com,10.19.0.174
po3-450-dc-core-z1wtc20c01.mydomain.com,10.19.3.5
```

- Records verifier: 

```
# chk.ps1
# This script verifies A/PTR records from DNS records in input file. Needs DNS admin privileges.
# Input file must be formatted as follows:
#   FQDN,IP
#   host01.mydomain.com,192.168.0.1
#   host30.mydomain.com,192.168.0.2
#   ...

$InputFile = "recs.csv"
$records = Import-CSV $InputFile
$ns = "ns1.mydomain.com"   # Update this according to your environment

# Print header
"{0,-60}{1,-18}{2,-8}{3,-8}" -f "FQDN", "IP ADDRESS", "A REC", "PTR REC"

# Loop through each record and display status
ForEach ($rec in $records) {
  $ip = $rec.IP.Trim()
  $fqdn = $rec.FQDN.Trim()

  $rec = (Resolve-DnsName -ErrorAction 'Ignore' -Name $fqdn -Type A -Server $ns -DnsOnly -NoHostsFile).IPAddress
  if ( $rec -eq $ip ) {
    $a = "OK"
  } else {
    $a = "BAD"
  }

  $rec = (Resolve-DnsName -ErrorAction 'Ignore' -Name $ip -Type PTR -Server $ns -DnsOnly -NoHostsFile).NameHost
  if ( $rec -eq $fqdn ) {
    $p = "OK"
  } else {
    $p = "BAD"
  }

  "{0,-60}{1,-18}{2,-8}{3,-8}" -f $fqdn, $ip, $a, $p
}
```

- Records creator: 

```
# add.ps1
# This script create all DNS records as per input file. Requires DNS admin privileges.
# Input file must be formatted as follows:
#   FQDN,IP
#   host01.mydomain.com,192.168.0.1
#   host30.mydomain.com,192.168.0.2
#   ...

$InputFile = "recs.csv"
$records = Import-CSV $InputFile
$ns = "ns1.mydomain.com"   # Update below according to your environment

# Step1: Validate records are correctly formatted
ForEach ($rec in $records) {
  $fqdn = $rec.FQDN.Trim()
  $len = $fqdn.split('.').length
  If ($len -lt 3) {
    Write-Host "Error: $fqdn is not in a proper FQDN format"
    break
  }
  $ip = $rec.IP.Trim()
  Try {
    $ip = [ipaddress]$ip
  }
  Catch {
    Write-Host "Error: $ip is not a valid IP address"
    break
  }
}

# Step2: Perform the actual updates
ForEach ($rec in $records) {
  $ip = $rec.IP.Trim()
  $fqdn = $rec.FQDN.Trim()
  Write-Host "DOING => $fqdn, $ip"

  # Get name and zone
  $fqdnArray = $fqdn.split('.')
  $len = $fqdnArray.length - 1
  $zone = $fqdnArray[1 .. $len] -join '.'
  $name = $fqdnArray[0]

  Write-Host "  Creating A and PTR records"
  Add-DnsServerResourceRecordA -ComputerName $ns -ZoneName $zone -TimeToLive 00:05:00 -Name $name -IPv4Address $ip -CreatePtr
}
```

- Records deleter: 

```
# del.ps1
# This script deletes DNS records in input file. Needs DNS admin privileges.
# Input file must be formatted as follows:
#   FQDN,IP
#   host01.mydomain.com,192.168.0.1
#   host30.mydomain.com,192.168.0.2
#   ...

$InputFile = "recs.csv"
$records = Import-CSV $InputFile
$ns = "ns1.mydomain.com"   # Update this according to your environment

# Step1: Validate records are correctly formatted
ForEach ($rec in $records) {
  $fqdn = $rec.FQDN.Trim()
  $len = $fqdn.split('.').length
  If ($len -lt 3) {
    Write-Host "Error: $fqdn is not in a proper FQDN format"
    break
  }
  $ip = $rec.IP.Trim()
  Try {
    $ip = [ipaddress]$ip
  }
  Catch {
    Write-Host "Error: $ip is not a valid IP address"
    break
  }
}

function RemoveAllPtrRecords ($ip) {
  $addr = $ip.split('.')
  Write-Host "  Removing any existing PTR records."
  Try {
    dnscmd $ns /recorddelete "$($addr[2]).$($addr[1]).$($addr[0]).in-addr.arpa" "$($addr[3])" PTR /f *> $null
    dnscmd $ns /recorddelete "$($addr[1]).$($addr[0]).in-addr.arpa" "$($addr[3]).$($addr[2])" PTR /f *> $null
    dnscmd $ns /recorddelete "$($addr[0]).in-addr.arpa" "$($addr[3]).$($addr[2]).$($addr[1])" PTR /f *> $null
  }
  Catch {
    # Do nothing. This try/catch is just to keep this quiet
  }
}

# Step2: Perform the actual updates
ForEach ($rec in $records) {
  $ip = $rec.IP.Trim()
  $fqdn = $rec.FQDN.Trim()
  Write-Host "DOING => $fqdn, $ip"

  # Get name and zone
  $fqdnArray = $fqdn.split('.')
  $len = $fqdnArray.length - 1
  $zone = $fqdnArray[1 .. $len] -join '.'
  $name = $fqdnArray[0]

  Write-Host "  Removing $name from $zone"
  Try {
    Remove-DnsServerResourceRecord -ComputerName $ns -ZoneName "$zone" -RRType "A" -Name "$name" -Force
  }
  Catch {
    # Do nothing. This try/catch is just to keep this quiet
  }

  RemoveAllPtrRecords "$ip"
}
```

- Records creator/updater: 

```
# upsert.ps1
# This script creates/updates DNS records in input file. Needs DNS admin privileges.
# Input file must be formatted as follows:
#   FQDN,IP
#   host01.mydomain.com,192.168.0.1
#   host30.mydomain.com,192.168.0.2
#   ...

$InputFile = "recs.csv"
$records = Import-CSV $InputFile
$ns = "ns1.mydomain.com"   # Update this according to your environment

# Step1: Validate records are correctly formatted
ForEach ($rec in $records) {
  $fqdn = $rec.FQDN.Trim()
  $len = $fqdn.split('.').length
  If ($len -lt 3) {
    Write-Host "Error: $fqdn is not in a proper FQDN format"
    break
  }
  $ip = $rec.IP.Trim()
  Try {
    $ip = [ipaddress]$ip
  }
  Catch {
    Write-Host "Error: $ip is not a valid IP address"
    break
  }
}

function RemoveAllPtrRecords ($ip) {
  $addr = $ip.split('.')
  Write-Host "  Removing any existing PTR records."
  Try {
    dnscmd $ns /recorddelete "$($addr[2]).$($addr[1]).$($addr[0]).in-addr.arpa" "$($addr[3])" PTR /f *> $null
    dnscmd $ns /recorddelete "$($addr[1]).$($addr[0]).in-addr.arpa" "$($addr[3]).$($addr[2])" PTR /f *> $null
    dnscmd $ns /recorddelete "$($addr[0]).in-addr.arpa" "$($addr[3]).$($addr[2]).$($addr[1])" PTR /f *> $null
  }
  Catch {
    # Do nothing. This try/catch is just to keep this quiet
  }
}

# Step2: Perform the actual updates
ForEach ($rec in $records) {
  $ip = $rec.IP.Trim()
  $fqdn = $rec.FQDN.Trim()
  Write-Host "DOING => $fqdn, $ip"

  # Get name and zone
  $fqdnArray = $fqdn.split('.')
  $len = $fqdnArray.length - 1
  $zone = $fqdnArray[1 .. $len] -join '.'
  $name = $fqdnArray[0]

  Write-Host "  Removing $name from $zone"
  Try {
    Remove-DnsServerResourceRecord -ComputerName $ns -ZoneName "$zone" -RRType "A" -Name "$name" -Force
  }
  Catch {
    # Do nothing. This try/catch is just to keep this quiet
  }

  RemoveAllPtrRecords "$ip"

  Write-Host "  Creating A and PTR records"
  Add-DnsServerResourceRecordA -ComputerName $ns -ZoneName $zone -TimeToLive 00:05:00 -Name $name -IPv4Address $ip -CreatePtr
}
```

## Speed Up Initial Record Creation
To speed this up initial record creation within a zone, update the **negative caching TTL** value in the SOA record for that zone: 

```
Format: 
    [authority-domain] [domain-of-zone-admin]
    [zone-serial-number] [refresh-time] [retry-time] 
    [expire-time] [negative caching TTL] 
Example: 
    ns.example.net. hostmaster.example.com. 1 
    7200 900 1209600 86400
```

## Google DNS Flush cache
<https://developers.google.com/speed/public-dns/cache>

## Improving DNS Perfomance 
- Use a DNS service that uses Anycast for their servers
- Make sure the DNS provider has servers distributed globally (and that perform well)
- Try to avoid long CNAME chains (try to avoid them at all if possible)
- Use a long Time To Live (TTL) on your records so they can be cached by the ISPs and users

