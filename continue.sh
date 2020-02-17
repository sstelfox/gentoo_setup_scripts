#!/bin/bash

. ./_error_handling.sh

function prefix_output() {
  local PREFIX="${1:-unknown_segment}"
  awk "{ print \"[${PREFIX}]\", \$0 }"
}

CONTINUE_FROM="${1:-}"
if [ -z "${CONTINUE_FROM}" ]; then
  echo 'Need to provide an ID to start from'
  exit 1
fi

for segment in $(ls build_scripts/0*.sh | sort -n); do
  seg_num="$(echo ${segment} | cut -d _ -f 1)"

  if [ "${seg_num}" -ge "${CONTINUE_FROM}" ]; then
    ./resize_console.sh

    echo "Executing segment: ${segment}"
    ./${segment} 2>&1 | prefix_output "$(basename ${segment%%.sh})"
    echo "Segment complete"
  fi
done
