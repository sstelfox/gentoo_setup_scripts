#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

# There are a lot of diagnostic flags turned on by default that don't provide
# any runtime diagnostics, and are primarily targetted at kernel developers.
# They usually have a runtime cost associated with them. I disable these to
# squeeze out a bit more performance at very little potential cost to my use
# cases.

log "Disabling unused diagnostic information"

kernel_config --disable BINARY_PRINTF
kernel_config --disable BLK_DEV_IO_TRACE
kernel_config --disable BRANCH_PROFILE_NONE
kernel_config --disable CONTEXT_SWITCH_TRACER
kernel_config --disable CORE_DUMP_DEFAULT_ELF_HEADERS
kernel_config --disable DEBUG_BOOT_PARAMS
kernel_config --disable DEBUG_BUGVERBOSE
kernel_config --disable DEBUG_MEMORY_INIT
kernel_config --disable DEBUG_STACK_USAGE
kernel_config --disable DYNAMIC_EVENTS
kernel_config --disable EARLY_PRINTK_DBGP
kernel_config --disable EARLY_PRINTK_USB
kernel_config --disable EVENT_TRACING
kernel_config --disable FTRACE
kernel_config --disable GENERIC_TRACER
kernel_config --disable KPROBE_EVENTS
kernel_config --disable NOP_TRACER
kernel_config --disable PROBE_EVENTS
kernel_config --disable PROC_VMCORE
kernel_config --disable PROFILING
kernel_config --disable PROVIDE_OHCI1394_DMA_INIT
kernel_config --disable RCU_TRACE
kernel_config --disable RING_BUFFER
kernel_config --disable RUNTIME_TESTING_MENU
kernel_config --disable SCHED_INFO
kernel_config --disable SCHEDSTATS
kernel_config --disable SECTION_MISMATCH_WARN_ONLY
kernel_config --disable SLUB_DEBUG
kernel_config --disable STACKTRACE
kernel_config --disable STRIP_ASM_SYMS
kernel_config --disable TRACE_CLOCK
kernel_config --disable TRACEPOINTS
kernel_config --disable TRACING
kernel_config --disable UPROBE_EVENTS
kernel_config --disable UPROBES
