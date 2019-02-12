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

- nginx config file: `/etc/nginx/nginx.conf`
- IP-address of VM: `192.168.56.42`
- `https://192.168.56.42/`

### Prerequisites
- Set keyboard-settings to AZERTY: `sudo localectl set-keymap be` & `set-x11-keymap be`

### Phase 1: Network Acces Layer
- [ ] Cables are connected and working
    - Cable not connected in VirtualBox, connect cable through settings via VirtualBox GUI
    - [x] Cables are connected and working now
- [x] `ip link` returns desired output (All interfaces are up)

### Phase 2: Internet Layer
- Checking ip addresses: `ip a`
    - [x] enp0s3 has ip `10.0.2.15` (standard NAT of VB)
    - [ ] enp0s8 has ip `192.168.56.42`
        - No ipv4 address available
        - Check config: `cat /etc/sysconfig/network-scripts/ifcfg-enp0s8`
            - Fault in configuration: changed IPADRR to IPADDR
            - Afterwards: `sudo service network restart`
            - [x] enp0s8 has ip `192.168.56.42` now


- Checking default gateway: `ip r`
    - [x] DG is `10.0.2.2`
- Checking DNS server: `cat /etc/resolv.conf`
    - [x] nameserver is `10.0.2.3`

- Lan Connectivity:
    - [x] Ping Default Gateway 10.0.2.2: `ping -c 4 10.0.2.2`
    - [x] Ping DNS server 10.0.2.3: `ping -c 4 10.0.2.3`
    - [x] `getent ahosts icanhazip.com` works


### Phase 3: Transport Layer

- Check if nginx is running: `sudo systemctl status nginx`
    - [] nginx is enabled and running
        - nginx is inactive (dead)
        - start nginx: `sudo systemctl start nginx`
        - Returns the following error: 
    ``` 
    Job for nginx.service failed because the control process exited with error code. see "systemctl status nginx.service" and "journalctl -xe" for details.
    ```
    - Changes made now in the `nginx.conf` file happens on Application layer
    - Restart nginx: `sudo systemctl restart nginx`
    - Enable nginx: `sudo systemctl enable nginx`
    - [x] nginx is enabled and running


- Check ports/interfaces
    - [x] nginx is listening on port 80 & 443: `sudo ss -tlnp`
    - Modify the `nginx.conf` file  to allow listening on port 443
    ```
    server {
        listen 443 ssl;
        listen[::]:443 ssl;
  ```

- Check firewall settings
    - Run `sudo firewall-cmd --list-all` to check current firewall rules:
    - Output:
```
[vagrant@nginx ~]$ sudo firewall-cmd --list-all
$public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s8 enp0s3
  sources: 
  services: dhcpv6-client http ssh
  ports:
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
- Observations: http is running but https not yet, this needs to be added to the firewall in order to be able to browse via https://
- Add following firewall-rules: `$ sudo firewall-cmd --add-service=https --permanent`
- Reload the firewall: `$ sudo firewall-cmd --reload`
- [x] http and https added to firewall



### Phase 4: Application Layer
- Modifying `nginx.conf` file is done on application layer
  - According to the logs there must be something wrong in the nginx config file (syntax error). Edit the file with `sudo vi /etc/nginx/nginx.conf` 
  - Error with the syntax of the certificate:
    - Things changed in the file: 
    ```
    server {
        ...
        ssl_certificate /etc/pki/tls/certs/nginx.pem;
    ```


## End result

- [x] Browsing to http://192.168.56.42 works
- [x] Browsing to https://192.168.56.42 works
- Both pages display: `Keep calm and vagrant up`

```
[vagrant@nginx ~]$ sudo ./runbats.sh 
Running test /home/vagrant/01-whitebox.bats
 ✓ The SELinux status should be ‘enforcing’
 ✓ The firewall should be running
 ✓ Apache should not be installed
 ✓ Apache should not be running

4 tests, 0 failures
Running test /home/vagrant/02-blackbox.bats
 ✓ The web server host should be reachable
 ✓ The website should be accessible through HTTP
 ✓ The website should be accessible through HTTPS

3 tests, 0 failures
```

## Resources

* [Troubleshooting network services in Linux](https://bertvv.github.io/linux-network-troubleshooting/)
* [Demo slides](https://hogenttin.github.io/elnx-syllabus/troubleshooting/#/title-slide)
* [Screencast Linux Troubleshooting](https://www.youtube.com/watch?v=ciXpmDwJKOM)

