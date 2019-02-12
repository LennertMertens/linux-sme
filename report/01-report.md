# Enterprise Linux Lab Report: 01-lamp

- Student name: Lennert Mertens
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens>

Installing a LAMP stack on `pu004`

## Test plan

1. On the host system, go to the local working directory of the project repository
2. Destroy previous machine  `vagrant destroy pu004`
3. Execute `vagrant up pu004`
    - The command should run without errors (exit status 0)
4. Log in on the server with `vagrant ssh pu004` and run the acceptance tests. They should succeed
```
[vagrant@pu004 test]$ sudo /vagrant/test/runbats.sh
Running test /vagrant/test/common.bats
 ✓ The necessary packages should be installed
 ✓ The Apache service should be running
 ✓ The Apache service should be started at boot
 ✓ The MariaDB service should be running
 ✓ The MariaDB service should be started at boot
 ✓ The SELinux status should be ‘enforcing’
 ✓ Web traffic should pass through the firewall
 ✓ Mariadb should have a database for Wordpress
 ✓ The MariaDB user should have write
 ✓ The website should be accessible through HTTP
 ✓ The website should be accessible through HTTPS
 ✓ The certificate should not be the default one
 ✓ The Wordpress install page should be visible under http://192.0.2.50/wordpress/
 ✓ MariaDB should not have a test database
 ✓ MariaDB should not have anonymous users

15 tests, 0 failures
```

## Procedure/Documentation

### 1. Adding roles for LAMP to site.yml

- Search for roles meeting the requirements at [Ansible Galaxy](https://galaxy.ansible.com)

```yml
- hosts: pu004
  become: true
  roles: 
    - bertvv.httpd
    - bertvv.mariadb
    - bertvv.wordpress
```

Now install the roles by executing following command in the home directory: `~$ ./scripts/role-deps.sh`
  
#### 1.1. httpd

The first role we'll need is an httpd role which installs the Apache webserver: [bertvv.httpd](https://galaxy.ansible.com/bertvv/httpd)

- Modify `httpd_scripting: 'none'` variable into `httpd_scripting: 'php'` to be able to run a wordpress website.
- Manage certificates for a secure network conection with the server:
    - Create a new certificate. We first need a new directory to store our private key: `sudo mkdir /etc/ssl/private`
    - Generate SSL key and certificate: `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt`
    - Fill in the list of prompts:
    ```
    Country Name (2 letter code) [XX]:BE
    State or Province Name (full name) []:Oost-Vlaanderen
    Locality Name (eg, city) [Default City]:Dendermonde 
    Organization Name (eg, company) [Default Company Ltd]:Avalon
    Organizational Unit Name (eg, section) []:
    Common Name (eg, your name or your server's hostname) []:avalon.lan
    Email Address []:
    ```
    - Copy the `.key` and `.cert` generated files to our host system in `/vagrant/ansible/files` for deployment to the webserver via Ansible.
    - Configure the following: 

```yml
# pu004.yml
httpd_SSLCertificateFile: /etc/pki/tls/certs/apache-selfsigned.crt
httpd_SSLCertificateKeyFile: /etc/pki/tls/private/apache-selfsigned.key
```

#### 1.2. mariadb
The second role we'll need is a mariadb role which installs the databses we need: [bertvv.mariadb](https://galaxy.ansible.com/bertvv/mariadb)

What we need: 
- A database for wordpress
- A mariadb user for wordpress
- Apply the right priviledges
```yml
# bertvv.mariadb variables
mariadb_databases:
 - name: wp_db
mariadb_users:
  - name: wp_user
    password: CorkIgWac
    priv: 'wp_db.*:ALL,GRANT'
mariadb_root_password: fogMeHud8
```
#### 1.3. wordpress
The last role we'll be using is wordpress: [bertvv.wordpress](https://galaxy.ansible.com/bertvv/wordpress)
- Define which databsae is used for wordpress
- Define the database user and password
```yml
# bertvv.wordpress
wordpress_database: wp_db
wordpress_user: wp_user
wordpress_password: CorkIgWac
```

## Test report

####  05/10/2018 Run the acceptance tests after basic install of the roles

- 5 tests are failing so we continue tweaking the first service: `httpd`
- Modifications of `httpd role`: [httpd](#1.1.-httpd)
```
$ sudo /vagrant/tests/runbats.sh

Running test /vagrant/test/pu004/lamp.bats
 ✗ Mariadb should have a database for Wordpress
   (in test file /vagrant/test/pu004/lamp.bats, line 55)
     `mysql -uroot -p${mariadb_root_password} --execute 'show tables' ${wordpress_database}' failed
   ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
 ✗ The MariaDB user should have write
   (in test file /vagrant/test/pu004/lamp.bats, line 59)
     `mysql -u${wordpress_user} -p${wordpress_password} \' failed
   ERROR 1045 (28000): Access denied for user 'wp_user'@'localhost' (using password: YES)
 ✗ The certificate should not be the default one
   (in test file /vagrant/test/pu004/lamp.bats, line 90)
     `[ -z "$(echo ${output} | grep SomeOrganization)" ]' failed
 ✗ The Wordpress install page should be visible under http://192.0.2.50/wordpress/
   (in test file /vagrant/test/pu004/lamp.bats, line 94)
     `[ -n "$(curl --silent --location http://${sut}/wordpress/ | grep '<title>WordPress')" ]' failed
 ✗ MariaDB should not have anonymous users
   (in test file /vagrant/test/pu004/lamp.bats, line 103)
     `result=$(mysql -uroot -p${mariadb_root_password} --execute "select * from user where user='';" mysql)' failed
   ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

#### 07/10/2018 Run the acceptance tests after modifications for httpd role

- Test are all failing because of a fault in the configuration.
- Added `remote_src: yes` to site.yml. remote_src is our host computer
- Provision and run the tests again: everything based on the httpd role is now working properly.

#### 08/10/2018
- All acceptance test passed, webserver is fully functional


## Resources

- RHEL7, System Administrators Guide (Chapter 14. WEB SERVERS)
- [Create a self signed certificate](https://www.sslshopper.com/article-how-to-create-and-install-an-apache-self-signed-certificate.html)
- [How To Create an SSL Certificate on Apache for CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-apache-for-centos-7)