#!/bin/bash

. ./_error_handling.sh

podman run -d --rm --security-opt label=disable -p 2049:2049 \
  --name gentoo_nfs_server -e SHARED_DIRECTORY=/setup_scripts \
  -v $(pwd):/setup_scripts itsthenetwork/nfs-server-alpine:latest

mkdir -p $(pwd)/cache
podman run -d --rm --security-opt label=disable -p 8200:80 \
  --name gentoo_binhost -v $(pwd)/cache:/usr/share/nginx/html:ro \
  nginx:alpine

echo "Ensure the following ports are allowed through any firewall that's present: 2049/tcp, 8200/tcp"
