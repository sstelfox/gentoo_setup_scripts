#/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Don't use on everything
exit 0

chroot /mnt/gentoo emerge app-portage/repoman dev-util/catalyst
