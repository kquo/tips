# Linux
Useful Linux tips.

## Install Homebrew for Linux
At the moment Homebrew doesn't support Linux on ARM64

```bash
sudo dnf install -y curl git gcc make procps file
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
brew --version
brew install htop
htop
```

## Log Rotate
```bash
Setup rotation for example Java app name hal-linker:
$ cat /etc/logrotate.d/hal-linker
# This file is managed by Puppet, changes may be overwritten
/cn/runtime/hal-linker/java/logs/app.log {
    daily
    missingok
    notifempty
    copytruncate
    rotate 14
    compress
    maxsize 300M
    dateext dateformat -%Y%m%d-%s
}
```


## CentOS Tips
```
# Update grub timeout value
vi /etc/default/grub
GRUB_TIMEOUT=0
grub2-mkconfig -o /boot/grub2/grub.cfg


# Reduce disk size by only keeping English locales ('^en')
# Takes /usr/sbin/build-locale-archive from ~100MB to ~3MB
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive
# You may lose SSH connection

# Get network adapter MAC address
cat /sys/class/net/*/address
cat /sys/class/net/eth0/address

# Removing a systemd service
systemctl stop [servicename]
systemctl disable [servicename]
rm /etc/systemd/system/[servicename]
rm /etc/systemd/system/[servicename] symlinks that might be related
systemctl daemon-reload
systemctl reset-failed
```


## lsof
You can find the biggest open files with:
```
sudo lsof -s | awk '$5 == "REG"' | sort -n -r -k 7,7 | head -n 50
This will list the regular files (not pipes, sockets, etc) sort by size in descending order, and take the top 50.
You might also look at what processes have the most files open, with something like
sudo lsof | awk '$5 == "REG" {freq[$2]++ ; names[$2] = $1 ;} END {for (pid in freq) print freq[pid], names[pid], pid ; }' | sort -n -r -k 1,1
```


## Disable IP Tables and SELinux
If you have to do this:
```
service iptables stop  ; service ip6tables stop
chkconfig iptables off ; chkconfig ip6tables off

sestatus                                            Check overall SElinux status
getenforce                                          Check if enforcing
setenforce 0                                        Disable temporarily
vi /etc/sysconfig/selinux and set to 'permissive'   Disable permanently
```


## No Login Shell
To disable shell login for some users:
```
vi /etc/passwd   # and update shell to /sbin/nologin
to prevent no shell from SFTP you have to use /usr/bin/scponly as the shell
```


## Mirror a Site With Wget
Scrape an entire site with `wget`:

```bash
wget -mkEpnp https://www.google.com/
```


## Backup the Entire Files System
- See <https://help.ubuntu.com/community/BackupYourSystem/TAR>

- Backup 

```
tar -cvpzf backup.tar.gz --exclude=/backup.tar.gz --exclude=/proc --exclude=/lost+found --exclude=/sys --exclude=/mnt --exclude=/media --exclude=/dev /

rsync -aAXv / --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} /mnt
```

- Restore 

```
tar -xvpzf /home/test/backup.tar.gz -C /
 (change last directory whatever you need)
```


## Clear Chace Memory
`sync ; echo 3 > /proc/sys/vm/drop_caches`


## Postfix
To setup Postfix as default MTA.
```
1. Install postfix
2. To setup as relay edit the main.cf with:

relayhost = <IP-Address-of-SMPT-server>    ## it must allow you to send mail
smtp_generic_maps = hash:/etc/postfix/generic

3. Edit /etc/postfix/generic and add any required users
4. postmap /etc/postfix/generic
5. Restart postfix: /etc/init.d/postfix restart

NOTE:
Fedora uses sendmail as default MTA.
After you have postfix installed you may have to select postfix using:

alternatives --config mta
```


## Send Email from CLI
```
sendmail -f sender@example.com recipient@example.com
From: Sender Name <sender@example.com>
Subject: Test                
Test message.                
.
CTRL-D
```


## TCPDUMP
Sample `tcpdump` commands:
- Capture reset (RST) flag:
```
tcpdump -nni eth0 host 17.154.66.159 and 'tcp[13] & 4 != 0'
```


## WIRESHARK
Sample search:
```
ip.addr == 10.91.29.249 and ip.addr == 17.154.66.159 or tcp.flags.reset == 1
```


## NFS
```
  On SERVER
  1. yum install nfs-utils autofs
  2. chkconfig nfs on
  3. service nfs start

  4. Setup your exports:
  # cat /etc/exports
  /export/vol1     *(rw,sync,no_subtree_check)
  /export/vol2     *(rw,sync,no_subtree_check)
  /export/vol3     *(rw,sync,no_subtree_check)

  5. Let NFS know
  exportfs -var      # Let NFS server know

  On CLIENT
  1. Mount any of the vols
  # mount SERVER:/export/vol1 /mnt

List exported volumes
  showmount  
```


## TMPFS
```
vi /etc/fstab
tmpfs       /dev/shm      tmpfs   defaults,size=512m   0 0
then run
  mount -o remount /dev/shm
```


## LVM
LVM is a thin software layer on top of the hard disks and partitions, which creates an illusion of continuity and ease-of-use for managing hard-drive replacement, repartitioning, and backup.
```
  LV(LogicalVolume) = Mountable drive
    => VG(VirtualGroup) = Defined group
      => PV(PhysicalVolume) = Partition from any physical disk

  PREP DISK PARTITION
  Force scan of scsi bus so host reports added disks
    echo "- - -" > /sys/class/scsi_host/host0/scan
    echo "- - -" > /sys/class/scsi_host/host1/scan
    echo "- - -" > /sys/class/scsi_host/host2/scan
  fdisk
    fdisk /dev/sdb
    Create a new partition #1, using entire disk if appropriate
    Toggle partition type to 8e (Linux LVM)
    Write partition table and exit
  parted
    parted -s /dev/sdb mklabel gpt
    parted -s /dev/sdb mkpart 1 0% 100%
    parted -s /dev/sdb set 1 lvm on

  COMMON COMMANDS
  lvmdiskscan                            Scan for all devices visible to LVM2
  pvs / pvscan / pvdisplay               Info on Physical Volumes
  vgs / vgscan / vgdisplay               Info on Virtual Groups
  lvs / lvscan / lvdisplay               Info on Logical Volumes

  pvcreate /dev/sdb1                     Create PV /dev/sdb1 (/dev/sdb1 must be type 8e Linux LVM)

  vgcreate vg0 /dev/sdb1                 Create VG vg0 with PV /dev/sdb1 (Creating a VG from partial PV not allowed)
  vgcreate vg1 /dev/sdb2 /dev/sdb3       Create VG vg1 with PV /dev/sdb2 and /dev/sdb3
  vgreduce vg1 /dev/sdb3                 Remove PV /dev/sdb3 from VG vg1
  vgextend vg1 /dev/sdb4                 Add PV /dev/sdb4 to vg1
  vgremove vg1                           Remove VG vg1
  vgdisplay -v vg1                       Displays all Logical & Physical volumes that make up VG vg1

  lvcreate -l 100%FREE -n web vg0        Create LV web with all remaining space in VG vg0 (LOWERCASE l!)
  lvcreate -L 100G -n web vg0            Create LV web of 100GB in VG vg0
  lvcreate -L 250G -n app vg0            Create LV app of 100GB in VG vg0
  lvremove /dev/vg0/app                  Remove LV app (Must umount beforehand)

  lvextend -L +50G /dev/vg0/projects     Increase LV projects by 50G (follow up with resize2fs)
  lvresize -l -50G /dev/vg0/projects     Resizes LV projects by 50G (WARNING: DANGEROUS! FS must be resized beforehand)
  resize2fs /dev/vg0/projects            Updates LV FS size after running lvextend or lvresize
  mkfs -t xfs /dev/vg0/web               Format LV web as XFS

  PREP VOLUME FOR USE
  lsblk -f                                   Breakdown of disk/partition/volume, FS types, labels, uuids, and mounts (RHEL)
  blkid                                      Show current volume labels
  e2label /dev/mapper/vg0-web WEB            EXT4 FS  Label web volume to ease mounting and ID'ing
  xfs_admin -L WEB /dev/mapper/vg0-web       XFS FS   Label web volume 
  xfs_admin -U generate /dev/mapper/vg0-web  Generate a new UUID

  MOUNT OPTIONS
  mount -o nouuid /dev/sdb7 /mnt         Without UUID

  FEDORA/CENTOS KICKSTART FILE LVM SETUP
  # Creates:
  #    Device Boot      Start         End      Blocks   Id  System
  # /dev/sda1   *        2048     1026047      512000   83  Linux
  # /dev/sda2         1026048    16777215     7875584   8e  Linux LVM
  #
  # Disk /dev/sda: 8589 MB, 8589934592 bytes, 16777216 sectors
  # Disk /dev/mapper/vg-lv_root: 6731 MB, 6731857920 bytes, 13148160 sectors
  # Disk /dev/mapper/vg-lv_swap: 1287 MB, 1287651328 bytes, 2514944 sectors
  #
  clearpart --all --drives=sda
  zerombr 
  part /boot --fstype=ext4 --size=500
  part pv.01 --grow --size=1
  volgroup vg --pesize=4096 pv.01
  logvol / --fstype=ext4 --name=lv_root --vgname=vg --grow --size=1024 --maxsize=51200
  logvol swap --name=lv_swap --vgname=vg --grow --size=1228 --maxsize=1228
  # net.ifnames=0 biosdevname=0 disables CentOS 7 predictable network interface names
  bootloader --location=mbr --driveorder=sda --append="set crashkernel=auto rhgb quiet net.ifnames=0 biosdevname=0" --timeout=0
```


## SSH
```
PRINT PUBLIC KEY
alias sshpub='ssh-keygen -y -f'


IDEAL WHEN RUNNING SSH SHELL LOOPS
ssh -o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=no


GET PUBLIC KEY FINGERPRINT
Method1 - OpenSSH
  ssh-keygen -E md5 -lf /dev/stdin <<< `ssh-keygen -f id_rsa -y`
Method2 - OpenSSL
  openssl rsa -in ~/.ssh/id_rsa_devops3 -pubout -outform DER | openssl md5 -c
User Method2/OpenSSL one to compare AWS EC2 SSH2 fingerprints

SSH CLIENT USING BASH AUTO-COMPLETE
1. Add this line to your .bashrc file:

# .bashrc
# notice it affects all scp, sftp and ssh commands
complete -o default -o nospace -W "$(grep ^Host $HOME/.ssh/config | grep -v "*" | awk '{print $2}')" scp sftp ssh

2. Then create/add/modify these settings on your $HOME/.ssh/config file:
# ~/.ssh/config
# General SSH client-wide settings
CheckHostIP           no
ForwardX11            yes
ForwardX11Trusted     yes
ServerAliveCountMax   20
ServerAliveInterval   60
StrictHostKeyChecking no

# ------------ group-1 ---------------
# For servers whose names start with ‘myservers-*’ and ‘ip-10*’
Host myservers-* ip-10*
   User root
   IdentityFile /Users/myusername/.ssh/group1-key.pem

# ------------ group-2 -------------------
# For servers in this group where my account name is ‘username2’
   User username2
   IdentityFile /Users/myusername/.ssh/username2.pem
Host host20-prd-app01
   HostName ec2-174-100-100-100.compute-1.amazonaws.com
Host whatever-name-i-want
   HostName 100.100.100.100

# ------------ group-3 -------------------
# Examples to proxy connections through a jump box gateway server
# Note that the User will be whatever you’re currently logged in as when .bashrc is read

Host group3-host1
   ProxyCommand ssh g3jumpbox.mydomain.com /usr/bin/nc 10.10.10.1 22
   LocalForward localhost:8081 localhost:8080
   LocalForward localhost:3000 localhost:3000
Host group3-host2
   ProxyCommand ssh g3jumpbox.mydomain.com /usr/bin/nc 10.10.10.2 22
   LocalForward localhost:8000 localhost:8000
```


## Measure Network Performance
Use `iperf3` to measure network speed.
```
ON_SERVER: iperf3 -s <IP-or-Hostame> [-p PORT]   # Default port is 5301 
ON_CLIENT: iperf3 -c <IP-or-Hostame> [-p PORT]
```

## Out-of-Memory Crashes
When a process is leaking memory and tops out and experiences an OOM (Out of Memory) crash the kernel can panic and the entire machine can crash. This is actually a deliberate OS policy that's followed whereby the oom-killer is invoked and halts the system. These problems can be averted if the system has enough swap space, but that will only mask the fact there's a bad that's leaking memory, which is really the core issue.
- Say Apache httpd service runs out of memory because of a bad PHP app:
```
/var/log/messages
  Feb  2 00:50:39 s612770nj3vl412 kernel: httpd invoked oom-killer: gfp_mask=0x201da order=0 oom_adj=0 oom_score_adj=0  
  Feb  2 00:50:39 s612770nj3vl412 kernel: [<ffffffff811131c2>] ? oom_kill_process+0x82/0x2a0
  Feb  2 00:50:39 s612770nj3vl412 kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
```
- To prevent this, add the following to `/etc/sysctl.conf`:
```
# Prevent OOM killer (Out of Memory) which causes the server to crash
vm.overcommit_memory = 2
vm.overcommit_ratio = 80
```
- Or run it manually for immediate effect:
```
echo 2 > /proc/sys/vm/overcommit_memory ; echo 80 > /proc/sys/vm/overcommit_ratio
```
- References
  1. <http://www.calazan.com/how-to-prevent-your-linux-server-from-crashing-due-to-php5-oom-killer-out-of-memory-errors/>
  2. <http://www.win.tue.nl/~aeb/linux/lk/lk-9.html#ss9.6>


## Increase Ephemeral Ports
Usually needed from Load Test server performing a large number of connections.
See <http://www.cyberciti.biz/tips/linux-increase-outgoing-network-sockets-range.html>
```
cat /proc/sys/net/ipv4/ip_local_port_range
32768 61000
echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
# Also add to /etc/sysctl.conf
```


## Samba Optimize Config
Using <http://www.eggplant.pro/blog/faster-samba-smb-cifs-share-performance/>
```
strict allocate      = Yes
read raw             = Yes
write raw            = Yes
strict locking       = No
socket options       = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
min receivefile size = 16384
use sendfile         = true
aio read size        = 16384
aio write size       = 16384
```


## SYSTEMD JOURNALD
Rate-limiting systemd/journald logging.
```
1. Default in /etc/systemd/journald.conf is to drop any log messages over 1000 over a span of 30 seconds;
   RateLimitInterval=30s
   RateLimitBurst=1000
   a. Setting both to zero will disable all rate limiting but may cripple a system from too much logging
   b. Default setting is a balanced compromised
2. Key questions
   a. How widespread are these rate-limiting log messages?
   b. Are they causing us to miss critical and actionable log messages?
```


## Ansible
- To set on Linux, add all your hostnames/IP address to `/etc/ansible/hosts` under the `[all]` section.

- For a specific group of IPs, say 'server-group', add the following:
```
[server-group]
10.90.37.128
10.90.40.195
10.90.32.192
10.90.44.178
```

- Top avoid "The authenticity of host X can't be established" errors edit `/etc/ansible/ansible.cfg` and set:
```
[defaults]
host_key_checking = False
```

- On macOS admin laptop use `~/.ansible.cfg` instead of `/etc/ansible/ansible.cfg` and for hosts point to:
```
hostfile = /path/to/hostfile
```

- Sample commands
```
ansible server-group -m shell -a "crontab -u user -l " -u root --sudo
ansible all --private-key=id_rsa -m shell -a "hostname" -u root --sudo
ansible all --private-key=id_rsa -a "systemctl status sensu-client.service | grep Active" -u root --sudo
ansible all --private-key=.ssh/id_rsa_devops -m shell -a "hostname" -u cloud-user --sudo > sensu-nonprod-removal-confirm.log 2>&1 &
```

- Sample `~/.ansible.hosts` file:
```
[nonprod]
10.191.43.58
10.191.26.103
10.191.24.163
[prod]
10.190.24.73
10.190.29.246
10.190.24.133
```

- Set up Ansible and run command
```
brew install ansible
# Set up ~/.ansible.cfg accordingly, with below two lines being the most likely one to update.
[defaults]
host_key_checking = False
inventory = ~/.ansible.hosts
```

## Debug NTP Time Service
- Check NTP drift
```
service datadog-agent info -v 2>/dev/null | grep NTP
ntpstat
ntpq -c rv
chronyc sources -v
chronyc tracking
timedatectl  
```

- Reset time immediately (ntpdate mode):
```
ntpdate -u pool.ntp.org
ntpd -gq
chronyd -q 'pool pool.ntp.org iburst'
service ntpd stop && ntpd -gq && service ntpd start
service chronyd stop && chronyd -q 'pool pool.ntp.org iburst' && service chronyd start
```

- Test connectivity with Netcat (`nc`)
```
nc -zvu ntp.ubuntu.com 123    # UDP
nc -zv ntp.ubuntu.com 123     # TCP    
```

## SELinux
- Use configuration management to successfully deploy SELinux in a production environment.
- Android uses SE-Android by default.
- Security model of containers and SELinux is very similar: both controll a group of processes
- Always run SELinux in container environments by default!
- Check SElinux file issues with `ls -lZ`. Sometimes requires `restorecon FILE` to restore access.

## SystemD
- Handles dependencies between "units" (rather than daemons)
- Tracks processes with service info: owned by cgroups, simple to configure SLA for sys resources
- min boot time, and properly kills daemons
- debuggability
- simple to learn and backwards compat
- Unit file:
```
/usr/lib/systemd/system   DO NOT MODIFY files here
/etc/systemd/system       Administrator
/run/systemd/system       Temp run
```

- Slices, scopes, and services = cgroups
  - mixed hierarchies

