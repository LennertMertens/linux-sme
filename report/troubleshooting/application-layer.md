# Application Layer

## Checklist: Aplication Layer
1. Check the *logs*: `journalctl` (met opties (-f -l -u))
2. Validate config file *syntax*
3. Use (command line) *client* tools
    * e.g. `curl`, `smbclient`(Samba), `dig`(DNS), etc.
4. Read the MANUALS

### 1. Check the log files
* Either journalctl: `journalctl -f -u httpd.service`
* Or /var/log/:
  * `tail -f /var/log/httpd/error_log`
  
### 2. Check config file syntax
* Application dependant
  * for Apache: `apachectl configtest`
  * for Nginx: `configtest`
  * for fileserver: `testparm`
  * for DNS: `named-checkconf`, `named-checkzone`

* Restart service after config modifications and watch the `logs`!

### 4. Read the *#!@ manual!
* RedHat Manuals:
  - System Administrator’s Guide
  - Networking guide
  - SELinux guide
* Reference manuals, e.g.
  - https://httpd.apache.org/docs/2.4/configuring.html
* Man pages
  - smb.conf(5), dhcpd.conf(5), named.conf(5), …


Next step: troubleshoot [SELinux](selinux.md)