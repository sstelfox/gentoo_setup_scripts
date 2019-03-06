#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Disable three finger salutes
sed -i '/ctrlaltdel/d' /mnt/gentoo/etc/inittab

# This doesn't seem to be necessary as the serial console seems to be setup by
# default now. I may want to switch the terminal type from vt100 to vt102 or
# linux at some point but this should be fine
#
# * I will likely want to add '--login-pause --wait-cr --timeout 61' to the agetty arguments
# * I could also try using '-n' to force the login problem to handle everything
#   (maybe?)
# * If I wanted to allow automatic login (since local accounts don't have
#   passwords by default here, or any other reason, untested). I can use:
#
#   `/sbin/agetty -L --autologin --login-pause root 115200 ttyS0 vt100`
#
#   I could also do the above on another serial port
#
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
