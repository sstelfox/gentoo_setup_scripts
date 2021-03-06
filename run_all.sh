#!/bin/bash

. ./_error_handling.sh

function prefix_output() {
  local PREFIX="${1:-unknown_segment}"
  awk "{ print \"[${PREFIX}]\", \$0 }"
}

START_TIME="$(date +%s)"

for segment in $(ls build_scripts/0*.sh | sort -n); do
  ./resize_console.sh || true

  echo "Executing segment: ${segment}"
  ./${segment} 2>&1 | prefix_output "$(basename ${segment%%.sh})"
  echo "Segment complete"
done

END_TIME="$(date +%s)"

echo "Elapsed run took $((${END_TIME} - ${START_TIME})) seconds"
