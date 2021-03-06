#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

cat << 'EOF' > /mnt/gentoo/etc/locale.gen
en_US ISO-8859-1
en_US.UTF-8 UTF-8
EOF

chroot /mnt/gentoo locale-gen

# Locale IDs vary though not by much, this ensures we get always end up on UTF-8
LOCALE_ID=$(chroot /mnt/gentoo eselect locale list | grep 'en_US.utf8' | awk '{ print $1 }' | grep -oE '[0-9]+')
chroot /mnt/gentoo eselect locale set ${LOCALE_ID}
chroot /mnt/gentoo env-update
