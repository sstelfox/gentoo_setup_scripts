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

# These are still core, but they depend on some earlier settings
kernel_config --enable ACPI
kernel_config --enable INET
kernel_config --enable NUMA
kernel_config --enable PCI
kernel_config --enable PRINTK
kernel_config --enable SWAP
