#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring firewall options"

# Generally enable the ability to perform kernel firewalling
#kernel_config --enable NETFILTER

# TODO: Generally for the firewalls I make use of, I don't actually need
# connection tracking. This likely needs to be moved into something specific.
#kernel_config --enable NF_CONNTRACK

# Personal preference or livin' in the future, you decide but I'm only support
# nftables instead of iptables
#kernel_config --enable NF_TABLES
#kernel_config --enable NF_TABLES_SET
#kernel_config --enable NF_TABLES_INET
#kernel_config --enable NFT_LOG
#kernel_config --enable NFT_REJECT

# TODO: Selective requirement... but allow matching on IPSec policies
#kernel_config --enable NFT_XFRM
