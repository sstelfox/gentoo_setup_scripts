#!/bin/bash

. ./_error_handling.sh

if [ "$(getenforce)" == "Enforcing" ]; then
  echo "Unable to run with SELinux in enforcing mode..."
  exit 1
fi

docker run -d --rm --name gentoo_nfs --privileged -v $(pwd):/gentoo_cache \
  -p 2049:2049 -e SHARED_DIRECTORY=/gentoo_cache itsthenetwork/nfs-server-alpine:latest

sudo iptables -A INPUT -m tcp -p tcp --dport 2049 -i virbr0 -j ACCEPT
