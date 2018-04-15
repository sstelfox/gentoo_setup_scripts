#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

cat << EOF >> /mnt/gentoo/etc/security/limits.conf
# /etc/security/limits.conf

@adm    soft    nproc   100
@users  soft    nproc   50

@adm    hard    nproc   200
@users  hard    nproc   200

*       soft    core    0
*       hard    core    0
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/fs_hardening.conf
fs.suid_dumpable = 0
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/net_hardening.conf
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.all.log_martians=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.default.accept_redirects=0
EOF
