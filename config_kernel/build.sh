#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

# Ensure we're in our base directory
cd ${BASE_DIRECTORY}

# Collect an ordered list of sections to run...
SECTION_LIST="$(ls sections/*.sh 2> /dev/null | sort -n)"

# Run each of them
for section in ${SECTION_LIST}; do
  if [ -x ${section} ]; then
    log "${TTY_COLOR_GREEN}Running config section: ${section}${TTY_COLOR_RST}"
    ./${section}
  else
    log "${TTY_COLOR_GREEN}Skipping config section: ${section}${TTY_COLOR_RST}"
  fi
done

if [ -x "target_specific/${KERNEL_TARGET}" ]; then
  log "${TTY_COLOR_GREEN}Running target specific kernel options${TTY_COLOR_RST}"
fi

log "Finalizing the config..."
run_command /usr/src/linux make olddefconfig
