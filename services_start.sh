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

podman run -d --rm --security-opt label=disable -p 2049:2049 \
  --name gentoo_nfs_server --privileged -e SHARED_DIRECTORY=/setup_scripts \
  -v $(pwd):/setup_scripts itsthenetwork/nfs-server-alpine:latest

mkdir -p $(pwd)/cache
podman run -d --rm --security-opt label=disable -p 8200:80 \
  --name gentoo_binhost -v $(pwd)/cache:/usr/share/nginx/html:ro \
  nginx:alpine

echo "Ensure the following ports are allowed through any firewall that's present: 2049/tcp, 8200/tcp"
