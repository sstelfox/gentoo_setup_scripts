#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling software RAID support"

kernel_config --enable BLK_DEV_MD
kernel_config --enable DM_RAID

# I may want to disable this and allow dracut to handle the raid initialization
# based on a configuration as the info about this option warn of the potential
# for several seconds of delay.
kernel_config --enable MD_AUTODETECT

# Support for various raid modes
kernel_config --enable MD_RAID0
kernel_config --enable MD_RAID1
kernel_config --enable MD_RAID10
kernel_config --enable MD_RAID456
