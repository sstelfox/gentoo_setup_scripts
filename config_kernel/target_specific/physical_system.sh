#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

kernel_config --enable ENERGY_MODEL
kernel_config --enable KSM
kernel_config --enable SFI
kernel_config --enable WQ_POWER_EFFICIENT_DEFAULT
kernel_config --enable X86_ACPI_CPUFREQ

kernel_config --disable CPU_FREQ_DEFAULT_GOV_PERFORMANCE
kernel_config --enable CPU_FREQ_DEFAULT_GOV_SCHEDUTIL

kernel_config --disable CPU_FREQ_GOV_PERFORMANCE
kernel_config --enable CPU_FREQ_GOV_CONSERVATIVE

kernel_config --enable ACPI_AC
kernel_config --enable ACPI_BATTERY
kernel_config --enable ACPI_FAN
kernel_config --enable ACPI_PCI_SLOT
kernel_config --enable ACPI_PROCESSOR_AGGREGATOR

kernel_config --enable NETWORK_PHY_TIMESTAMPING

# Support ECC memory
kernel_config --enable MEMORY_FAILURE
kernel_config --enable HWPOISON_INJECT
