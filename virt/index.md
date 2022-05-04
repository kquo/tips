# Virtualization
Tips on virtualization.


## QEMU Common
```
# HDD Image create
qemu-img create centos70.raw 8G             # Creates an empty 8GB file!
qemu-img create -f qcow2 centos70.qcow 8G   # Space saver
qemu-img create -f vdi centos70.vdi 8G      # Compatible with VirtualBox

# Image Info
qemu-img info centos70.raw

# Image Convert
qemu-img convert -f vdi centos70.vdi -O raw /dev/xvdf        # VDI to raw (direct to device)
qemu-img convert -f raw -O qcow2 centos70.raw centos7.qcow   # Raw to qcow2

# Test ISO
qemu-system-x86_64 -m 1G -cdrom CentOS-7.0-1406-x86_64-Minimal.iso

# Install CentOS 7.0, then run it
qemu-system-x86_64 -hda centos70.qcow -cdrom CentOS-7.0-1406-x86_64-Minimal.iso -m 2G -boot d
qemu-system-x86_64 -hda centos70.qcow -m 2G

# Networking
-net nic -net user   # Is default

# Run with other options and OSes
qemu-system-x86_64 -hda winxp.qcow -localtime -cdrom /dev/sr0 -boot order=dc -m 2G -soundhw es1370 -vga std
qemu-system-x86_64 -hda winxp.qcow -m 2G -soundhw es1370 -vga std
qemu-system-x86_64 -hda ubuntu.qcow -m 2G -soundhw es1370 -vga std -net nic,model=rtl8139
qemu-system-x86_64 -cpu phenom -cdrom systemrescuecd-x86-1.5.4.iso
```
