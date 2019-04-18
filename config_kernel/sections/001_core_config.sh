#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling basic kernel functionality"

### Top level menuconfig options

kernel_config --enable 64BIT
kernel_config --enable BLOCK
kernel_config --enable NET
kernel_config --enable CRYPTO
kernel_config --enable SWAP
kernel_config --enable MULTIUSER

kernel_config --disable EMBEDDED

kernel_config --enable CC_OPTIMIZE_FOR_PERFORMANCE
kernel_config --disable CC_OPTIMIZE_FOR_SIZE

# Enable the Gentoo specific options, this option is added by the Gentoo
# maintainer patches.
kernel_config --enable GENTOO_LINUX
kernel_config --enable GENTOO_LINUX_PORTAGE
kernel_config --enable GENTOO_LINUX_UDEV
kernel_config --enable GENTOO_LINUX_INIT_SCRIPT
kernel_config --disable GENTOO_LINUX_INIT_SYSTEMD

# Recommended by the Gentoo Handbook: "Also select Maintain a devtmpfs file
# system to mount at /dev so that critical device files are already available
# early in the boot process (CONFIG_DEVTMPFS and DEVTMPFS_MOUNT)":
kernel_config --enable DEVTMPFS
kernel_config --enable DEVTMPFS_MOUNT

kernel_config --enable PROC_FS

# Other very core settings
kernel_config --enable INET
