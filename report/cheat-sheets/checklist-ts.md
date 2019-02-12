# Checklist troubleshooting

## Checklist physical and network access layer
1. Staat het aan?
2. Is de netwerkkabel ingeplugd? Voor VB kijk je bij het Netwerk van je box bij advanced of de kabel geconnecteerd is.
3. Zijn de Ethernet poort LED's aan?
4. Gebruik het commando `ip link` om te zien of de adapters 'Up' of 'No carrier' zijn.

#### Commands
| Functie | Command |
| :------ | :------ |
| Zie of alle adapters 'Up' zijn.  | `ip link`  |
| Ping die maar 4 keer stuurt |`ping -c 4 10.0.2.2`|

## Checklist internet layer
### IP-address
1. Kijk in de ifcfg-IFACE of IP-adres via DHCP of manueel is ingesteld. Bij DHCP kijk je of Device de juiste naam heeft, of ONBOOT op 'yes' staat en dat BOOTPROTO op 'DHCP' staat. Als het manueel ingesteld is, dan moeten IP-adres en Netmask ingevuld zijn. 
2. Kijken of je de juiste ip-adressen hebt gekregen. Op VB is heeft een NAT-adapter een ip-adres 10.0.2.15/24 en een host-only adapter 192.168.56.0/24. DHCP begint uit te delen op 192.168.56.101.

### Default gateway
Elke host op de LAN moet zijn router kennen. 
1. No default set => probleem met IP adres. als dhcp is => verkeerd geconfigureerd.

### DNS Server
Om ip-adressen om te zetten naar hostnames of omgekeerd, is er DNS Server nodig! Je kan dit checken door naar de resolv.conf te kijken. 
Door dit alleen kan je niet zien of je DNS Server ech beschikbaar is. Je zal 'dig' en nslookup' moeten gebruiken.


#### Commands
| Functie | Command |
| :------ | :------ |
| Bekijk de ifconfig voor een specifieke adapter  | `cat /etc/sysconfig/network-scripts/ifcfg-eth0`  |
| IP-address OK?                    | `ip a` |
| Laat de routeringstabel zien     | `ip r` | 
| DNS Server beschikbaar?           |`cat /etc/resolv.conf`|
| Zien of DNS Server echt werkt     | `dig www.google.com +short`|
| Zien of DNS Server echt werkt     | `nslookup www.google.com`|
| Als 'dig' en nslookup' niet aanwezig is|`getent ahost www.google.com`|
| Als je geen IP-adres ziet in ip a bij een adapter|`sudo dhclient`|
| Herstart het netwerk|`service network restart`|

## Checklist transport layer
In dit stukje gaan we bekijken of de service zelf aan het runnen is en welke poort het gebruikt. Hier voor httpd, maar kan voor alle services.
1. Is de service aan het lopen?
2. Welke poort gebruikt de service?
3. Laat de firewall het verkeer toe op de services?

#### Commands
| Functie | Command |
| :------ | :------ |
| Staat de service aan?  |`sudo systemctl status httpd.service`|
| Staat de service aan?  |`sudo systemctl status nginx.service`|
| Start de service|`sudo systemctl start httpd.service`|
| Start de service|`sudo systemctl start nginx.service`|
| Zorg ervoor dat de service van boot opstart|`sudo systemctl enable httpd.service`|
| Laat de poorten zien die in process zijn|`sudo ss -tlnp`|
| Wijzigen httpd.conf voor Listen poort|`sudo vi /etc/httpd/conf/httpd.conf`|
| Bekijk de poortnummers voor gekende services|`cat /etc/services`|
| Bekijk alle services die toegelaten worden door firewall|`sudo firewall-cmd --list-all`|
| Voeg een service toe die de firewall toelaat|`sudo firewall-cmd --permanent --add-service=httpd`|
| Herlaad de firewall|`sudo firewall-cmd --reload`|
| Voeg een interface toe die de firewall toelaat|`sudo firewall-cmd --add-interface=eth1 --permanent`|
| Voeg de benodigde poorten toe die firewall toelaat|
`sudo firewall-cmd --add-port=80/tcp` `sudo firewall-cmd --add-port=80/tcp --permanent` `sudo firewall-cmd --add-port=443/tcp` `sudo firewall-cmd --add-port=443/tcp --permanent`|



## Checklist application layer

1. Check de log files.
2. Kijk of de configuratie van de applicatie correct is.
3. Is de service beschikbaar voor clients?


#### Commands
| Functie | Command |
| :------ | :------ |
| Relevante logs en kijkend naar wijzigingen | `sudo journalctl -f -u httpd.service`|
| Kijk naar de error log van httpd | `sudo tail -f /var/log/httpd/error_log`|
| Bekijk de configuration file van httpd | `cat /etc/httpd/httpd.conf`|
| Valideren van syntax | `apachectl configtest`|
| Na changes altijd | `sudo systemctl restart httpd.service`|
| Poortscan op 80 en 443 | `sudo nmap -sS -p 80,443 HOST`|

## Checklist SELinux

#### Commands
| Functie | Command |
| :------ | :------ |
|Kijken naar booleans | `getsebool -a| grep httpd`|
|Wijzigen boolean httpd | `sudo setsebool httpd_can_network_connect_db on`|
|Toelaten van httpd traffic | `sudo setsebool httpd_can_network_connect on`|
|Bekijk de context van de test.php | `ls -Z /var/www/html/test.php`|
|Verander de context zodat httpd de file kan accessen | `sudo chcon -t httpd_sys_content_t /var/www/html/test.php`|


