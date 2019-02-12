# Enterprise Linux Checklist

## Environment
| IP address   | Server name    | Server job |
| :----------   | :----------    | :--------- |
| `192.0.2.50`  | `pu004 (www)`  | web server |
| `192.0.2.10`  | `pu001 (ns1)`  | DNS 1      |
| `192.0.2.11`  | `pu002 (ns2)`  | DNS 2      |
| `172.16.0.2`  | `pr001 (dhcp)` | DHCP       |
| `172.16.0.11` | `pr011 (files)`| file server|      |

### 2 Zones
- Public zone:
  - DG: `192.0.2.254`
- Private zone:
  - DG: `172.0.255.254`
  
## Tests

- [ ] Provision all servers
- [ ] Running `runbats.sh` on every server passes

- [ ] Default gateways confgured through the router: `ip r`
- [ ] DNS settings are done right on every server: `cat /etc/resolv.conf`
  
### Client testing

- [ ] Pinging to devices on `ip address` works
- [ ] Pinging to devices on `server name` works
- [ ] Pinging to devices on `server alias` works

- [ ] Website is available through `https://www.avalon.lan`
- [ ] Internet is available on the client

- [ ] DHCP Testing
  - [ ] Adapter 1 receives ip address of: `172.16.128.7`
  - [ ] Adapter 2 has an ip address in the range of `172.16.192.1-172.16.255.253`

- [ ] File server is available from the client:
  - [ ] `ftp://files.avalon.lan/public`
  - [ ] `smb://files.avalon.lan/public`
- [ ] Nehirb (password: `nehirb`) has acces to `it` and `public` and read permissions to `technical`

- [ ] SSH Testing
  - [ ] user `elenaa` cannot login via ssh -> `shell /sbin/nologin`
  - [ ] user `nehirb` can login via ssh

- [ ] A created file on the file server is visible from the client 