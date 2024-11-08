# macOS
macOS tips.


## Homebrew
1. Install
   - Follow instructions at <https://brew.sh/>
2. Common usage
    ```
    brew cleanup -ns                    # See what you'd be cleaning up 
    brew cleanup -s                     # Clean it all up, including cache
    brew remove  <package name>         # Uninstall/remove
    brew uninstall <package name>       # Uninstall/remove
    brew leaves                         # List all installed top-level packages, that are not dependencies
    brew list                           # List all install packages
    brew deps --tree --installed        # List all with deps
   ```
3. Uninstall
   **Review link before running**!:
   `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"`


## Mac Migration
- Update hostname:
    ```
    sudo scutil --set HostName <new_name>
    sudo scutil --set LocalHostName <new_name>
    sudo scutil --set ComputerName <new_name>
    dscacheutil -flushcache`
    ```
- Install Homebrew and the usual suspects
    `brew install iterm2 coreutils fd jq git vscodium duckduckgo imagemagick appcleaner ffmpeg dos2unix pwgen nmap iperf3 gnutls python go`
- iTerm2
    - Use the saved preferences under `~/data/etc/term/`
- VSCodium
    - On SRC: `cd && tar czf data/codium.tar.gz --exclude='*.sock' Library/Application\ Support/VSCodium`
    - On DST: `cd && tar xzf data/codium.tar.gz`
- Switch to BASH: `chsh -s /bin/bash`
- Update screencapture behaviour: `./tools/macos/screencapture`


## BASHRC
- `.bashrc` for a user: 

```
ExitFunc() { sh ~/.bash_logout ; } # Save ~/.bash_logout with "history -c"
trap ExitFunc EXIT
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

```
ExitFunc() { sh ~/.bash_logout ; } # Save ~/.bash_logout with "history -c"
trap ExitFunc EXIT
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

## Export iCloud Photos Locally
Use [iCloud Photo Downloader](https://github.com/icloud-photos-downloader/icloud_photos_downloader) Python utility - `icloudpd`. It downloads all photos from your iCloud account via the CLI. This means *all* photos as well as *all* videos.
```
mkdir photos
icloud -d photos -u <your-icloud-id>
```
then follow prompts.


## Recover Deleted Files
Use known recovery tools like `testdisk` and `photorec` that are part of the the popular System Rescue CD.
Insert USB disk, or more dangerously, scan your OS HDD.
```
brew install testdisk
sudo photorec              # Then pick drive to scan, and destination folder for scanned files
```  


## Adding macOS Static Routes
```
# Check existing routes on "wifi" interface
networksetup -getadditionalroutes wifi

# Set permanently and verify an additional route
sudo networksetup -setadditionalroutes "wifi" 10.10.5.0 255.255.255.0 10.10.9.71
networksetup -getadditionalroutes wifi

# Remove permanently
sudo networksetup -setadditionalroutes "wifi"

# See also
netstat -rn                                              # Check routes
sudo route -n add -net 10.67.0.0/16 192.168.120.254      # Add a network route
```


### Set Mac as Router
```
sudo sysctl -w net.inet.ip.forwarding=1                  # Enable IP forwarding
```


### Install Ubuntu on a Mac

1. <https://github.com/marcosfad/mbp-ubuntu> [VERIFIED]
2. <https://linuxnewbieguide.org/how-to-install-linux-on-a-macintosh-computer/>
3. <https://itsfoss.com/create-bootable-ubuntu-usb-drive-mac-os/>
4. <https://www.lifewire.com/dual-boot-linux-and-mac-os-4125733>

If you update the kernel, remember to add the required drivers again.
The easy way:
```
sudo apt install dkms
sudo apt install linux-headers-<mbp-kernel-release>-mbp linux-image-<mbp-kernel-release>-mbp
sudo git clone --branch mbp15 https://github.com/roadrunner2/macbook12-spi-driver.git /usr/src/apple-ibridge-0.1
sudo dkms install -m apple-ibridge -v 0.1 -k <mbp-kernel-release>-mbp
modprobe apple-ib-tb
modprobe apple-ib-als
sudo git clone --branch aur https://github.com/marcosfad/mbp2018-bridge-drv.git /usr/src/apple-bce-0.1
sudo dkms install -m apple-bce -v 0.1 -k <mbp-kernel-release>-mbp
modprobe apple-bce
```

For an alternate way see <https://github.com/marcosfad/mbp-ubuntu/blob/master/files/chroot_build.sh>


## Dual-Booting macOS With Linux Without rEFInd
- <https://askubuntu.com/questions/831161/dual-booting-os-x-or-macos-with-linux-without-refind>

- If you booted into Ubuntu already
```
cp /boot/efi/EFI/ubuntu/grubx64.efi /boot/efi/EFI/Boot/bootx64.efi
# Note the destination filename changes
```

- Voila!

- Note that marcosfad/mbp-ubuntu did this automatically on a MacBookAir
  - latest kernel
  - Function keys
  - trackpad
  - wifi
  - BT


## What TCP Ports Are Listening
```
sudo lsof -iTCP -sTCP:LISTEN -n -P    # List what TCP ports apps are listening on
```


## Disk Speed
Use Blackmagic Disk Speed Test app
<https://malcont.net/2017/09/apfs-vs-hfs-benchmarks-on-2017-macbook-pro-with-macos-high-sierra/>


## Post-Upgrade OS Issues
- The error:
```
xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

- The fix:
```
xcode-select --install   # To accept Xcode License agreement
```

## Turn Off IPV6
```
sudo networksetup -setv6off "Wi-Fi"
sudo networksetup -setv6off "Thunderbolt Ethernet"
sudo networksetup -setv6off "Ethernet"
```

To re- enable
```
sudo networksetup -setv6automatic "Wi-Fi"
sudo networksetup -setv6automatic "Thunderbolt Ethernet"
sudo networksetup -setv6automatic "Ethernet"
```


## DNS
```
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

```
# Resize all files to 1024 pixels at their largest side (the other side proportionately)
for N in *.jpg ; do sips -Z 1024 $N ; done

# Lower resolution of all JPEG files by %20
for N in *.jpg ; do sips -s format jpeg -s formatOptions 20 $N -o ${N}.jpg ; done

# Convert all JPEG files in current directory to PDF, and vice-versa
for N in *.jpg ; do sips -s format pdf $N -o ${N}.pdf ; done
for N in *.pdf ; do sips -s format jpeg $N -o ${N}.jpg ; done
```

- PGN
```
# Resize file in place by 60%, replaces original
magick mogrify -resize 60% yul.png 
```


## Clear ACL
As root
```
find . -flags uchg
find . -flags uchg -exec chflags nouchg {} \;
```


## View Hardware Information
```
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


## WiFi Info
```
networksetup -listpreferredwirelessnetworks en0       # List networks
sudo wdutil log -wifi                                 # disable wifi logging
```


## Use iCloud For Login
```
sudo dscl . append /Users/someuser AuthenticationAuthority ";AppleID;leo@tek.uno"
```
Above will append the specific AppleID as an Authentication Authority to authenticate against.
Restart your Mac
Click on the Change Password in the Users & Groups preferences and you'll see different behaviour dialog

- Reference
  - <https://www.linkedin.com/pulse/reenable-icloud-password-login-os-x-el-capitan-10114-higher-herman?articleId=8846780083667873083>


## Restarting the Setup Assistant
Boot into Single User Mode ⌘ + S
Mount the drive by typing `/sbin/mount -uw /` then ENTER
Remove the Apple Setup Done file by typing `rm /var/db/.AppleSetupDone` then ENTER
Reboot by typing reboot then ENTER
Complete the setup process, creating a new admin account


## macOS VNC Trix
Enabling VNC connection to a Mac via SSH
```
Step A: Server side (SSH to your mac):
$ sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
$ sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes
$ sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvncpw -vncpw [YourPwdHere]
$ sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console

Step B: Install VNC Viewer on you PC then connect to Mac host using IP address.
```

## Disk Trix
```
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
```
hdiutil convert ubuntu-20.04-desktop-amd64.iso -format UDRW -o ubuntu-20.04-desktop-amd64
# Will automatically add the .dmg extension = ubuntu-20.04-desktop-amd64.dmg
```


## Obliterate a Disk Partition
WARNING: You better know what you're doing!
From recovery Terminal: `gpt destroy /dev/disk1`


## Homebrew Personal Tap
See <https://github.com/lencap/homebrew-tools>

- Create a tap repo on GitHub. The repo should be named homebrew-{mytapname}, where {mytapname} is the name you want to give your tap (which will contain all your Homebrew formulae). I call mine 'tools', so:
```
  My tap repo    = <https://github.com/lencap/homebrew-tools>
  My tap name    = `lencap/tools`
  Sample install = `brew install lencap/tools/awslogin`
```

- Tar and upload your formula binary somewhere. Using the GitHub Releases feature of this very same repo is a good place because of its proximity to the source code. A good naming convention for your tar file is {appname}-{version}.tar.gz, e.g. delta-0.5.0.tar.gz. This allows Homebrew to infer your app's version. Create the gzipped file and generate SHA rum:
```
  tar czf awsinfo-2.0.11.tar.gz awsinfo
  shasum -a 256 awsinfo-2.0.11.tar.gz
```

- In your tap repo, create a Formula for your app, using the URL and SHA from above. This is a ruby file of the format {appname}.rb. For example:
```
  class Awsinfo < Formula
    desc "AWS CLI Information Utility"
    homepage "https://github.com/lencap/awsinfo"
    url "https://github.com/lencap/awsinfo/releases/download/2.0.11/awsinfo-2.0.11.tar.gz"
    sha256 "ee0604e10a0eebaec8e8389287d17b0d9e91b12873189e00572abbd77d5aba2a"  
    version "2.0.11"
    bottle :unneeded
    def install
      bin.install "awsinfo"
    end
    test do
      system "#{bin}/awsinfo -h"
    end
  end
```

- Also check out the Formula API for all the things you can do with your formula, like a post_install command.
- Commit and push your tap repo to GitHub.
- Voila! Now users can install your app easily with: `brew install lencap/tools/awsinfo`


## Install MS PowerShell
See <https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-macos?view=powershell-6>
```
brew install powershell 
pwsh                                          # Test
brew update && brew upgrade powershell        # Upgrade
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
```
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

## Systems Updates
```
CHECK EXISTING   system_profiler SPInstallHistoryDataType | grep -A5 MRTConfigData
SPECIFIC         softwareupdate -i MRTConfigData_10_14-1.45 --include-config-data
ALL              softwareupdate -ia --include-config-data
```

## DVD Copying
```
Insert DVD
diskutil list                                                 # To identify disk =  /dev/disk4
diskutil unmountDisk /dev/disk4                               # Unmount
sudo dd if=/dev/disk4 of=dvd_1.iso bs=2048 status=progress    # Record DVD into dvd_1.iso
diskutil eject /dev/disk4                                     # Eject disk
```

