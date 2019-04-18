#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring binary execution options"

# Neither of these are required for general use
kernel_config --disable BINFMT_MISC
kernel_config --disable COREDUMP
