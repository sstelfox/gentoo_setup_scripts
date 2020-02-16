# Personal Gentoo Setup Scripts

This is a collection of bash scripts designed to be run from a Gentoo minimal
install CD that will setup and provision a hardened relatively minimal install
that can be a solid foundation for additional services.

I regularly tweak and rebuild portions of my infrastructure with these scripts.
I will make changes to these without notice as my hardening preferences and
preferred setups change.

## Usage

A from scratch build does take quite a long time time, using NFS to cache the
build artifacts and packages will speed this up after the initial run. The base
build system is tested from the latest Fedora version using libvirtd and
podman. The base package requirements are available in my [setup][1]
[scripts][2].

From that base set of requirements I use a bridge network (the scripts expect a
bridge named `br0`). By default the scripts expect and NFS share and a binary
package host, these can be setup using the `services_start.sh` script run as
root which will start up containers to handle the services, if you don't want
to use them you can disable the cacheing setup in the `_config.sh` file.

Once the services are running (or their use has been disabled). You can start
an initial VM build using the `create_vm.sh`. This will startup an interactive
console that does require a little bit of manual work to get started, but
nothing onerous.

You'll want to review the entirety of `_config.sh` setting anything
appropropriate (likely username, and source of authentication key at a
minimum).

After running it, there will be a pause when you need to pay attention. When
the boot menu comes up, press `e` to edit the initial boot line and add
`console=ttyS0` anywhere in the line (ensuring whitespace separates it from the
other options). Continue the boot until a prompt shows up asking you to login.
Use `root` as the username which won't have a password and run the following
commands to start the install:

```
mkdir /mnt/nfs_source
mount -t nfs <HOST_IP>:/ /mnt/nfs_source
cd /mnt/nfs_source
./run_all.sh
```

You'll need to make sure you replace `<HOST_IP>` with the host that is running
the NFS server pod. If you're opting not to use the NFS server or cacheing
options than copying this entire directory over to the build system is required
(you'll need to enable the SSH server and set a password on the root account,
then SCP the directory over, and run the `run_all.sh` script from there).

The system will automatically run through the entirety of the install and
unmount everything cleanly. Once complete you should just be able to reboot
directly into your freshly compiled and optimized Gentoo system.

## Kernels

The kernel config uses a programatic approach to setting and unsetting various
options. These are periodically updated as different config options come and
go. I always welcome recommendations via pull requests.

The specific settings are separated into groups within the
`kernel_config/sections` directory that are largely universal for my
environments. Hardware specific settings live in
`kernel_config/target_specific` and are sorted based on hardware (including
virtual machines).

## Why not Puppet, Ansible, Chef, Salt, etc...

I appreciate the consistency of devops tools such as Puppet for maintaining the
state of servers and handling the initial provisioning. Many of them, Puppet
included, and their open source modules have very poor support for Gentoo. The
application configuration would of course still work, but there would be a lot
of custom file creation and modification of the modules to get them to work.

Puppet additionally requires software running on the system that would not
normally be there. This requires the system be bootstrapped up to a point that
code can be run before it can start making any changes, and the vast majority
of the provisioning will have already be done at that point. I've tried using
the agent-less devops tools such as Ansible as well, which does solve this
issue but requires weaker sudo security settings, and is significantly slower
for a task that is mostly static.

I've instead chosen a different path for my Gentoo servers, which is this
collection of bash scripts and let the server build itself up initially. This
is snapshotted and used as the basis for additional server type specific
scripts.

[1]: https://github.com/sstelfox/dotfiles/blob/master/setup-scripts/podman.sh
[2]: https://github.com/sstelfox/dotfiles/blob/master/setup-scripts/virtualization.sh
