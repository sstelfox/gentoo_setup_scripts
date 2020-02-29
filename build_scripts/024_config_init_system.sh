#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Disable three finger salutes
sed -i '/ctrlaltdel/d' /mnt/gentoo/etc/inittab

# Clear out the default serial console and configure one that allows us to
# login before the local admin user has set a password (but only if this is a
# KVM guest, other system will have to rely on the SSH key created during the
# install for access). This file also places a checklist of required actions in
# the MOTD as a reminder for the first time setup tasks.

sed -i '/^s0:/d' /mnt/gentoo/etc/inittab

if [ "${KERNEL_TARGET}" = "kvm_guest" ]; then
  cat << EOF >> /mnt/gentoo/etc/inittab

# During the initial bit (admin user doesn't have a local password), this
# should be removed during the inital VM setup.
s0:12345:respawn:/sbin/agetty -L --login-pause --timeout 0 --autologin ${ADMIN_USER} 115200 ttyS0 linux

# One of these should be enabled to allow for serial console access. The former
# doesn't make the system feel like it has hung during boot but if you connect
# to the serial after its already booted you won't see the MOTD when you press
# enter.
#
# The latter one is more friendly for post boot serial connections and times
# out the login if left half logged in, but during a full boot it seems like
# the boot process is frozen as it doesn't display anything after service
# startup until the user presses the enter key...
#s0:12345:respawn:/sbin/agetty -L --login-pause --timeout 0 115200 ttyS0 linux
#s0:12345:respawn:/sbin/agetty -L --timeout 30 --wait-cr 115200 ttyS0 linux
EOF
fi

cat << 'EOF' > /mnt/gentoo/etc/motd

NOTICE: Initial setup checklist that still needs to be done:

* Setup a local administrative password and/or central authentication
* Set a root password (yes really)
* Disable automatic serial login on ttyS0 in /etc/inittab (if it's been enabled)
* Enable authentication in the sudoers file
* Update the hostname in /etc/hostname and /etc/conf.d/hostname
* Update the hosts file
* Remove this MOTD

EOF

cat << 'EOF' > /mnt/gentoo/etc/rc.conf
# /etc/rc.conf

rc_controller_cgroups="YES"
rc_interactive="NO"
rc_nocolor="YES"
rc_shell="/sbin/sulogin"
rc_tty_number="9"

rc_logger="YES"
rc_parallel="NO"

unicode="YES"
EOF
