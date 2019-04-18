#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling SELinux and supporting settings"

# Baseline SELinux requirements
kernel_config --enable AUDIT
kernel_config --enable SECURITY

# TODO: Additional good to have hook... May not be necessary but may provide
# important hooks.
#kernel_config --enable SECURITY_NETWORK
#kernel_config --enable SECURITY_NETWORK_XFRM

# Explicitly enable SELinux and mark it as the default
kernel_config --enable SECURITY_SELINUX
kernel_config --enable DEFAULT_SECURITY_SELINUX
kernel_config --disable DEFAULT_SECURITY_DAC

# TODO: Once policies are tight, these settings should be revisited.
kernel_config --enable SECURITY_SELINUX_BOOTPARAM
#kernel_config --disable SECURITY_SELINUX_DEVELOP

# YAMA is not technically SELinux but provides some deeper hardening especially
# around ptrace'ing processes.
kernel_config --enable SECURITY_YAMA

# TODO: Additional secure boot settings:
#kernel_config --enable EVM
#kernel_config --enable IMA
#kernel_config --enable INTEGRITY_SIGNATURE
