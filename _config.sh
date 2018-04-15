DISK="/dev/vda"

# Whether or not to use UEFI or a normal boot shim
EFI="no"

# Whether to encrypt the root partition and the swap partition. Encrypted
# mechanism is a work in process as there needs to be an initramfs to handle
# it.
ENCRYPTED="no"

# Whether or not to rebuild all packages once the profile has been selected.
FULL_REBUILD="no"

# Which of the pre-generated kernel configs to use
KERNEL_CONFIG="kvm"

# Serpent is slower but a more conservative security wise, AES is fast and
# generally hardware accelerated...
#CIPHER="serpent-xts-plain64"
CIPHER="aes-xts-plain64"
HASH="sha512"
KEY_SIZE="512"

HOST_NAME="unprovisioned-base-image.stelfox.net"

ADMIN_NAME="Sam Stelfox"
ADMIN_USER="sstelfox"

# What user we'll use to source the SSH public keys for the ADMIN_USER account.
GITHUB_KEY_USER="sstelfox"

# Set this to "true" to log all executed commands to the screen.
DEBUG=""

BASE_DIRECTORY="$( cd "$(dirname $( dirname "${BASH_SOURCE[0]}" ))" && pwd )"

# When installing from an arch minimal ISO the path is really weird and
# prevents things like emerge from finding sed and bzip which is really
# annoying...
export PATH="/sbin:/bin:/usr/sbin:/usr/bin"
