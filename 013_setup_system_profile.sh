#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

PROFILE_ID=$(
  chroot /mnt/gentoo eselect profile list | \
  grep 'hardened/linux/amd64/no-multilib/selinux' | \
  awk '{ print $1 }' | \
  grep -oE '[0-9]+'
)
chroot /mnt/gentoo eselect profile set ${PROFILE_ID}

chroot /mnt/gentoo emerge --update --newuse --deep @world
chroot /mnt/gentoo emerge @preserved-rebuild

# This may need to have the selinux feature disabled, and may need to
# be || true
FEATURES="-selinux" chroot /mnt/gentoo emerge sec-policy/selinux-base sys-kernel/linux-firmware \
  sec-policy/selinux-base-policy
