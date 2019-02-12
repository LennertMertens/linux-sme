# Cheat sheets and checklists

- Student name: Lennert Mertens
- Github repo: https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens

Basic ELNX Commands: [Commands](https://hogenttin.github.io/elnx-syllabus/el7/#/network-settings)
## Basic commands

| Task                                         | Command                                                        |
| :---                                         | :---                                                           |
| Query IP-adress(es)                          | `ip a`                                                         |
| Search which package provides a desired tool | `yum provides /usr/sbin/semanage'`                             |
| Test Samba's config file                     | `testparm [-s]`                                                |
| Put system to azerty                         | `sudo localectl set-keymap be sudo localectl set-x11-keymap be`|

## Git workflow

Simple workflow for a personal project without other contributors:

| Task                                         | Command                   |
| :---                                         | :---                      |
| Current project status                       | `git status`              |
| Select files to be committed                 | `git add FILE...`         |
| Commit changes to local repository           | `git commit -m 'MESSAGE'` |
| Push local changes to remote repository      | `git push`                |
| Pull changes from remote repository to local | `git pull`                |

## Vagrant workflow and commands

https://gist.github.com/wpscholar/a49594e2e2b918f4d0c4

## Checklist network configuration

1. Is the IP-adress correct? `ip a`
2. Is the router/default gateway correct? `ip r -n`
3. Is a DNS-server available? `cat /etc/resolv.conf`

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

### General SELinux settings
- `getsebool [-a]` (-a lists all. Use grep to seatch for desired values)
- `setsebool [-P] SETTING=val` (-P makes permanent even after reboot)
e.g.
```
setsebool -P samba_enable_home_dirs on
setsebool -P samba_export_all_rw on
```

### Context: additional file permissions
- Because Linux file permissions is limited
- via "policies": `/etc/selinux/targeted/contexts/files/file_contexts`
- Check with: `ls -Z`
#### SELinux modify context
- Temporarily (=till relabeling):
  - `chcon [-R] -t CONTEXT DIR...`
- Permanent:
  - `semanage fcontext -a -t CONTEXT PATTERN`
  - e.g. `semanage fcontext -a -t samba_share_t "/srv/shares(/.*)?"`
  - remark: Install package `policycoreutils-python`
  - see `/etc/selinux/targeted/context/files/file_contexts.local`
- Afterwards relabeling: `restorecon -Rv /srv`

## Smbclient
### Summary of shared folders:
- As guest: `smbclient -L //nasbox -U%`
- As user: `smbclient -L //nasbox -Ualice`

### Log in on share
- As guest: `smbclient //nasbox/public -U%`
- As user: `smbclient //nasbox/public -Ualice`

### Commando-shell
- `ls, cd, pwd, mkdir, rmdir, del, chmod, chown`
- `get pub.txt`, `mget *.txt`
- `put somefile.txt`, `mput *.txt`
- `exit`(Ctrl + d)


## DNS en BIND

- File with DNS servers: `/etc/resolv.conf`

### Commands

| Task                                           | Command                           |
| :---                                           | :---                              |
| Query the DNS server                           | `nslookup www.hogent.be`          |
| dig forward lookups                            | `dig www.hogent.be`               |
| dig reverse lookups                            | `dig -x 178.62.144.90`            |
| dig IPv6 address                               | `dig AAAA www.hogent.be +short`   |
| dig: who is the authoritative ns for hogent.be | `dig NS hogent.be`                |
| dig: who is the mailserver for hogent.be       | `dig MX hogent.be`                |
| dig: Start-of-Authority section for hogent.be  | `dig SOA hogent.be`               |
| dig: query specific DNS-server                 | `$ dig +short @8.8.8.8 www.hogent.be` |
| Check the named logd                           | `journalctl -u named`             |
| Validate main config file                      | `named-checkconf /etc/named.conf` |
| Validate zone files                            | `named-checkzone ZONE FILE`       |

e.g.  
```
$ sudo named-checkzone example.com /var/named/example.conf
$ sudo named-checkzone 16.172.in-addr.arpa /var/named/16.172.in-addr.arpa
```

### BIND

- Package: `named`
- Service config file: `/etc/named*`
- Zone files: `/var/named/`

### Main config file: 
```bash
options {
  listen-on port 53 { any; };     # port number + interfaces
  listen-on-v6 port 53 { any; };
  directory   "/var/named";

  // ...

  allow-query     { any; };      # which hosts may send queries?
  allow-transfer  { any; };      # which secondary name servers may receive zone transfers?

  recursion no;                  # allow recursive queries (should be no on authoritative name server!)

  rrset-order { order random; };

  // ...
};
```

### Main config file: zone definition

- Forward lookkup zone for example.com  
```bash
zone "example.com" IN {
  type master;
  file "example.com";
  notify yes;
  allow-update { none; };
};
```

- On a secondary name server:  
```bash
zone "example.com" IN {
  type slave;
  masters { 192.168.56.10; };
  file "slaves/example.com";
};
```

### Reverse lookup zone  
```bash
zone "56.168.192.in-addr.arpa" IN {
  type master;
  file "56.168.192.in-addr.arpa";
  notify yes;
  allow-update { none; };
};
```

**IP to reverse lookup zone**
1. Take the "dotted quad"; `192.165.56.0/24`
2. Drop the host part: `192.168.56`
3. Reverse the quads: `56.168.192`
4. Add `in-addr.arpa.`:
   - `56.168.192.in-addr.arpa.`

### Example zone file  
```bash
$ORIGIN example.com
$TTL 1W

@ IN SOA ns1.example.com. hostmaster.example.com. ( # Start-of-Authority
                                                    # ns1.example.com: primary name server
                                                    # hostmaster.example.com: mail of sysadmin @example.com
  18042020 1D 1H 1W 1D )  # 18042020: serial 

                     IN  NS     ns1
                     IN  NS     ns1

ns1                  IN  A      192.168.56.10
ns2                  IN  A      192.168.56.11
dc                   IN  A      192.168.56.40
web                  IN  A      192.168.56.172
www                  IN  CNAME  web
db                   IN  A      192.168.56.173

priv0001             IN  A      172.16.0.10
priv0002             IN  A      172.16.0.11
```

### Recourse records

- `A`: name to IP
- `AAAA`: name to IPv6
- `PTR`: IP to name
- `CNAME`: alias
- `SOA`: start of authority, info about the domain
- `NS`: authoritative name server(s)
- `MX`: mail server
- `SRV`: service
- `TXT`: text record

Example: 
```
web  IN  A      192.168.56.172
www  IN  CNAME  web
```

### Start of Authority  
```
@ IN SOA ns1.example.com hostmaster.example.com (
  18042020 1D 1H 1W 1D )
```

`1D`: when will secondary ns try to refresh the zone
`1H`: time between update retries
`1W`: when is zone data no longer authoritative (slave only)
`1D`: how long can NAME ERROR result be cached

### Root hint  
- Every (forwarding) name server should have list of root name servers  
- `dig @a.root-servers.net`  
```
.           518400  IN  NS  a.root-servers.net.
.           518400  IN  NS  b.root-servers.net.

[...]

a.root-servers.net. 518400  IN  A   198.41.0.4
b.root-servers.net. 518400  IN  A   199.9.14.201

[...]

a.root-servers.net. 518400  IN  AAAA    2001:503:ba3e::2:30
b.root-servers.net. 518400  IN  AAAA    2001:500:200::b

[...]
```

### Tips & tricks
#### Zone-files syntax meestvoorkomende fouten
- FQDN in een zonebestand moet altijd met een `.` worden afgesloten
- IP-adressen worden op een eigenaardige manier genoteerd. Ten eerste wordt het host-deel van het netwerkadres niet geschreven, de getallen in de “dotted quad”-notatie worden omgekeerd en je moet er “in-addr.arpa.” achter schrijven. Met andere woorden, 192.0.2.0/24 wordt als “2.0.192.in-addr-arpa." geschreven.
  

#### Logs bekijken
- Aparte console openen
- DNS-query's van clients in logs weergeven: `$ sudo rndc querylog on`
- Logs van BIND tonen: `$ sudo journalctl -l -f -u named.service`

#### Packages
Installeer `bind-tools` voor testing

