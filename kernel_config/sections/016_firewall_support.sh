#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring firewall options"

kernel_config --enable NETFILTER_ADVANCED
#kernel_config --enable IP_SET
#kernel_config --enable IP_SET_HASH_IP

# TODO: Generally for the firewalls I make use of, I don't actually need
# connection tracking, but some other features may depend on it...
kernel_config --disable NF_CONNTRACK

# Personal preference or livin' in the future, you decide but I only support
# nftables on my systems at this point
kernel_config --enable NF_TABLES
kernel_config --enable NF_TABLES_SET
kernel_config --enable NF_TABLES_INET
kernel_config --enable NFT_LOG
kernel_config --enable NFT_REJECT

# Not needed for any of my internet connections, great description though
kernel_config --disable NETFILTER_XT_TARGET_TCPMSS

# These are local, broadcast, and multicast traffic types...
kernel_config --disable NETFILTER_XT_MATCH_ADDRTYPE

# A couple of options that I may want in the future
#kernel_config --enable NFT_LIMIT
#kernel_config --enable NFT_SOCKET
#kernel_config --enable NFT_TUNNEL
#kernel_config --enable NFT_XFRM
#kernel_config --enable NETFILTER_XT_SET

kernel_config --disable LOG_ARP
kernel_config --disable IP_NF_MANGLE
kernel_config --disable IP6_NF_MANGLE

#kernel_config --enable NF_SOCKET_IPV4
#kernel_config --enable NF_SOCKET_IPV6
#kernel_config --enable NF_TABLES_ARP
#kernel_config --enable IP_NF_SECURITY
#kernel_config --enable IP6_NF_SECURITY
