#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling various networking components"

# My servers don't need Ham radio options
kernel_config --disable HAMRADIO

# This may get re-enabled on a system specific basis later on, but generally
# for what I build kernels for I don't need wireless support.
kernel_config --disable RFKILL
kernel_config --disable WLAN
kernel_config --disable WIRELESS




# This IPSec mode isn't ever needed for me
#kernel_config --disable INET_XFRM_MODE_BEET
#kernel_config --disable INET6_XFRM_MODE_BEET

# We don't need IPv6 in IPv4 tunneling
#kernel_config --disable IPV6_SIT

# TODO: If the physical hardware supports it, offload the packet timestamping
# to it. This isn't useful for VMs but should be enabled for physical hardware.
#kernel_config --enable NETWORK_PHY_TIMESTAMPING

# Allow routing of packets (definitely for IPv4, likely needed for IPv6 as
# well)
#kernel_config --enable IP_ADVANCED_ROUTER

# This may belong in the security section, but this is more networking IMHO.
# These can protect against a class of DoS attack.
#kernel_config --enable SYN_COOKIES

# Change the congestion control to use a more modern algorithm
#kernel_config --enable TCP_CONG_ADVANCED

# While router preference support is an optional extension, it can help pick
# routers. If there aren't any high priority routers in the network (such as
# default/normal only routers) and attacker may be able to abuse this to force
# traffic through them. TODO: Figure out if I should use this
#kernel-config --enable IPV6_ROUTER_PREF

# Allow autoconfigured IPv6 addresses to be used faster.
#kernel_config --enable IPV6_OPTIMISTIC_DAD

# TODO: Select advanced congestion control algorithm
# Networking support -> Networking options -> TCP/IP networking -> TCP: advanced congestion control

# Need: SECURITY, SECURITY_PATH, SECURITY_NETWORK
