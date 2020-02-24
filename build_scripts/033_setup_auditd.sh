#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

mkdir -p /mnt/gentoo/etc/portage/package.accept_keywords
echo 'sys-process/audit ~amd64' > /mnt/gentoo/etc/portage/package.accept_keywords/auditd

chroot /mnt/gentoo emerge sys-process/audit

# TODO: The audit rules and selinux policies need to be tweaked before I can
# really enable this, its very noisy and not meaningful right now
#chroot /mnt/gentoo rc-update add auditd boot

# TODO: When reviewing SELinux policy it may be useful to allow the normal
# plugin to log to the normal location. Likely I can use the normal tool
# inspection of offenses with my redirected audit log but no point is getting
# rid of a guaranteed useful diagnostic source without knowing for sure.
#rm -f /mnt/gentoo/etc/audisp/plugins.d/*

cat << 'EOF' > /mnt/gentoo/etc/audisp/audispd.conf
# /etc/audisp/audispd.conf

q_depth = 150
overflow_action = syslog
priority_boost = 4
max_restarts = 10
name_format = hostname
EOF

cat << 'EOF' > /mnt/gentoo/etc/audisp/plugins.d/syslog.conf
# /etc/audisp/plugins.d/syslog.conf

active = yes
direction = out
path = builtin_syslog
type = builtin
args = LOG_INFO LOG_LOCAL6
format = string
EOF

cat << 'EOF' > /mnt/gentoo/etc/audit/auditd.conf
# /etc/audit/auditd.conf

# Sane defaults:
#local_events = yes
#priority_boost = 4
#tcp_client_max_idle = 0
#tcp_max_per_addr = 1

# This program will receive a copy of all events via it's STDIN and will
# startup with root privileges when auditd comes up.
dispatcher = /sbin/audispd

# Don't tolerate dropping audit messages
disp_qos = lossless

# We send our logs to syslog for processing and policy analysis (using
# audispd), a lot of the remining settings won't have an effect unless this
# gets flipped.
write_logs = no

# Default location but be explicit
log_file = /var/log/audit/audit.log
log_format = ENRICHED
log_group = root

# Every 50 log entries trigger a background `sync` operation. There is a small
# potential for data loss here but the alternative is pretty poor throughput.
flush = incremental_async
freq = 50

# These settings control log rotation and indicate when a log file reaches 8MiB
# we will rotate the logs, keeping the current log and the last one.
num_logs = 2
max_log_file = 8
max_log_file_action = rotate

# How a node is identified in the audit message, `hostname` will use the local
# part. There is a `fqd` option for the full domain, but it performs name
# resolution for each event which isn't ideal.
name_format = hostname

# An alternative to above if I wanted the FQDN without incurring the lookup
# cost is by simply setting the value directly using the following settings
# instead:
#name_format = user
#name = "namey.mc.namepants.tld"

# This is the default, but we want it to be explicit
action_mail_acct = root

# When there is this much disk space (in MiB) left on the partition where
# auditd is logging, we want auditd to send an email and log to syslog.
# Hopefully this never trips as it's a pretty small amount of space...
space_left = 256
space_left_action = email

# If it gets to this point the system is in a really bad state, but we can try
# a notification to the admins again... A script could also be called here to
# attempt to trigger an alarm or something. That can be used by setting the
# action to `exec /path/to/script`. No arguments can be provided to the script.
admin_space_left = 64
admin_space_left_action = email

# We never want to be running our system where we can't persist our audit
# records so take the extreme action of shutting down the machine. Hopefully
# our two previous warning emails went through before this tripped...
disk_full_action = halt

# If there is ever an error writing our messages to disk we need to log that
# information.
disk_error_action = syslog

# Uncomment these to listen for events on the network
#tcp_listen_port = 48
#tcp_listen_queue = 16
#tcp_client_ports = 1024-65535
#use_libwrap = yes

# For kerberos to handle authentication and encryption. Mandatory for secure
# operation over a network. Be sure to generate a keytab, and replace
# `hostname` with the canonical FQDN of the host.
#enable_krb5 = yes
#krb5_principal = auditd/hostname@EXAMPLE.COM
#krb5_key_file = /etc/audit/audit.key

# If I accept audit events from other network hosts on this machine and I want
# them visible through the dispatcher program I should set this to yes.
#distribute_network = no
EOF

cat << 'EOF' > /mnt/gentoo/etc/audit/audit.rules
# /etc/audit/audit.rules

# NOTE: Audit rules vary based on the platform it is running on. These rules
# are written for a x86_64 system whose kernel doesn't support 32 bit
# applications. Binary paths are very specific as well. If your system doesn't
# match this profile you'll want to pay special attention to these rules and
# adapt them to your architecture.

# Reset any existing rules currently in the kernel
-D

# Increase our buffer size to prevent spikes of messages from DoS'ing the
# system. This buffer is quite huge as it is, and the individual messages don't
# take up much actual system memory. It may be worth while for you to monitor
# the use of the backlog and adjust this accordingly.
-b 8192

# The kernel should not perform any kind of time based backoff if the backlog
# limit is reached. This only really applies if the failure mode is not set to
# panic.
--backlog_wait_time 0

# What should the kernel do if the auditing subsystem fails for any reason? A
# value of 0 is silent, basically do nothing. 1 will print an error to the
# kernel log. Finally, 2, the safest but most disruptive option is to trigger a
# kernel panic. Generally while tuning I recommend setting this 1. Once the
# rules have been tested and are stable, changing this to 2 is the safe bet.
-f 1

# Ensure the loginuid remains immutable. This prevents even administrative
# users from masquerading as any other user, but may cause issues with some
# container systems.
--loginuid-immutable

# IMPORTANT PERFORMANCE NOTE: Audit rules are first-match-exit, and thus the
# number of checks per system call depend on the ordering of the rules in this
# file. To support high performance, the rules after this message are ordered
# roughly based on frequency they're expected to be seen in my environments,
# pay attention to this distribution for yourself.
#
# The filesystem monitoring calls are very efficient as far as lookups are
# concerned, so this performance monitoring concern is largely only for the
# syscall only rules.
#
# Some rules are specifically ordered to ensure a more specific rule happens
# before a catch all (such as elevated privileges over all execution
# monitoring).

# On 64 bit hosts, 32 bit compatibility calls are becoming increasingly rare.
# Everything should generally be running in 64 bit mode. This rule logs any
# attempts on the system to make use of the 32 bit ABIs.
#
# I compile my kernel without 32bit support so this rule isn't useful
#-a always,exit -F arch=b32 -S all -F key=32bitABI

# If performance begins to get effected, enabling this rule may drastically
# improve the performance of these syscalls as they will be able to occur
# with only a single audit lookup.
#-a never,exit -F arch=b64 -S brk,close,dup2,fcntl,fstat,fstatat,lstat,mmap,munmap,nanosleep,rt_sigaction,stat

# Monitor Network & Unix Socket Accepts & Connects
-a always,exit -F arch=b64 -S accept,connect -F key=networkControl

# PROCTITLE is an annoying & frequent message that has no appreciable security
# benefit (I suppose it could be used for data exfiltration though...)
-a exclude,always -F msgtype=PROCTITLE

# Monitor Elevation & Use of Privileges
-a always,exit -F arch=b64 -S setuid,setresuid -F a0=0 -F exe=/bin/su -F key=elevatedPrivs
-a always,exit -F arch=b64 -S setuid,setresuid -F a0=0 -F exe=/usr/bin/sudo -F key=elevatedPrivs
-a always,exit -F arch=b64 -S execve -C auid!=euid -F key=elevatedPrivs

# All Other Program Execution, useful in highly secure environments less useful
# on desktops.
#-a always,exit -F arch=b64 -S execve -F key=regularExec

# Monitor changes to the system time, this can have a dangerous impact on
# logging if the time were to change incorrectly. On the other hand many NTP
# clients make subtle small changes frequently, so this can become a very
# verbose log.
-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=timeChange
-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -F key=timeChange
# TODO: This line needs testing as it is a huge potential source of false
# positives
-a always,exit -F arch=b64 -S clock_adjtime -F key=timeChange
-a always,exit -F path=/etc/localtime -F perm=wa -F key=timeChange

# Successful File Removals
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=500 -F auid!=4294967295 -F key=successfulDelete

# System Calls That Were Denied
-a always,exit -F arch=b64 -S open,openat,open_by_handle_at -F exit=-EACCES -F key=failedAccess
-a always,exit -F arch=b64 -S open,openat,open_by_handle_at -F exit=-EPERM -F key=failedAccess
-a always,exit -F arch=b64 -S close -F exit=-EIO -F key=failedAccess

-a always,exit -F arch=b64 -S creat,link,linkat,mkdir,mknod,mknodat,symlink,symlinkat -F exit=-EACCES -F key=failedCreation
-a always,exit -F arch=b64 -S link,mkdir,mkdirat,symlink -F exit=-EPERM -F key=failedCreation

-a always,exit -F arch=b64 -S rmdir,unlink,unlinkat -F exit=-EACCES -F key=failedDelete
-a always,exit -F arch=b64 -S rmdir,unlink,unlinkat -F exit=-EPERM -F key=failedDelete

-a always,exit -F arch=b64 -S chmod,lsetxattr,lremovexattr,removexattr,rename,renameat,setxattr,truncate -F exit=-EACCES -F key=failedPermMod
-a always,exit -F arch=b64 -S chmod,lsetxattr,lremovexattr,removexattr,rename,renameat,setxattr,truncate -F exit=-EPERM -F key=failedPermMod

# Mount and Unmount Operations
-a always,exit -F arch=b64 -S mount,umount2 -F auid!=4294967295 -F key=mediaChange

# Module Loading & Unloading
-a always,exit -F arch=b64 -S init_module,finit_module -F key=moduleLoad
-a always,exit -F arch=b64 -S delete_module -F key=moduleUnload
-a always,exit -F dir=/etc/modprobe.d -F perm=wa -F key=moduleConfig

# Monitor Code Injection
-a always,exit -F arch=b64 -S ptrace -F key=tracing
-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -F key=codeInjection
-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -F key=dataInjection
-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -F key=registerInjection

# Personality syscalls may be an attempt to bypass auditd
-a always,exit -F arch=b64 -S personality -F a0!=4294967295 -F key=bypassAttempt

# Library Search Paths
-a always,exit -F arch=b64 -F path=/etc/ld.so.conf -F perm=wa -F key=libPath

# Monitor Changes to the Audit Logs
-a always,exit -F dir=/etc/audisp -F perm=wa -F key=auditIntegrity
-a always,exit -F dir=/etc/audit -F perm=wa -F key=auditIntegrity
-a always,exit -F dir=/var/log/audit -F perm=wa -F auid>=1000 -F auid!=4294967295 -F key=auditIntegrity
-a always,exit -F path=/etc/libaudit.conf -F perm=wa -F key=auditIntegrity

# Monitor Access to the Audit Logs
-a always,exit -F dir=/var/log/audit -F perm=r -F key=auditLogs
-a always,exit -F path=/sbin/aureport -F perm=x -F key=auditLogs
-a always,exit -F path=/sbin/ausearch -F perm=x -F key=auditLogs
-a always,exit -F path=/usr/bin/aulast -F perm=x -F key=auditLogs
-a always,exit -F path=/usr/sbin/auvirt -F perm=x -F key=auditLogs

# Authentication Configuration
-a always,exit -F dir=/etc/pam.d -F perm=wa -F key=authConfig
-a always,exit -F dir=/etc/security -F perm=wa -F key=authConfig
-a always,exit -F dir=/etc/sudoers.d -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/group -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/gshadow -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/login.defs -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/passwd -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/shadow -F perm=wa -F key=authConfig
-a always,exit -F path=/etc/sudoers -F perm=wa -F key=authConfig

# System Startup Scripts
-a always,exit -F dir=/etc/conf.d -F perm=wa -F key=initConfig
-a always,exit -F dir=/etc/init.d -F perm=wa -F key=initConfig
-a always,exit -F path=/etc/rc.conf -F perm=wa -F key=initConfig

# Network Environment Changes
-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=systemIdentity
-a always,exit -F path=/etc/conf.d/hostname -F perm=wa -F key=systemIdentity
-a always,exit -F path=/etc/conf.d/net -F perm=wa -F key=networkChange
-a always,exit -F path=/etc/hostname -F perm=wa -F key=systemIdentity
-a always,exit -F path=/etc/hosts -F perm=wa -F key=networkChange
-a always,exit -F path=/etc/issue -F perm=wa -F key=networkChange
-a always,exit -F path=/etc/issue.net -F perm=wa -F key=networkChange
-a always,exit -F path=/etc/resolv.conf -F perm=wa -F key=networkChange

# Monitor Changes to Kernel Parameters
-a always,exit -F arch=b64 -F path=/etc/sysctl.conf -F perm=wa -F key=sysctl

# Monitor AIDE config & databases
-a always,exit -F dir=/var/lib/aide -F perm=wa -F key=aideChange
-a always,exit -F path=/etc/aide.conf -F perm=wa -F key=aideChange

# Monitor the MAC Policy
-a always,exit -F dir=/etc/selinux -F perm=wa -F key=macPolicy

# Sensitive Cron Settings
-a always,exit -F arch=b64 -F dir=/etc/cron.daily -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F dir=/etc/cron.d -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F dir=/etc/cron.monthly -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F dir=/etc/cron.weekly -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F path=/etc/anacrontab -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F path=/etc/cron.allow -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F path=/etc/cron.deny -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F path=/etc/crontab -F perm=wa -F key=cronChange
-a always,exit -F arch=b64 -F path=/var/spool/cron/root -F perm=wa -F key=cronChange

# Mail Server Config Monitoring
-a always,exit -F dir=/etc/mail -F perm=wa -F key=mailConfig
-a always,exit -F dir=/etc/postfix -F perm=wa -F key=mailConfig

# Detect an admin accessing other user's files
-a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=4294967295 -C auid!=obj_uid -F key=powerAbuse

# This is almost silly, but almost as a rule of thumb attackers run 'whoami'
# and/or 'id' almost immediately after being able to run commands. These two
# binaries are used infrequently enough by normal users this generally won't
# produce a large amount of logs
-a always,exit -F path=/usr/bin/id -F perm=x -F key=selfIdentification
-a always,exit -F path=/usr/bin/whoami -F perm=x -F key=selfIdentification

## Additional Rules That May Be Useful

# Cron jobs are regular and expected, for these logs they are likely going to
# be noise. If you enable this rule ensure changes to the system cron files are
# audited.
#-a never,user -F subj_type=crond_t

# If you use chrony as your time keeping client. It makes quite a few small
# changes to the time during its normal operation. To avoid flooding the logs
# with these message we can exclude chrony time changes. This rule should be
# inserted before the other time monitoring tools.
#-a never,exit -F arch=b64 -S adjtimex -F auid=unset -F uid=chrony -F subj_type=chronyd_t

# If you're hosting a public SSH server on the default port or any other
# service that may get scanned or botted regularily you may want to enable this
# rule. It can be interesting, but you'll mostly be receiving junk from bots
# trying common passwords on your server and general internet scans...
#-a exclude,always -F msgtype=CRYPTO_KEY_USER

# Monitor Container Creation & Configuration
#-a always,exit -F arch=b64 -S clone -F a0&0x7C020000 -F key=containerCreate
#-a always,exit -F arch=b64 -S setns,unshare -F key=containerConfig
#-a always,exit -F path=/usr/bin/docker -F perm=x -F key=docker

# This controls the state of the auditing subsystem. -e 0 disables the auditing
# system entirely, -e 1 will enable the system, and -e 2 will enable the system
# and prevent any future changes to the auditing rules (requiring a restart for
# rules to be removed or added). During rule tuning, this should be set to -e
# 1. Once the rules are in place it should be upgraded to -e 2 to ensure
# attackers can't disable the auditing rules.
-e 1
EOF

truncate -c -s 0 /mnt/gentoo/etc/audit/audit.rules.stop.post
truncate -c -s 0 /mnt/gentoo/etc/audit/audit.rules.stop.post
truncate -c -s 0 /mnt/gentoo/etc/audit/audit.rules.stop.pre
