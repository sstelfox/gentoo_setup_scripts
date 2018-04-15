#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Ensure all the packages match the use flags we've set. Not all packages get
# rebuilt when other segments change their use flags...
chroot /mnt/gentoo emerge --update --newuse --deep @world
chroot /mnt/gentoo emerge @preserved-rebuild
chroot /mnt/gentoo emerge --depclean
