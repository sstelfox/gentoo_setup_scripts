#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo eselect profile set default/linux/amd64/17.0/no-multilib/hardened/selinux

# dev-python/matplotlib is broken and must be handled with some weird care, I
# don't know if this is going to be reliable here...
chroot /mnt/gentoo /bin/bash -l -c 'MAKEOPTS="-j1" emerge --jobs=1 --ignore-default-opts dev-python/matplotlib'

chroot /mnt/gentoo emerge --update --newuse --deep --with-bdeps=y --complete-graph y @world
chroot /mnt/gentoo emerge @preserved-rebuild

# This may need to have the selinux feature disabled, and may need to
# be || true
FEATURES="-selinux" chroot /mnt/gentoo emerge sec-policy/selinux-base sec-policy/selinux-base-policy

if [ "${KERNEL_TARGET}" != "kvm_guest" ]; then
  # These are the microcode updates. Ideally I should target the processor of
  # the physical machine that is being built for. When dealing with KVM guests
  # there aren't any microcode updates to be had, so we don't need either of
  # these.
  chroot /mnt/gentoo emerge sys-apps/iucode_tool sys-firmware/intel-microcode sys-kernel/linux-firmware
fi
