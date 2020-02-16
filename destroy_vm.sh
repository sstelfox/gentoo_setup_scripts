#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

function error_handler() {
  echo "Error occurred in ${3} executing line ${1} with status code ${2}"
  echo "The pipe status values were: ${4}"
}

# Please note basename... is intentionally at the end as it's a command that
# will effect the value of '$?'
trap 'error_handler ${LINENO} $? "$(basename ${BASH_SOURCE[0]})" "${PIPESTATUS[*]}"' ERR

# Log all commands before they're executed for debugging purposes
if [ -n "${DEBUG:-}" ]; then
  set -o xtrace
fi

if [ ${EUID} != 0 ]; then
  echo "This script is expecting to run as root."
  exit 1
fi

EXISTING_VM="$(virsh list --all | awk '/gentoo-test/ { print $2 }' | head -n 1)"

if [ -n "${EXISTING_VM}" ]; then
  # This first one will fail if it's not running
  virsh destroy ${EXISTING_VM} || true
  virsh undefine --remove-all-storage --nvram ${EXISTING_VM}
else
  echo "Couldn't find a running Gentoo VM"
fi
