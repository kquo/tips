# Arcade
Nowadays there are many ways to play the old-style coin-operated video arcade games:

1. You can buy the actual old game cabinets from eBay and other places.
2. You can set up [MAME](https://en.wikipedia.org/wiki/MAME) on your desktop, using game ROMs you legally own.
3. You can set up a small computer to run one of many special OSes that can turn it into a dedicated arcade machine, again using ROMs that you legally own.

These tips are primarily for those looking to do #2 and #3 above.


## MAME
MAME originally stood for Multiple Arcade Machine Emulator, but nowadays it means much more than that. Now it is a project to preserve the code that ran on those old machines. Some old-time favorites video arcade games are: Williams **Stargate** Defender, **Mrs. Pacman**, **Galaga**, and **1942**. More information on these games ROMs can be found at <https://edgeemu.net/browse-mame-num.htm>.

To set up MAME, do the following:
- Install the latest MAME binary using your OS package installer. On macOS you can just do `brew install mame`
- Copy the ROM zip files into the `~/.mame/roms/` directory
- Run any specific game from the CLI with `mame stargate`

**MAME References**:
- <https://docs.mamedev.org/index.html>


## MAME on Ubuntu 24.10 on a Raspberry Pi 5 

**Requirements:** 

a. Set up your Raspberry Pi 5 hardware as you wish
b. These tips assume the Pi5 with 8GB of RAM, with an M.2 HAT with an NVMe SSD
c. All this is done from an Apple Mac
d. You need a USB drive/stick of at least 16GB in size

**Basic setup:** 
    
    Insert the USB driver on your Mac
    brew install raspberry-pi-imager
    Run the Imager and burn the latest Ubuntu Desktop 24.10 image
    Once done, insert on your Pi5 and install Ubuntu on the NVMe drive. (May need more details here).

**Additional configurations and settings follow below:** 

1. Adjust CLI Console Character size: 
    sudo mount -o remount,rw /boot/firmware
    sudo vi /boot/firmware/cmdline.txt
    Remove the 'quiet splash' at the end, and add 'video=X' where X is one of 800x600 ; 1024x768 ; 1280x720 ; 1920x1080
    sudo vi /boot/firmware/config.txt
    Add below
    hdmi_group=2
    hdmi_mode=16  # 9=800x600 ; 16=1024x768 ; 4=1280x720 ; 82=1920x1080
    # Ensure hdmi_mode corresponds to 'video=1024x768' at end of /boot/firmware/cmdline.txt

If necessary, you can make further adjustments via `dpkg-reconfigure` utility: 

    sudo apt install console-setup kbd   # To optionally install addtional Font Sizes
    sudo dpkg-reconfigure console-setup
    Select Terminus (default is VGA)
    Select Font Size 16x32 or whatever

2. Setup SSH: 

    sudo systemctl enable ssh
    sudo systemctl start ssh

3. Updated Boot Order: 

    sudo apt update
    sudo apt install -y rpi-eeprom
    sudo rpi-eeprom-config
    sudo EDITOR=vi rpi-eeprom-config --edit
    BOOT_ORDER=0xf416 # SD>USB>NVMe>Net
    #BOOT_ORDER=0x4    # USB Only

4. Disable desktop: 

    sudo systemctl set-default multi-user.target
    sudo reboot
    sudo systemctl start graphical.target        # To manually start the Graphical Desktop
    sudo systemctl set-default graphical.target  # To re-enable Graphical Desktop

5. Auto-login setup. To set default user for automatic login, edit the getty service: 

    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
    sudo vi /etc/systemd/system/getty@tty1.service.d/override.conf
    Add:
    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin <USERNAME> --noclear %I $TERM
    sudo systemctl daemon-reload
    sudo systemctl restart getty@tty1.service
    sudo reboot

6. CURRENT STATUS

Keyboard not responding.


## GroovyArcade
You can setup [GroovyArcade](http://wiki.arcadecontrols.com/index.php/GroovyArcade) on that small X86 computer. It is an all-in-one OS based on Arch Linux aiming perfect [MAME](https://en.wikipedia.org/wiki/MAME) emulation on CRT screens. It can be installed from the LiveCD onto the hard drive, or booted from a USB flash drive. To set up GroovyArcade do the following:

* Download and create the GroovyArcade USB installer
* Check for latest release at <https://github.com/substring/os/releases>.
* Download above ISO using `curl -LO` (see below).
* You will need an empty USB drive of 8GB or more in size.
* Create the USB using below instructions, which are for macOS, and therefor require the ISO be converted to DMG format: 

    curl -LO https://github.com/substring/os/releases/download/2023.11/groovyarcade-2023.11-x86_64.iso.xz
    xz -d groovyarcade-2023.11-x86_64.iso.xz
    hdiutil convert groovyarcade-2023.11-x86_64.iso -format UDRW -o groovyarcade-2023.11-x86_64
    diskutil list 
    diskutil unmountDisk /dev/disk4
    sudo dd status=progress bs=1m if=groovyarcade-2023.11-x86_64.dmg of=/dev/rdisk4
    diskutil unmountDisk /dev/disk4

- Now remove USB from your Mac, and [follow the installation instructions](http://wiki.arcadecontrols.com/index.php/Groovy_Arcade_Installation_Guide).

In short, you'll need to:

- Ensure that the target system allows booting off of a USB drive.
- Insert USB into target system and follow wiki instructions above.
- Once Groovy Arcade is up and running, the primary frontend display is always available via virtual console 1 **(CTRL+ALT+1)**
- And **CTRL+ALT+7** will always shows current system logs.
- You can also switch to console mode display via **CTRL+ALT+2**, and login with username `arcade` and the password `arcade`.
- You can then copy your ROM files to the `/home/roms/MAME/roms/` directory, and do other types of configurations. 

GroovyArcade allows the use of multiple different frontends to manage MAME. A lot of folks prefer to use the **Attract-Mode** frontend. It seems easier to follow visually, and allows simple configuration via the TAB key.

To have AttractMode re-read the ROMs directory after you update the list of games, do the following: 
- See <https://gitlab.com/groovyarcade/support/-/wikis/3-Post-Installation-and-Maintenance/3.3-Adding-MAME-ROMs>
- Pressing TAB from Attract-Mode default screen
- Select "Emulators"
- Then "Generate Collection/Rom List" to have Attract-Mode create the new index of ROM games.
- To setup EXIT button; using keyboard hit TAB within MAME, then general configuration, then press ENTER and hold on "UI Cancel" option

To update GroovyArcade, including OS, MAME, etc., via CLI shell, do: 

    sudo pacman -Syu

    # If you get signature errors do ...
    pacman-key --init
    pacman-key --populate archlinux

To configure GroovyArcade for a vertical monitor, press ESCAPE from Attrach-Mode then exit into the GroovyArcade UI. There you will find configuration options to do that.

To configure MAME with a specific USB controller, you'll need configure within MAME itself, by selecting the game from the Attract-Mode menu, then pressing TAB, then configuring the buttons. There's more info on page <https://docs.mamedev.org/index.html>.

**GroovyArcade References**:
- <https://gitlab.com/groovyarcade/support/-/wikis/home>

