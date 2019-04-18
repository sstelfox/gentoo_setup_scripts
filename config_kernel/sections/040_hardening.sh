#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Enabling generic hardening options"

# If the kernel panics for any reason, oops out and automatically reboot
kernel_config --enable PANIC_ON_OOPS
kernel_config --set-val PANIC_TIMEOUT 30

# Harden the memory allocator to make it less predictable
kernel_config --enable SLAB_FREELIST_RANDOM
kernel_config --enable SLAB_FREELIST_HARDENED

# Un-seeded randomness could be particularly dangerous depending on how it's
# used. Warning on this and getting into logs is important.
kernel_config --enable WARN_ALL_UNSEEDED_RANDOM

# This won't provide extra security necessarily but allows us to log a rare
# exception type that would otherwise just be a silent reboot.
kernel_config --enable DOUBLEFAULT

# Warn when kernel memory includes writable executable pages
kernel_config --enable DEBUG_WX
