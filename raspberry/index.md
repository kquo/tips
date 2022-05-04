# Raspberry
Useful tips on the Raspberry Pi computers.


## Create Raspberry Pi OS MicroSD Card on macOS
1. Download OS image and SHA-256 hash digest value text file
```
curl -LO https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-04-09/2021-03-04-raspios-buster-arm64-lite.zip
curl -LO https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-04-09/2021-03-04-raspios-buster-arm64-lite.zip.sha256
```
2. Compare SHA-256 digest values
```
shasum -a 256 2021-03-04-raspios-buster-arm64-lite.zip
cat 2021-03-04-raspios-buster-arm64-lite.zip.sha256
```
3. Unzip image
```
unzip 2021-03-04-raspios-buster-arm64-lite.zip
# Results is a 2021-03-04-raspios-buster-arm64-lite.img file
```
4. Insert blank MicroSD card and burn the IMG file
```
diskutil list                                # Capture disk number, e.g., /dev/disk2
diskutil unmountDisk /dev/disk2              # Unmount it
# NOTE THE 'r' in rdisk2 TARGET!
sudo dd bs=32m conv=sync if=2021-03-04-raspios-buster-arm64-lite.img of=/dev/rdisk2
diskutil unmountDisk /dev/disk2              # Unmount it again
```
5. Test it
```
Remove MicroSD, and insert it into target raspberry device and boot it up.

Raspberry OS:
  Login =  pi / raspberry
  sudo raspi-config                    # To update keyboard layout and other settings
  sudo systemctl enable ssh && systemctl start ssh
  sudo apt update && sudo apt upgrade  # And reboot
```


## Configure Raspberry Pi OS
```
# Raspberry Pi 2 running Raspian
# Network setup for eth0 and wlan0
# ====================================
# vi /etc/network/interfaces
# /etc/network/interfaces
auto lo
iface lo inet loopback

# Wired
auto eth0
#iface eth0 inet dhcp
iface eth0 inet static
   address 10.19.65.100
   netmask 255.255.255.0
   gateway 10.19.65.1

# Wi-fi
auto wlan0
allow-hotplug wlan0
#iface wlan0 inet dhcp
iface wlan0 inet static
   address 10.19.65.101
   netmask 255.255.255.0
   gateway 10.19.65.1
   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

iface default inet dhcp

# vi /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
        ssid="YOUR_NETWORK_NAME"
        # Hashing the pwd with "wpa_passphrase [ssid] [passphrase]" is a little bit better
        psk="YOUR_NETWORK_PASSWORD"
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP
        auth_alg=OPEN
}
```


## CLI MP3 Player
```
omxplayer example.mp3
```


## Change Screen Orientation
```
vi /boot/config.txt
# To portrait
display_rotate = 3    # play with this number
reboot
```
For Raspberry Pi 4
```
vi /boot/cmdline.txt
  and add this to end of line
    video=HDMI-A-1:1920x1080M@60,rotate=90
```


## Change Screen Resolution
```
See https://www.raspberrypi.org/documentation/configuration/config-txt/video.md
sudo vi /boot/config.txt (RPOS) or /boot/firmware/usercfg.txt (on Ubuntu)
dtoverlay=vc4-fkms-v3d
disable_overscan=1
# Optional resolutions: 3840x2160 2560x1440 1920x1080 1280x720
#framebuffer_width=2560
#framebuffer_height=1440
```


## HDMI Sound
```
# Not working on Pi4
hdmi_drive=2
hdmi_force_edid_audio=1
```


## Overclock
```
vi /boot/config.txt
over_voltage=6
arm_freq=2147
```


## Allow Apple Keyboard
```
cat /etc/modprobe.d/hid_apple.conf
options hid_apple fnmode=2
sudo reboot
```


## Temperature
```
Raspian
  vcgencmd measure_temp
Ubuntu
  cd /tmp
  git clone https://github.com/raspberrypi/userland
  cd userland
 ./buildme
 NOT WORKING :-(
```


## QEMU
Emulate the Raspberry Pi in QEMU.
```
#!/bin/bash
# qemupi

IDir=$HOME/code/pi
HDD=$IDir/2020-05-27-raspios-buster-lite-armhf.img
KDir=$HOME/code/qemu-rpi-kernel
Kernel=$KDir/kernel-qemu-4.19.50-buster
DTB=$KDir/versatile-pb-buster.dtb

qemu-system-arm \
  -M versatilepb \
  -cpu arm1176 \
  -m 256 \
  -drive file=$HDD,format=raw \
  -net nic \
  -net user,hostfwd=tcp::5022-:22 \
  -dtb $DTB \
  -kernel $Kernel \
  -append "rw console=ttyAMA0 root=/dev/sda2 rootfstype=ext4 loglevel=8 rootwait fsck.repair=yes memtest=1 ipv6.disable=1" \
  -serial stdio \
  -no-reboot

# Notes
#   There is no raspi machine (-M) just yet
#   This versatilepb is very limited (max 256RAM)
#   Use -nographic IN PLACE of "-serial stdio" for headless run
#   Couldn't get network to work
#   You'll need expand the disk
#   Get kernel from https://github.com/dhruvvyas90/qemu-rpi-kernel
```


## Ubuntu 20.04
Run Ubuntu on the Raspberry Pi.
```
Disable Wifi
sudo vi /boot/firmware/usercfg.txt
  dtoverlay=disable-wifi
sudo reboot

Disable IPV6
sudo vi /etc/modprobe.d/ipv6.conf
  blacklist ipv6
sudo reboot
OR
sudo vi /boot/firmware/cmdline.txt   # and add 
  ipv6.disable=1
sudo reboot
```

