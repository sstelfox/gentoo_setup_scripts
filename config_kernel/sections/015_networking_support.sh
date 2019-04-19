#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling various networking components"

# My servers don't need Ham radio options
kernel_config --disable HAMRADIO

# This may get re-enabled on a system specific basis later on, but generally
# for what I build kernels for I don't need wireless support.
kernel_config --disable RFKILL
kernel_config --disable WLAN
kernel_config --disable WIRELESS

# Disable QoS support
kernel_config --disable NET_SCHED
