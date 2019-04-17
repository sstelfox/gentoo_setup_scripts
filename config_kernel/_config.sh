#!/bin/false
# The above is to prevent this file from being executed. It should only be
# sourced.

# When installing from an arch minimal ISO the path is really weird and
# prevents things like emerge from finding sed and bzip which is really
# annoying...
export PATH="/sbin:/bin:/usr/sbin:/usr/bin"

BASE_DIRECTORY="$( cd "$(dirname $( dirname "${BASH_SOURCE[0]}" ))" && pwd )"

# If not empty all commands will be chroot'd into the specified directory
# before being executed.
CHROOT_DIRECTORY="/mnt/gentoo"

# Set this to "yes" to log all executed commands to the screen.
DEBUG="${DEBUG:-yes}"

# Whether to build the kernel with EFI support or not
ENABLE_EFI="yes"

# Used to build up the custom kernel from configuration scripts rather than
# hard coded .config files
KERNEL_TARGET="kvm_guest"
