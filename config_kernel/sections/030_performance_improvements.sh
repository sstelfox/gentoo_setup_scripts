#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Adjusting some performance related settings"

# Switch to the more efficient panic unwinder
kernel_config --enable UNWINDER_ORC
kernel_config --disable UNWINDER_FRAME_POINTER

# This allows GCC to optimize highly likely paths while having a negligible
# performance impact on the least likely branches. Can provide large
# performance gains.
kernel_config --enable JUMP_LABEL
