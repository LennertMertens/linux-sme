# Enterprise Linux Lab Report: 03-fileshare

- Student name: Lennert Mertens
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens>

Being able to set up and troubleshout a file server with Samba and an FTP server with vsftpd.

## Test plan
### Acceptance tests vsftpf
```
[vagrant@pr011 vagrant]$ sudo ./test/runbats.sh
 ✓ VSFTPD service should be running
 ✓ VSFTPD service should be enabled at boot
 ✓ The ’curl’ command should be installed
 ✓ The SELinux status should be ‘enforcing’
 ✓ FTP traffic should pass through the firewall
 ✓ VSFTPD configuration should be syntactically correct
 ✓ Anonymous user should not be able to see shares
 ✓ read access for share ‘public’
 ✓ write access for share ‘public’
 ✓ read access for share ‘management’ 
 ✓ write access for share ‘management’ 
 ✓ read access for share ‘technical’ 
 ✓ write access for share ‘technical’ 
 ✓ read access for share ‘sales’ 
 ✓ write access for share ‘sales’ 
 ✓ read access for share ‘it’ 
 ✓ write access for share ‘it’ 

```
### Acceptance tests Samba
```
 ✓ The ’nmblookup’ command should be installed
 ✓ The ’smbclient’ command should be installed
 ✓ The Samba service should be running
 ✓ The Samba service should be enabled at boot
 ✓ The WinBind service should be running
 ✓ The WinBind service should be enabled at boot
 ✓ The SELinux status should be ‘enforcing’
 ✓ Samba traffic should pass through the firewall
 ✓ Check existence of users
 ✓ Checks shell access of users
 ✓ Samba configuration should be syntactically correct
 ✓ NetBIOS name resolution should work
 ✓ read access for share ‘public’
 ✓ write access for share ‘public’
 ✓ read access for share ‘management’
 ✓ write access for share ‘management’
 ✓ read access for share ‘technical’
 ✓ write access for share ‘technical’
 ✓ read access for share ‘sales’
 ✓ write access for share ‘sales’
 ✓ read access for share ‘it’
 ✓ write access for share ‘it’
```

### testparm for checking Samba configuration
- When you issue this command in the vm, you can check if samba is configured correctly

### Acces the shares as the samba users
- You can test all users but for example we'll use the admin user as test:
  - HOST SYSTEM: Go to your file explorer on host system and connect to a server
    - Server address: `smb://172.10.0.11/public`
    - User: `lennertm`, password: `lennertm`
    - Public folder should be visible to the user
  - VIRTUAL MACHINE: Log in as a user for example `nehirb` in the VM. The user sould have acces to `public` nad `technical` put no permission to acces the other shares. Test this case.

### Users without acces to shell shouldn't be able to log in (users except for it members)
- Try to log in as `evyt`, a user which shouldn't have shell acces, into the shell.

## Procedure/Documentation
#### vagrant-hosts.yml
[vagrant-hosts.yml](../vagrant-hosts.yml)

- Add  `pr011` with the correct ip (`172.16.0.11`)

#### site.yml
[Link to file](../ansible/site.yml)

- Add entry for `pr011` with the roles:
  - bertvv.samba
  - bertvv.vsftpd
  

## Prequisites
### Configure the firewall to allow SMB and FTP
- Define these firewall rules in [pr011.yml](../ansible/host_vars/pr011.yml)
```yml
rhbase_firewall_allow_services:
  - samba
  - samba-client
  - ftp
```

### Create the required user groups
- Define these groups in [pr011.yml](../ansible/host_vars/pr011.yml)
```yml
rhbase_user_groups:
  - management
  - technical
  - sales
  - it
  - public
```
### Create the required users on the system
- create all users in `avalon-employees.csv`
- Define users in [pr011.yml](../ansible/host_vars/pr011.yml) using the `bertvv.rhbase` role
- For testing purposes, the users have a password that is identical to their name.

## Configure Samba
### Configure netbios name
```yml
# pr011.yml
samba_netbios_name: 'files'
```
### Disable anonymous guest login
```yml
# pr011.yml
samba_map_to_guest: 'Never'
```

### Add Samba users
- Define the required users in [pr011.yml](../ansible/host_vars/pr011.yml)
- For testing purposes, the users have a password that is identical to their name.

### Add the Samba shares
- All share options are listed in [pr011.yml](../ansible/host_vars/pr011.yml)

#### share public
- Every user has read and write
- Users are allowed to modify files owned by others
#### share management
- Completely inaccessible for employees outside of this business unit
#### share technical
- Visible for employees outside of their business unit but not writable
#### shares it and sales 
- Visible to management but not writable
- Only users in it can get shell acces to the server


## Configre Vsftpd
- Configurations are done in [pr011.yml](../ansible/host_vars/pr011.yml)
### Disable anonymous acces
- `vsftpd_anonymous_enable: false`
### Allow login of registered users
- `vsftpd_local_enable: true`
### Folder for samba shares
- `vsftpd_local_root: /srv/shares`



## Configure ACLs (ACL's in Galaxy role not working)
- ACLs are used to configure acces to files for users and groups
- Management has acces to both it and sales share, for this reason we need ACLs. ACLs make it possible to add multiple permissions for different groups to a folder
```yml
- name: ACL for management read access to the it share
      acl:
        path: /shares/it
        entity: management
        etype: group
        permissions: r-x
        state: present
```

## Test report

### 22/10/2018 16:20
- Running the acceptance tests
- Test 9-17 of vsftp fails
- Failing on permissions, after further investigation and talking to colleagues it seemed like we would need ACLs to define the share acces and allow the acces to more than one group

### 22/10/2018 22:20
- [x] Acceptance tests vsftpd
  - All `/tests/runbats.sh` tests passed
- [x] Acceptance tests Samba
  - All `/tests/runbats.sh` tests passed
- [x] Check configurations with `testparm`
  - Ran `testparm` command, in the output all groups/folders we wanted to add are listed with the correct permissions
- [x] Acces from host system
  - Host system: `Macbook Pro with Mac OSX Mojave 10.14`
  - In Finder (OSX's file explorer), connect to: `smb://172.10.0.11/public` 
  - Use these credentials: username `lennertm`, password `lennertm`
  - Once connected the public share is visible in the file explorer
- [x] Acces from virtual machine
  - Log in to the vagrant box as `nehirb`
  - Check wheter the user has only acces to `public` and `technical`. The groups belonging to this user.
  ```
  [vagrant@pr011 ~]$ su nehirb
  Password: nehirb
  [nehirb@pr011 vagrant]$ ls /srv/shares/
  it  management  public  sales  technical
  [nehirb@pr011 vagrant]$ ls /srv/shares/technical/
  [nehirb@pr011 vagrant]$ ls /srv/shares/sales/
  ls: cannot open directory /srv/shares/sales/: Permission denied
  ```
- [x] Users without permissions to log in to the shell don't get acces
  ```
  [nehirb@pr011 vagrant]$ su evyt
  Password: 
  This account is currently not available.
  ```

## Resources

- [Samba documentation](documentation/samba.md)
- [Install and configure Samba Server in CentOS7](https://www.unixmen.com/install-configure-samba-server-centos-7/)
- [vsftpd documentation](https://github.com/bertvv/ansible-role-vsftpd)
- [ACLs with Andsible](https://docs.ansible.com/ansible/2.6/modules/acl_module.html)
- Communication with colleagues on failing tests
  Idea of generating folders in advance with Ansible Task (Thomas Vandeveire)