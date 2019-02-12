# Oplossing troubleshoot voorbeeld DNS

- Port 53/UDP

# Master (ns1)
## Stap 1: Ip settings bekijken
- `ip a`

## Stap 2: Poort testen
- `sudo yum install telnet`
- `telnet 192.168.56.10 53` gebruikt tcp (niet perfecte manier)
- Kijken naar UDP: `ss -ulnp`
- Kijken naar `/etc/services`
  
## Stap 3: Service testen
- status bekijken: `systemctl status named.service`
- service starten: `sudo systemctl start named.service`
- Nogmaals status bekijken
- Logs of fouten bekijken

## Stap 4: Bestanden bekijken
- `/var/named/` bekijken
- `cd /var/named`
- File checken: `named check-zone example.com example.com`
- Opletten met FQDN, zeker checken of er geen `.` achter moet
- In dit geval moeten we een `.` toevoegen achter de domeinen
- `named checkconf /etc/named.conf`
- Nogmaals telnet uitvoeren
- Ports checken `ss -tlnp`

## Stap 4: Listening address cheken
- `vim etc/named.conf`
- Listening address (local) vervangen naar het juiste
- `listen-on port 53 { 127.0.0.1; 192.168.56.0/24; }`

## Stap 5: tetsen adhv een query
- `nslookup 192.168.56.10`
- allow query aanpassen in /etc/named.conf
- `vim /etc/named.conf`
- allow-query { 127.0.0.0/8; 192.168.56.0/24; };
- Service herstarten `systemctl restart named.service`
- *Name server moet ook aangepast worden in /etc/resolv.conf (192.168.56.10)*

## Stap 6: Status opnieuw bekijken
- `systemctl status named.service`
- in `example.com` (/var/named/example.com) aanpassingen doen. verkeerde ip's web en db: 172/173 -> 72/73
 
# Slave (ns2)
## Stap 1: Kijk of server als slave functioneert
- `allow-transfer`
master: /etc/named.conf: `allow-transfer { 127.0.0.0/8; 192.168.56.11; };`
slave: nslookup 192.168.56.10 (server can't find 10.56.168.192.in-addr)
slave: `sudo systemctl restart network`
