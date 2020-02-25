#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# TODO: Sample server config, probably restrict default config a bit more,
# enable authentication, statistics, and logging. Setup control and control
# authentication.

echo 'net-misc/ntpsec early smear' > /mnt/gentoo/etc/portage/package.use/ntpsec
chroot /mnt/gentoo emerge net-misc/ntpsec

cat << 'EOF' > /mnt/gentoo/etc/ntp.conf
# /etc/ntp.conf

# Query the US pools for faster and better synchronization
pool 0.us.pool.ntp.org iburst
pool 1.us.pool.ntp.org iburst
pool 2.us.pool.ntp.org iburst

# Allow exchanging time with everyone, but don't allow configuration
restrict default kod limited nomodify nopeer noquery
restrict -6 default kod limited nomodify nopeer noquery

# Local users have additional access to the NTP server, maybe I don't want this
# either
restrict 127.0.0.1
restrict -6 ::1

# Where the service records the frequency of the local clock oscillator and its
# divergence from true over time
driftfile /var/lib/ntp/ntp.drift
EOF

chroot /mnt/gentoo rc-update add ntp default

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
