* Review all log rotation configs for each service
* Embed configs into the Gentoo directory instead of pulling them via my
  website
* Update syslog-ng config to latest version
* Test watchdog to make sure it properly resets VMs on service failures

* Make bare minimum custom initramfs (manual build, do I want a rescue shell?)
* Make custom microcode initramfs (manual build)
* Script initramfs build and combination
* Embed built initramfs in kernel
* Automate the kernel/initramfs into VM build

* Embed kernel command line options in the kernel itself
* Drop grub in favor of using EFI directly
* Figure out EFI key management
* Test signing of EFI binaries in libvirt (test the hello world binaries)
* Start signing Linux kernel
* Can I embed EFI certificates in the UEFI loader from VM creation?

* Take control of TPM ownership automatically
* Investigate boot measurements, sealing, etc

* Get LUKS working in custom initramfs
* Embed TPM tooling in custom initramfs
* Make LUKS & TPM tooling conditional on whether the system has an encrypted
  hard drive.
* Get clevis/tang or something equivalent working in custom initramfs

* Review auditd rules

* Document and review the SELinux strict policies and how things are supposed to be used
* Set SELinux to enforcing
