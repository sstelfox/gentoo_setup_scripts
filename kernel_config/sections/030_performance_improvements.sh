#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Adjusting some performance related settings"

# TODO: Look into Automatic process group scheduling as it applies to server
# loads. It's primarily designed for desktop loads but may provide some
# protection against resource stealing by aggressive processes.
#kernel_config --enable SCHED_AUTOGROUP

kernel_config --enable TRANSPARENT_HUGEPAGE

kernel_config --enable CLEANCACHE
kernel_config --enable FRONTSWAP
kernel_config --enable ZSWAP
kernel_config --enable ZBUD
kernel_config --enable Z3FOLD
