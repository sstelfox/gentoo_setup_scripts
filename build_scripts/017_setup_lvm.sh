#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge sys-fs/lvm2
chroot /mnt/gentoo rc-update add lvm boot
chroot /mnt/gentoo rc-update add lvmetad boot

# If there is a raid setup thre are some additional steps we need to take care
# of.
if [ -b /dev/md0 ]; then
  chroot /mnt/gentoo emerge sys-fs/mdadm
  chroot /mnt/gentoo rc-update add mdraid boot
  mdadm --examine --scan >> /mnt/gentoo/etc/mdadm.conf
fi
