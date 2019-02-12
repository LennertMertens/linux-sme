# Enterprise Linux Lab Report: 02-dns

- Student name: Lennert Mertens
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens>

Setting up a CentOS DNS server with BIND. In this environment we'll need a master and a slave server for replication.

## Test plan

### 1. ns1: Master server
**1.1. Automated BIND tests**
```
$ sudo /vagrant/test/runbats.sh
 ✓ The 
 ✓ The main config file should be syntactically correct
 ✓ The forward zone file should be syntactically correct
 ✓ The reverse zone files should be syntactically correct
 ✓ The service should be running
 ✓ Forward lookups public servers
 ✓ Forward lookups private servers
 ✓ Reverse lookups public servers
 ✓ Reverse lookups private servers
 ✓ Alias lookups public servers
 ✓ Alias lookups private servers
 ✓ NS record lookup
 ✓ Mail server lookup

13 tests, 0 failures
```
**1.2. dig testing**
**Within the virtual environment**

Querying the DNS server can be used for testing if DNS is properly configured.

Issue following command from eg. the webserver in our network (VM) and check wether the name of the server + ip-address is returned:
```bash
[vagrant@pu004 ~]$ dig @<dns-ip-address> {alias}.avalon.lan +short
pxxxx.avalon.lan # Full server name
x.x.x.x          # Servers IP Address
```
- Test for all aliases: `www, mail, ns1, ns2, files, dhcp, directory, inside, gw`

**From host machine**

Issue following command from the host machine and check wether the name of the server + ip-address is returned:
```bash
Lennerts-MacBook-Pro:~ lennert$ dig @<dns-ip-address> {alias}.avalon.lan +short
pxxxx.avalon.lan # Full server name
x.x.x.x          # Servers IP Address
```
- Test for all aliases: `www, mail, ns1, ns2, files, dhcp, directory, inside, gw`

### 2. ns2: Slave server
**2.1. Automated BIND tests**
```
$ sudo /vagrant/test/runbats.sh
 ✓ The 
 ✓ The main config file should be syntactically correct
 ✓ The server should be set up as a slave
 ✓ The server should forward requests to the master server
 ✓ There should not be a forward zone file
 ✓ The service should be running
 ✓ Forward lookups public servers
 ✓ Forward lookups private servers
 ✓ Reverse lookups public servers
 ✓ Reverse lookups private servers
 ✓ Alias lookups public servers
 ✓ Alias lookups private servers
 ✓ NS record lookup
 ✓ Mail server lookup

14 tests, 0 failures
```
**2.2. dig testing**

Issue following command from eg. the webserver in our network (VM) and check wether the name of the server + ip-address is returned:
```bash
[vagrant@pu004 ~]$ dig @<slave-dns-ip-address> {alias}.avalon.lan +short
pxxxx.avalon.lan # Full server name
x.x.x.x          # Servers IP Address
```
- Test for all aliases: `www, mail, ns1, ns2, files, dhcp, directory, inside, gw`

**From host machine**

Issue following command from the host machine and check wether the name of the server + ip-address is returned:
```bash
Lennerts-MacBook-Pro:~ lennert$ dig @<slave-dns-ip-address> {alias}.avalon.lan +short
pxxxx.avalon.lan # Full server name
x.x.x.x          # Servers IP Address
```
- Test for all aliases: `www, mail, ns1, ns2, files, dhcp, directory, inside, gw`
  

## Procedure/Documentation

###  Add the new servers to `site.yml`, `vagrant-hosts.yml`
- Add the first and slave DNS server to `site.yml` and `vagrant-hosts.yml`
- Install the BIND role [bertvv.bind](https://galaxy.ansible.com/bertvv/bind) for setting up DNS
```yml
# site.yml
- hosts: pu001
  become: true
  roles: 
    - bertvv.bind

- hosts: pu002
  become: true
  roles: 
    - bertvv.bind
```
```yml
# vagrant-host.yml
- name: pu001
  ip: 192.0.2.10

- name: pu002
  ip: 192.0.2.11
```

### ns1: Master server  
- Firewall allows `dns` service
- pu001 is defined as the bind zone master sever
- Server is listening on: 192.0.2.10
- All hosts are allowed to query this dns server
- `avalon.lan` is added as bind zone domain
- Name servers are defined
- Mail servers are defined 
- Networks are defined
- Hosts are defined: these generate a `forward` and a `reverse` lookup zone

Configurations of [pu001](https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens/blob/master/ansible/host_vars/pu001.yml) 

### ns2: Slave server 
- Firewall allows `dns` service
- pu001 is defined as the bind zone master sever, pu002 replicates this server
- Server is listening on: 192.0.2.11
- All hosts are allowed to query this dns server
- `avalon.lan` is added as bind zone domain
- Networks are defined
- `Forward`and `reverse` lookup zone is known throug the master dns server

**Note:** If pu001 is not running, then pu002 won't work. pu002 get's all necessary information from pu001.

Configurations of [pu002](https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens/blob/master/ansible/host_vars/pu002.yml) `

## Test report
**Note:** Tests failed several times, after further investigation it seemed that it was caused by incorrect syntax.

### ns1: Master server
- [x] Automated BIND tests

__dig testing from VM__

How command is issued on pu004 and the output it generates:
```bash
[vagrant@pu004 ~]$ dig @192.0.2.10 www.avalon.lan +short
pu004.avalon.lan.
192.0.2.50
# The output generated confirms that dns is properly working
```

| alias  | Working?|
| :----  | :-----: |
| `www`  | [X]     |
| `mail` | [X]     |
| `ns1`  | [X]     |
| `ns2`  | [X]     |
| `files`| [X]     |
| `dhcp` | [X]     |
| `directory`| [X] |
| `inside`| [X]    |
| `gw`   | [X]     |


__dig testing from Host__

How command is issued on host machine and the output it generates:
```bash
[Lennerts-MacBook-Pro:~ lennert$ dig @192.0.2.10 files.avalon.lan +short
pr011.avalon.lan.
172.16.0.11
# The output generated confirms that dns is properly working
```

| alias  | Working?|
| :----  | :-----: |
| `www`  | [X]     |
| `mail` | [X]     |
| `ns1`  | [X]     |
| `ns2`  | [X]     |
| `files`| [X]     |
| `dhcp` | [X]     |
| `directory`| [X] |
| `inside`| [X]    |
| `gw`   | [X]     |

### ns2: Slave server
- [x] Automated BIND tests

__dig testing from VM__

How command is issued on pu004 and the output it generates:
```bash
[vagrant@pu004 ~]$ dig @192.0.2.11 mail.avalon.lan +short
pu003.avalon.lan.
192.0.2.20
# The output generated confirms that dns is properly working
```

| alias  | Working?|
| :----  | :-----: |
| `www`  | [X]     |
| `mail` | [X]     |
| `ns1`  | [X]     |
| `ns2`  | [X]     |
| `files`| [X]     |
| `dhcp` | [X]     |
| `directory`| [X] |
| `inside`| [X]    |
| `gw`   | [X]     |


__dig testing from Host__

How command is issued on host machine and the output it generates:
```bash
Lennerts-MacBook-Pro:~ lennert$ dig @192.0.2.11 gw.avalon.lan +short
router.avalon.lan.
172.16.255.254
192.0.2.254
# The output generated confirms that dns is properly working
```

| alias  | Working?|
| :----  | :-----: |
| `www`  | [X]     |
| `mail` | [X]     |
| `ns1`  | [X]     |
| `ns2`  | [X]     |
| `files`| [X]     |
| `dhcp` | [X]     |
| `directory`| [X] |
| `inside`| [X]    |
| `gw`   | [X]     |

### Conclusion
- All tests passed: DNS is properly configured and working.
## Resources

- RHEL7 Networking Guide (Chapter 11. DNS Servers)
- [bertvv.bind](https://github.com/bertvv/ansible-role-bind)
- [dig command](https://www.thegeekstuff.com/2012/02/dig-command-examples/)