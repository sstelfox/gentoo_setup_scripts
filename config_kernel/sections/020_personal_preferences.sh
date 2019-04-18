#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting some unnecessary options that are personal preferences"

### General setup section

# Use LZ4 to compress the kernel instead of the Gzip default
kernel_config --disable KERNEL_GZIP
kernel_config --enable KERNEL_LZ4

# Expose a copy of the kernel's running config through /proc/config.gz
kernel_config --enable IKCONFIG
kernel_config --enable IKCONFIG_PROC
