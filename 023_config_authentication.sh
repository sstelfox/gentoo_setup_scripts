#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

chroot /mnt/gentoo emerge app-admin/sudo

#cat << 'EOF' > /etc/portage/package.use/ldap
#app-crypt/mit-krb5 openldap
#net-nds/openldap kinit gnutls sasl -berkdb -tcpd
#sys-auth/nss_ldap sasl
#sys-auth/pam_ldap sasl
#net-libs/gnutls tools
#dev-libs/boehm-gc threads
#EOF
#emerge app-crypt/mit-krb5 net-nds/openldap sys-auth/pam_krb5

cat << 'EOF' > /mnt/gentoo/etc/pam.d/system-auth
auth          required        pam_env.so
#auth          sufficient      pam_krb5.so
auth          sufficient      pam_unix.so try_first_pass likeauth nullok
auth          required        pam_deny.so

account       required        pam_unix.so

password      required        pam_cracklib.so difok=3 minlen=12 retry=3 reject_username
#password      sufficient      pam_krb5.so
password      sufficient      pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password      required        pam_deny.so

session       required        pam_limits.so
session       required        pam_env.so
#session       optional        pam_krb5.so
session       required        pam_unix.so
session       required        pam_mkhomedir.so umask=0027
session       optional        pam_permit.so
EOF

cat << 'EOF' > /mnt/gentoo/etc/pam.d/system-login
auth          required        pam_tally2.so audit deny=5 unlock_time=300 onerr=succeed
auth          required        pam_shells.so
auth          required        pam_nologin.so
auth          include         system-auth

account       required        pam_access.so
account       required        pam_nologin.so
account       include         system-auth
account       required        pam_tally2.so onerr=succeed

password      include         system-auth

session       optional        pam_loginuid.so
session       required        pam_env.so
session       optional        pam_lastlog.so silent
session       include         system-auth
session       optional        pam_motd.so motd=/etc/motd
session       optional        pam_mail.so quiet
EOF

cat << 'EOF' > /mnt/gentoo/etc/sudoers
# /etc/sudoers

Cmnd_Alias ALLOWED_EXEC = /sbin/poweroff, /sbin/rc-service, /sbin/rc-status, /sbin/rc-update, /sbin/reboot, /sbin/shutdown, /usr/bin/emerge, /usr/bin/equery, /usr/bin/eselect, /usr/sbin/usermod
Cmnd_Alias BLACKLIST = /bin/su
Cmnd_Alias SHELLS = /bin/sh, /bin/bash
Cmnd_Alias USER_WRITEABLE = /home/*, /tmp/*, /var/tmp/*

Defaults env_reset, ignore_dot, mail_badpass, mail_no_perms, noexec
Defaults requiretty, use_pty
Defaults !path_info, !use_netgroups, !visiblepw

Defaults editor = /usr/bin/vim
Defaults env_keep += "TZ"
Defaults iolog_dir = /var/log/sudo-io/%{user}
Defaults passwd_timeout = 2
Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin

Defaults mailfrom = root
Defaults mailsub = "Sudo Policy Violation on %H by %u"

Defaults!ALLOWED_EXEC,SHELLS !noexec
Defaults!SHELLS log_output

# Disable this once proper authentication has been setup:
Defaults !authenticate

root      ALL=(ALL)   ALL
%sudoers  ALL=(ALL)   ALL,!BLACKLIST,!USER_WRITEABLE,!SHELLS
EOF
