
# Which block device to use as the root filesystem, specify two separated with
# a space for a raid setup.
DISK="/dev/vda"

# Should provide two disks in the 'DISK' variable separated with a space if
# this is set to yes.
RAID="no"

# Whether to attempt to run the entire installation without making an external
# network connection, instead this will use the configured NFS server
LOCAL="${LOCAL:-no}"

# When specified, this will mount an NFS directory specified. When run in local
# mode this will be used to source installation files, otherwise it'll be used
# to cache installation files.
NFS_SOURCE="192.168.122.1"

# When provided the install will configure and attempt to source compiled
# packages from the following location. This can drastically speed up the
# install time if matching packages are available.
BIN_HOST="http://${NFS_SOURCE}:8200/binpkgs"

# Whether or not to use UEFI or a normal boot shim
EFI="yes"

# Whether to encrypt the root partition and the swap partition. Encrypted
# mechanism is a work in process as there needs to be an initramfs to handle
# it.
ENCRYPTED="no"

# Whether or not to rebuild all packages once the profile has been selected.
FULL_REBUILD="no"

# Which of the pre-generated kernel configs to use
KERNEL_TARGET="kvm_guest"

# Serpent is slower but a more conservative security wise, AES is fast and
# generally hardware accelerated...
#CIPHER="serpent-xts-plain64"
CIPHER="aes-xts-plain64"
HASH="sha512"
KEY_SIZE="512"

HOST_NAME="looming-spring-waterfall.0x378.net"

ADMIN_NAME="Sam Stelfox"
ADMIN_USER="sstelfox"

# What user we'll use to source the SSH public keys for the ADMIN_USER account.
GITHUB_KEY_USER="sstelfox"

# Set this to "true" to log all executed commands to the screen.
DEBUG="${DEBUG:-}"

BASE_DIRECTORY="$( cd "$(dirname $( dirname "${BASH_SOURCE[0]}" ))" && pwd )"

# When installing from an arch minimal ISO the path is really weird and
# prevents things like emerge from finding sed and bzip which is really
# annoying...
export PATH="/sbin:/bin:/usr/sbin:/usr/bin"
