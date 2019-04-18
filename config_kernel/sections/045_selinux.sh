#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling SELinux and supporting settings"

# TODO: Additional good to have hook... May not be necessary but may provide
# important hooks.
#kernel_config --enable SECURITY_NETWORK
#kernel_config --enable SECURITY_NETWORK_XFRM

# TODO: Once policies are tight, these settings should be revisited.
#kernel_config --disable SECURITY_SELINUX_BOOTPARAM
#kernel_config --disable SECURITY_SELINUX_DEVELOP
