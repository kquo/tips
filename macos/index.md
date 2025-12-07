# macOS
macOS tips.

- [iCloud Photos Backup Guide](photos.md)

## Mac Migration
- Update hostname: 

    ```
    sudo scutil --set HostName <new_name>
    sudo scutil --set LocalHostName <new_name>
    sudo scutil --set ComputerName <new_name>
    dscacheutil -flushcache`
    ```

- Install Homebrew as per <https://brew.sh/>

- Install the usual suspects using `brew`
    - `brew install iterm2 coreutils fd jq git vscodium duckduckgo imagemagick appcleaner ffmpeg dos2unix pwgen nmap iperf3 gnutls python go tree`

- iTerm2
    - Use the saved preferences under `~/data/etc/term/`

- VSCodium
    - On SRC: `cd && tar czf data/codium.tar.gz --exclude='*.sock' Library/Application\ Support/VSCodium`
    - On DST: `cd && tar xzf data/codium.tar.gz`

- Switch to BASH: `chsh -s /bin/bash`

- Update screencapture behaviour: `./tools/macos/screencapture`


## BASHRC
- `.bashrc` for a user: 

```bash
echo "history -c" > ~/.bash_logout
on_exit() { rm ~/.bash_history && sh ~/.bash_logout ; }
trap on_exit EXIT

export GOPATH=~/go
export PATH=$PATH:/usr/local/bin:$GOPATH/bin:$GOROOT/bin
export HISTCONTROL=ignoreboth  # Ignore both duplicates and space-prefixed commands
export HISTIGNORE='ls:cd:ll:h' # Ignore these commands
export EDITOR=vi
export Grn='\e[1;32m' Rst='\e[0m' # Green color and reset
export PS1="\[$Grn\]\u@\h:\W\[$Rst\]$ "
alias ls='gls -N --color -h --group-directories-first'
alias ll='ls -ltr'
alias h='history'
alias vi='vim'
export GREP_COLOR='1;36' # Cyan
alias grep='grep --color'
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias pwgen='pwgen -s1 14 6'
alias code='/Applications/VSCodium.app/Contents/Resources/app/bin/codium'
export BASH_SILENCE_DEPRECATION_WARNING=1
export HOMEBREW_NO_ANALYTICS=1    # Disable homebrew Google Analytics collection
```
- `.bashrc` for root: 

```bash
echo "history -c" > ~/.bash_logout
on_exit() { rm ~/.bash_history && sh ~/.bash_logout ; }
trap on_exit EXIT

export BASH_SILENCE_DEPRECATION_WARNING=1
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:cd:ll:h'
export EDITOR=vi
export Red='\e[1;31m' Rst='\e[0m' # Red color and reset
export PS1="\[$Red\]\u@\h:\W\[$Rst\]$ "
alias ls='gls -N --color -h --group-directories-first'
alias ll='ls -ltr'
alias h='history'
alias vi='vim'
export GREP_COLOR='1;36' # Cyan
alias grep='grep --color'
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
```

## Network Quality
Check network quality => `networkQuality -v`

## Useful CLI Site
Awesome macOS Command-Line = <https://git.herrbischoff.com/awesome-macos-command-line/about/>

## What TCP Ports Are Listening

```bash
sudo lsof -iTCP -sTCP:LISTEN -n -P    # List what TCP ports apps are listening on
```


## Turn Off IPV6

```bash
sudo networksetup -setv6off "Wi-Fi"
sudo networksetup -setv6off "Thunderbolt Ethernet"
sudo networksetup -setv6off "Ethernet"
```

To re- enable

```bash
sudo networksetup -setv6automatic "Wi-Fi"
sudo networksetup -setv6automatic "Thunderbolt Ethernet"
sudo networksetup -setv6automatic "Ethernet"
```


## DNS

```bash
FLUSH
sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache

SHOW  
sudo networksetup -getdnsservers    "Wi-Fi"
sudo networksetup -getsearchdomains "Wi-Fi"
sudo networksetup -getdnsservers    "Thunderbolt Ethernet"
sudo networksetup -getsearchdomains "Thunderbolt Ethernet"

SET
sudo networksetup -getsearchdomains "Wi-Fi"
sudo networksetup -getsearchdomains "Thunderbolt Ethernet"
sudo networksetup -setsearchdomains "Wi-Fi" "advancemags.com aws.conde.io conde.io"
sudo networksetup -setsearchdomains "Thunderbolt Ethernet" "advancemags.com aws.conde.io conde.io"
sudo killall -HUP mDNSResponder
sudo networksetup -getsearchdomains "Wi-Fi"
sudo networksetup -getsearchdomains "Thunderbolt Ethernet"

networksetup -listallnetworkservices

sudo networksetup -setdnsservers Wi-Fi empty
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
sudo killall -HUP mDNSResponder

scutil --dns | grep 'nameserver\[[0-9]*\]'
```


## Image Conversion
- JPEG 

```bash
# Resize all files to 1024 pixels at their largest side (the other side proportionately)
for N in *.jpg ; do sips -Z 1024 $N ; done

# Lower resolution of all JPEG files by %20
for N in *.jpg ; do sips -s format jpeg -s formatOptions 20 $N -o ${N}.jpg ; done

# Convert all JPEG files in current directory to PDF, and vice-versa
for N in *.jpg ; do sips -s format pdf $N -o ${N}.pdf ; done
for N in *.pdf ; do sips -s format jpeg $N -o ${N}.jpg ; done
```

- PGN

```bash
# Resize file in place by 60%, replaces original
magick mogrify -resize 60% yul.png 
```

## View Hardware Information

```bash
# NUMBER OF CPUs, etc. Equivalent commands to Linux's nproc and free, etc
sysctl -n hw.ncpu
python -c 'import multiprocessing as mp; print(mp.cpu_count())'
system_profiler SPHardwareDataType  # To see actual number of cores

sysctl hw.memsize
hw.memsize: 68719476736

sysctl hw.ncpu
hw.ncpu: 12

system_profiler SPHardwareDataType
Hardware:

    Hardware Overview:

      Model Name: Mac mini
      Model Identifier: Macmini8,1
      Processor Name: 6-Core Intel Core i7
      Processor Speed: 3.2 GHz
      Number of Processors: 1
      Total Number of Cores: 6
      L2 Cache (per Core): 256 KB
      L3 Cache: 12 MB
      Hyper-Threading Technology: Enabled
      Memory: 64 GB
      Boot ROM Version: 1037.40.124.0.0 (iBridge: 17.16.11081.0.0,0)
      Serial Number (system): C07ZQ114JYW0
      Hardware UUID: B887018F-72F5-5B68-9B4B-3181F72D634F
      Activation Lock Status: Disabled
```


## Disk Trix

```bash
FORMAT
sudo newfs_msdos -F 16 /dev/disk2

BURN RAW IMAGE TO DISK
sudo dd -f image.raw /dev/disk2
brew install ddrescue
sudo ddrescue -f image.raw /dev/disk2

CREATE IMAGE FROM DISK
diskutil unmountDisk /dev/disk2
sudo ddrescue -vS /dev/disk2 image.raw ddrescue.log

LIST ALL DISKS
diskutil list

LIST SUPPORTED FILESYSTEMS
diskutil listFilesystems

UNMOUNT DISK
diskutil unmountDisk /dev/disk2

MOUNT/UNMOUNT NON-HYBRID ISO FILES : PUT IT ON /Volume/nonhybrid
hdiutil mount -quiet "nonhybrid.iso"
hdiutil unmount -quiet nonhybrid

MOUNTING HYBRID ISO FILES (usually Linux CDs)
hdiutil attach -quiet -noverify -nomount "centos.iso"
diskutil list   # To capture the /dev/diskX identifier above was mapped to
sudo mkdir /Volumes/centos
sudo mount_cd9660 /dev/diskX /Volumes/centos
...
sudo umount /Volumes/centos && diskutil eject /dev/diskX
sudo rmdir /Volumes/centos
```


## Convert ISO to IMG

```bash
hdiutil convert ubuntu-20.04-desktop-amd64.iso -format UDRW -o ubuntu-20.04-desktop-amd64
# Will automatically add the .dmg extension = ubuntu-20.04-desktop-amd64.dmg
```

## Create macOS USB Installer
- Download latest macOS installer via the App Store
  - Quit without continuing installation!
  - May take a while

- Format a +16GB size USB
  - Name   = Untitled
  - Format = Mac OS Extended (Journaled)
  - Scheme = GUID Partition Map
  - Security Options = Fastest

- `sudo "/System/Volumes/Data/Applications/Install macOS Catalina.app/Contents/Resources/createinstallmedia" --volume /Volumes/Untitled`
  Path will differ based on macOS version name

- Right click and EJECT

## Startup Keys
- For newer Apple Silicon CPU machines:
  Switch on your Mac device with the Power Button and do not stop pressing the power button until you see a window that displays a list of drives connected to your Mac.

- For older Apple Intel CPU machines:

```bash
Options-Command-R    Boot into Recovery Mode with latest OS for this hardware
Command-R            Boot into Recovery Mode with original OS
Options              Access Mac Startup Manager
C                    Boot from USB/CD
N                    NetBoot
Shift                Safe Boot
Command-V            Verbose Mode
Command-S            Single User Mode
Command-Option-P-R   Reset PRAM
T                    Enable Target Disk Mode
```
