#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

exit 0

echo 'RUBY_TARGETS="ruby24"' >> /mnt/gentoo/etc/portage/make.conf
cat << 'EOF' > /mnt/gentoo/etc/portage/package.accept_keywords/ruby
dev-lang/ruby ~amd64
dev-ruby/* ~amd64
virtual/rubygems ~amd64
EOF

chroot /mnt/gentoo emerge app-crypt/gnupg app-misc/tmux dev-lang/go \
  dev-lang/ruby mail-client/mailx mail-client/mutt net-analyzer/netcat \
  net-analyzer/tcpdump net-dns/bind-tools net-wireless/aircrack-ng \
  www-client/elinks net-analyzer/nmap sys-apps/pv
