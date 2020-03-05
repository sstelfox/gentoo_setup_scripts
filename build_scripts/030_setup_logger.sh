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

# Send all system emergency messages to all users
destination allUsers { usertty("*"); };
filter emergency { level(emerg) and not (facility(mail)); };
log { source(local); filter(emergency); destination(allUsers); };

# General logging configuration that matches the standard RHEL rsyslog config,
# the only difference is the messages file which also excludes local6
# informational level which we use for auditd logging.
destination bootFile { file(/var/log/boot.log); };
destination cronFile { file(/var/log/cron); };
destination mailFile { file(/var/log/maillog); };
destination messageFile { file(/var/log/messages); };
destination secureFile { file(/var/log/secure); };

filter authpriv { facility(authpriv); };
filter boot { facility(local7); };
filter cron { facility(cron); };
filter mail { facility(mail); };
filter messages { level(info) and not (facility(mail, authpriv, cron, local6)); };

log { source(local); filter(boot); destination(bootFile); };
log { source(local); filter(cron); destination(cronFile); };
log { source(local); filter(mail); destination(mailFile); };
log { source(local); filter(messages); destination(messageFile); };
log { source(local); filter(authpriv); destination(secureFile); };

# I can't help but think there are some important logs being missed... This
# diagnostic coding can allow me to track down missing logs locally when I need
# to find those.
#destination allLogs { file(/var/log/all template("${FACILITY}/${LEVEL} ${SOURCE} ${PROGRAM}/${PID} ${ISODATE} ${HOST} ${MSGHDR}${MESSAGE}\n")); };
#log { source(local); destination(allLogs); };

# Handle the auditd syslog events to a dedicated file
destination auditFile { file(/var/log/audit.log); };
filter audit { level(info) and facility(local6); };
log { source(local); filter(audit); destination(auditFile); };

# Simple Syslog UDP receiver (untested / probably not working)
#source net { udp(); };
#destination net_logs { file("/var/log/network/$HOST/system.log" create-dirs(yes)); };
#log { source(net); destination(net_logs); };

# Sample network senders
#destination loghost { udp("10.100.0.23", port(514)); };
#log { source(local); destination(loghost); };
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

# Immediately compress rotated log files
nodelaycompress

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

# Note: /var/log/lastlog isn't rotated intentionally. It is not an append-style
# file and can be read with the `lastlog` binary. This keeps the last timestamp
# each user has logged into the system. Useful for disabling user accounts that
# haven't been used in some time.
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/aide
/var/log/aide/aide.log {
  create 0600 root root
  missingok

  nocreate
  notifempty
}
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/elog-save-summary
/var/log/emerge.log
/var/log/emerge-fetch.log
/var/log/portage/elog/summary.log {
  create 0600 portage portage
  missingok

  nocreate
  notifempty
}
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/syslog-ng
/var/log/audit.log
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure {
  missingok
  notifempty

  sharedscripts

  postrotate
    /etc/init.d/syslog-ng reload > /dev/null 2>&1 || true
  endscript
}

# This covers rotating the UDP network host example and is fine to leave
# enabled even on machines not acting as a loghost.
/var/log/network/*/system.log {
  missingok

  # Keep three months of logs for each host
  rotate 90

  # Keep the file in the same directory as the host, but only bother rotating
  # them if we have some content from them
  nocreate
  notifempty
  noolddir

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
chmod 0660 /mnt/gentoo/var/log/lastlog
chmod 0664 /mnt/gentoo/var/log/wtmp

# Genkernel isn't used by these builds but this file persists, lets get rid of
# it for a nice clean root.
rm -f /mnt/gentoo/var/log/genkernel.log
