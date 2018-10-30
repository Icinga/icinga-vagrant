# CentOS 7 Development Vagrant Box

This Vagrant VM comes pre-installed with CentOS 7 and
all build requirements for Icinga 2.

* ccache
* gdb
* Build environment with scripts

## SSH

Copy your SSH key into the box:

```
ssh-copy-id vagrant@192.168.33.21
vagrant
```

Use agent-forwarding to ssh into the box and become root.
```
ssh -A vagrant@192.168.33.21
sudo -i
```

## Build Environment

```
vim /etc/profile.d/env_dev.sh

source /etc/profile.d/env_dev.sh
```

## Builds

The source is cloned from GitHub into `/root`.

```
cd /root/icinga2
```

Debug builds:
```
i2_debug
```

Release builds:
```
i2_release
```

### Compile & Install

```
make -j2 install -C debug
```

### Run

```
/usr/local/icinga2/lib/icinga2/prepare-dirs /usr/local/icinga2/etc/sysconfig/icinga2

icinga2 daemon
```

### GDB

```
gdb --args /usr/local/icinga2/lib64/icinga2/sbin/icinga2 daemon
```

