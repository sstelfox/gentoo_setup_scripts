#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Removing any existing kernel config and all build artifacts"
run_command /usr/src/linux make mrproper

# Start with a completely empty config, we'll enable hardware support and
# software selection as we need / want to for our appropriate targets.
log "Creating an empty config"
run_command /usr/src/linux make allnoconfig
