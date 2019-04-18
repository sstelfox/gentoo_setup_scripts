#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Adjust various logging related settings"

# This information can be very useful for debugging and diagnostics
kernel_config --enable X86_VERBOSE_BOOTUP

# And start logging as quickly as possible
kernel_config --enable EARLY_PRINTK

# Enable timestamps on all the messages dumped by the kernel
#kernel_config --enable PRINTK_TIME
#kernel_config --set-val CONSOLE_LOGLEVEL_DEFAULT 7
#kernel_config --set-val CONSOLE_LOGLEVEL_QUIET 4
#kernel_config --set-val MESSAGE_LOGLEVEL_DEFAULT 4
