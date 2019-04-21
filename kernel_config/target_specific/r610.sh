#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

./target_specific/intel.sh

log "Running target specific kernel options: r610"

# Support ECC memory
kernel_config --enable MEMORY_FAILURE
kernel_config --enable HWPOISON_INJECT

kernel_config --enable NET_VENDOR_BROADCOM
kernel_config --enable BNX2

# This isn't supported on this platform so don't bother
kernel_config --disable PCIEASPM

# There is a PCI address collision on the R610 motherboard. We need to enable
# the quirk workarounds for it.
kernel_config --enable PCI_QUIRKS

kernel_config --enable WDAT_WDT
kernel_config --enable ACPI_IPMI
kernel_config --enable IPMI_HANDLER
kernel_config --enable IPMI_SI
kernel_config --enable IPMI_SSIF
kernel_config --enable IPMI_WATCHDOG

kernel_config --enable DCDBAS

kernel_config --enable CHR_DEV_SCH
kernel_config --enable CHR_DEV_ST
kernel_config --enable SCSI_LOWLEVEL
kernel_config --enable SCSI_SCAN_ASYNC

kernel_config --enable RAS_CEC

kernel_config --enable FUSION
kernel_config --enable FUSION_SAS

kernel_config --enable USB_PRINTER
kernel_config --enable USB_UAS

# TODO: Is this useful?
#kernel_config --enable SCSI_SAS_ATTRS

# If I start using iSCSI stuff
#kernel_config --enable SCSI_ISCSI_ATTRS
#kernel_config --enable ISCSI_TCP
