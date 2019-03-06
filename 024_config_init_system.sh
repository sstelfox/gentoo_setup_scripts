#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Disable three finger salutes
sed -i '/ctrlaltdel/d' /mnt/gentoo/etc/inittab

# This doesn't seem to be necessary as the serial console seems to be setup by
# default now. I may want to switch the terminal type from vt100 to linux at
# some point but this should be fine
#if [ "${KERNEL_CONFIG}" = "kvm" ]; then
#  echo 's0:12345:respawn:/sbin/agetty -L 115200 ttyS0 vt100' >> /mnt/gentoo/etc/inittab
#fi

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
