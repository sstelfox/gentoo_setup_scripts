#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ "${KERNEL_TARGET}" = "kvm_guest" ]; then
  exit 0
fi

chroot /mnt/gentoo emerge sys-apps/smartmontools

cat << 'EOF' > /mnt/gentoo/etc/conf.d/smartd
# /etc/conf.d/smartd

# Change the default check time from half an hour to three hours
SMARTD_OPTS="-i 10800 "
EOF

# TODO: I need to finish evaluating and configuring the following config option...

cat << 'EOF' > /mnt/gentoo/etc/smartd.conf
# /etc/smartd.conf

# Prevent the system from spinning up disks in powerdown
#DEVICESCAN -n standby,15,q

# A previous very specific config that I need to understand
#DEVICESCAN -a -p -o on -S on -m root -M diminishing -s (S/../.././00|L/../../7/02)

# -a is equivalent to: -H -f -t -l error -l self-test -l selfteststs -C 197 -U 198

# -H Check the health status of the disk, if there is a failing health status,
#       log a message at LOG_CRIT and return a non-zero return status
# -f
# -t
# -l error
# -l self-test Report if the failed values have increased since the last check
# -l selfteststs
# -C 197
# -U 198

# -n standby,8,q check the device unless it is in sleep or standby mode, if it
#       hasn't been checked in 8x the polling interval (we set it to 3 hours
#       elsewhere, so at most once a day). The 'q' prevents writing a log
#       message when the check is skipped.

# -p
# -o on Enable automatic offline testing
# -S on Enable attribute autosave
# -m root
# -M diminishing
# -s (S/../.././00|L/../../7/02)

DEVICESCAN -a
EOF

chroot /mnt/gentoo rc-update add smartd default
