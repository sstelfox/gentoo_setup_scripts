#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ "${LOCAL}" != "yes" ]; then
  # Do a fast bulk sync if we have nothing, then a slower more refined rsync
  [ -f /mnt/gentoo/usr/portage/header.txt ] || chroot /mnt/gentoo emerge-webrsync &> /dev/null
  chroot /mnt/gentoo emerge --sync &> /dev/null
fi

# TODO: I should probably set the system profile now so the packages can go
# straight to the final binary targets.

# Remove all of the gentoo news that has been announced to date
chroot /mnt/gentoo eselect news read all --quiet
chroot /mnt/gentoo eselect news purge

PROFILE_ID=$(
  chroot /mnt/gentoo eselect profile list | \
  grep 'hardened/linux/amd64/no-multilib/selinux' | \
  awk '{ print $1 }' | \
  grep -oE '[0-9]+'
)
chroot /mnt/gentoo eselect profile set ${PROFILE_ID}

# Future installs may incompatible, make sure we're up to date before we
# attempt to hit important things like the kernel.
chroot /mnt/gentoo emerge --update --newuse --deep @world
chroot /mnt/gentoo emerge @preserved-rebuild

# This may need to have the selinux feature disabled, and may need to
# be || true
FEATURES="-selinux" chroot /mnt/gentoo emerge sec-policy/selinux-base sys-kernel/linux-firmware \
  sec-policy/selinux-base-policy
