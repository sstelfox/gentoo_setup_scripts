#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge sys-apps/rng-tools sys-apps/watchdog

cat << 'EOF' > /mnt/gentoo/etc/conf.d/rngd
# /etc/conf.d/rngd

HWRNG_DEVICE="/dev/hwrng"

INCLUDE_ENTROPY_SOURCES="hwrng rdrand"

RDRAND_OPTIONS="use_aes:1"
EOF

# TODO: The postfix master process's pid file prefixes the number with a bunch
# of whitespace for some stupid reason. When the watchdog process reads the
# file it interprts the PID identity as 0, which is a special case that is
# handled by the kernel and will always check as positive.
#
# This unfortunately means that if I want to verify that this core service
# continues to operate, I'll need to write some kind of script, init hook, or
# cron job that extracts the pid to a file that can be read by the watchdog
# process so it can actually check it.
#
# It's probably also worth reviewing all the core system services again once I
# get to the point I'm addressing these TODOs... The core services are already
# pretty locked down but by then they should be even more stable.

cat << EOF > /mnt/gentoo/etc/watchdog.conf
# /etc/watchdog.conf

watchdog-device = /dev/watchdog
watchdog-timeout = 60

# How often in seconds to check the watchdog device. If all the tests pass this
# will update the watchdog process. If the kernel doesn't receive an all clear
# within `watchdog-timeout` seconds, the system will be rebooted. This either
# happens by the kernel or the VM host.
interval = 5

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

# If we trust the network more than we trust the stability of the system, we
# can perform a soft reboot when the gateway isn't available.
#ping = 10.64.0.1
#interface = eth0

# Ensure the processes defined in the pidfiles here are running. If they fail,
# crash, or are shutdown for too long we need to reset the system. This could
# be a system fault, or it could be due to an attack.
pidfile = /var/run/crond.pid
#pidfile = /var/spool/postfix/pid/master.pid
pidfile = /var/run/sshd.pid
pidfile = /var/run/syslog-ng.pid
EOF

if [ ! -f /dev/tpm0 ]; then
  # TODO: Figure out the tpm2-abrmd PID file and append it to the watchdog file
fi

chroot /mnt/gentoo rc-update add rngd default
chroot /mnt/gentoo rc-update add watchdog default
