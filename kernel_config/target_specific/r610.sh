#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

./target_specific/intel.sh

log "Running target specific kernel options: r610"
