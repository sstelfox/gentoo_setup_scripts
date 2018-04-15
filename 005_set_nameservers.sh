#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Put a barebones resolve configuration in place for the chroot until it can be
# properly setup.
cat << 'EOF' > /mnt/gentoo/etc/resolv.conf
nameserver 8.8.4.4
nameserver 8.8.8.8
EOF
