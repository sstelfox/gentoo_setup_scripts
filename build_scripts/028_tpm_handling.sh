#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# If there isn't a TPM device skip this section
if [ ! -c /dev/tpm0 ]; then
  exit 0
fi

cat << 'EOF' > /mnt/gentoo/etc/portage/package.accept_keywords/tpm_handling
app-crypt/tpm2-abrmd ~amd64
app-crypt/tpm2-tools ~amd64
app-crypt/tpm2-tss ~amd64
EOF

# I hit an incredibly annoyingly issue where the tss user and group weren't
# created... I have no idea what went wrong but re-emerging the package didn't
# solve it either... I had to unmerge the package, remove the binary package,
# validate there were no artifacts left behind then re-install it.

chroot /mnt/gentoo emerge app-crypt/tpm2-abrmd app-crypt/tpm2-tools

# Might be useful:
# * app-crypt/tpm2-totp
# * app-crypt/tpm2-tss-engine

# tpm2-abrmd doesn't depend on dbus even though it'll fail to start if the dbus
# daemon isn't running. I may need to update the init definition myself.

# I may want to use the app-crypt/tpm-tools / app-crypt/trousers instead of
# tpm2-tools instead. I don't know what the compatibility actually looks like
# between the two with different types of hardware. It would be really annoying
# to have to use one for one type of hardware and another for the other kind.
#
# I might also want to use the other tools if they don't depend on a running
# daemon for when I need them in my initramfs... Maybe I don't care about
# background that daemon in the initramfs though, it'll get killed anyway when
# I switch root...
#
# OOoohhh neat it looks like I can pass `-T device` to the tpm2* tools to not
# use a daemon and talk to the TPM device directly. Looks like I could also
# just set this environment variable:
#
#   export TPM2TOOLS_TCTI="device:/dev/tpm0"
#
# The official
# [INSTALL][https://github.com/tpm2-software/tpm2-abrmd/blob/master/INSTALL.md]
# doc mentions SELinux will likely require policy changes to allow this to run
# when I get that to enforcing mode.

chroot /mnt/gentoo rc-update add dbus default
chroot /mnt/gentoo rc-update add tpm2-abrmd default
