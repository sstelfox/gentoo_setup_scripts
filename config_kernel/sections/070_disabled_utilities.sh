#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Disabling kernel built in utilities that aren't needed"

# Using undefine allows us to know if the menuconfig would like to set it
kernel_config --undefine LIBCRC32C
kernel_config --undefine ZLIB_INFLATE
