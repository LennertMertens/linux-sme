# Documentation DNS on CentOS7
**Note:** This document is mainly a summarized version of RHEL7 Networking Guide for better understanding DNS.

- DNS or Name server
- Client request usually via port 53
- Authoritative and recursive servers

## BIND
- Berkely Internet Name Domain

### Empty zones
- Prevent recursive servers from sending unnecessary queries to Internet servers that cannot handle them. The configuration option empty-zones-enable controls whether or not empty zones are created, whilst the option disable-empty-zone can be used in addition to disable one or more empty zones from the list of default prefixes that would be used.
  
### Configuring the named Service
- When the named service starts, it reads the configuration from the files as described in The named Service Configuration Files
  
| Path | Description |
| :--- | :---------- |
| `/etc/named.conf` |The main configuration file. |
| `/etc/named`| An auxiliary directory for configuration files that are inclided in the main configuration file. |

Atypical /etc/named.conffileis organized as follows:
```
statement-1 ["statement-1-name"] [statement-1-class] { option-1;
option-2;
option-N;
};
```

## Common Statement Types
Following statements are commonly used in `/etc/named.conf`

### ACL
- The ACL (Acces Control List) statement alloxs you to define groups of hosts, so that they can be permitted or denied acces to the nameserver. It takes the following form:
```
acl acl-name { 
  match-element; 
  ...
};
```
**Note:** The acl-name statement name is the name of the access control list, and the
is usually an individual IP address (such as 10.0.1.1) or a Classless Inter-Domain Routing (CIDR) network notation (for example, 10.0.1.0/24). For a list of already defined keywords.

__Predefined Acces Control Lists__

| Keyword | Description |
| :------ | :---------- |
| `any` | Matches every IP address. '
| `localhost` | Matches any IP address that is in use by the local system. |
| `localnets` | Matches any IP address on any network to which the local system is connected. |
| `none` | Does not match any IP address. |


Example using acl in Conjunction with Options
```bash
# Black-hats on black-list
# Red-hats have normal acces
acl black-hats { 10.0.2.0/24; 192.168.0.0/24; 1234:5678::9abc/24;
       };
       acl red-hats {
         10.0.1.0/24;
       };
options {
blackhole { black-hats; }; allow-query { red-hats; }; allow-query-cache { red-hats; };
};
```

### include
- The include statement allows you to include files int he `/etc/named.conf`, so that potentially sensitive data can be placed in a separate file with restricted permissions. It takes the following form:
```
include "file-name"
```
**Note:** The *file-name* statement name is an absolute path to a file.

### options
- The options statement allows you to define global server configuration options as well as to set defaults for other statements. It can be used to specify the location of the named working directory, the types of queries allowed, and much more. It takes the following form:
```
options { 
  option;
  ... 
};
```
__Commonly used configuration options__


| Option | Description |
| :----- | :---------- |
| `allow-query` | Specifies which hosts are allowed to query the nameserver for authoritative resource records. It accepts an access control list, a collection of IP addresses, or networks in the CIDR notation. All hosts are allowed by default. |
| `directory` | Specifies a working directory for the named service. The default option is /var/named/. |
| `disable-empty-zones` | Used to disable one or more empty zones from the list of default prefixes that would be used. Can be specified in the options statement and also in view statements. It can be used multiple times. |
| `dnssec-enable` | Specifies whether to return DNSSEC related resource records. The default option is yes. |
| `empty-zones-enable` | Controls whether or not empty zones are created. Can be specified only in the options statement. |
| `forwarders` | Controls whether or not empty zones are created. Can be specified only in the options statement. |
| `forward` | Specifies the behavior of the forwarders directive. It accepts the following options: first  The server will query the nameservers listed in the forwarders directive before attempting to resolve the name on its own. only — When unable to query the nameservers listed in the forwarders directive, the server will not attempt to resolve the name on its own. |
| `listen-on` | Specifies the IPv4 network interface on which to listen for queries. On aDNS server that also acts as gateway, you can use this option to answer queries originating from a single network only. All IPv4 interfaces are used by default. |
| `listen-on-v6` | Specifies the IPv6 network interface on which to listen for queries. On a DNS server that also acts as a gateway, you can use this option to answer queries originating from a single network only. All IPv6 interfaces are used by default. |
| `notify` | Specifies whether to notify the secondary nameservers when a zone is updated. It accepts the following options: yes — The server will notify all secondary nameservers. no — The server will not notify any secondary nameserver.master-onl — The server will notify primary server for the zone only.explicit — The server will notify only the secondary servers that are specified in the also-notify list within a zone statement. |
| `recursion` | Specifies whether to act as a recursive server. The default option is yes. |


### zone
- The zone statement allows you to define the characteristics of a zone, such as the location of its configuration file and zone-specific options, and can be used to override the global options statements. It takes the following form:
```
zone zone-name [zone-class] { 
  option;
  ... 
};
```

The zone-name attribute is particularly important, as it is the default value assigned for the $ORIGIN directive used within the corresponding zone file located in the /var/named/directory. The named daemon appends the name of the zone to any non-fully qualified domain name listed in the zone file. For example, if a zone statement defines the namespace for example.com, use example.com as the zone-name so that it is placed at the end of host names within the example.com zone file.

Example a Zone Statement for a Primary nameserver
```
zone "example.com" IN {
  type master;
  file "example.com.zone"; 
  allow-transfer { 192.168.0.2; };
};
```

Example a Zone Statement for a Secondary nameserver (slave)
```
zone "example.com" {
  type slave;
  file "slaves/example.com.zone"; 
  masters { 192.168.0.1; };
};
```

### Other statement types

- See RHEL7 Networking Guide from page 236

## Common Resource Records
- The following recource records are commonly used in zone files:
### A
- The Address record specifies an IP address to be assigned to a name. It takes the following form:
```
hostname IN A ip-address
```
**Note:** if the *hostname* value is omitted, the record will point to the last specified *hostname*

Example: the requests for server1.example.com are pointed to 10.0.1.3 or 10.0.1.5
```
server1  IN  A  10.0.1.3
         IN  A  10.0.1.5
```

### CNAME
- The Canonical Name record maps one name to another. Because of this, this type of record is sometimes referred to as an alias record. It takes the following form:
```
alias-name IN CNAME real-name
```
CNAME records are most commonly used to point to services that use a common naming scheme, such as www for Web servers. However, there are multiple restrictions for their usage:
- CNAME records should not point to other CNAME records. This is mainly to avoid possible infinite loops.
- CNAME records should not contain other resource record types (such as A, NS, MX, and so on). The only exception are DNSSEC related records (RRSIG, NSEC, and so on) when the zone is signed.
- Other resource records that point to the fully qualified domain name (FQDN) of a host (NS, MX, PTR) should not point to a CNAME record.

Example: the A record binds a hostname to an IP address,while the CNAME record points the commonly used www host name to it.
```
server1  IN  A      10.0.1.5
www      IN  CNAME  server1
```
### MX
- The Mail Exchange record specifies where the mail sent to a particular namespace controlled by this zone should go. It takes the following form:
```
IN MX preference-value email-server-name
```
The email-server-name is a fully qualified domain name (FQDN). The preference-value allows numerical ranking of the email servers for a namespace, giving preference to some email systems over others. The MX resource record with the lowest preference-value is preferred over the others. However, multiple email servers can possess the same value to distribute email traffic evenly among them.

Example: the first mail.example.com email server is preferred to the mail2.example.com email server when receiving email destined for the example.com domain.
```
example.com. IN MX 10 mail.example.com. 
             IN MX 20 mail2.example.com.
```
### NS
- The Nameserver record announces authoritative nameservers for a particular zone. It takes the following form:
```
IN NS nameserver-name
```
The nameserver-name should be a fully qualified domain name (FQDN). Note that when two nameservers are listed as authoritative for the domain, it is not important whether these nameservers are secondary nameservers, or if one of them is a primary server. They are both still considered authoritative.

### PTR
- The Pointer record points to another part of the namespace. It takes the following form: 
```
last-IP-digit IN PTR FQDN-of-system
```

The last-IP-digit directive is the last number in an IP address, and the FQDN-of-system is a fully qualified domain name (FQDN).
PTR records are primarily used for reverse name resolution, as they point IP addresses back to a particularname

### SOA
- The Start of Authority record announces important authoritative information about a namespace to the nameserver. Located after the directives, it is the first resource record in a zone file. It takes the following form:
```
@ IN SOA primary-name-server hostmaster-email ( 
  serial-number
  time-to-refresh
  time-to-retry
  time-to-expire minimum-TTL )
```


## Using the dig utility
- RHEL7 Networking Guide from page 243

__Brief overview of dig commands__

| Command | Description |
| :------ | :---------- |
| `dig example.com NS` | Looking up a nameserver |
| `dig example.com A` | Looking up an ip-address |
| `dig -x 192.0.32.10` | Looking up a hostname |


