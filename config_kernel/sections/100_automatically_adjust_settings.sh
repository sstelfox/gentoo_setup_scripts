#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Automatically adjusting dependent settings using the kernel tool..."

run_command /usr/src/linux make olddefconfig
