#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Use NFTables...
chroot /mnt/gentoo emerge net-firewall/nftables

cat << 'EOF' > /mnt/gentoo/etc/conf.d/nftables
# /etc/conf.d/nftables

NFTABLES_SAVE="/var/lib/nftables/rules-save"
SAVE_OPTIONS="-n"
SAVE_ON_STOP="no"
EOF

cat << 'EOF' > /mnt/gentoo/var/lib/nftables/rules-save
# /var/lib/nftables/rules-save

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    # Drop invalid connections
    ct state invalid drop

    # Allow established and related connections
    ct state established,related accept

    # Allow traffic crossing the loopback interface
    iif "lo" accept

    ip protocol icmp icmp type { destination-unreachable, echo-request, parameter-problem, time-exceeded } accept

    # IPv6 routers will also want: nd-router-solicit
    ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, packet-too-big, parameter-problem, time-exceeded } accept

    # SSH (port 22 locally and my alt port everywhere)
    ip saddr 192.168.122.0/24 tcp dport 22 accept
    tcp dport 2200 accept

    # IPv4 DHCP
    ip protocol tcp tcp dport 67 tcp sport 68 accept

    # Probably don't want this on production systems but great for
    # diagnostics...
    #ct state new log level warn prefix "ingress attempt: "
    counter
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy drop;

    # Allow established and related connections
    ct state established,related accept

    # Allow traffic crossing the loopback interface
    oif "lo" accept

    ip protocol icmp icmp type { echo-request, echo-reply } accept

    # IPv6 routers will also want: nd-router-advert, packet-too-big, time-exceeded
    ip6 nexthdr icmpv6 icmpv6 type { echo-request, echo-reply, nd-router-solicit, nd-neighbor-solicit, nd-neighbor-advert, parameter-problem } accept

    # Allow IPv4 DHCP
    tcp dport 67 tcp sport 68 accept

    # Allow HTTP, HTTPS, and rsync protocols, for updating. Could be restricted
    # with a dedicated update server and/or web proxies.
    tcp dport { 80, 443, 873 } accept

    # Allow SSH'ing into other local boxes once you're on one, this is libvirt specific
    # TODO: This should be whatever local network the box is on
    ip daddr 192.168.122.0/24 tcp dport 22 accept

    # Allow connecting to the NFS portage share, this is libvirt specific
    # TODO: This should be whatever the local build box share is
    ip daddr 192.168.122.1 tcp dport 2049 accept

    # Allow DNS, could be restricted with a local recursive resolver
    tcp dport 53 accept
    udp dport 53 accept

    # Allow NTP, probably not needed in KVM guests...
    udp dport 123 accept

    # Logging attempts to leave the host are either hostile, or a
    # misconfiguration of something. Either way they should be logged and
    # addressed.
    ct state new log level warn prefix "egress attempt: "
    counter reject with icmp type admin-prohibited
  }
}
EOF

chroot /mnt/gentoo rc-update add nftables default
