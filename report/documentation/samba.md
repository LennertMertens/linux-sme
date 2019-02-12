# Setting up a fileserver with Samba 4

- SMB protocol
- Samba = Clean room implementation
- File/print server in enterprises
- NAS-systems

### Warning:
- Don't deactivate SELi,ux
- Don't deactivate firewall
- Don't set up `"security=share"`

## Prequisites
#### Hostname
- Configure `hostname`:  `/etc/sysconfig/network`
- Configure IP address and hostname in: `/etc/hosts`
- Reboot the system after changes
  
#### Install packages
- Install `samba` and `samba-client`

#### Create group
- `sudo groupadd groepsnaam`

#### Add users
- `sudo useradd -m -G groepsnaam alice`

#### User passwords
- `passwd`
- `smbpasswd -a`
- Both needed because they are maintained separately!

#### Create shared folders
- `/srv/shares/public`
- `/srv/shares/private`
- Property of group `groepsnaam`: `sudo chgrp -R groepsnaam /srv/shares/*`
- writable for groupmembers: `sudo chmod -R g+w /srv/shares/*`


## SELinux
### Turn on/off
- Must be turned on!
- `sestatus`
```bash
# When enabled following values are visible
SELinux status:           enabled
SELinuxfs mount:          /selinux
Current mode:             enforcing
Mode from config file:    enforcing
Policy version:           24
Policy from config file:  targeted
```
- `/etc/sysconfig/selinux`
- **Reboot after changes!**

### Change sebool values for samba
- `sudo setsebool -P samba_enable_home_dirs on`
- `sudo setsebool -P samba_export_all_rw on`
- 
### Change file context
- Install: `yum install policyutils-python`
- `sudo semanage fcontext -a -t samba_share_t "/srv/shares(/.*)?"`
- Relable: `sudo restorecon -Rv /srv/`

## Samba configuration
- `/etc/samba/smb.conf`
- After every change:
  - `service smb restart`
  - `service nmb restart`

### Tips
- Make back-ups of last working versions: `sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.orig`
- Small changes: 
  - Validate the configuration: `testparam -s [CONFIG]`
  - Check the result each tim
- Follow the logs:
  - `/var/log/samba/*`
  - `/var/log/messages`
  - `/var/log/audit/audit.log` (SELinux)
- Remove unnecessary comments
- Make it impossible for guest users to write: `writable = no` and `read only = yes` (in confg file)!!!

## Config file
- change log file to: `/var/log/samba/samba.log`

## Services
- Start and enable following services:
```bash
sudo service smb start
sudo service nmb start
sudo chkconfig smb on
sudo chkconfig nmb on
# Check result of previous command run level 3 and 5 must be on
chkconfig --list
```

## Firewall-settings
- Check open ports: `sudo ss -tulnp`
  - TCP: 139, 445 (smbd)
  - UDP 137, 138 (nmbd)
- Add port 139, 445 to firewall for samba
```
firewall-cmd --permanent --add-port=137/udp
firewall-cmd --permanent --add-port=138/udp
firewall-cmd --permanent --add-port=139/tcp
firewall-cmd --permanent --add-port=445/tcp
firewall-cmd --reload
```

## Testing
### WINS name reolution 
- So "\\nasbox" works in Windows explorer
- `nmblookup -B SERVER '*'`
- `nmbloookup -d 2 '*'`
### List of public shared folders
 - `smbclient -L //localhost -U%`
 - `smbclient -L //IPADRES -U%`
 - `smbclient -L //nasbox -U%`


## Testing acces to shares
- As guest 
  - `smbclient //nasbox/public -U%`
- Registered user:
  - `smbclient //nasbox/public -Ualice`
- First local, then from host system 
- Linux host system:
  - File manager > connect to server or ctrl + L
  - As guest: `smb://nasbox/public`
  - User: `smb://alice@nasbox/public`
  - Attention for firewall!
    - Allow samba-client on prt 137, 138 UDP
  - smbclient is best test tool!
  
## Write permissions: checklist
- Linux file permissions
- Samba configuration: (`write list, writeable, valid useres)
- SELinux settings: (`setsebool` and `semanage fcontext`)


### Sources
- [Bert Van Vreckem een fileserver installeren met samba](https://www.youtube.com/watch?v=w2RxBkqQ3ZQ)
- [Red Hat Manual Ch. 21 Samba](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-file_and_print_servers#s1-Samba)
- [SELinux for mere mortals](https://www.youtube.com/watch?v=cNoVgDqqJmM&feature=youtu.be)