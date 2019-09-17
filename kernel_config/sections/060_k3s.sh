#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling various options for k3s"

kernel_config --enable BRIDGE
kernel_config --enable VETH
kernel_config --enable VXLAN

kernel_config --enable OVERLAY_FS
kernel_config --enable OVERLAY_FS_INDEX
kernel_config --enable OVERLAY_FS_METACOPY
kernel_config --enable OVERLAY_FS_REDIRECT_DIR
