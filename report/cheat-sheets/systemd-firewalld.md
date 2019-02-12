# Cheat sheet systemd and firewalld

# systemd
<dl>
  <dt>systemd</dt>
  <dd>Init system and system manager (new standard for linux systems</dd>

  <dt>systemctl</dt>
  <dd>Central management tool for controlling the init system</dd>
</dl>

## Enabling/Disabling services and checking their status

| Command | Meaning |
| :------ | :------ |
| `sudo systemctl start application.service` | start a desired service |
| `sudo systemctl stop application.service` | stop a running service |
| `sudo systemctl restart application.service` | restart a running service |
| `sudo systemctl reload application.service` | reload  an applications config files |
| `sudo systemctl reload-or-restart application.service` | if you're unsure issue this command |
| `sudo systemctl enable application.service` | start services automatically at boot |
| `sudo systemctl disable application.service` | disable a service from starting automatically |
| `systemctl status application.service` | check the status of a service |
| `systemctl is-active application.service` | check if a unit is currently active |
| `systemctl is-enabled application.service` | check if the service is enabled or disabled |
| `systemctl is-failed application.service` | check wheter the service failed or not |

**Note:** if an expression evaluates "true" (or active, enabled, ...) the exit code will be set to 0, if it's false, then the exit code is 1.

## System State Overview
### Listing current units

To see a list of all the units that systemd knows about we can use the list-units command: 
```
systemctl list-units
```

This command shows a list of all units currently active on the system. The output will look like this:
```
UNIT                                      LOAD   ACTIVE SUB     DESCRIPTION
atd.service                               loaded active running ATD daemon
avahi-daemon.service                      loaded active running Avahi mDNS/DNS-SD Stack
dbus.service                              loaded active running D-Bus System Message Bus
dcron.service                             loaded active running Periodic Command Scheduler
dkms.service                              loaded active exited  Dynamic Kernel Modules System
getty@tty1.service                        loaded active running Getty on tty1
```
- Shows the same as `systemctl'

Meaning of comulms:
- **UNIT**: The `systemd`unit name
- **LOAD**: Whether the unit's configuration has been parsed by systemd. The configuration of loaded units is kept in memory.
- **ACTIVE**: A summary state about whether the unit is active. This is usually a fairly basic way to tell if the unit has started successfully or not.
- **SUB**: This is a lower-level state that indicates more detailed information about the unit. This often varies by unit type, state, and the actual method in which the unit runs.
-**DESCRIPTION**: A short textual description of what the unit is/does.

More possible optins for displaying desired information:
```
systemctl list-units --all 
systemctl list-units --all --state=inactive
systemctl list-units --type=service

```
Extra information on systemctl: https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units

# firewalld

<dl>
  <dt>firewalld</dt>
  <dd>Default firewallsystem on RHEL</dd>
</dl>

https://www.certdepot.net/rhel7-get-started-firewalld/

# Andere interessante commando's uitgelegd
https://hogenttin.github.io/elnx-syllabus/el7/#/title-slide
