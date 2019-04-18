#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting up initramfs support"

#kernel_config --enable BLK_DEV_INITRD
