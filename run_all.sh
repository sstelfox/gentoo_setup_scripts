#!/bin/bash

. ./_error_handling.sh

function prefix_output() {
  local PREFIX="${1:-unknown_segment}"
  awk "{ print \"[${PREFIX}]\", \$0 }"
}

for segment in $(ls 0*.sh | sort -n); do
  echo "Executing segment: ${segment}"
  ./${segment} 2>&1 | prefix_output "${segment%%.sh}"
  echo "Segment complete"
done
