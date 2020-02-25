#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ "${LOCAL}" != "yes" ]; then
  # Do a fast bulk sync if we have nothing, then a slower more refined rsync
  [ "$(ls /var/db/pkg/ 2>/dev/null | wc -l)" -eq 0 ] || chroot /mnt/gentoo emerge-webrsync &> /dev/null
  chroot /mnt/gentoo emerge --sync &> /dev/null
fi

# Remove all of the gentoo news that has been announced to date
chroot /mnt/gentoo eselect news read all --quiet
chroot /mnt/gentoo eselect news purge
