#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge net-misc/dhcpcd net-misc/iputils sys-apps/iproute2

echo ${HOST_NAME%%.*} > /mnt/gentoo/etc/hostname
echo hostname="${HOST_NAME}" > /mnt/gentoo/etc/conf.d/hostname

cat << EOF > /mnt/gentoo/etc/hosts
# /etc/hosts

127.0.0.1   ${HOST_NAME} ${HOST_NAME%%.*} localhost localhost4
::1         ${HOST_NAME} ${HOST_NAME%%.*} localhost localhost6
EOF

chroot /mnt/gentoo rc-update add hostname boot

cat << 'EOF' > /mnt/gentoo/etc/conf.d/net
# /etc/conf.d/net
modules="iproute2"

# Default DHCP config for interfaces...
dhcp="release nodns nonis nontp"

config_eth0="dhcp"

#config_eth0="10.13.37.250/24"
#routes_eth0="default gw 10.13.37.1"
EOF

cat << 'EOF' > /mnt/gentoo/etc/host.conf
# /etc/host.conf:

# This file contains configuration information specific to the resolver
# library.

# The 'order' keyword specifies how host lookups are to be performed. Valid
# methods are 'bind', 'hosts', and 'nis'. This prefers anything in the hosts
# file over any remote systems.
order hosts, bind

# When the 'multi' option is set to 'on' all IP addresses that have the
# hostname associated with them are returned. When 'off' only the first found
# entry is returned.
multi on
EOF

cat << 'EOF' > /mnt/gentoo/etc/resolv.conf
# /etc/resolv.conf

# Set this host's domain and when no FQDN is provided which domains to query to
# try and find the host requested.
domain devtty.org
search prd.btv.devtty.org devtty.org

# Make DNS resolution fail fast, limit unqualified queries, and change which
# DNS servers we're using per-query. When IPv6 is more supported on the local
# networks I should add the 'inet6' to prefer IPv6 addresses (even going so far
# as to return IPv4 names in their IPv6 forms).
options attempts:2 rotate timeout:1 edns0 no-tld-query

# Configure the nameserver IPs this machine will use
nameserver 8.8.4.4
nameserver 8.8.8.8
EOF

chroot /mnt/gentoo ln -s /etc/init.d/net.{lo,eth0}
chroot /mnt/gentoo rc-update add net.eth0 default
