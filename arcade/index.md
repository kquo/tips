# Arcade
Nowadays there are many ways to play the old-style, coin-operated video arcade games:

- You can buy the actual old game cabinets from eBay and other places.
- You can set up [MAME](https://en.wikipedia.org/wiki/MAME) on your desktop, using game ROMs you legitimately own.
- You can set up a small form-factor PC with [GroovyArcade](http://wiki.arcadecontrols.com/index.php/GroovyArcade) as a dedicated arcade machine, again using ROMs you own.

The rest of these tips are general notes on setting up either or the last two.


## MAME
MAME originally stood for Multiple Arcade Machine Emulator, but nowadays it means much more than that. Now it is a project to preserve the code that ran on those old machines. My all time personal favorites video arcade games are: Williams **Stargate** Defender, **Mrs. Pacman**, **Galaga**, and **1942**. More information on these games ROMs can be found at <https://edgeemu.net/browse-mame-num.htm>.

To set up MAME, do the following:
- Install the latest MAME binary using your OS package installer. On macOS you can just do `brew install mame`.
- Copy the ROM zip files into the `~/.mame/roms/` directory and `cd` to it.
- Run any specific game from the CLI with `mame stargate`

**MAME References**:
- <https://docs.mamedev.org/index.html>


## GroovyArcade
[GroovyArcade](http://wiki.arcadecontrols.com/index.php/GroovyArcade) is an all-in-one OS based on Arch Linux aiming perfect [MAME](https://en.wikipedia.org/wiki/MAME) emulation on CRT screens. It can be installed from the LiveCD onto the hard drive, or booted from a USB flash drive. To set up GroovyArcade do the following:

* Download and create the GroovyArcade USB installer
* Check for latest release at <https://github.com/substring/os/releases>.
* Download above ISO using `curl -LO` (see below).
* You will need an empty USB drive of 8GB or more in size.
* Create the USB using below instructions, which are for macOS, and therefor require the ISO be converted to DMG format: 

```
curl -LO https://github.com/substring/os/releases/download/2023.11/groovyarcade-2023.11-x86_64.iso.xz
xz -d groovyarcade-2023.11-x86_64.iso.xz
hdiutil convert groovyarcade-2023.11-x86_64.iso -format UDRW -o groovyarcade-2023.11-x86_64
diskutil list 
diskutil unmountDisk /dev/disk4
sudo dd status=progress bs=1m if=groovyarcade-2023.11-x86_64.dmg of=/dev/rdisk4
diskutil unmountDisk /dev/disk4
```

- Now remove USB from your Mac, and [follow the installation instructions](http://wiki.arcadecontrols.com/index.php/Groovy_Arcade_Installation_Guide).

In short, you'll need to:

- Ensure that the target system allows booting off of a USB drive.
- Insert USB into target system and follow wiki instructions above.
- Once Groovy Arcade is up and running, the primary frontend display is always available via virtual console 1 **(CTRL+ALT+1)**
- And **CTRL+ALT+7** will always shows current system logs.
- You can also switch to console mode display via **CTRL+ALT+2**, and login with username `arcade` and the password `arcade`.
- You can then copy your ROM files to the `/home/roms/MAME/roms/` directory, and do other types of configurations. 

GroovyArcade allows the use of multiple different frontends to manage MAME. I prefer to use the **Attract-Mode** frontend. It seems easier to follow visually, and allows simple configuration via the TAB key.

To have AttractMode re-read the ROMs directory after you update the list of games, do the following: 
- See <https://gitlab.com/groovyarcade/support/-/wikis/3-Post-Installation-and-Maintenance/3.3-Adding-MAME-ROMs>
- Pressing TAB from Attract-Mode default screen
- Select "Emulators"
- Then "Generate Collection/Rom List" to have Attract-Mode create the new index of ROM games.
- To setup EXIT button; using keyboard hit TAB within MAME, then general configuration, then press ENTER and hold on "UI Cancel" option

To update GroovyArcade, including OS, MAME, etc., via CLI shell, do: 

```
sudo pacman -Syu                     # But it seems to fail .. so then do ..
sudo pacman -S archlinux-keyring
sudo pacman -Syu
```

To configure GroovyArcade for a vertical monitor, press ESCAPE from Attrach-Mode then exit into the GroovyArcade UI. There you will find configuration options to do that.

To configure MAME with a specific USB controller, you'll need configure within MAME itself, by selecting the game from the Attract-Mode menu, then pressing TAB, then configuring the buttons. There's more info on page <https://docs.mamedev.org/index.html>.

**GroovyArcade References**:
- <https://gitlab.com/groovyarcade/support/-/wikis/home>

