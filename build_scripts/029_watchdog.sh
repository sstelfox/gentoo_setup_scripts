#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

emerge sys-apps/watchdog

cat << EOF > /mnt/gentoo/etc/watchdog.conf
# /etc/watchdog.conf

watchdog-device = /dev/watchdog

# How often in seconds to check the watchdog device. The kernel will reboot the
# system if this exceeds 60 seconds.
interval = 15

# This may be dangerous but ensures the watchdog runs with the highest priority
# over system processes. This ensures the watchdog runs but will take away
# compute time from core processes.
priority = 1
realtime = yes

# This is memory based on page size (which on the systems I've tested are all
# 4Kb). 512 pages is 2Mb. If there isn't two megabytes availble something very
# bad has gone wrong or the system is overwhelmed.
#
# If the complex system overall is also unhealthy this may cause a chain
# reaction of failures, but it is the responsibility of the administrators to
# not let the complex architecture they're responsible for get that bad.
min-memory = 512
allocatable-memory = 512

# These are pretty crazy high thresholds, if the load ever gets this high the
# system is wildly overloaded and needs to be reset (Note: I have the 1 minute
# disabled).
max-load-1 = 0
max-load-5 = $(($(nproc) * 5))
max-load-15 = $(($(nproc) * 3))

# Ensure the processes defined in the pidfiles here are running. If they fail,
# crash, or are shutdown for too long we need to reset the system. This could
# be a system fault, or it could be due to an attack.
pidfile = /var/run/crond.pid
pidfile = /var/spool/postfix/pid/master.pid
pidfile = /var/run/sshd.pid
pidfile = /var/run/syslog-ng.pid

# If we trust the network more than we trust the stability of the system, we
# can perform a soft reboot when the gateway isn't available.
#ping = 10.64.0.1
#interface = eth0
EOF

chroot /mnt/gentoo rc-update add watchdog default
