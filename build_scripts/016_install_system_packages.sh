#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge sys-apps/dmidecode app-arch/lz4 net-misc/curl \
  sys-apps/usbutils sys-apps/pciutils sys-block/parted sys-fs/cryptsetup \
  sys-fs/dosfstools sys-fs/lvm2 sys-fs/xfsprogs

# We don't care about physical sensors on virtual machines
if [ "${KERNEL_TARGET}" != "kvm_guest" ]; then
  chroot /mnt/gentoo emerge sys-apps/lm-sensors
  # Note: I haven't tested this... It may fail, but good to enable
  chroot /mnt/gentoo rc-update add lm_sensors default

  # TODO: This probably requires additional machine specific configuration in /etc/sensors.d
fi

# Remove some unecessary packages
chroot /mnt/gentoo emerge -D net-firewall/iptables net-misc/dhcp
