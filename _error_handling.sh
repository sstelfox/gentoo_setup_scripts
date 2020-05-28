#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

function error_handler() {
  echo
  echo "Error occurred in ${3} executing line ${1} with status code ${2}"
  echo "The pipe status values were: ${4}"
  echo

  if [ -f "${3}" ]; then
    echo "The line that triggered the issue was:"
    echo -e "\t$(awk "NR==${1}" ${3})"
  else
    echo "Unable to find file to grab source line from..."
  fi

  echo
}

# Please note basename... is intentionally at the end as it's a command that
# will effect the value of '$?'
trap 'error_handler ${LINENO} $? "${BASH_SOURCE[0]}" "${PIPESTATUS[*]}"' ERR

# Log all commands before they're executed for debugging purposes
if [ -n "${DEBUG:-}" ]; then
  set -o xtrace
fi

# Check the script for syntax errors but don't actually execute it
if [ -n "${SYNTAX_CHECK:-}" ]; then
  set -o noexec
fi
