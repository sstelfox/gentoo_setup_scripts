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

kernel_config --enable CPU_ISOLATION

# Only root should be able to access dmesg
kernel_config --enable SECURITY_DMESG_RESTRICT

# For TPM and IMA support the securityfs filesystem needs to be enabled
kernel_config --enable SECURITYFS

# Perform additional checks when copying memory between the userspace and the
# kernel. This protects against large classes of heap overflow exploits and
# memory exposures.
kernel_config --enable HARDENED_USERCOPY

# Provide additional protection on string and memory functions when the
# compiler is aware of buffer sizes.
kernel_config --enable FORTIFY_SOURCE

# Validate the stack when things are scheduled
kernel_config --enable SCHED_STACK_END_CHECK

# TODO: I really want to test this to see if I can restrict all the contents to
# a signed on boot initramfs. This would prevent loading modules post-boot, but
# I vastly prefer static kernel anyways.
#kernel_config --enable SECURITY_LOADPIN
