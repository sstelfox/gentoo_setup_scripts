#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Adjusting some performance related settings"

kernel_config --enable UNWINDER_ORC
kernel_config --disable UNWINDER_FRAME_POINTER
