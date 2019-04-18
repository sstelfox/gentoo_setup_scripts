#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling SELinux and supporting settings"

kernel_config --enable AUDIT
