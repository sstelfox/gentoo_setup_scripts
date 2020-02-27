#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

echo 'dev-libs/libpcre2 jit' > /mnt/gentoo/etc/portage/package.use/git
chroot /mnt/gentoo emerge dev-vcs/git

# Note: upgrading this requires the repoman utility and running:
# repoman --digest=y -d full

mkdir -p /mnt/gentoo/etc/portage/repos.conf
cat << 'EOF' > /mnt/gentoo/etc/portage/repos.conf/sstelfox.conf
[sstelfox]
location = /var/db/repos/sstelfox
sync-type = git
sync-uri = https://github.com/sstelfox/personal_overlay.git
auto-sync = yes
priority = 9999
EOF

# We need to get our repo synced down as well if we're online
if [ "${LOCAL}" != "yes" ]; then
  chroot /mnt/gentoo emerge --sync
fi
