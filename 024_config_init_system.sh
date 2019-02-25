#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

sed -i '/ctrlaltdel/d' /mnt/gentoo/etc/inittab

# There is some kind of issue with KVM hosts exposing a serial console even
# when it isn't actually present, so don't setup this terminal on those hosts.
if [ -c /dev/ttyS0 -a "${KERNEL_CONFIG}" != "kvm" ]; then
  echo 's0:12345:respawn:/sbin/agetty -L 115200 ttyS0 vt100' >> /mnt/gentoo/etc/inittab
fi

if [ -c /dev/hvc0 ]; then
  echo 'vs0:12345:respawn:/sbin/agetty -L 115200 hvc0 vt100' >> /mnt/gentoo/etc/inittab
fi

cat << 'EOF' > /mnt/gentoo/etc/rc.conf
# /etc/rc.conf

rc_controller_cgroups="YES"
rc_interactive="NO"
rc_nocolor="YES"
rc_shell="/sbin/sulogin"
rc_tty_number="9"

rc_logger="YES"
rc_parallel="YES"

unicode="YES"
EOF
