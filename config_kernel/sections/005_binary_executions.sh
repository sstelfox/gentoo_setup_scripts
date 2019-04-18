#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring binary execution options"

# Allow the kernel to run and recognize common binary formats
kernel_config --enable BINFMT_ELF
kernel_config --enable BINFMT_SCRIPT
