# Transport Layer

## Checklist: Transport Layer
1. Service running? `sudo systemctl status SERVICE`
2. Correct port/inteface? `sudo ss -tulpn`
3. Firewall settings: `sudo firewall-cmd --list-all`

### 1. Is the service running?
command: `systemctl status httpd.service`
* `active (running)`vs; `inactive (dead)`
    * Start service: `systemctl start httpd`
    * Fail? See Application Layer
* Start at boot: `enabled` vs. `disabled`
    * `systemctl enable httpd`

### 2. Correct ports/interfaces?
* Use `ss`
  * TCP service: `sudo ss -tlnp`
  * UDP service: `sudo ss -ulnp'
* Correct port number?
  * See `/etc/services`
* Correct interface?
  * Only loopback?
```
e.g. For apache 
port 80 & port 443
```

### 3. Firewall settings
command: `sudo firewall-cmd --list-all`
* Is the service or port listed?
* Use `--add-service`if possible
  * Supported: `--get-services`
* Don't use both `--add-service` and `-add-port`
* Add `--permanent`
* `--reload` firewall rules

```
$ sudo firewall-cmd --add-service=http --permanent
$ sudo firewall-cmd --add-service=https --permanent
$ sudo firewall-cmd --reload
```

Next step: troubleshoot [Appication Layer](application-layer.md)