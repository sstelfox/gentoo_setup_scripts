#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

exit 0

# Note to self: I don't know what net-analyzer/netcat is up to but despite
# claiming to it doesn't actually support IPv6. You can't connect to the
# addresses directly even when the `-6` flag is specified. The
# `net-analyzer/openbsd-netcat` also seems to be garbage. Luckily nmap does
# have a sane version but we need to enable it.
cat << 'EOF' > /mnt/gentoo/etc/portage/package.use/nmap
net-analyzer/nmap ncat
EOF

chroot /mnt/gentoo emerge app-crypt/gnupg app-misc/tmux app-text/tree \
  mail-client/mutt net-analyzer/tcpdump net-dns/bind-tools \
  www-client/elinks net-analyzer/nmap sys-apps/pv
