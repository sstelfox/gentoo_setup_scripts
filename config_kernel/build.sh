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
    log "Running config section: ${section}"
    ./${section}
  else
    log "Skipping config section: ${section}"
  fi
done
