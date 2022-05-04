# Arcade
Tips on setting up old style arcade machines.

## RetroPie on Ubuntu
RetroPie does __not__ just run on the Raspberry Pi. It can also run on top of many other OSes, including __Ubuntu__.

1. Do a basic installation of Ubuntu, then do 
```
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install git dialog unzip xmlstarlet
```

2. Next, clone the latest RetroPie setup scripts from Github 

```
cd
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git

OPTIONAL: As an experiment you could try selecting which libretro cores you only want by doing:
mv RetroPie-Setup/scriptmodules/libretrocores/ RetroPie-Setup/scriptmodules/libretrocores_
mkdir RetroPie-Setup/scriptmodules/libretrocores/
Then copying ONLY the cores you want to above directory. For example, to only do MAME:
cd RetroPie-Setup/scriptmodules/libretrocores_/
mv lr-mam* ../libretrocores
mv lr-mes* ../libretrocores
```

3. Then:
```
cd RetroPie-Setup
sudo ./retropie_setup.sh
```

4. Select `Basic install` to perform the base installation and __compilation__ of RetroPie. This may take _a long time_.

5. Copy your ROM files to `$HOME/RetroPie/roms/arcade/`

6. Reboot, then run `emulationstation`, then go into Setup / Configuration and enable autostart as you like.

For more information see also <https://retropie.org.uk/docs/Debian/>

## Retropie
RetroPie is n all-in-one arcade system built on top of Raspbian OS, based on RetroArch/LibRetro.
See <https://retropie.org.uk/docs/>

To disable IPV6:
```
  Append ipv6.disable=1 to /boot/cmdline.txt:
    console=serial0,115200 console=tty1 root=PARTUUID=97a6378b-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait loglevel=3 consoleblank=0 plymouth.enable=0 usbhid.quirks=0x16c0:0x05e1:0x040 ipv6.disable=1
  OR
    root@nc2004:~# grep GRUB_CMDLINE_LINUX /etc/default/grub
    GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"
    GRUB_CMDLINE_LINUX="ipv6.disable=1"
    root@nc2004:~# update-grub
    Sourcing file `/etc/default/grub'
    Sourcing file `/etc/default/grub.d/init-select.cfg'
    Generating grub configuration file ...
    Found linux image: /boot/vmlinuz-5.4.0-33-generic
    Found initrd image: /boot/initrd.img-5.4.0-33-generic
    Found linux image: /boot/vmlinuz-5.4.0-31-generic
    Found initrd image: /boot/initrd.img-5.4.0-31-generic
    Adding boot menu entry for UEFI Firmware Settings
    done
```


## RetroArch Boot Into Single Game
To have Retropie boot into Stargate Defender only:
```
- sudo vi /opt/retropie/configs/all/autostart.sh and
  - Comment out existing line
    #emulationstation #auto
  - Add this line:
    /opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ mame-libretro ~/RetroPie/roms/mame-libretro/stargate.zip
```

## RetroArch Quiet Startup
```
- sudo vi /boot/cmdline.txt and append "logo.nologo" to line
- sudo vi /boot/config.txt and append next 2 lines to bottom of file:
  disable_splash=1
  avoid_warnings=1
```

## RetroArch Old CRT Look
Make it look like the old style TV monitors.
```
sudo vi /opt/retropie/configs/all/retroarch.cfg 
  Try any of these:
    video_shader = "/opt/retropie/configs/all/retroarch/shaders/zfast_crt_standard.glslp"
    video_shader = "/opt/retropie/configs/all/retroarch/shaders/zfast_crt_standard_vertical.glslp"
    video_shader = "/opt/retropie/configs/all/retroarch/shaders/crt-pi.glslp"
    video_shader = "/opt/retropie/configs/all/retroarch/shaders/crt-pi-vertical.glslp"
```

## Lakka
Lakka is the default all-in-one OS for RetroArch/LibRetro. See <https://github.com/libretro/Lakka-LibreELEC/wiki>

To run Lakka in __Live Mode__ from a USB key, create a USB drive image for appropriate hardware, and boot off of it. This will run Lakka of the USB while leaving the existing hard disk intact.

To SSH to device:
- Set up the Ethernet cable 
- Enabled SSH service via _Settings -> Services_
- Find IP via _Information -> Network Information_
- `ssh root@IP` and password is `root`

```
systemctl stop retroarch
vi /storage/.config/retroarch/retroarch.cfg
systemctl start retroarch
```

## Reset MAME Tab UI Controller
`rm /home/pi/RetroPie/roms/mame-libretro/mame2003/cfg/default.cfg`


## Boot Into Single ROM on Raspberry Pi 4
1. Create RetroPie SD image, boot into it, and run `raspi-config` to do basic locale adjustments.

2. Set up RetroPie to your liking, configuring controllers, etc., and adding ROMs under `/home/pi/RetroPie/roms/arcade/`

3. Reboot then hit F4 to exit to CLI then:
- Do `sudo vi /boot/cmdline.txt` and edit the single line
- Replace `console=tty1` with `console=tty3`
- Add `quiet` before `loglevel=3`
- At the end of the line add `logo.nologo`
- For 90 degrees portrait monitor configuration append `video=HDMI-A-1:1920x1080M@60,rotate=90`

4. Then do `sudo vi /boot/config.txt` and add below to bottom of file:
```
disable_splash=1
avoid_warnings=1
```
- Also set `disable_overscan=1` if your monitor is showing black borders.
- Reboot

5. Hit F4 to jump to CLI
```
   sudo -i
   vi /opt/retropie/configs/all/autostart.sh
     - Comment out the only line with a `#`
     - Then add below line:
       /opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ arcade /home/pi/RetroPie/roms/arcade/mspacman.zip
   Reboot.
```

6. Edit RetroArch settings
```
sudo vi /opt/retropie/configs/all/retroarch.cfg
  - Find video_shader area, and add:
    video_shader = "/opt/retropie/configs/all/retroarch/shaders/zfast_crt_standard.glslp"
  - For 90 degrees portrait monitor configuration:
    video_rotation = 1
```

7. Update RetroArch Video Scaling
- While in the game, press `F1` to go into RetroArch Quick Menu
- Press `Z`, arrow down to `Settings`, then press `X`. Arrow down to `Configuration` and press `X`
- Press `X` again to set `Save Configuration on Exit` to `ON`
- Press `Z`, then arrow up to `Video`, then `X`.
- Arrow down to `Scaling`, then `X`; Arrow down to `Aspect Ratio` and press `X`, and select `4:3`
- Press `Z` to back up to the top, then `F1` to exit.

References:
- <https://learn.adafruit.com/retro-gaming-with-raspberry-pi/adding-controls-hardware?view=all>
- <https://retropie.org.uk/forum/topic/23257/two-thoughts-auto-boot-retropie-into-a-game-into-a-slideshow/19>
- <https://howchoo.com/g/n2qyzdk5zdm/build-your-own-raspberry-pi-retro-gaming-rig>
