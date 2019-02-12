#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#
# Basic settings
#
set system domain-name 'avalon.lan'
set system host-name 'Router'
#set service ssh port '22'

#
# IP settings
#
set interfaces ethernet eth0 description 'WAN link'
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth1 description 'DMZ'
set interfaces ethernet eth1 address '192.0.2.254/24'
set interfaces ethernet eth2 description 'internal'
set interfaces ethernet eth2 address '172.16.255.254/16'

#
# Network Address Translation
#
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '172.16.0.0/16'
set nat source rule 100 translation address masquerade
set nat source rule 300 outbound-interface 'eth0'
set nat source rule 300 source address '192.0.2.0/24'
set nat source rule 300 translation address masquerade

# IP masquerade: example, if a Linux host is connected to the Internet via PPP, Ethernet, etc., 
# the IP Masquerade feature allows other "internal" computers connected to this Linux box (via PPP, Ethernet, etc.) 
# to also reach the Internet as well. Linux IP Masquerading allows for this functionality even though these internal 
# machines don't have an officially assigned IP address.



#
# Time
#
delete system ntp
set system ntp server be.pool.ntp.org
set system time-zone 'Europe/Brussels'

#
# Domain Name Service
#
set service dns forwarding domain avalon.lan server 192.0.2.10
set service dns forwarding name-server 10.0.2.3
set service dns forwarding listen-on 'eth1'
set service dns forwarding listen-on 'eth2'

# Make configuration changes persistent
commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
