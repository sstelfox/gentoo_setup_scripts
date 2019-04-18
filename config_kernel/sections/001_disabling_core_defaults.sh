#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Disabling selective core default features"

# TODO: I've never been sure about this. It probably makes sense for a VM host
# but does this help me or do anything at all under normal workloads? Maybe for
# forked processes? Needs additional research.
#kernel_config --disable KSM

# This is specifically virtual hosting (allowing guests to run under this
# kernel). Generally my kernels are used more as guests and thus don't need
# this whole class of options.
kernel_config --disable VIRTUALIZATION

# This is a legacy compatibility layer I won't be using
kernel_config --disable USELIB

# For servers and server workloads we want to disable kernel preemption to
# allow it to prioritise work over an interactive session's latency.
kernel_config --enable PREEMPT_NONE
kernel_config --disable PREEMPT_VOLUNTARY

# Don't support some obscure extended platforms
kernel_config --disable X86_EXTENDED_PLATFORM

# I don't need core dumps and they may reveal sensitive memory contents
kernel_config --disable CRASH_DUMP

kernel_config --enable EXPERT
kernel_config --disable ELF_CORE

# No. Just No.
kernel_config --disable PCSPKR_PLATFORM
kernel_config --disable I8253_LOCK

# This is an interesting feature but can allow unprivileged triggering of
# certain behaviors such as hard rebooting. The kernels are stable enough that
# the magic sequences have the potential for more harm than good.
kernel_config --disable MAGIC_SYSRQ
kernel_config --disable MAGIC_SYSRQ_SERIAL
kernel_config --undefine MAGIC_SYSRQ_DEFAULT_ENABLE

# These compression methods aren't ever used by me, eventually I'll likely want
# to disable LZ4 as well when I embed the initramfs CPIO file in the kernel
# itself for EFI but until then it's the only one I need.
kernel_config --disable RD_BZIP2
kernel_config --disable RD_GZIP
kernel_config --disable RD_LZMA
kernel_config --disable RD_LZO
kernel_config --disable RD_XZ

# Use LZ4 to compress the kernel instead of the Gzip default
kernel_config --disable KERNEL_GZIP
kernel_config --enable KERNEL_LZ4

# Because we don't need to decompress a initramfs or the kernel with any of
# these algorithms we can also remove the support for them inside the kernel.
kernel_config --disable DECOMPRESS_BZIP2
kernel_config --disable DECOMPRESS_GZIP
kernel_config --disable DECOMPRESS_LZMA
kernel_config --disable DECOMPRESS_LZO
kernel_config --disable DECOMPRESS_XZ
