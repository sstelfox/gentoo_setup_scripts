#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

exit 0

# TODO (this whole file really)

cat << 'EOF' > /mnt/gentoo/etc/portage/package.accept_keywords/tpm_handling
app-crypt/tpm2-abrmd ~amd64
app-crypt/tpm2-tools ~amd64
app-crypt/tpm2-tss ~amd64
EOF

chroot /mnt/gentoo emerge app-crypt/tpm2-abrmd app-crypt/tpm2-tools

# Might be useful:
# * app-crypt/tpm2-totp
# * app-crypt/tpm2-tss-engine

# Alright so tpm2-abrmd needs dbus... And that's something I definitely want to
# go through the configuration and hardening of but I haven't yet (TODO). It
# also seems like tpm-abrmd doesn't properly depend on dbus even though it'll
# fail to start if the dbus daemon isn't running.

# Note: I may want this to be a boot target instead of a default target
chroot /mnt/gentoo rc-update add dbus default
