#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

mkdir -p /mnt/gentoo/etc/portage/package.use
echo 'app-admin/syslog-ng json' > /mnt/gentoo/etc/portage/package.use/syslog-ng

chroot /mnt/gentoo emerge app-admin/logrotate app-admin/syslog-ng
chroot /mnt/gentoo rc-update add syslog-ng default

cat << 'EOF' > /mnt/gentoo/etc/syslog-ng/syslog-ng.conf
# /etc/syslog-ng/syslog-ng.conf

@version: 3.22
@module system-source

options {
  # IP addresses are more reliable descriptors and doesn't require a network
  # connection for consistent logging
  use_dns(no);
  dns_cache(no);

  # Output log stats every 12 hours, and include details about individual
  # connections and log files.
  stats_freq(43200);
  stats_level(1);

  # Use a more standard timestamp, but keep the precision requested for
  # RFC5424 TIME-SECFRAC
  ts_format(iso);
  frac_digits(6);
};

source local {
  system();
  internal();
};

destination auditFile { file(/var/log/audit.log); };
destination cronFile { file(/var/log/cron); };
destination kernFile { file(/var/log/kern); };
destination mailFile { file(/var/log/maillog); };
destination messageFile { file(/var/log/messages); };
destination secureFile { file(/var/log/secure); };

filter authpriv { facility(authpriv); };
filter audit { level(info) and facility(local6); };
filter cron { facility(cron); };
filter kern { facility(kern); };
filter mail { facility(mail); };
filter messages { level(info) and not (facility(mail, authpriv, cron, local6)); };

log { source(local); filter(audit); destination(auditFile); };
log { source(local); filter(authpriv); destination(secureFile); };
log { source(local); filter(cron); destination(cronFile); };
log { source(local); filter(kern); destination(kernFile); };
log { source(local); filter(mail); destination(mailFile); };
log { source(local); filter(messages); destination(messageFile); };
EOF

chmod 0600 /mnt/gentoo/etc/syslog-ng/syslog-ng.conf

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

# When we rotate any files, by default stick them in this directory to keep the
# standard log locations uncluttered
olddir /var/log/archive
createolddir 0700 root root

# Dates are much better suffixes than incrementing numbers
dateext

# Older logs can be compressed. This saves a surprising amount of disk space.
compress

# Don't care about receiving legacy logs via email when they're rotated out,
# and keep them next to the original logs
nomail

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

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/syslog-ng
/var/log/audit.log
/var/log/cron
/var/log/kern
/var/log/maillog
/var/log/messages
/var/log/secure {
  delaycompress
  missingok
  notifempty

  sharedscripts

  postrotate
    /etc/init.d/syslog-ng reload > /dev/null 2>&1 || true
  endscript
}
EOF

# Pre-create the directories others will create on the first boot so we can
# proactively set their permissions
mkdir -p /mnt/gentoo/var/log/{aide,archive,audit,chrony,portage,sandbox,sudo-io,watchdog}

chmod -R u=rwX,g=,o= /mnt/gentoo/etc/logrotate.*
chmod -R u=rwX,g=rX,o= /mnt/gentoo/var/log

touch /mnt/gentoo/var/log/{lastlog,wtmp}
chmod 0660 /mnt/gentoo/var/log/{lastlog,wtmp}

# Genkernel isn't used by these builds but this file persists, lets get rid of
# it for a nice clean root.
rm -f /mnt/gentoo/var/log/genkernel.log

# TODO: Files that should be rotated but haven't been yet...
#
# /var/log/aide/aide.log
# /var/log/boot
# /var/log/dmesg
# /var/log/emerge-fetch.log
# /var/log/emerge.log
# /var/log/genkernel.log
# /var/log/lastlog
