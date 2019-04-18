#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Setting some unnecessary options that are personal preferences"

### General setup section

# Use LZ4 to compress the kernel instead of the Gzip default
kernel_config --disable KERNEL_GZIP
kernel_config --enable KERNEL_LZ4

# Expose a copy of the kernel's running config through /proc/config.gz
kernel_config --enable IKCONFIG
kernel_config --enable IKCONFIG_PROC

# Additional performance improvements
kernel_config --enable OPTIMIZE_INLINING

kernel_config --enable ENABLE_MUST_CHECK
# TODO:
#kernel_config --enable STACK_VALIDATION
kernel_config --enable STRIP_ASM_SYMS

# TODO: I may want to increase this if there are a lot of warnings, 1024 is the
# default, but it seems like other distributions raises this up to 2048.
#kernel_config --set-val FRAME_WARN 2048
