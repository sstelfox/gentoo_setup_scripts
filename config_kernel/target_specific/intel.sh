#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

${BASE_DIRECTORY}/target_specific/physical_system.sh

kernel_config --enable INTEL_IDLE
kernel_config --enable X86_INTEL_PSTATE
kernel_config --enable X86_P4_CLOCKMOD

kernel_config --enable CONFIG_MICROCODE
kernel_config --enable CONFIG_MICROCODE_AMD
kernel_config --enable CONFIG_MICROCODE_INTEL

kernel_config --enable HW_RANDOM_INTEL

kernel_config --enable INTEL_IOMMU
kernel_config --enable INTEL_TXT

kernel_config --enable MTRR
kernel_config --enable SCHED_MC_PRIO

kernel_config --enable X86_INTEL_MEMORY_PROTECTION_KEYS
kernel_config --enable X86_INTEL_MPX
kernel_config --enable X86_MCE_INTEL

kernel_config --enable PERF_EVENTS_INTEL_CSTATE
kernel_config --enable PERF_EVENTS_INTEL_RAPL
kernel_config --enable PERF_EVENTS_INTEL_UNCORE

# Optimize the kernel with newer Intel instructions
kernel_config --disable GENERIC_CPU
kernel_config --enable MCORE2
