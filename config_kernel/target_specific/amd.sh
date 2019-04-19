#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

${BASE_DIRECTORY}/target_specific/physical_system.sh

kernel_config --enable AMD_MEM_ENCRYPT
kernel_config --enable PERF_EVENTS_AMD_POWER
kernel_config --enable X86_MCE_AMD

# Optimize the kernel with newer Intel instructions
kernel_config --disable GENERIC_CPU
kernel_config --enable MK8
