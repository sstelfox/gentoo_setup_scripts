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

template t_raw_message {
  template('${MESSAGE}\n');
};


### Network Server & Client Logging

# NOTE: There are two network sources, syslog() and network(). network()
# handles RFC3164 and RFC5424 syslog message formats with or without framing.
# syslog() appears to only accept framed messages in RFC5424. syslog() defaults
# to port 601/tcp, network() default to port 514/tcp.
#
# NOTE: By specifying IPv6 the port will bind to both protocols instead of just
# IPv4
#
#source networkSrc {
#  network(ip-protocol(6) transport(tcp));
#  network(ip-protocol(6) transport(udp));
#
#  # Optional TLS mechanism for receiving logs encrypted and/or authenticated
#  #network(
#  #  ip-protocol(6)
#  #  port(6514)
#  #  transport(tls)
#  #
#  #  tls(
#  #    cert-file(/etc/syslog-ng/server.crt)
#  #    key-file(/etc/syslog-ng/server.key)
#  #
#  #    # Directory containing certificates in the PEM format that are
#  #    # considered trusted signers for authentication.
#  #    ca-dir(/etc/syslog-ng/ca.d)
#  #
#  #    # A custom suite of accepted ciphers, this is based on the version of
#  #    # openssl used by syslog-ng.
#  #    #cipher-suite('ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384')
#  #
#  #    # Other use parameters...
#  #    #dhparam-file(...)
#  #    #ecdh-curve-list('prime256v1:secp384r1')
#  #
#  #    # Disable mutual authentication, but if the client presents a
#  #    # certificate ensure its valid. Default is 'required-trusted'
#  #    #peer-verify(optional-trusted)
#  #  )
#  #);
#};
#destination networkLogs { file(/var/log/network/$HOST/system.log create-dirs(yes)); };
#log { source(networkSrc); destination(networkLogs); };

# NOTE: Due to the 'final' flags later on in the config, any network based
# senders need to be configured before the local destinations.
#
#destination centralLogServer {
#  network('10.64.0.120'
#    ip-protocol(6)
#    port(514)
#    transport(tcp)
#
#    # TODO: Transport could be switched to TLS by adjusting the transport(),
#    # and matching the tls() configs in the sample network server above. This
#    # requires a certificate authority and distribution of client certificates.
#
#    # Ensure any reload/restarts on server or client, or ephemeral network
#    # issues do not cause us to lose messages.
#    disk-buffer(
#      mem-buf-size(10000)
#      disk-buf-size(2000000)
#      reliable(yes)
#    )
#  );
#};
#log { source(local); destination(centralLogServer); };


### Handle the auditd syslog events to dedicated files, and prevent them from
### going anywhere else.

destination auditFile { file(/var/log/audit.log template(t_raw_message)); };
destination avcFile { file(/var/log/avc.log template(t_raw_message));   };
filter auditLogs { level(info) and facility(local6) and program(audispd); };

# NOTE: I don't believe AVC messages are getting grabbed by this...

log {
  source(local);

  filter(auditLogs);

  if (message('type=AVC')) {
    destination(avcFile);
  } else {
    destination(auditFile);
  };

  flags(final);
};


### General logging configuration that matches the standard RHEL rsyslog
### config.

destination messageFile { file(/var/log/messages); };
filter messages { level(info) and not (facility(mail, authpriv, cron)); };
log { source(local); filter(messages); destination(messageFile); };

destination secureFile { file(/var/log/secure); };
filter authpriv { facility(authpriv); };
log { source(local); filter(authpriv); destination(secureFile); };

destination mailFile { file(/var/log/maillog); };
filter mail { facility(mail); };
log { source(local); filter(mail); destination(mailFile); flags(final); };

destination cronFile { file(/var/log/cron); };
filter cron { facility(cron); };
log { source(local); filter(cron); destination(cronFile); };

destination spoolFile { file(/var/log/spooler); };
filter spool { facility(uucp) or (facility(news) and level(crit)); };
log { source(local); filter(spool); destination(spoolFile); };

destination bootFile { file(/var/log/boot.log); };
filter boot { facility(local7); };
log { source(local); filter(boot); destination(bootFile); };


### Send all system emergency messages to all users

destination allUsers { usertty('*'); };
filter emergency { level(emerg) and not (facility(mail)); };
log { source(local); filter(emergency); destination(allUsers); };


### Diagnostic Logging

# I can't help but think there are some important logs being missed... This
# diagnostic coding can allow me to track down missing logs locally when I need
# to find those and where they're coming from. Worth noting that
#
#template t_diagnostic {
#  template('f:${FACILITY}/l:${LEVEL}/s:${SOURCE}/prog:${PROGRAM}/pid:${PID} - ${ISODATE} ${HOST} ${MSGHDR}${MESSAGE}\n');
#};
#destination allLogs { file(/var/log/all template(t_diagnostic); };
#log { source(local); destination(allLogs); };
EOF

chmod 0600 /mnt/gentoo/etc/syslog-ng/syslog-ng.conf

cat << 'EOF' > /mnt/gentoo/etc/logrotate.conf
# /etc/logrotate.conf

# Rotate logs daily and keep a week's worth of them. System logs should be
# centrally managed with copies of logs that persist much longer than on the
# individual systems. Keeping one week of logs should handle non-security
# related situations. When a security event occurs we should compare these
# against centrally stored logs for evidence of tampering.
daily
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
  rotate 3
}

/var/log/btmp {
  create 0600 root utmp
  missingok

  monthly
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
  notifempty
}
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/elog-save-summary
/var/log/emerge.log
/var/log/emerge-fetch.log
/var/log/portage/elog/summary.log {
  create 0600 portage portage
  missingok
  notifempty
}
EOF

cat << 'EOF' > /mnt/gentoo/etc/logrotate.d/syslog-ng
/var/log/audit.log
/var/log/avc.log
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler {
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
  daily
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
