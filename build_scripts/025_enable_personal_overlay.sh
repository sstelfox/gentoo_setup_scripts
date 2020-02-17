#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# TODO: I don't think this is needed anymore
exit 0

echo 'dev-libs/libpcre2 jit' > /mnt/gentoo/etc/portage/package.use/git
chroot /mnt/gentoo emerge dev-vcs/git

mkdir -p /mnt/gentoo/etc/portage/repos.conf
cat << 'EOF' > /mnt/gentoo/etc/portage/repos.conf/sstelfox.conf
[sstelfox]
location = /usr/local/overlay/sstelfox
sync-type = git
sync-uri = https://github.com/sstelfox/personal_overlay.git
auto-sync = yes
EOF

# We need to get our repo synced down as well if we're online
if [ "${LOCAL}" != "yes" ]; then
  chroot /mnt/gentoo emerge --sync
fi
