# Ubuntu
Useful Ubuntu tips.


## Turn Ubuntu into a Router
```
/etc/ufw/sysctl.conf:
net/ipv4/ip_forward=1
```


## Ubuntu General Configs
General 20.04 configs

Disable unused services:
```
nmcli radio wifi off                   # Disable Wifi
nmcli g                                # For status
systemctl disable bluetooth.service    # Disable Bluetooth
```

Setup Static IP 
```
# cat /etc/netplan/01-network-manager-all.yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  #renderer: NetworkManager
  ethernets:
    enp2s0:
      addresses: [10.10.2.2/24]
      gateway4: 10.10.2.1
      nameservers:
        addresses: [10.10.2.1]
```


##  Install Ubuntu on a Mac
Below isn't working with T2 machines [2021-mar-07]. For a working alternative see <https://github.com/marcosfad/mbp-ubuntu>

- Create Ubuntu USB installer
- Insert USB thumb disk 16GB or bigger
- Download your target OS (specify desktop or server ISO):
```
curl -LO https://releases.ubuntu.com/20.10/ubuntu-20.10-desktop-amd64.iso
curl -LO https://releases.ubuntu.com/20.10/ubuntu-20.10-live-server-amd64.iso
curl -LO https://releases.ubuntu.com/20.10/SHA256SUMS
```
- Confirm SHA sums match
```
cat SHA256SUMS
shasum -a 256 ubuntu-20.10-live-server-amd64.iso
```
- Convert to DMG format
```
hdiutil convert ubuntu-20.10-live-server-amd64.iso -format UDRW -o ubuntu-20.10-live-server-amd64
```
- List, umount, burn image
```
diskutil list  # and capture the USB disk number, e.g., /dev/disk2
diskutil unmountDisk /dev/disk2
sudo dd bs=32m conv=sync if=ubuntu-20.10-live-server-amd64.dmg of=/dev/rdisk2

# WARNING: May see a GUI error message. Ignore it.
diskutil unmountDisk /dev/disk2  # Again, after dd finishes
```
- Prepare TARGET Mac
  - Boot into Recovery Mode by pressing: Command-R
  - Within Recovery Mode UI, click on Utilities menu, then Startup Security Utility
  - Sign in with an existing macOS Admin account
  - Disable Secure Boot (No Security), and Allow Booting from external media
- Start Intallation
- Insert USB into target Mac and boot into Startup Manager by pressing Options key
- Select EFI Boot on the far right (this may take some time)
- At the Grub installer prompt select "Ubuntu" (this may also take some time)
- Ubuntu will check the hardware then jump into GUI installer
- Select Install Ubuntu

- Switch to visudo sudoers to using vi editor
`sudo update-alternatives --config editor  # Selection option 3`

- Why does default ubuntu server connect to astomi.canonical.com?


## Fix initramfs Error
To fix "initramfs unpacking failed decoding failed" error:
```
sudo vi /etc/initramfs-tools/initramfs.conf
Replace COMPRESS=lz4 with COMPRESS=gzip
sudo update-initramfs -u
Reboot
```


## Speedup Boot Time
Run `systemd-analyze blame` to see which services are taking the most time.

Set up Grub profiling to speed things up.
```
sudo vi /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash profile"
sudo update-grub2
```
During this next boot time you will see a noticeable SLOW DOWN. This could take minutes and is normal because Grub is now running the profile.

Once the boot up is complete, vi `/etc/default/grub` again and remove the `profile` part, re-run `sudo update-grub2`, and reboot. You should notice a distinct speed increase in your boot times.

Run `systemd-analyze blame` again and compare.

If NetworkManager takes the most time, you can disable at boot time:
```
systemctl mask NetworkManager-wait-online.service      # Disable
systemctl unmask NetworkManager-wait-online.service    # To re-enable if necessary
```

On some systems you can disable and remove cloud-init:
```
sudo touch /etc/cloud/cloud-init.disabled
Reboot machine, then run these commands to remove:
sudo apt-get purge cloud-init
sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/
```


## Grub Customizer
Install and run `grub-customizer` to ease grub customization of special kernel selections and settings. This doesn't work on a headless server, only on a graphical Desktop UI.
```
sudo apt install grub-customizer
grub-customizer 
```


## Rescue OS From Live CD
Boot from a Live Media to rescue existing OS on built-in disks.
Usually to update grub:
```
sudo -i
blkid  # To show all the partitions
IF ROOT IS ENCRYPTED and LVM is being used
  You'll need to unencrypt and mount the right LVM volume:
  blkid | grep LUKS                         # To show qualifying partitions
  cryptsetup open /dev/nvme0n1p3 crypt      # Enter passphrase to open LUKS encrypted disk
  lvs                                       # If using LVM, to list all logical drives
  mount /dev/mapper/vgubuntu-root /mnt      # The 'vgubuntu' would be gathered from previous command
mount /dev/ROOT_PART /mnt                   # Or mount correct root partition, if not using LVM
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount /dev/BOOT_PART /mnt/boot
chroot /mnt
vi /etc/default/grub   # Make necessary changes
MAY also need to preload some modules:
  nano /etc/default/grub  and add:
    GRUB_PRELOAD_MODULES="luks cryptodisk lvm"
update-initramfs -uv
update-grub
```


## Headless Server LUKS Encrypted
```
# Create a key file 
dd if=/dev/urandom of=/root/keyfile bs=1024 count=4
chmod 0400 /boot/keyfile
# Add it as an unlock key
cryptsetup -v luksAddKey /dev/sda3 /root/keyfile
# Find UUID of root partition
blkid | grep LUKS
# Update crypttab file
nano /etc/crypttab
sda3_crypt UUID=025c66a2-c683-42c5-b17c-322c2188fe3f /dev/disk/by-uuid/9e7a7336-3b81-4bbe-9f1a-d43415df1ccb:/root/keyfile luks,keyscript=/usr/lib/cryptsetup/scripts/passdev

```


## Ubuntu Desktop
To set up the MATE Ubuntu graphical desktop once you've installed a minimalist Ubuntu server, do the following:
```
MATE
sudo apt install ubuntu-mate-desktop
Gnome
sudo apt-get install ubuntu-gnome-desktop
```


## Snap
In Ubuntu version 20.04 Snap is installed by default, but it seems to mess with some progream. For instance, dig sometimes gives this error:
```
user@nc2004:~# dig www.google.com
dig: symbol lookup error: /lib/x86_64-linux-gnu/libisc.so.1601: undefined symbol: uv_handle_get_data
```
One is able to locate that library, and ldconfig -v even says the path is there, but it's unclear why the error still appears.
Removing Snap fixes the issue, if you don't care for Snap.

To remove Snap:
``` 
snap list
sudo snap remove X             # Repeat for each installed snap, except for snapd itself
df -h                          # To locate the snapd mount (/snap/snapd/7264, etc)
sudo umount /snap/snapd/7264   # Umount it
sudo apt purge snapd           # Finally, remove it. That's it!
# In version 20.10 last 2 above can simply be done with 'remove snapd'

Or in script form:

# Remove snap
UbuntuVer=$(hostnamectl | awk '/Operating System/ {print $4}')
UbuntuVer=${UbuntuVer%%.*}
if [[ "$UbuntuVer" -ge "20" ]]; then
  echo "==> Uninstalling all SNAP installs, including its daemon"
  sudo snap remove lxd
  sudo snap remove core18
  Ver=$(snap list | awk '/^snapd/ {print $3}')
  sudo umount /snap/snapd/$Ver
  sudo apt -y purge snapd
  # Again, since v20.10 you can also just do 'remove snapd'
fi
```


## Disable Power Management Automatic Sleep / Suspend
`sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target`


## Generate Crypted Password
For crafting automated user-data install
```
sudo apt install whois
echo password | mkpasswd -m sha512crypt --stdin
$6$z6Vuz0vA1KV2y0nF$HJvQL8YsuvKgYkg8lgnp7APOyujE/6OuHQKvh07rMgDpog58apqDVL51K5nnQgWtiRaWqvO2mRr2ZyX5if61n0
or
mkpasswd -m sha512crypt password
$6$z6Vuz0vA1KV2y0nF$HJvQL8YsuvKgYkg8lgnp7APOyujE/6OuHQKvh07rMgDpog58apqDVL51K5nnQgWtiRaWqvO2mRr2ZyX5if61n0
or
openssl passwd -1 -salt SaltSalt password
$1$SaltSalt$Nos71yblHcV.MLJOq5Njp.
```


## System Info
```
sudo apt -y install inxi
sudo inxi -Fxz

Kernel graphics driver info (specific to i915)
modinfo i915
```


## CPU Benchmark
```
sudo apt -y install sysbench
sysbench cpu --threads=2 run
```


## Sudo
```
cat /etc/sudoers.d/user1
user1 ALL=(ALL) NOPASSWD: ALL
```


### Bash
For root:
```
export PS1='\[\033[01;31m\]\u@\h:\W\[\033[00m\]\$ '
LS_COLORS='ex=31:ln=36'
alias ls='ls -N --color --time-style="+%Y-%m-%d %H:%M"'
alias ll='ls -ltr'
alias h='history'
```
For regular users use `01;32`


## Vim RC
```
syntax on
hi comment ctermfg=blue
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
set visualbell
set t_vb=
set ruler
set paste
```


## IPV6
Disable IPv6 
```
vi /etc/default/grub
  add ipv6.disable=1
  to GRUB_CMDLINE_LINUX_DEFAULT
Then run
  update-grub
OR
vi /etc/sysctl.conf and add below lines
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
sudo sysctl -p    # to invoke 
ip a              # to check 
OR
On some systems, like Raspberry Pi, you have to do this instead of master file:
cat /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
```


## Network
Switch from DHCP to static IP:
```
cat /etc/netplan/01-netcfg.yaml
  network:
    version: 2
    renderer: networkd
    ethernets:
      enp2s0:
        dhcp4: yes
      optional: true   # Don't wait on bootup
cp /etc/netplan/01-netcfg.yaml /root/        
vi /etc/netplan/01-netcfg.yaml
  network:
    version: 2
    renderer: networkd
    ethernets:
      enp2s0:
        addresses: [10.10.2.2/24]
        gateway4: 10.10.2.1
        nameservers:
          addresses: [10.10.2.1]
        optional: true  # Don't wait on bootup
```


## Disable CONTROL-ALT-DELETE
__Not 100% sure about this__. It can mess things up a bit. Needs more vetting.
```
sudo systemctl mask ctrl-alt-del.target
sudo systemctl daemon-reload
```


## NTP
```
timedatectl   # Will show that System clock synchronized: no
vi /etc/systemd/timesync.conf  # Set NTP=your server IP
sudo timedatectl set-ntp on
sudo systemctl restart systemd-timesyncd
timedatectl   # Should show that System clock synchronized: yes
```


## Change Timezone
```
sudo dpkg-reconfigure tzdata
```


## Swap File
```
sudo swapon --show   # Check current setting .. OR
free
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo vi /etc/fstab
  /swapfile swap swap defaults 0 0
```


## Disable Unattended Upgrades
Unexpected unattended upgrades can be really _annoying_. To disable them:
``` 
sudo dpkg-reconfigure unattended-upgrades
Choose NO
Plus, you can remove it entirely:
sudo apt remove unattended-upgrades
Henceforth, upgrades will need to be done manually:
sudo apt update
sudo apt upgrade
```


## Disable Unused Services
If you're not running LVM, you can disable these services:
```
sudo systemctl stop lvm2-lvmetad
sudo systemctl stop lvm2-lvmetad.socket
sudo systemctl disable lvm2-lvmetad
sudo systemctl disable lvm2-lvmetad.socket
```


## Disable WiFi 
Hard block = disable physically via BIOS
Soft block = disable disable via OS
```
sudo rfkill list          # Show status
sudo rfkill block wifi    # Disable via OS
```


## Disable GUI Desktop
`sudo systemctl set-default multi-user`


## System Housekeeping
Cleanup stuff that's not needed.
- Check `ps auxwww`
- Disable unused cronjobs
- Remove excess `apt`
- Disable excess `systemctl`
- Disable Canonical advertising motd
- Remove unused desktop folders: `rmdir Templates Public Downloads Documents Desktop Music Videos Pictures`

- Remove packages that are hardly ever used:
```
sudo apt purge whoopsie               # Canonical error reporting daemon
sudo apt purge kerneloops             # Could leave around, but nah
sudo apt remove unattended-upgrades   # Run all upgrades manually
sudo apt purge popularity-contest     # Being removed by Canonical anyway
sudo apt purge modemmanager           # Why?
```

- Remove packages not used on most servers:
```
sudo apt purge wpasupplicant
sudo apt purge pulseaudio 
sudo apt purge `dpkg -l | grep cups | awk '{print $2}'`
sudo apt autoremove
```

- Disable unused services:
  - <https://www.linux.com/topic/desktop/cleaning-your-linux-startup-process/>
  - <https://delightlylinux.wordpress.com/2017/06/19/speed-up-linux-boot-by-disabling-services/>
```
sudo service --status-all  # To see what services are enabled
sudo systemctl stop ufw && sudo systemctl disable ufw
sudo systemctl stop saned && sudo systemctl disable saned
sudo systemctl stop motd-news && sudo systemctl disable motd-news
sudo systemctl stop motd-news.timer && sudo systemctl disable motd-news.timer
sudo systemctl stop pppd-dns && sudo systemctl disable pppd-dns
sudo systemctl stop avahi-daemon && sudo systemctl disable avahi-daemon
sudo systemctl stop accounts-daemon && sudo systemctl disable accounts-daemon
sudo systemctl stop apport && sudo systemctl disable apport
sudo systemctl stop openvpn && sudo systemctl disable openvpn
sudo systemctl stop bluetooth && sudo systemctl disable bluetooth
```

- Disable MOTD at login
```
sudo su -c "echo ENABLED=0 > /etc/default/motd-news"
sudo vi /etc/pam.d/sshd  # and disable the only 2 'motd' lines 
```
