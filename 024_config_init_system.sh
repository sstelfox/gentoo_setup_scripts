#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

sed -i '/ctrlaltdel/d' /mnt/gentoo/etc/inittab
#echo 's0:12345:respawn:/sbin/agetty -L 115200 ttyS0 vt100' >> /mnt/gentoo/etc/inittab

cat << 'EOF' > /mnt/gentoo/etc/rc.conf
# /etc/rc.conf

rc_controller_cgroups="YES"
rc_interactive="NO"
rc_nocolor="YES"
rc_shell="/sbin/sulogin"
rc_tty_number="9"

rc_logger="NO"

rc_parallel="YES"

unicode="YES"
EOF
