#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

# Remove any existing config and all build artifacts
run_command /usr/src/linux make mrproper

# Start with a completely empty config, we'll enable hardware support and
# software selection as we need / want to for our appropriate targets.
run_command /usr/src/linux make allnoconfig
