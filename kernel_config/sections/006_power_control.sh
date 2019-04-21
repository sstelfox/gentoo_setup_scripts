#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring various power control settings"

kernel_config --enable ACPI_SPCR_TABLE

kernel_config --enable CPU_FREQ_DEFAULT_GOV_PERFORMANCE
kernel_config --disable CPU_FREQ_DEFAULT_GOV_USERSPACE

kernel_config --disable CPU_FREQ_GOV_USERSPACE
kernel_config --disable CPU_FREQ_GOV_ONDEMAND
kernel_config --disable X86_ACPI_CPUFREQ

kernel_config --enable ACPI_WATCHDOG

kernel_config --enable WATCHDOG_HANDLE_BOOT_ENABLE
kernel_config --enable WATCHDOG_NOWAYOUT
kernel_config --enable WATCHDOG_SYSFS
