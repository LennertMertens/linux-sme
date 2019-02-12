# Documentation DHCP on CentOS7

[DHCP process](/images/dhcp.png)

## Manually installing DHCP on CentOS7
1. Install DHCP package 
```
# yum install dhcp
```

2. Update /ect/sysconfig/dhcp file
   - Set the ethernet interface name as `DHCPARGS=eth1`

3. Configure DHCP Server
   - DHCP creates `/ect/dhcp/dhcp.conf`  and provides a sample configuration file at `/usr/share/doc/dhcp*/dhcpd.conf.sample`
   - Copy the content of the sample configuration file to the main configuration file:
   ```
   # cp /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample /etc/dhcp/dhcpd.conf
   ```

- 3.1. parameter configuration
  - First configure the basic options which is common to all supported networks
  ```
  option domain-name "green.local";
  option domain-name-servers ns1.green.local, ns2.green.local;
  default-lease-time 600;
  max-lease-time 7200;
  authoritative;
  log-facility local7;
  ```
- 3.2. IP Subnet Declaration
  - Edit the DHCP configuration file and update subnet details as per your network. For this example we're configuring DHCP for `192.168.1.0/24` LAN network
  ```
  subnet 192.168.1.0 netmask 255.255.255.0 {
        option routers                  192.168.1.254;
        option subnet-mask              255.255.255.0;
        option domain-search            "green.local";
        option domain-name-servers      192.168.1.1;
        option time-offset              -18000;     # Eastern Standard Time
	range   192.168.1.10   192.168.1.100;
  }
  ```

- 3.3. Assign static IP address to host
  - In some cases, we need to assign a fixed IP to an interface each time it requested from dhcp. We can also assign a fixed IP on basis of MAC address (hardware ethernet) of that interface. Setup host-name is optional to set up.
  ```
  host station1 {
   option host-name "station1.green.local";
   hardware ethernet 00:11:1A:2B:3C:AB;
   fixed-address 192.168.1.100;
  }
  ```

4. Start DHCP service
- `systemctl start dhcp`

5. Setup client system
- Edit the network interface which should obtain an IP address via DHCP: `vim /etc/sysconfig/network-scripts/ifcfg-eth1`
- Set BOOTPROTO to dhcp:
  ```
  DEVICE=eth1
  BOOTPROTO=dhcp
  TYPE=Ethernet
  ONBOOT=yes
  ```
- Restart the netwotk service: `systemctl restart network`

### Sources
- [How to configure DHCP server on CentOS/RHEL7/6/5 ](https://tecadmin.net/configuring-dhcp-server-on-centos-redhat/)