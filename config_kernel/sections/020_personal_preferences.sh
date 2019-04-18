#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting some unnecessary options that are personal preferences"

# Expose a copy of the kernel's running config through /proc/config.gz
kernel_config --enable IKCONFIG
kernel_config --enable IKCONFIG_PROC
kernel_config --enable BUILD_BIN2C
