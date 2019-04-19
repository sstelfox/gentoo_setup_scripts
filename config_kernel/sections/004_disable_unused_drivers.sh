#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Removing unecessary drivers"

# Don't need PCMCIA cards...
kernel_config --disable PCCARD

# Or any form of Mac hardware support...
kernel_config --disable MACINTOSH_DRIVERS

# Definitely not sound support for servers
kernel_config --disable SOUND

# The logo is cool but I generally use serial consoles (virt-console) or SSH to
# access my servers.
kernel_config --disable LOGO

# Specific hardware will enable any graphics cards and support that they may
# need
kernel_config --disable AGP
kernel_config --disable DRM_I915
kernel_config --disable VGA_ARB

kernel_config --disable BLK_DEV_SR_VENDOR
kernel_config --disable SCSI_PROC_FS

kernel_config --disable ATA_SFF

# Generally I don't need RAID support on any of my machines, ZFS is used when
# multiple disks are involved and I don't believe this is required for it.
# Further testing may be required.
kernel_config --disable BLK_DEV_MD

# A couple of data mapper targets I've never made use of
kernel_config --disable DM_MIRROR
kernel_config --disable DM_ZERO

# NOTE: Physical servers will almost certainly need this
kernel_config --disable SATA_PMP

# Note to self: This seems to be a requirement for supporting scanners via
# SANE, generally I don't need it though.
kernel_config --disable CHR_DEV_SG

# I don't believe this is necessary for USB mouse emulation but I generally
# don't have a GUI and hate GPM so if it breaks mouse support so be it. NOTE:
# This is one thing I may actually want to turn back on but it needs further
# testing.
kernel_config --disable INPUT_MOUSE

kernel_config --disable INPUT_JOYSTICK
kernel_config --disable INPUT_POLLDEV
kernel_config --disable INPUT_TABLET
kernel_config --disable INPUT_TOUCHSCREEN
kernel_config --disable INPUT_MISC

kernel_config --disable NETCONSOLE

kernel_config --disable FDDI
kernel_config --disable USB_NET_DRIVERS
kernel_config --disable SERIAL_NONSTANDARD

# This seems to only be needed by input devices that use serial ports which I
# doubt I'll need.
kernel_config --disable SERIO_SERPORT

# There is a bunch of ethernet devices enabled by default that I don't need
kernel_config --disable NET_VENDOR_3COM
kernel_config --disable NET_VENDOR_ADAPTEC
kernel_config --disable NET_VENDOR_AGERE
kernel_config --disable NET_VENDOR_ALACRITECH
kernel_config --disable NET_VENDOR_ALTEON
kernel_config --disable NET_VENDOR_AMAZON
kernel_config --disable NET_VENDOR_AMD
kernel_config --disable NET_VENDOR_AQUANTIA
kernel_config --disable NET_VENDOR_ARC
kernel_config --disable NET_VENDOR_ATHEROS
kernel_config --disable NET_VENDOR_AURORA
kernel_config --disable NET_VENDOR_BROADCOM
kernel_config --disable NET_VENDOR_BROCADE
kernel_config --disable NET_VENDOR_CADENCE
kernel_config --disable NET_VENDOR_CAVIUM
kernel_config --disable NET_VENDOR_CHELSIO
kernel_config --disable NET_VENDOR_CISCO
kernel_config --disable NET_VENDOR_CORTINA
kernel_config --disable NET_VENDOR_DEC
kernel_config --disable NET_VENDOR_DLINK
kernel_config --disable NET_VENDOR_EMULEX
kernel_config --disable NET_VENDOR_EZCHIP
kernel_config --disable NET_VENDOR_HP
kernel_config --disable NET_VENDOR_HUAWEI
kernel_config --disable NET_VENDOR_I825XX
kernel_config --disable NET_VENDOR_INTEL
kernel_config --disable NET_VENDOR_MARVELL
kernel_config --disable NET_VENDOR_MELLANOX
kernel_config --disable NET_VENDOR_MICREL
kernel_config --disable NET_VENDOR_MICROCHIP
kernel_config --disable NET_VENDOR_MICROSEMI
kernel_config --disable NET_VENDOR_MYRI
kernel_config --disable NET_VENDOR_NATSEMI
kernel_config --disable NET_VENDOR_NETERION
kernel_config --disable NET_VENDOR_NETRONOME
kernel_config --disable NET_VENDOR_NI
kernel_config --disable NET_VENDOR_NVIDIA
kernel_config --disable NET_VENDOR_OKI
kernel_config --disable NET_VENDOR_PACKET_ENGINES
kernel_config --disable NET_VENDOR_QLOGIC
kernel_config --disable NET_VENDOR_QUALCOMM
kernel_config --disable NET_VENDOR_RDC
kernel_config --disable NET_VENDOR_REALTEK
kernel_config --disable NET_VENDOR_RENESAS
kernel_config --disable NET_VENDOR_ROCKER
kernel_config --disable NET_VENDOR_SAMSUNG
kernel_config --disable NET_VENDOR_SEEQ
kernel_config --disable NET_VENDOR_SOLARFLARE
kernel_config --disable NET_VENDOR_SILAN
kernel_config --disable NET_VENDOR_SIS
kernel_config --disable NET_VENDOR_SMSC
kernel_config --disable NET_VENDOR_SOCIONEXT
kernel_config --disable NET_VENDOR_STMICRO
kernel_config --disable NET_VENDOR_SUN
kernel_config --disable NET_VENDOR_SYNOPSYS
kernel_config --disable NET_VENDOR_TEHUTI
kernel_config --disable NET_VENDOR_TI
kernel_config --disable NET_VENDOR_VIA
kernel_config --disable NET_VENDOR_WIZNET

# All of the above could be accomplished with this setting alone (which is not
# required for the virtio network driver so it can be enabled by my hardware
# specific config). I want to explicitly keep the above disabled though for
# when I selectively re-enable it in a hardware specific config so they don't
# all come back.
kernel_config --disable ETHERNET

# With all of the network cards disabled we also don't need the PHY support.
# Hardware specific drivers can enable this as needed. Seems like it's
# primarily used by the realtek drivers more than the ones I'd enable.
kernel_config --disable PHYLIB
kernel_config --disable MDIO_DEVICE