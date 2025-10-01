# Arcade
Tips on playing the old-style coin-operated video arcade games. You can buy the actual old game cabinets from eBay and other places. Or you can set up [MAME](https://en.wikipedia.org/wiki/MAME) on your desktop, using game ROMs you legally own. Or you can build you own game cabinet, with a small dedicated computer running running MAME.

## MAME on Your Desktop
MAME originally stood for Multiple Arcade Machine Emulator, but nowadays it means much more than that. As its website states: 

    MAME is a hardware emulator: it faithfully reproduces the behavior of many
    arcade machines (it is not a simulation). This program is not a game but can
    directly, through ROM images, run the complete system of these old arcade
    machines. These ROMs are subject to copyright and it is in most of the cases
    illegal to use them if you do not own the arcade machine.

To set up MAME, do the following:
- Install the latest MAME binary using your OS package installer. On macOS you can just do `brew install mame`
- Copy the ROM zip files into the `~/.mame/roms/` directory
- Run any specific game from the CLI with `mame stargate`
- Install [`manu`](https://github.com/git719/manu), a small Go util that reas above roms directory and prompts for what game to run 

**MAME References**:
- <https://docs.mamedev.org/index.html>


## MAME on Ubuntu 24.10 on a Raspberry Pi 5 

### Requirements

a. Set up your Raspberry Pi 5 hardware as you wish
b. These tips assume the Pi5 with 8GB of RAM, with an M.2 HAT with an NVMe SSD
c. All this is done from an Apple Mac
d. You need a USB drive/stick of at least 16GB in size

### Basic setup
    
- Insert the USB driver on your Mac
- `brew install raspberry-pi-imager`
- Run the Imager and burn the latest Ubuntu Desktop 24.10 image
- Once done, insert on your Pi5 and install Ubuntu on the NVMe drive. (May need more details here).

### Additional configurations and settings follow below

#### Adjust CLI Console Character size

```bash
sudo mount -o remount,rw /boot/firmware
sudo vi /boot/firmware/cmdline.txt
Remove the 'quiet splash' at the end, and add 'video=800x600' or 1024x768 ; 1280x720 ; 1920x1080
sudo vi /boot/firmware/config.txt
Add below
hdmi_group=2
hdmi_mode=16  # 9=800x600 ; 16=1024x768 ; 4=1280x720 ; 82=1920x1080
dtparam=pciex1_gen=2
```

If necessary, you can make further adjustments via `dpkg-reconfigure` utility: 

```bash
sudo apt install console-setup kbd   # To optionally install addtional Font Sizes
sudo dpkg-reconfigure console-setup
Select Terminus                      # Default is VGA
Select Font Size 8x14, or whatever
```

#### Setup SSH

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

#### Updated Boot Order

```bash
sudo apt update
sudo apt install -y rpi-eeprom
sudo rpi-eeprom-config
sudo EDITOR=vi rpi-eeprom-config --edit
Set BOOT_ORDER=0x6 to only boot off NVMe or 0x4 to only boot off USB
(Trying to set it to conditionally boot off USB is a nightmare)
sudo reboot
```

#### Disable desktop

```bash
sudo systemctl set-default multi-user.target
sudo reboot
sudo systemctl start graphical.target        # To manually start the Graphical Desktop
sudo systemctl set-default graphical.target  # To re-enable Graphical Desktop
```

#### Auto-login setup

To set default user for automatic login, edit the getty service: 

```bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo vi /etc/systemd/system/getty@tty1.service.d/override.conf

Add below:

[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin USERNAME --noclear %I $TERM

# Note: Replace USERNAME with the actual username

sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service
sudo reboot
```

#### Issues
- If keyboard does not respond when the **manu** menu comes up, try: 
  
```bash
sudo usermod -a -G input $USER
```

### Set New Hostname

```bash
sudo hostnamectl set-hostname <new-hostname>
sudo vi /etc/hosts  # Change it here too
sudo reboot
```

### Ensure Sound is Working

Plug a USB-to-3.5mm audio connector to the Raspberry Pi 5 and connect that to your speakers. Test sound system with below steps: 

```bash
sudo apt update
sudo apt install --reinstall pipewire pipewire-pulse wireplumber pipewire-audio-client-libraries
sudo apt install --reinstall libspa-0.2-bluetooth
pactl info | grep "Server Name"
pactl list short sinks
aplay /usr/share/sounds/alsa/Front_Center.wav  # To test speaker
```

### Compile MAME

You can also compile MAME yourself, which allows you to select only the machines you are interested in, thus keeping things as simple as possible. Follow below instructions to do so on the Raspberry Pi 5 running Ubuntu.

#### Install required packages and clone MAME repo 

```bash
sudo apt update
sudo apt install build-essential libsdl2-dev libfontconfig1-dev libpulse-dev \
  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5opengl5-dev \
  libasound2-dev libxinerama-dev libxi-dev libgl1-mesa-dev python3
sudo apt install libsdl2-ttf-dev

git clone https://github.com/mamedev/mame.git
cd mame
```

#### Clean out stale objects and headers 

```bash
time make clean
rm -rf obj
```

#### Run a regular make

This build build the needed `emu.h` and other core headers: 

```bash
time make SUBTARGET=mame SOURCES="src/mame/skeleton/testpat.cpp" REGENIE=1 NOWERROR=1 -j$(nproc)
```

Note that `emu.h` and the `.pch` files aren’t part of the source tree, and they are ONLY generated during regular build. In order to restrict SOURCES to build a "tiny" MAME binary with only selected games, as we do below, this pre-step is a requirement.

#### Prepare the needed source files

From the root of the checked out `mame` directory: 

```bash
$ cat src/mame/custom/custom.mak
# Custom build for specific games

SOURCES += src/mame/capcom/1942.cpp
SOURCES += src/mame/namco/galaga.cpp
SOURCES += src/mame/pacman/pacman.cpp
SOURCES += src/mame/midway/williams.cpp

$ cat src/mame/custom.lst
@source:capcom/1942.cpp
1942            // (c) Capcom

@source:namco/galaga.cpp
galaga          // (c) Namco
galagamf        // (c) Namco
galagamk        // (c) Namco

@source:pacman/pacman.cpp
mspacman        // (c) Namco/Midway

@source:midway/williams.cpp
stargate        // (c) Williams
```

#### Now rebuild with only your games 

```bash
time make SUBTARGET=mame SOURCES="src/mame/capcom/1942.cpp,src/mame/namco/galaga.cpp,src/mame/pacman/pacman.cpp,src/mame/midway/williams.cpp" REGENIE=1 NOWERROR=1 OPTIMIZE=3 USE_QTDEBUG=1 -j$(nproc)

# Confirm version and list of supported games
./mame -version
./mame -listfull
```

### Boot into manu Binary

Boot into default `manu` Game Menu binary - See <https://github.com/git719/manu>

To configure MAME with a specific USB controller, you'll need configure within MAME itself, by selecting the game from the Attract-Mode menu, then pressing TAB, then configuring the buttons. There's more info on page <https://docs.mamedev.org/index.html>.


## Creating USB Installers

* Download the desired ISO using `curl -LO` (see below).
* You will need an empty USB drive of 16GB or more in size.
* Create the USB using below instructions, which are for macOS, and therefore require the ISO be converted to DMG format: 

```bash
curl -LO https://github.com/substring/os/releases/download/2023.11/groovyarcade-2023.11-x86_64.iso.xz
xz -d groovyarcade-2023.11-x86_64.iso.xz
hdiutil convert groovyarcade-2023.11-x86_64.iso -format UDRW -o groovyarcade-2023.11-x86_64
diskutil list 
diskutil unmountDisk /dev/disk4
sudo dd status=progress bs=1m if=groovyarcade-2023.11-x86_64.dmg of=/dev/rdisk4
diskutil unmountDisk /dev/disk4
```

Now remove USB from your Mac, and in short, you'll need to:

- Ensure that the target system allows booting off of a USB drive
- Insert USB into target system and follow the OS installation instructions
