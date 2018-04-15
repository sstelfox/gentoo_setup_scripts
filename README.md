# Personal Gentoo Setup Scripts

This is a collection of bash scripts designed to be run from a Gentoo minimal
install CD that will setup and provision a hardened relatively minimal install
that can be a solid foundation for additional services.

I regularly tweak and rebuild portions of my infrastructure with these scripts.
I will make changes to these without notice as my hardening preferences and
preferred setups change. I will do my best to keep the `master` branch
relatively stable.

## Usage

By its nature this does take a long time but then can be snapshott'ed and
reused as an AMI, kvm image, etc.

* Boot the Gentoo install CD
* Set a password for the root user
* Start the SSH server
* Transfer this set of scripts using scp, or wget'ing a release
* Modify the `_config.sh` settings
* Execute `./run_all.sh` and let the server build itself up...

After installation the one change you'll want to make is setting an account
password on your administrator account and disabling the `!authenticate` line
in the sudoers file.

## Kernel Selection

I've dropped in place several different kernel configs, these are very minimal
configs, with a large number of security options enabled (in some cases at the
expense of performance) and only provide what I need for my specific setups. If
you are going to use these yourself I recommend using your own kernel configs.

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
