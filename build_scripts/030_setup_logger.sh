#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# TODO: Need to convert this to support local mode

mkdir -p /mnt/gentoo/etc/portage/package.use
echo 'app-admin/syslog-ng json' > /mnt/gentoo/etc/portage/package.use/syslog-ng

chroot /mnt/gentoo emerge app-admin/logrotate app-admin/syslog-ng
chroot /mnt/gentoo rc-update add syslog-ng default

chroot /mnt/gentoo curl -s -o /etc/syslog-ng/syslog-ng.conf https://stelfox.net/note_files/syslog-ng/syslog-ng.conf

cat << 'EOF' > /mnt/gentoo/etc/logrotate.conf
# /etc/logrotate.conf

# Rotate log files daily
daily

# System logs should be centrally managed with copies of logs that persist much
# longer than on the individual systems. Keeping one week of logs should handle
# most non-security related situations. When a security event occurs we can't
# trust locally stored logs anyway.
rotate 7

# If the log file doesn't exist... create it. It won't get rotated if it's
# empty.
create
notifempty

# Dates are much better suffixes than incrementing numbers
dateext

# Older logs can be compressed. This saves a surprising amount of disk space.
compress

# Don't care about receiving legacy logs via email when they're rotated out,
# and keep them next to the original logs
nomail
noolddir

# Include package specific log configuration from the directory
include /etc/logrotate.d
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/login_data
# /etc/logrotate.d/login_data

# This data is normally in the global root, but isn't maintained by any
# package. To keep the system consistent, it seems to belong here a lot more.

/var/log/wtmp {
  create 0664 root utmp

  monthly
  minsize 1M

  rotate 3
}

/var/log/btmp {
  create 0600 root utmp
  missingok

  monthly
  minsize 1M

  rotate 3
}
EOF
