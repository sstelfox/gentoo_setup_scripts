#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting additional settings required by others"

# Allow the kernel to read and watch machine check exceptions
kernel_config --enable X86_MCE

# We don't need the legacy DMA interface for ISA controllers
kernel_config --disable ISA_DMA_API

# TODO: I've never been sure about this. It probably makes sense for a VM host
# but does this help me or do anything at all under normal workloads?
#kernel_config --enable KSM
