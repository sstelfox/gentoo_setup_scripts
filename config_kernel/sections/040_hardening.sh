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

# Enable protections against speculative indirect branch prediction attacks in
# the kernel
kernel_config --enable RETPOLINE

# While rare, corruption of lower bytes can indicate faulty hardware, attacks,
# or other things. This also opens a bunch of other security options.
kernel_config --enable X86_CHECK_BIOS_CORRUPTION

# Based on the documentation this is likely only useful on Intel processor but
# may prevent userspace access to more privileged runtime modes.
# TODO: Should this be hardware specific?
kernel_config --enable X86_SMAP

# Allow the kernel functions to live in different address spaces. This makes
# additional security options available and enables them like KASLR.
kernel_config --enable RELOCATABLE

# Add canary values around the stack to assist in detection of certain classes
# of memory overwrite attacks.
kernel_config --enable STACKPROTECTOR

# This is a performance trade of but provides more aggressive protections
# against use-after-free conditions.
kernel_config --enable REFCOUNT_FULL
