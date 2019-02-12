# Enterprise Linux Lab Report - Troubleshooting

- Student name: Lennert Mertens
- Class/group: TIN-TI-3B (Gent)

## Instructions

- Write a detailed report in the "Report" section below (in Dutch or English)
- Use correct Markdown! Use fenced code blocks for commands and their output, terminal transcripts, ...
- The different phases in the bottom-up troubleshooting process are described in their own subsections (heading of level 3, i.e. starting with `###`) with the name of the phase as title.
- Every step is described in detail:
    - describe what is being tested
    - give the command, including options and arguments, needed to execute the test, or the absolute path to the configuration file to be verified
    - give the expected output of the command or content of the configuration file (only the relevant parts are sufficient!)
    - if the actual output is different from the one expected, explain the cause and describe how you fixed this by giving the exact commands or necessary changes to configuration files
- In the section "End result", describe the final state of the service:
    - copy/paste a transcript of running the acceptance tests
    - describe the result of accessing the service from the host system
    - describe any error messages that still remain

## Report
### Prerequisites
- Set keyboard-settings to AZERTY: `sudo localectl set-keymap be` & `set-x11-keymap be`

### Phase 1: Network Acces Layer
- [x] Cables are connected and working
- [ ] Check if VirtualBox Network settings are correct (proper Host-Only network)
    - [x] Default name is a non-existing adapter on my computer; Changed to `vboxnet2`
- [ ] `ip link` returns desired output (All interfaces are up)
    - Interface `enp0s8` is in DOWN state
    - Modify the file `vim /etc/sysconfig/network-scripts/ifcfg-enp0s8`. Change `ONBOOT=no` to `ONBOOT=yes`
    - Restart the network: `sudo systemctl restart network`
    - [x] `ip link` show that all interfaces are now up

### Phase 2: Internet Layer
- Checking ip addresses: `ip a`
    - [x] enp0s3 has ip `10.0.2.15` (standard NAT of VB)
    - [x] enp0s8 has ip `192.168.56.42`

- Checking default gateway: `ip r`
    - [x] DG is `10.0.2.2`
  
- Checking DNS server: `cat /etc/resolv.conf`
    - [x] name server is `10.0.2.3`

- Lan Connectivity:
    - [x] Ping Default Gateway 10.0.2.2: `ping -c 4 10.0.2.2`
    - [x] Ping DNS server 10.0.2.3: `ping -c 4 10.0.2.3`
    - [x] `getent ahosts icanhazip.com` works
  
- Test host to vm
    - [x] ping from host to vm works
    - [ ] ssh to vm works
        - Doesn't work at this moment, solving this is done on Transport layer level (fixed here)
        - [x] Check opened firewall ports `sudo firewall-cmd --list-all`  
            - Port 22/tcp is not opened so ssh is disabled!
        - [x] Enable ssh: `sudo firewall-cmd --add-port=22/tcp --permanent` & `sudo firewall-cmd --reload`
        - [x] Check if `port 22/tcp` is opened now
        - [x] Connecting via ssh from host: `ssh vagrant@192.168.56.42`

### Phase 3: Transport Layer

- [ ] Check if `named.service` is running: `sudo systemctl status named.service`
- Output generated
```
[root@golbat ~]# sudo systemctl status named.service 
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2018-12-03 12:36:54 UTC; 26min ago
  Process: 1061 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=1/FAILURE)$
```
- The output tells us that there are still eroors in the `named.conf` file, troubleshooting these will be done on Application level.
 

- Check ports/interfaces:
    - [ ] BIND is listening on port 53/tcp: `ss -tlnp`
    - [ ] BIND is listening on port 53/udp: `ss -ulnp`
        - BIND isn't listening on either of these ports. Checking named.conf if the ports are well configured.
        - [x] open `/etc/named.conf`
        - output: 
        ```
        options {
        // listen-on port 53 { 127.0.0.1; };
        ```
        - the `listen-on port` is commented out, this should be changed to the following, also add the network-address range.
        ```
        options {
        listen-on port 53 { 127.0.0.1; 192.168.56.0/24; };
        ```

- Check firewall settings
    - [ ] ports 53 and 22 tcp are added to the firewall; `sudo firewall-cmd --list-all` to check current firewall rules
    - Output:
    ```
    [root@golbat ~]# sudo firewall-cmd --list-all
    public (active)
    target: default
    icmp-block-inversion: no
    interfaces: enp0s8 enp0s3
    sources: 
    services: dhcpv6-client ssh
    ports: 53/tcp 22/tcp
    protocols: 
    masquerade: no
    forward-ports: 
    source-ports: 
    icmp-blocks: 
    rich rules: 
    ```
    - Still need to add port 53/udp to the firewall in order to be able to query the name server from the host system
    - [x] Add firewall port 53/udp: `sudo firewall-cmd --add-port=53/udp --permanent` & `sudo firewall-cmd --reload`

### Phase 4: Application Layer

- Changes to BIND configuration happen in this layer
- Become root before troubleshooting DNS: `sudo -i`

#### Checking the Main config file
- [x] `named.conf` configuration syntax is correct: `named-checkconf named.conf`

#### Checking zone files
- Change to the `/var/named` directory, all zone files are listed here

- [x] The `cynalco.com` file has a correct syntax

- [ ] The IP-addresses defined in `/var/named/cynalco.com` are equal to the ones in the exercice README.md
    - The butterfree and beedle address are switched
    - [x] change IP of butterfree to `192.168.56.12`
    - [x] change IP of beedle to `192.168.56.13`
    - [x] IP's in readme are equal to the ones in `cynalco.com` now

- Check the `56.168.192.in-addr.arpa` file for errors:
    - $ORIGIN 192.168.56.in-addr.arpa. should be changed to `56.168.192.in-addr.arpa.`
    - Change following:
    ```
    13       IN  PTR  butterfree.cynalco.com.
    12       IN  PTR  beedle.cynalco.com.
    ```
    to:
    ```
    12       IN  PTR  butterfree.cynalco.com.
    13       IN  PTR  beedle.cynalco.com.
    ```

- Check the `2.0.192.in-addr.arpa` file for errors
    - [x] file is correct

- [x] restart the `named.service`; `sudo systemctl restart named.service`
- [ ] Running bats-tests all work
    - Executing the acceptance tests fail
    - There are missing records in the `cynalco.com` file
    Add all of this to the file:
```bash
$ORIGIN cynalco.com.
$TTL 1W

@ IN SOA golbat.cynalco.com. hostmaster.cynalco.com. (
  16121208
  1D
  1H
  1W
  1D )

                     IN  NS     golbat.cynalco.com.
                     # Add this record
                     IN  NS     tamatama.cynalco.com.
@                    IN  MX     10  sawamular.cynalco.com.

fushigisou           IN  A      192.168.56.2
butterfree           IN  A      192.168.56.12
db1                  IN  CNAME  butterfree
beedle               IN  A      192.168.56.13
db2                  IN  CNAME  beedle
pikachu              IN  A      192.168.56.25
inside               IN  CNAME  pikachu
golbat               IN  A      192.168.56.42
ns1                  IN  CNAME  golbat
mankey               IN  A      192.168.56.56
# Add this record
files                IN  CNAME  mankey
tamatama             IN  A      192.0.2.2
ns2                  IN  CNAME  tamatama
karakara             IN  A      192.0.2.4
www                  IN  CNAME  karakara
sawamular            IN  A      192.0.2.6
smtp                 IN  CNAME  sawamular
imap                 IN  CNAME  sawamular
```   
- [x] After adding this the tests are all passing



## End result
### Bats tests
Bats tests output: 
```
[vagrant@golbat ~]$ sudo ./acceptance_test.bats 
 ✓ Forward lookups private servers
 ✓ Forward lookups public servers
 ✓ Reverse lookups private servers
 ✓ Reverse lookups public servers
 ✓ Alias lookups private servers
 ✓ Alias lookups public servers
 ✓ NS record lookup
 ✓ Mail server lookup

8 tests, 0 failures
```

### Testing from host
- Add the nameserver and lookup domain to your network settings
- Test by querying the server, through nslookups
    - [x] Checked and approved by teacher!
```
Lennerts-MacBook-Pro:repo lennert$ nslookup tamatama
Server:		192.168.56.42
Address:	192.168.56.42#53

Name:	tamatama.cynalco.com
Address: 192.0.2.2

Lennerts-MacBook-Pro:repo lennert$ nslookup db1
Server:		192.168.56.42
Address:	192.168.56.42#53

db1.cynalco.com	canonical name = butterfree.cynalco.com.
Name:	butterfree.cynalco.com
Address: 192.168.56.12

Lennerts-MacBook-Pro:repo lennert$ nslookup fushigisou
Server:		192.168.56.42
Address:	192.168.56.42#53

Name:	fushigisou.cynalco.com
Address: 192.168.56.2
```


## Resources

* [Troubleshooting network services in Linux](https://bertvv.github.io/linux-network-troubleshooting/)
* [Demo slides](https://hogenttin.github.io/elnx-syllabus/bind/#/title-slide)
* [Screencast Linux Troubleshooting](https://www.youtube.com/watch?v=ciXpmDwJKOM)
* [linux-network-troubleshooting](https://bertvv.github.io/linux-network-troubleshooting/bind.html)