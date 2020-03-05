#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge --update --newuse net-misc/chrony
chroot /mnt/gentoo rc-update add chronyd default

chroot /mnt/gentoo chronyc keygen 1337 SHA256 256 > /mnt/gentoo/etc/chrony.keys
chmod 0600 /mnt/gentoo/etc/chrony.keys

# Note: For best architecture design while using public servers, internal
# servers that are relaying the public server's time should likely be using
# ntpd as it supports public certificate authentication of public servers while
# chronyd doesn't. Chronyd itself is in general better as an internal system
# against trusted or authenticated sources. These authenticated sources need to
# use symmetrical encryption with chronyd which is pretty easy and straight
# forward.

cat << 'EOF' > /mnt/gentoo/etc/chrony/chrony.conf
# /etc/chrony/chrony.conf

# Query the US pools for faster and better synchronization
pool 0.us.pool.ntp.org iburst
pool 1.us.pool.ntp.org iburst
pool 2.us.pool.ntp.org iburst

# If connecting to an internal server (use server if just for one) or set of
# servers (use pool if behind DNS, or multiple server entries otherwise). The
# keyfile needs to be specified for the authentication (see the server setting
# below).
#server 10.116.109.101 key 7 iburst trust require
#pool ntp.int.stelfox.net key 7 iburst trust require

# This key file is used for both command authentication as well as client
# authentication. I use the key slot 1337 for commands (yep hahah doesn't
# matter if its guessed, this file is public and authentication still needs to
# happen). Some clients may need SHA1 or *shudder* MD5 authentication.
keyfile /etc/chrony.keys

# Restrict commands to the local system and require authentication. This key
# number should be different than any of the client authentication keys but
# still needs to be in the same `chrony.keys` file.
bindcmdaddress 127.0.0.1
commandkey 1337
cmdallow 127.0.0.1

# Record the rate at which the system clock gains/loses time
driftfile /var/lib/chrony/drift

# Don't jump the clock for leap seconds, skew it out over time (by default 12
# seconds) so we maintain a consistent monitoncailly increasing clock.
leapsecmode slew

# Define which timezone reference is used by the system for determining if a
# leap second exists or not
leapsectz right/UTC

# When serving NTP clients that don't support slewing of seconds I'll want to
# add the following. I have to be careful to only have those clients sync to
# similarly configured servers.
#maxslewrate 1000
#smoothtime 400 0.001 leaponly

# Step the clock for the first three updates if the difference is larger than a
# second (allows quick clock recovery when highly inaccurate).
makestep 1.0 3

# Ensure we sync our clock the hardware one so it is close to accurate between
# reboots
rtcsync

# Keep various logs on the adjustments and measurements of the time
logdir /var/log/chrony
log measurements statistics tracking

# Generate a syslog announcement if the system clock changes over this
# threshold. This can be very important for correlating problematic events.
logchange 0.1

# By default operate in client only mode by specifying a zero to disable the
# server portion
port 0

# To enable server mode comment out the `port 0` line above, and enable the
# following options

# To generate additional keys for clients to authenticate against you can run
# the following commands:
#
# ```
# chronyc keygen $RANDOM MD5 160 >> /etc/chrony.keys
# chronyc keygen $RANDOM SHA1 256 >> /etc/chrony.keys
# chronyc keygen $RANDOM SHA256 256 >> /etc/chrony.keys
# ```
#
# Review the above file to ensure the IDs (first column) don't collide. If
# clients that support MD5, or SHA1 aren't required I would omit those
# respective lines. Clients will need to have a copy of the key with the same
# ID in a similar file. If multiple servers are in use you should share the
# served key IDs across all of them and add the servers to a pool.
#
# In general this should probably be restricted to the minimum required subnet.
# I would go with a zero-trust architecture and might still anyway as there
# isn't much security risk in exposing this service. Ideally I'd want
# authentication here... but for the love of me chronyd doesn't seem to support
# requiring client authentication.
#
#allow 10.0.0.0/8

# Allow clients to use iburst against this server, otherwise allow no more than
# a packet ever 2^1 (2) seconds.
#ratelimit interval 1 burst 16
EOF

# From my personal experience it's good to generally ensure the hardware clock
# doesn't drift to much from true. While the NTP daemon is configured to handle
# this synchronization, it takes a trivial amount of resources to have a cron
# job run periodically to ensure this sync is kept up and redundancies are
# good.
cat << 'EOF' > /mnt/gentoo/etc/cron.daily/hwclock_sync
#!/bin/sh
/sbin/hwclock --utc --systohc
EOF
chmod +x /mnt/gentoo/etc/cron.daily/hwclock_sync
