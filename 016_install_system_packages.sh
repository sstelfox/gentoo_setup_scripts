#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge sys-apps/dmidecode app-arch/lz4 \
  sys-apps/lm_sensors sys-apps/usbutils sys-apps/pciutils sys-block/parted \
  sys-fs/cryptsetup sys-fs/dosfstools sys-fs/lvm2 sys-fs/xfsprogs \
  sys-kernel/dracut
