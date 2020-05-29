#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

cat << 'EOF' >> /mnt/gentoo/etc/security/limits.conf
# /etc/security/limits.conf

# Ensure the default priority is 0 for all processes
*       soft    priority   0

# Prevent core files from being generated by default but allow them to be
# temporarily enabled when needed with the command `ulimit -c unlimited`.
*       soft    core       0
*       hard    core       unlimited

# Prevent non-root users from running at minimal niceness, while still allowing
# root to fix the system when unresponsive.
*       hard    nice       -19
root    hard    nice       -20

# Place a generally safe limit on process's ability to open files. This may
# need tweaking for some specific processes
*       hard    nofile     8192

# Place a restrictions on the simulataneous number of processes running under
# any individual user. Some processes may require additional processes so this
# may need to be selectively lifted. We give the administrative users a bit
# higher default and root relatively unlimited (though not actually).
*       soft    nproc      1024
*       hard    nproc      2048

@adm    soft    nproc      2048
@adm    hard    nproc      65536

root    soft    nproc      65536
root    hard    nproc      65536
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/fs_hardening.conf
# Restrict the maximum size of file handles and inodes from unlimited to a
# still incredibly high number, but protect against certain forms of memory
# exhaustion.
fs.file-max = 2097152

# Provide protection against ToCToU races
fs.protected_fifos = 2
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1

# Prevent SUID executables from creating core dumps, should be set to '2' if an
# administrator needs a dump from one of these executables
fs.suid_dumpable = 0
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/kernel_hardening.conf
# By default the Linux kernel will enable any line disciplines requested which
# is a potential security issue
dev.tty.ldisc_autoload = 0

# Prevent unprivileged users from viewing the dmesg output
kernel.dmesg_restrict = 1

# I may want to support kexec'ing kernels in the future, but until then disable
# the call.
kernel.kexec_load_disabled = 1

# Make locating kernel addresses more difficult
kernel.kptr_restrict = 2

# Retrict perf calls to only be done by root
kernel.perf_event_paranoid = 2

# Disable the magic sysrq key
kernel.sysrq = 0

# Prevent unprivileged use of BPF for generic hooks and networking programmings
net.core.bpf_jit_harden = 2
kernel.unprivileged_bpf_disabled = 1

# Disable unprivileged use of userspace namespaces. If I use unprivileged
# podman containers I'll need to allow this.
kernel.unprivileged_userns_clone = 0

# Set ptrace protections (can't be 3 as gentoo build sandbox uses ptracing)
kernel.yama.ptrace_scope = 2

# Increase the bits of entropy used for the kernel ASLR. There is a compat
# control as well but that only applies to 32 bit compatible applications which
# are not supported by my kernel.
vm.mmap_rnd_bits = 32
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/net_hardening.conf
# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Ignore source-routed packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log spoofed, source-routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Reverse path filtering to help protect against IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Don't allow traffic between networks or act as a router
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Ignore ICMP redirects from non-GW hosts
net.ipv4.conf.all.secure_redirects = 1
net.ipv4.conf.default.secure_redirects = 1

# Don't allow traffic to traverse the system interfaces (will need to change
# for systems that actually route traffic)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.mc_forwarding = 0
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.default.mc_forwarding = 0

# Don't respond to garbage ICMP errors or broadcast pings
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Increase the available port range for connections
net.ipv4.ip_local_port_range = 16384 65535

# Increase the default backlog size for SYNs, even with syncookies these can be
# exhausted.
net.ipv4.tcp_max_syn_backlog = 4096

# Reduce the time that the kernel holds on to connections that have are in the
# FIN state. This helps prevent certain forms of exhaustion attacks.
net.ipv4.tcp_fin_timeout = 15

# Implement informational RFC1337, this helps prevent against TIME_WAIT
# assasination and corruption of connections.
net.ipv4.tcp_rfc1337 = 1

# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1

# Reduce the TCP keepalive setting to prevent various DoS attacks
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 300

# Disable TCP timestamps to avoid minor leaks of system information
net.ipv4.tcp_timestamps = 0

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

# TCP window scaling may cause issues if upstream routers or firewalls don't
# support it but it can drastically improve the performance of network
# connections.
net.ipv4.tcp_window_scaling = 1

# Allow negotiation of selective TCP ACK negotiation. This will only be used on
# remote hosts that support it but can also improve back and forth performance
# by requiring fewer packets in general.
net.ipv4.tcp_sack = 1

## Settings for Static IPv6 Addresses:

# Configuration for static IPv6 settings, this prevents a significant number of
# potential attacks.

# In static environments we don't need to accept router advertisements
#net.ipv6.conf.default.accept_ra = 0

# When we're statically configured, we shouldn't send any router solicitations
# as the information isn't useful to us.
#net.ipv6.conf.default.router_solicitations = 0

# When statically configured don't attempt any kind of auto configuration
#net.ipv6.conf.default.autoconf = 0

# We shouldn't need to check if our address is available on statically
# configured interfaces. If something else is using it must've been dynamic and
# will have to get off our address.
#net.ipv6.conf.default.dad_transmits = 0

# Don't accept the router preference field
#net.ipv6.conf.default.accept_ra_rtr_pref = 0

# Don't accept hop limit settings from router advertisements
#net.ipv6.conf.default.accept_ra_defrtr = 0

# Limit the maximum global addresses on individual interfaces, the only edge
# case this shouldn't be enabled is when privacy addresses with expiration is
# on. Link local addresses do not count toward this.
#net.ipv6.conf.default.max_addresses = 1

## Settings for Dynamic IPv6 Addresses:

# Privacy address settings (optional) can prefer outbound connections to use
# changing 'privacy' addresses. A static address can still be set on the
# interface for normal inbound operations. Unless the firewall is configured to
# prevent it services will also be available on the additional privacy
# addresses.
#
# These should only be enabled on servers when a static address is set.
# Otherwise the server will close connections once temp_valid_lft, and move to
# an unpredictable address.
#
# Note: When adjusting these values there are a couple things to consider:
#         * temp_valid_lft should be > than temp_prefered_lft
#         * max_desync_factor should be < (0.5 * temp_prefered_lft)
#         * max_addresses should be a minimum of:
#             2 + roundup(temp_valid_ft / temp_preferred_lft)
#           This accounts for the static address (1), the potential delay of
#           the lifetime by the desync factor (1), and the maximum temporary
#           active addresses the machine can have at once.
net.ipv6.conf.all.addr_gen_mode = 3
net.ipv6.conf.all.max_addresses = 5
net.ipv6.conf.all.max_desync_factor = 600
net.ipv6.conf.all.temp_prefered_lft = 7200
net.ipv6.conf.all.temp_valid_lft = 14400
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.addr_gen_mode = 3
net.ipv6.conf.default.max_addresses = 5
net.ipv6.conf.default.max_desync_factor = 600
net.ipv6.conf.default.temp_prefered_lft = 7200
net.ipv6.conf.default.temp_valid_lft = 14400
net.ipv6.conf.default.use_tempaddr = 2
EOF

cat << EOF > /mnt/gentoo/etc/sysctl.d/swap_tuning.conf
# Reduce default swappiness, this is a much better default for servers,
# especially databases. A value of 0 is never recommended.
vm.swappiness = 10

# Define at what percentage of total memory is dirty do we begin writing it
# out. These values are tuned for more database oriented workloads, but should
# be generally good on servers in general.
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3

vm.overcommit_memory = 0
vm.overcommit_ratio = 50
EOF
