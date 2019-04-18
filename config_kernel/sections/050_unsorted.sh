#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting all the generally unsorted options"

# https://lwn.net/Articles/680989/
# https://lwn.net/Articles/681763/
kernel_config --enable BLK_WBT
kernel_config --enable BLK_WBT_SQ
kernel_config --enable BLK_WBT_MQ

# https://www.phoronix.com/scan.php?page=article&item=linux_2637_video&num=1
kernel_config --enable SCHED_AUTOGROUP

# TODO: I probably need this options
#kernel_config --enable POSIX_MQUEUE
#kernel_config --enable CROSS_MEMORY_ATTACH

# TODO: These various lock detection mechanisms are likely good to enable
#kernel_config --enable SOFTLOCKUP_DETECTOR
#kernel_config --enable HARDLOCKUP_DETECTOR
#kernel_config --enable DETECT_HUNG_TASK
#kernel_config --enable WQ_WATCHDOG

# This seems super interesting but probably isn't generally necessary. The
# reboot to enable also kind of sucks. If I ever needed these kind of
# diagnostics I wouldn't want to effect the bad state by rebooting to try and
# get metrics. The reboot would destroy the state and we'd have to wait for the
# issue to re-occur.
#
# https://lwn.net/Articles/759781/
#kernel_config --enable PSI
#kernel_config --enable PSI_DEFAULT_DISABLED
